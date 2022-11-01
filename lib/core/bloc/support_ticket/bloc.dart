import 'package:flutter/material.dart';
import 'package:hyppe/core/bloc/support_ticket/state.dart';
import 'package:hyppe/core/config/url_constants.dart';
import 'package:hyppe/core/constants/enum.dart';
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
        if (onResult.statusCode! > HTTP_CODE) {
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
        if (onResult.statusCode! > HTTP_CODE) {
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
}
