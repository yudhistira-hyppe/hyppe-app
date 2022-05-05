import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';

import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/status_code.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';

import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/core/services/api_action.dart';
import 'package:hyppe/core/services/error_service.dart';
import 'package:hyppe/core/services/shared_preference.dart';

import 'package:hyppe/core/extension/log_extension.dart';

import 'package:hyppe/core/models/collection/error/error_model.dart';

import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_coloured_sheet.dart';

class Repos {
  Repos._private();

  static final Repos _instance = Repos._private();

  factory Repos() {
    return _instance;
  }

  static final _routing = Routing();
  static final _apiAction = ApiAction();

  static Future<Response> _communicate(
    MethodType methodType, {
    required String host,
    required dynamic data,
    required String? token,
    required String? savePath,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    required Map<String, dynamic>? headers,
  }) {
    switch (methodType) {
      case MethodType.get:
        return _apiAction.get(
          host,
          token: token,
          headers: headers,
          onReceiveProgress: onReceiveProgress,
        );
      case MethodType.post:
        return _apiAction.post(
          host,
          data: data,
          token: token,
          headers: headers,
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress,
        );
      case MethodType.download:
        return _apiAction.download(
          host,
          savePath!,
          headers: headers,
          onReceiveProgress: onReceiveProgress,
        );
      case MethodType.postUploadProfile:
        return _apiAction.postUploadProfile(
          host,
          data: data,
          token: token,
          headers: headers,
          cancelToken: cancelToken,
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress,
        );
      case MethodType.postUploadContent:
        return _apiAction.postUploadContent(
          host,
          data: data,
          token: token,
          headers: headers,
          cancelToken: cancelToken,
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress,
        );
      case MethodType.delete:
        return _apiAction.delete(
          host,
          data: data,
          token: token,
          headers: headers,
        );
    }
  }

  Future reposPost(
    @Deprecated('This implementation is deprecated. Will be remove in future update.')
        BuildContext context,
    Function(Response onResult) logic,
    Function(DioError errorData) onDioError, {
    dynamic data,
    String? savePath,
    bool verbose = false,
    required String host,
    Function? onNoInternet,
    CancelToken? cancelToken,
    ErrorType? errorServiceType,
    Map<String, dynamic>? headers,
    required bool withAlertMessage,
    required MethodType methodType,
    required bool withCheckConnection,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _language =
        Provider.of<TranslateNotifierV2>(context, listen: false).translate;
    bool? connection;
    String? token = SharedPreference().readStorage(SpKeys.userToken);
    'User Token = $token'.logger();
    'Send data $data'.logger();
    if (withCheckConnection) connection = await System().checkConnections();

    try {
      /// check if property withCheckConnection null, true or false
      if (connection != null && !connection) {
        /// connect with ErrorService if property [errorService] not null
        if (errorServiceType != null) {
          context.read<ErrorService>().addErrorObject(
              errorServiceType, _language.noInternetConnection!);
        }
        return ShowBottomSheet.onNoInternetConnection(context,
            tryAgainButton: onNoInternet);
      }

      /// communicate with backend
      final _response = await _communicate(
        methodType,
        host: host,
        data: data,
        token: token,
        headers: headers,
        savePath: savePath,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      /// log statusCode from backend
      if (verbose) 'Actual response data ${_response.data}'.logger();
      'StatusCode from dio ${_response.statusCode}'.logger();
      if (methodType != MethodType.download &&
          _response.data != null &&
          _response.data.isNotEmpty) {
        'StatusCode from backend ${_response.data?['statusCode'] ?? _response.data?['status']}'
            .logger();
      }

      /// check if token is valid or not, if not, force logOut
      if (_response.statusCode == HTTP_UNAUTHORIZED ||
          _response.statusCode == HTTP_FORBIDDEN) {
        await SharedPreference().logOutStorage();
        _routing.moveAndRemoveUntil(Routes.login, Routes.root);
        return;
      }

      /// execute given logic
      logic(_response);

      /// show message if any error
      if (_response.statusCode! > HTTP_CODE) {
        'Error communicate with host $host'.logger();

        /// serialize error data from backend
        final _errorData = ErrorModel.fromJson(_response.data);

        /// connect with ErrorService if property [errorService] not null
        if (errorServiceType != null) {
          context.read<ErrorService>().addErrorObject(errorServiceType,
              _errorData.message ?? _language.somethingWentWrong!);

          if (withAlertMessage) {
            _showSnackBar(kHyppeDanger, _errorData.message!,"");
          }
        } else {
          if (withAlertMessage) {
            _showSnackBar(kHyppeDanger, _language.unfortunately!,
                "${_language.somethingWentWrong}, ${_language.pleaseTryAgain}");
          }
        }
      } else {
        final _statusCodeFromBackend = methodType != MethodType.download &&
                _response.data != null &&
                _response.data.isNotEmpty
            ? _response.data['statusCode'] ?? _response.data['status']
            : null;
        if (_statusCodeFromBackend != null &&
            _statusCodeFromBackend > HTTP_CODE) {
          'Error communicate with host $host'.logger();

          /// serialize error data from backend
          final _errorData = ErrorModel.fromJson(_response.data);

          /// connect with ErrorService if property [errorService] not null
          if (errorServiceType != null) {
            context.read<ErrorService>().addErrorObject(errorServiceType,
                _errorData.message ?? _language.somethingWentWrong!);
          }

          if (withAlertMessage) {
            _showSnackBar(kHyppeDanger, _language.unfortunately!,
                "${_language.somethingWentWrong}, ${_language.pleaseTryAgain}");
          }
        } else {
          'Success with message in host $host with status code ${_response.statusCode}'
              .logger();
        }
      }
    } on DioError catch (e) {
      /// connect with ErrorService if property [errorService] not null
      if (errorServiceType != null) {
        context
            .read<ErrorService>()
            .addErrorObject(errorServiceType, e.message);
      }
      if (withAlertMessage) {
        _showSnackBar(kHyppeDanger, _language.unfortunately!,
            "${_language.somethingWentWrong}, ${_language.pleaseTryAgain}");
      }
      'Error detail ${e.toString()} with status code ${e.response?.statusCode}, message ${e.message} and host $host'
          .logger();
      onDioError(e);
    } catch (e) {
      e.toString().logger();
      try {
        /// connect with ErrorService if property [errorService] not null
        if (errorServiceType != null) {
          context
              .read<ErrorService>()
              .addErrorObject(errorServiceType, e.toString());
        }
      } catch (eIn) {
        eIn.toString().logger();
      }
      if (withAlertMessage) {
        _showSnackBar(kHyppeDanger, _language.unfortunately!,
            "${_language.somethingWentWrong}, ${_language.pleaseTryAgain}");
      } else {
        'Error detail with no alertMessage ${e.toString()}'.logger();
      }
    }
  }

  void _showSnackBar(Color color, String message, String desc) {
    _routing.showSnackBar(
      snackBar: SnackBar(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        behavior: SnackBarBehavior.floating,
        content: SafeArea(
          child: SizedBox(
            height: 56,
            child: OnColouredSheet(
              maxLines: 2,
              caption: message,
              subCaption: desc,
              fromSnackBar: true,
              iconSvg: "${AssetPath.vectorPath}remove.svg",
            ),
          ),
        ),
        backgroundColor: color,
      ),
    );
  }
}
