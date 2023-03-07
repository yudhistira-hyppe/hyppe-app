import 'package:hyppe/core/bloc/report/state.dart';
import 'package:hyppe/core/bloc/repos/repos.dart';
import 'package:hyppe/core/config/url_constants.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/status_code.dart';
import 'package:hyppe/core/models/collection/report/report.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';

class ReportBloc {
  ReportFetch _reportFetch = ReportFetch(ReportState.init);
  ReportFetch get reportFetch => _reportFetch;
  setReportFetch(ReportFetch val) => _reportFetch = val;

  Future getReportOptionsBloc(BuildContext context) async {
    setReportFetch(ReportFetch(ReportState.loading));
    await Repos().reposPost(
      context,
      (onResult) {
        if (onResult.statusCode! > HTTP_CODE) {
          print('error1');

          setReportFetch(ReportFetch(ReportState.getReportOptionsError));
        } else {
          Report _result = Report.fromJson(onResult.data);
          setReportFetch(ReportFetch(ReportState.getReportOptionsSuccess, data: _result));
        }
      },
      (errorData) {
        ShowBottomSheet.onInternalServerError(context);
        setReportFetch(ReportFetch(ReportState.getReportOptionsError));
      },
      data: {"type": "content"},
      host: UrlConstants.getOptionReport,
      withAlertMessage: false,
      methodType: MethodType.post,
      withCheckConnection: false,
    );
  }

  Future reports(BuildContext context, {required Map data}) async {
    setReportFetch(ReportFetch(ReportState.loading));
    await Repos().reposPost(
      context,
      (onResult) {
        if (onResult.statusCode! > HTTP_CODE) {
          setReportFetch(
            ReportFetch(ReportState.reportsError, message: onResult.data['message']),
          );
        } else {
          setReportFetch(ReportFetch(ReportState.reportsSuccess));
        }
      },
      (errorData) {
        ShowBottomSheet.onInternalServerError(context);
        setReportFetch(ReportFetch(ReportState.reportsError));
      },
      host: UrlConstants.insertReport,
      data: data,
      withAlertMessage: false,
      methodType: MethodType.post,
      withCheckConnection: false,
    );
  }

  Future appealPost(BuildContext context, {required Map data}) async {
    setReportFetch(ReportFetch(ReportState.loading));
    await Repos().reposPost(
      context,
      (onResult) {
        if (onResult.statusCode! > HTTP_CODE) {
          setReportFetch(ReportFetch(ReportState.appealError, message: onResult.data['message']));
        } else {
          setReportFetch(ReportFetch(ReportState.appealSuccess));
        }
      },
      (errorData) {
        ShowBottomSheet.onInternalServerError(context);
        setReportFetch(ReportFetch(ReportState.appealError));
      },
      host: UrlConstants.appealPost,
      data: data,
      withAlertMessage: false,
      methodType: MethodType.post,
      withCheckConnection: false,
    );
  }

  Future reportReasonAppeal(BuildContext context, {required Map data}) async {
    setReportFetch(ReportFetch(ReportState.loading));
    await Repos().reposPost(
      context,
      (onResult) {
        if (onResult.statusCode! > HTTP_CODE) {
          setReportFetch(ReportFetch(ReportState.appealError, message: onResult.data['message']));
        } else {
          setReportFetch(ReportFetch(ReportState.appealSuccess, data: onResult.data));
        }
      },
      (errorData) {
        ShowBottomSheet.onInternalServerError(context);
        setReportFetch(ReportFetch(ReportState.appealError));
      },
      host: UrlConstants.detailTypeAppeal,
      data: data,
      withAlertMessage: false,
      methodType: MethodType.post,
      withCheckConnection: false,
    );
  }
}
