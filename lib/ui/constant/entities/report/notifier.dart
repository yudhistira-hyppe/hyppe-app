import 'dart:async';

import 'package:hyppe/core/bloc/report/bloc.dart';
import 'package:hyppe/core/bloc/report/state.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/constants/utils.dart';
import 'package:hyppe/core/models/collection/advertising/ads_video_data.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/models/collection/report/report.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/playlist/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/playlist/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/playlist/slide/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/other_profile/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/playlist/notifier.dart';
import 'package:hyppe/ui/inner/home/notifier_v2.dart';
import 'package:hyppe/ui/inner/search_v2/notifier.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReportNotifier with ChangeNotifier {
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
  AdsData? adsData;
  String typeContent = '';

  contentPosition? _inPosition = contentPosition.home;
  contentPosition? get inPosition => _inPosition;

  String _type = '';
  String get type => _type;

  set type(String val) {
    _type = val;
    notifyListeners();
  }

  set inPosition(contentPosition? val) {
    _inPosition = val;
    notifyListeners();
  }

  setPosition(contentPosition? val) {
    _inPosition = val;
  }

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
  }

  Future reportPost(BuildContext context, {bool inDetail = true}) async {
    _isLoading = true;
    final data = {
      "postID": contentData != null ? contentData?.postID ?? '' : adsData?.adsId ?? '',
      "type": contentData != null ? "content" : "ads",
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
      if (contentData != null) {
        context.read<HomeNotifier>().onReport(
              context,
              postID: contentData?.postID ?? '',
              content: typeContent,
              isReport: true,
            );
      }

      _isLoading = false;
      Routing().moveBack();
      if (inDetail) {
        Routing().moveBack();
      }
      final language = context.read<TranslateNotifierV2>().translate;
      ShowBottomSheet()
          .onShowColouredSheet(context, language.reportReceived ?? '', subCaption: language.yourReportWillbeHandledImmediately, color: kHyppeTextSuccess, milisecond: 1000, dismissible: false);
    } else {
      _isLoading = false;
      ShowBottomSheet().onShowColouredSheet(context, fetch.message, color: kHyppeRed, milisecond: 500);
    }

    notifyListeners();
  }

  void seeContent(BuildContext context, ContentData data, String typeContent) {
    switch (_inPosition) {
      case contentPosition.otherprofile:
        context.read<OtherProfileNotifier>().showContentSensitive(
              context,
              postID: data.postID ?? '',
              content: typeContent,
              isReport: false,
            );
        break;
      case contentPosition.myprofile:
        context.read<SelfProfileNotifier>().showContentSensitive(
              context,
              postID: data.postID ?? '',
              content: typeContent,
              isReport: false,
            );
        break;
      case contentPosition.searchFirst:
        context.read<SearchNotifier>().showContentSensitive(
              context,
              postID: data.postID ?? '',
              content: typeContent,
              isReport: false,
            );
        break;
      case contentPosition.search:
        switch (_type) {
          case 'vid':
            context.read<VidDetailNotifier>().showContentSensitive();
            break;
          case 'pict':
            context.read<PicDetailNotifier>().showContentSensitive();
            break;
          default:
            context.read<DiariesPlaylistNotifier>().showContentSensitive(data.postID);
        }
        break;
      case contentPosition.seeAllVid:
        context.read<VidDetailNotifier>().showContentSensitive();
        break;
      case contentPosition.seeAllDiary:
        context.read<DiariesPlaylistNotifier>().showContentSensitive(data.postID);
        break;
      case contentPosition.seeAllPict:
        context.read<PicDetailNotifier>().showContentSensitive();
        break;
      default:
        context.read<HomeNotifier>().showContentSensitive(
              context,
              postID: data.postID ?? '',
              content: typeContent,
              isReport: false,
            );
    }
    context.read<OtherProfileNotifier>().onUpdate();
    switch (typeContent) {
      case hyppeVid:
        context.read<VidDetailNotifier>().onUpdate();
        break;
      case hyppeDiary:
        context.read<DiariesPlaylistNotifier>().onUpdate();
        break;
      case hyppePic:
        context.read<PicDetailNotifier>().onUpdate();
        context.read<SlidedPicDetailNotifier>().onUpdate();
        break;
      default:
        '';
        break;
    }
    _type = '';

    notifyListeners();
  }

  String titleLang(id, en) {
    final lang = SharedPreference().readStorage(SpKeys.isoCode);
    if (lang == 'en') {
      return en;
    } else {
      return id;
    }
  }
}
