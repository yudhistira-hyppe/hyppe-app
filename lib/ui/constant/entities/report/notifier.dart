import 'dart:async';

import 'package:hyppe/core/bloc/report/bloc.dart';
import 'package:hyppe/core/bloc/report/state.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/models/collection/report/report.dart';
import 'package:hyppe/core/models/collection/report/report_data.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/inner/home/notifier_v2.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReportNotifier with ChangeNotifier {
  LocalizationModelV2 language = LocalizationModelV2();
  translate(LocalizationModelV2 translate) {
    language = translate;
    notifyListeners();
  }

  bool _loadingOption = false;
  bool get loadingOption => _loadingOption;

  String _currentReport = '';
  String get currentReport => _currentReport;

  String _currentReportDesc = '';
  String get currentReportDesc => _currentReportDesc;

  String? _appBar;
  String _fABCaption = "Submit";
  ReportType? _reportType;
  bool _screen = false;
  bool _fromLandscapeMode = false;
  Map<String, dynamic>? _data;
  ReportAction? _reportAction;

  String? get appBar => _appBar;
  String get fABCaption => _fABCaption;
  ReportType? get reportType => _reportType;
  bool get screen => _screen;
  bool get fromLandscapeMode => _fromLandscapeMode;
  Map<String, dynamic>? get data => _data;
  ReportAction? get reportAction => _reportAction;
  ContentData? contentData;
  String typeContent = '';

  set currentReport(String val) {
    _currentReport = val;
    notifyListeners();
  }

  set currentReportDesc(String val) {
    _currentReportDesc = val;
    notifyListeners();
  }

  set appBar(String? val) {
    _appBar = val;
    notifyListeners();
  }

  set fABCaption(String val) {
    _fABCaption = val;
    notifyListeners();
  }

  set reportType(ReportType? val) {
    _reportType = val;
    notifyListeners();
  }

  set screen(bool val) {
    _screen = val;
    notifyListeners();
  }

  set fromLandscapeMode(bool val) {
    _fromLandscapeMode = val;
    notifyListeners();
  }

  set data(Map<String, dynamic>? val) {
    _data = val;
    notifyListeners();
  }

  set reportAction(ReportAction? val) {
    _reportAction = val;
    notifyListeners();
  }

  // Parameter
  ///////////////////////////////////////////////////////////////

  int? _selectedIndex;
  String _remarkID = '';
  Report? _initData;
  bool _isLoading = false;

  int? get selectedIndex => _selectedIndex;
  String get remarkID => _remarkID;
  Report? get initData => _initData;
  bool get isLoading => _isLoading;

  set initData(Report? val) {
    _initData = val;
    notifyListeners();
  }

  set selectedIndex(int? val) {
    _selectedIndex = val;
    notifyListeners();
  }

  set remarkID(String val) {
    _remarkID = val;
    notifyListeners();
  }

  set isLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  Future initializeData(BuildContext context) async {
    _loadingOption = true;
    final notifier = ReportBloc();
    await notifier.getReportOptionsBloc(context);
    final fetch = notifier.reportFetch;

    if (fetch.reportState == ReportState.getReportOptionsSuccess) {
      initData = fetch.data;
    }
    _loadingOption = false;
    notifyListeners();
  }

  Future reportPost(BuildContext context) async {
    _isLoading = true;
    final data = {
      "postID": contentData!.postID,
      "type": "content",
      "reportedStatus": "ALL",
      "contentModeration": false,
      "contentModerationResponse": "",
      "reportedUser": [
        {
          "userID": SharedPreference().readStorage(SpKeys.userID),
          "email": SharedPreference().readStorage(SpKeys.email),
          "reportReasonId": _currentReport,
          "description": _currentReportDesc,
        }
      ]
    };
    final notifier = ReportBloc();
    await notifier.reports(context, data: data);
    final fetch = notifier.reportFetch;
    if (fetch.reportState == ReportState.reportsSuccess) {
      context.read<HomeNotifier>().onReport(
            context,
            postID: contentData!.postID!,
            content: typeContent,
            isReport: true,
          );
      _isLoading = false;
      Routing().moveBack();
      // _showMessage("Your feedback will help us to improve your experience.");

    } else {
      _isLoading = false;
      var _showMessage = 'Error';
      ShowBottomSheet().onShowColouredSheet(context, _showMessage, color: Theme.of(context).colorScheme.onError);
    }

    notifyListeners();
  }

  // void onClickButton(context) async {
  //   if (remarkID.isNotEmpty) {
  //     isLoading = true;
  //     final notifier = ReportBloc();
  //     // final notifier2 = Provider.of<StoriesPlaylistNotifier>(context, listen: false);
  //     // ignore: missing_enum_constant_in_switch
  //     switch (reportType) {
  //       case ReportType.post:
  //         {
  //           await notifier.reports(
  //             context,
  //             data: ReportData(langID: 'en', remarkID: remarkID, userID: data!['userID'], postID: data!['postID']),
  //             reportType: ReportType.post,
  //           );
  //           print("REPORT POST");
  //         }
  //         break;
  //       case ReportType.comment:
  //         {
  //           await notifier.reports(
  //             context,
  //             data: ReportData(langID: 'en', remarkID: remarkID, userID: data!['userID'], postID: data!['postID'], commentID: data!['commentID']),
  //             reportType: ReportType.comment,
  //           );
  //           print("REPORT COMMENT");
  //         }
  //         break;
  //       case ReportType.profile:
  //         {
  //           await notifier.reports(
  //             context,
  //             data: ReportData(langID: 'en', remarkID: remarkID, userID: data!['userID'], ruserID: data!['ruserID'], reportType: data!['reportType']),
  //             reportType: ReportType.profile,
  //           );
  //           print("REPORT PROFILE");
  //         }
  //         break;
  //       case ReportType.story:
  //         {
  //           await notifier.reports(
  //             context,
  //             data: ReportData(langID: 'en', remarkID: remarkID, userID: data!['userID'], storyID: data!['storyID']),
  //             reportType: ReportType.story,
  //           );
  //           print("REPORT STORY");
  //         }
  //         break;
  //     }
  //     final fetch = notifier.reportFetch;
  //     isLoading = false;
  //     if (fetch.reportState == ReportState.reportsSuccess) {
  //       print('Success Reporting');
  //       // notifier2.forceStop = false;
  //       Routing().moveBack();
  //       Routing().moveBack();
  //     }
  //   } else {
  //     print('No remark selected');
  //   }
  // }
}
