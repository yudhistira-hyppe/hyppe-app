import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:hyppe/core/bloc/support_ticket/state.dart';
import 'package:hyppe/core/config/url_constants.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/core/bloc/repos/repos.dart';
import 'package:hyppe/core/constants/status_code.dart';
import 'package:hyppe/core/response/generic_response.dart';

class SupportTicketBloc {
  final _repos = Repos();

  SupportTicketFetch _supportTicketFetch = SupportTicketFetch(SupportTicketState.init);
  SupportTicketFetch get supportTicketFetch => _supportTicketFetch;
  setSupportTicket(SupportTicketFetch val) => _supportTicketFetch = val;

  Future getCategory(BuildContext context) async {
    var type = FeatureType.other;
    setSupportTicket(SupportTicketFetch(SupportTicketState.loading));
    await _repos.reposPost(
      context,
      (onResult) {
        print(onResult.statusCode);
        if ((onResult.statusCode ?? 300) > HTTP_CODE) {
          setSupportTicket(SupportTicketFetch(SupportTicketState.getCategoryIssueError, message: onResult.data['message'], data: onResult.data));
        } else {
          setSupportTicket(SupportTicketFetch(SupportTicketState.getCategoryIssueSuccess, message: onResult.data['message'], data: GenericResponse.fromJson(onResult.data).responseData));
        }
      },
      (errorData) {
        setSupportTicket(SupportTicketFetch(SupportTicketState.getCategoryIssueError, data: errorData.error));
      },
      withAlertMessage: false,
      withCheckConnection: false,
      host: UrlConstants.categoryTickets,
      methodType: MethodType.get,
      errorServiceType: System().getErrorTypeV2(type),
    );
  }

  Future getLevel(BuildContext context) async {
    var type = FeatureType.other;
    setSupportTicket(SupportTicketFetch(SupportTicketState.loading));
    await _repos.reposPost(
      context,
      (onResult) {
        print(onResult.statusCode);
        if ((onResult.statusCode ?? 300) > HTTP_CODE) {
          setSupportTicket(SupportTicketFetch(SupportTicketState.getLevelError, message: onResult.data['message'], data: onResult.data));
        } else {
          setSupportTicket(SupportTicketFetch(SupportTicketState.getLevelSuccess, message: onResult.data['message'], data: GenericResponse.fromJson(onResult.data).responseData));
        }
      },
      (errorData) {
        setSupportTicket(SupportTicketFetch(SupportTicketState.getLevelError, data: errorData.error));
      },
      withAlertMessage: false,
      withCheckConnection: false,
      host: UrlConstants.levelTickets,
      methodType: MethodType.get,
      errorServiceType: System().getErrorTypeV2(type),
    );
  }

  Future postTicketBloc(
    BuildContext context, {
    // ProgressCallback? onSendProgress,
    // ProgressCallback? onReceiveProgress,
    required List<File>? docFiles,
    Map<String, dynamic>? data,
  }) async {
    FormData formData = FormData.fromMap(data!);

    if (docFiles != null) {
      for (File docFile in docFiles) {
        formData.files.add(
          MapEntry(
              "supportFile",
              await MultipartFile.fromFile(docFile.path,
                  filename: System().basenameFiles(docFile.path),
                  contentType: MediaType(
                    System().lookupContentMimeType(docFile.path)?.split('/')[0] ?? '',
                    System().extensionFiles(docFile.path)?.replaceAll(".", "") ?? "",
                  ))),
        );
      }
    }

    setSupportTicket(SupportTicketFetch(SupportTicketState.loading));
    await _repos.reposPost(
      context,
      (onResult) {
        if ((onResult.statusCode ?? 300) > HTTP_CODE) {
          setSupportTicket(SupportTicketFetch(SupportTicketState.postTicketError));
        } else {
          setSupportTicket(SupportTicketFetch(SupportTicketState.postTicketSuccess, data: onResult));
        }
      },
      (errorData) {
        setSupportTicket(SupportTicketFetch(SupportTicketState.postTicketError));
      },
      data: formData,
      headers: {
        'x-auth-user': SharedPreference().readStorage(SpKeys.email),
        'x-auth-token': SharedPreference().readStorage(SpKeys.userToken),
      },
      withAlertMessage: true,
      withCheckConnection: true,
      host: UrlConstants.createTicket,
      // onSendProgress: onSendProgress,
      // onReceiveProgress: onReceiveProgress,
      methodType: MethodType.postUploadContent,
      errorServiceType: System().getErrorTypeV2(FeatureType.other),
    );
  }

  Future getListFaq(BuildContext context) async {
    setSupportTicket(SupportTicketFetch(SupportTicketState.loading));
    await _repos.reposPost(
      context,
      (onResult) {
        if ((onResult.statusCode ?? 300) > HTTP_CODE) {
          setSupportTicket(SupportTicketFetch(SupportTicketState.faqError));
        } else {
          setSupportTicket(SupportTicketFetch(SupportTicketState.faqSuccess, data: GenericResponse.fromJson(onResult.data).responseData));
        }
      },
      (errorData) {
        setSupportTicket(SupportTicketFetch(SupportTicketState.faqError));
      },
      data: {"tipe": "faq"},
      headers: {
        'x-auth-user': SharedPreference().readStorage(SpKeys.email),
        'x-auth-token': SharedPreference().readStorage(SpKeys.userToken),
      },
      withAlertMessage: false,
      withCheckConnection: false,
      host: UrlConstants.faqList,
      methodType: MethodType.post,
      errorServiceType: System().getErrorTypeV2(FeatureType.other),
    );
  }
}
