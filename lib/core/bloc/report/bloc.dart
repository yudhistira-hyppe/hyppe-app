import 'package:hyppe/core/bloc/report/state.dart';
import 'package:hyppe/core/bloc/repos/repos.dart';
import 'package:hyppe/core/config/url_constants.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/status_code.dart';
import 'package:hyppe/core/models/collection/report/report.dart';
import 'package:hyppe/core/models/collection/report/report_data.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';

class ReportBloc {
  ReportFetch _reportFetch = ReportFetch(ReportState.init);
  ReportFetch get reportFetch => _reportFetch;
  setReportFetch(ReportFetch val) => _reportFetch = val;

  _translateReportAction(ReportAction? reportAction) {
    // ignore: missing_enum_constant_in_switch
    switch (reportAction) {
      case ReportAction.report:
        return 'report';

      case ReportAction.hide:
        return 'hide';

      case ReportAction.block:
        return 'block';
    }
  }

  _translateReportType(ReportType? reportType) {
    // ignore: missing_enum_constant_in_switch
    switch (reportType) {
      case ReportType.profile:
        return 'profile';

      case ReportType.comment:
        return 'comment';

      case ReportType.story:
        return 'story';

      case ReportType.post:
        return 'post';
    }
  }

  _translateReportApi(ReportType reportType) {
    switch (reportType) {
      case ReportType.profile:
        return UrlConstants.addProfileReport;

      case ReportType.comment:
        return UrlConstants.reportOnComment;

      case ReportType.story:
        return UrlConstants.reportOnStory;

      case ReportType.post:
        return UrlConstants.reportOnPost;
    }
  }

  Future getReportOptionsBloc(BuildContext context, {required String langID, required ReportType? reportType, required ReportAction? action}) async {
    setReportFetch(ReportFetch(ReportState.loading));
    await Repos().reposPost(
      context,
      (onResult) {
        if ((onResult.statusCode ?? 300) != HTTP_OK) {
          setReportFetch(ReportFetch(ReportState.getReportOptionsError));
        } else {
          Report _result = Report.fromJson(onResult.data);
          setReportFetch(ReportFetch(ReportState.getReportOptionsSuccess, data: _result));
        }
      },
      (errorData) {
        ShowBottomSheet.onInternalServerError(context, tryAgainButton: () => Routing().moveBack());
        setReportFetch(ReportFetch(ReportState.getReportOptionsError));
      },
      host: UrlConstants.getReportOptions + "?langID=$langID&reportType=${_translateReportType(reportType)}&action=${_translateReportAction(action)}",
      withAlertMessage: false,
      methodType: MethodType.get,
      withCheckConnection: false,
    );
  }

  Future reports(BuildContext context, {required ReportData data, required ReportType reportType}) async {
    setReportFetch(ReportFetch(ReportState.loading));
    await Repos().reposPost(
      context,
      (onResult) {
        if ((onResult.statusCode ?? 300) != HTTP_OK) {
          setReportFetch(ReportFetch(ReportState.reportsError));
        } else {
          setReportFetch(ReportFetch(ReportState.reportsSuccess));
        }
      },
      (errorData) {
        ShowBottomSheet.onInternalServerError(context, tryAgainButton: () => Routing().moveBack());
        setReportFetch(ReportFetch(ReportState.reportsError));
      },
      host: _translateReportApi(reportType),
      data: data.toMap(),
      withAlertMessage: true,
      methodType: MethodType.post,
      withCheckConnection: false,
    );
  }
}
