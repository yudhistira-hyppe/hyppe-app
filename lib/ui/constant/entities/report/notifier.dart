import 'dart:async';

import 'package:hyppe/core/bloc/report/bloc.dart';
import 'package:hyppe/core/bloc/report/state.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/utils.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/models/collection/report/report.dart';
import 'package:hyppe/core/models/collection/report/report_data.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/notifier.dart';
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
    final notifier = ReportBloc();
    await notifier.getReportOptionsBloc(context, langID: 'en', reportType: reportType, action: reportAction);
    final fetch = notifier.reportFetch;
    if (fetch.reportState == ReportState.getReportOptionsSuccess) {
      initData = fetch.data;
    }
  }

  Future<void> reportPost(BuildContext context) async {
    context.read<HomeNotifier>().onReport(
          context,
          postID: contentData!.postID!,
          content: typeContent,
          isReport: true,
        );
    notifyListeners();
    Navigator.pop(context, true);

    // _showMessage("Your feedback will help us to improve your experience.");
    var _showMessage = 'Thanks for letting us know", "We will review your report. If we find this content is violating of our community guidelines we will take action on it.';
    ShowBottomSheet().onShowColouredSheet(context, _showMessage, color: Theme.of(context).colorScheme.onError);
  }

  void onClickButton(context) async {
    if (remarkID.isNotEmpty) {
      isLoading = true;
      final notifier = ReportBloc();
      // final notifier2 = Provider.of<StoriesPlaylistNotifier>(context, listen: false);
      // ignore: missing_enum_constant_in_switch
      switch (reportType) {
        case ReportType.post:
          {
            await notifier.reports(
              context,
              data: ReportData(langID: 'en', remarkID: remarkID, userID: data!['userID'], postID: data!['postID']),
              reportType: ReportType.post,
            );
            print("REPORT POST");
          }
          break;
        case ReportType.comment:
          {
            await notifier.reports(
              context,
              data: ReportData(langID: 'en', remarkID: remarkID, userID: data!['userID'], postID: data!['postID'], commentID: data!['commentID']),
              reportType: ReportType.comment,
            );
            print("REPORT COMMENT");
          }
          break;
        case ReportType.profile:
          {
            await notifier.reports(
              context,
              data: ReportData(langID: 'en', remarkID: remarkID, userID: data!['userID'], ruserID: data!['ruserID'], reportType: data!['reportType']),
              reportType: ReportType.profile,
            );
            print("REPORT PROFILE");
          }
          break;
        case ReportType.story:
          {
            await notifier.reports(
              context,
              data: ReportData(langID: 'en', remarkID: remarkID, userID: data!['userID'], storyID: data!['storyID']),
              reportType: ReportType.story,
            );
            print("REPORT STORY");
          }
          break;
      }
      final fetch = notifier.reportFetch;
      isLoading = false;
      if (fetch.reportState == ReportState.reportsSuccess) {
        print('Success Reporting');
        // notifier2.forceStop = false;
        Routing().moveBack();
        Routing().moveBack();
      }
    } else {
      print('No remark selected');
    }
  }
}
