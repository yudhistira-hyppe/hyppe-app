import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/bloc/repos/repos.dart';
import 'package:hyppe/core/config/url_constants.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/status_code.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/boost_response_new.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';

import 'state.dart';

class BoostPostContentDataBloc {
  BoostPostContentDataFetch _dataFetch = BoostPostContentDataFetch(BoostPostContentState.init);
  BoostPostContentDataFetch get dataFetch => _dataFetch;
  setBoostPostContentFetch(BoostPostContentDataFetch val) => _dataFetch = val;

  Future createBoostPostContent(BuildContext context,{Map? data}) async {
    setBoostPostContentFetch(BoostPostContentDataFetch(BoostPostContentState.loading));
    try {
      
      String email = SharedPreference().readStorage(SpKeys.email);
      await Repos().reposPost(
        context,
        (onResult) {
          if ((onResult.statusCode ?? 300) > HTTP_CODE) {
            setBoostPostContentFetch(
                BoostPostContentDataFetch(BoostPostContentState.getBlocError, data: onResult.data));
          } else {
            setBoostPostContentFetch(
              BoostPostContentDataFetch(BoostPostContentState.getBlocSuccess,
                  data: onResult.data['data_response'] != null
                          ? BoostpostResponseModel.fromJson(onResult.data['data_response'])
                          : null),
            );
          }
        },
        (errorData) {
          ShowBottomSheet.onInternalServerError(context, statusCode: errorData.response?.statusCode);
          setBoostPostContentFetch(
              BoostPostContentDataFetch(BoostPostContentState.getBlocError));
          Dio().close(force: true);
        },
        headers: {
          'x-auth-user': email,
        },
        data: data,
        host: UrlConstants.createboostContent,
        methodType: MethodType.post,
        withAlertMessage: false,
        withCheckConnection: true,
      );
    } on SocketException catch (_) {
      setBoostPostContentFetch(
          BoostPostContentDataFetch(BoostPostContentState.getBlocError));
      Dio().close(force: true);
    } catch (_) {
      setBoostPostContentFetch(
          BoostPostContentDataFetch(BoostPostContentState.getBlocError));
      Dio().close(force: true);
    }
  }
}
