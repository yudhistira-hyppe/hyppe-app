// import 'dart:js';

import 'dart:async';
import 'dart:convert';

import 'package:hyppe/core/arguments/general_argument.dart';
import 'package:hyppe/core/bloc/ads_video/bloc.dart';
import 'package:hyppe/core/bloc/ads_video/state.dart';
import 'package:hyppe/core/bloc/challange/bloc.dart';
import 'package:hyppe/core/bloc/challange/state.dart';
import 'package:hyppe/core/bloc/posts_v2/state.dart';
import 'package:hyppe/core/config/url_constants.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/utils.dart';
import 'package:hyppe/core/models/collection/advertising/ads_video_data.dart';
import 'package:hyppe/core/models/collection/common/user_badge_model.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/services/SqliteData.dart';
import 'package:hyppe/core/services/check_version.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/ui/constant/entities/report/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/scroll/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/playlist/slide/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/scroll/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/other_profile/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/playlist/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/scroll/notifier.dart';
import 'package:hyppe/ui/inner/main/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/core/services/overlay_service/overlay_handler.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/inner/home/content_v2/stories/preview/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/preview/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/notifier.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../core/bloc/posts_v2/bloc.dart';
import '../search_v2/notifier.dart';

class HomeNotifier with ChangeNotifier {
  //for visibilty

  List<ContentData>? _landingData;
  List<ContentData>? get landingData => _landingData;

  LocalizationModelV2 language = LocalizationModelV2();

  translate(LocalizationModelV2 translate) {
    language = translate;

    notifyListeners();
  }

  bool _preventReloadAfterUploadPost = false;
  bool get preventReloadAfterUploadPost => _preventReloadAfterUploadPost;
  set preventReloadAfterUploadPost(val) {
    _preventReloadAfterUploadPost = val;
    notifyListeners();
  }

  bool _isShowInactiveWarning = false;
  bool get isShowInactiveWarning => _isShowInactiveWarning;
  set isShowInactiveWarning(val) {
    _isShowInactiveWarning = val;
    notifyListeners();
  }

  FeatureType _uploadedPostType = FeatureType.pic; // set default to pic because pic is at 0 index
  FeatureType get uploadedPostType => _uploadedPostType;
  set uploadedPostType(val) {
    _uploadedPostType = val;
    notifyListeners();
  }

  bool _isLoadingVid = false;
  bool _isLoadingDiary = false;
  bool _isLoadingPict = false;

  int skipPic = 0;
  int skipDiary = 0;
  int skipvid = 0;
  int limit = 2;

  bool get isLoadingVid => _isLoadingVid;
  bool get isLoadingDiary => _isLoadingDiary;
  bool get isLoadingPict => _isLoadingPict;

  bool isLoadingLoadmore = false;

  List _visibiltyList = [];
  List get visibiltyList => _visibiltyList;

  String _visibilty = 'PUBLIC';
  String get visibilty => _visibilty;

  String _visibilitySelect = 'PUBLIC';
  String get visibilitySelect => _visibilitySelect;

  // bool _isHaveSomethingNew = false;
  String? _sessionID;

  // bool get isHaveSomethingNew => _isHaveSomethingNew;
  String? get sessionID => _sessionID;

  String _profileImage = '';
  String get profileImage => _profileImage;

  UserBadgeModel? _profileBadge;
  UserBadgeModel? get profileBadge => _profileBadge;

  String _profileImageKey = '';
  String get profileImageKey => _profileImageKey;

  String _select = 'PUBLIC';
  String get select => _select;

  int _tabIndex = 0;
  int get tabIndex => _tabIndex;

  int _lastCurIndex = -1;
  int get lastCurIndex => _lastCurIndex;

  bool _connectionError = false;
  bool get connectionError => _connectionError;
  set connectionError(bool state) {
    _connectionError = state;
    notifyListeners();
  }

  set tabIndex(val) {
    _tabIndex = val;
    notifyListeners();
  }

  set lastCurIndex(val) {
    _lastCurIndex = val;
    notifyListeners();
  }

  set landingData(List<ContentData>? val) {
    _landingData = val;
    notifyListeners();
  }

  var db = DatabaseHelper();

  set profileImage(String url) {
    _profileImage = url;
    notifyListeners();
  }

  set profileBadge(UserBadgeModel? badge) {
    _profileBadge = badge;
    notifyListeners();
  }

  set profileImageKey(String val) {
    _profileImageKey = val;
    notifyListeners();
  }

  set select(String val) {
    _select = val;
    notifyListeners();
  }

  // final box = Boxes.boxDataContents;

  // set isHaveSomethingNew(bool val) {
  //   _isHaveSomethingNew = val;
  //   notifyListeners();
  // }

  set isLoadingVid(bool val) {
    _isLoadingVid = val;
    notifyListeners();
  }

  set isLoadingDiary(bool val) {
    _isLoadingDiary = val;
    notifyListeners();
  }

  set isLoadingPict(bool val) {
    _isLoadingPict = val;
    notifyListeners();
  }

  set visibilty(String val) {
    _visibilty = val;
    notifyListeners();
  }

  set visibilitySelect(String val) {
    _visibilitySelect = val;
    notifyListeners();
  }

  set visibiltyList(List val) {
    _visibiltyList = val;

    notifyListeners();
  }

  void setSessionID() {
    _sessionID ??= System().generateUUID();

    // _visibiltyList = [
    //   {"id": '1', 'name': "${language.all}", 'code': 'PUBLIC'},
    //   {"id": '2', 'name': "${language.friends}", 'code': 'FRIEND'},
    //   {"id": '3', 'name': "${language.following}", 'code': 'FOLLOWING'},
    //   {"id": '4', 'name': "${language.onlyMe}", 'code': 'PRIVATE'},
    // ];
    notifyListeners();
  }

  void resetSessionID() {
    _sessionID = null;
  }

  void onUpdate() => notifyListeners();

  Future checkConnection() async {
    bool connect = await System().checkConnections();
    connectionError = !connect;
  }

  Future initNewHome(BuildContext context, bool mounted, {int? forceIndex, bool isreload = true, bool isgetMore = false, bool isNew = false}) async {
    ReportNotifier rp = Provider.of(Routing.navigatorKey.currentContext ?? context, listen: false);
    rp.inPosition = contentPosition.home;
    bool isConnected = await System().checkConnections();
    connectionError = !isConnected;
    if (isLoadingLoadmore) return;
    if (isConnected) {
      if (!mounted) return;
      getDataChallengeJoin(context);
      final profile = Provider.of<MainNotifier>(Routing.navigatorKey.currentContext ?? context, listen: false);
      final vid = Provider.of<PreviewVidNotifier>(Routing.navigatorKey.currentContext ?? context, listen: false);
      final diary = Provider.of<PreviewDiaryNotifier>(Routing.navigatorKey.currentContext ?? context, listen: false);
      final pic = Provider.of<PreviewPicNotifier>(Routing.navigatorKey.currentContext ?? context, listen: false);
      final stories = Provider.of<PreviewStoriesNotifier>(Routing.navigatorKey.currentContext ?? context, listen: false);
      // if (!isgetMore) {
      //   stories.myStoryGroup = {};
      //   stories.storiesGroups = [];
      //   notifyListeners();
      // }

      print("data pic ${(pic.pic?.isNotEmpty ?? [].isNotEmpty) && (diary.diaryData?.isNotEmpty ?? [].isNotEmpty)}");
      if ((!isreload && !isgetMore) && ((pic.pic?.isNotEmpty ?? [].isNotEmpty) && (diary.diaryData?.isNotEmpty ?? [].isNotEmpty) && (vid.vidData?.isNotEmpty ?? [].isNotEmpty))) {
        print("pic pic masuk ");
        return;
      }
      var email = SharedPreference().readStorage(SpKeys.email);
      Map data = {"email": email, "limit": limit};
      var index = _tabIndex;
      if (forceIndex != null) index = forceIndex;

      if (isgetMore) {
        isLoadingLoadmore = true;
        notifyListeners();
        if (index == 0) skipPic = skipPic + limit;
        // if (index == 1) skipDiary = skipDiary + limit;
        if (index == 1) skipvid = skipvid + limit;
        isreload = false;
      }

      print("ini index $index");

      switch (index) {
        case 0:
          if (isreload) {
            skipPic = 0;
            _isLoadingPict = true;
            notifyListeners();
          }
          data['type'] = 'pict';
          data['skip'] = skipPic;
          break;
        // case 1:
        //   if (isreload) {
        //     skipDiary = 0;
        //     _isLoadingDiary = true;
        //     notifyListeners();
        //   }
        //   data['type'] = 'diary';
        //   data['skip'] = skipDiary;
        //   break;
        case 1:
          if (isreload) {
            skipvid = 0;
            _isLoadingVid = true;
            notifyListeners();
          }
          data['type'] = 'vid';
          data['skip'] = skipvid;
          break;
      }
      if (!isgetMore && stories.storiesGroups!.isEmpty || isreload) {
        stories.myStoryGroup = {};
        stories.storiesGroups = [];

        stories.initialStories(Routing.navigatorKey.currentContext ?? context);
        notifyListeners();
        // notifyListeners();
      }
      // if (isreload) {
      //   await stories.initialStories(context);
      // }

      final allContents = await reload(Routing.navigatorKey.currentContext ?? context, data);

      // if (profileImage == '') {
      //   try {
      await profile.initMain(Routing.navigatorKey.currentContext ?? context, onUpdateProfile: true);

      //   } catch (e) {
      //     'profile.initMain error $e'.logger();
      //   }
      // }

      _isLoadingPict = false;
      _isLoadingDiary = false;
      _isLoadingVid = false;
      notifyListeners();
      print("index= ====== $index");
      switch (index) {
        case 0:
          if (!mounted) return;
          if (!isreload && isNew && pic.pic != null) return;
          await pic.initialPic(Routing.navigatorKey.currentContext ?? context, reload: isreload || isNew, list: allContents).then((value) async {
            if (pic.pic != null && isNew) {
              limit = pic.pic?.first.limitLandingpage ?? 2;
              if (mounted) {
                if ((Routing.navigatorKey.currentContext ?? context).read<MainNotifier>().tutorialData.isEmpty) {
                  // (Routing.navigatorKey.currentContext ?? context).read<MainNotifier>().tutorialData = pic.pic?.first.tutorial ?? [];
                }
              }
            }
            // if (diary.diaryData == null) {
            //   await initNewHome(context, mounted, forceIndex: 1);
            //   // diary.initialDiary(context, reload: isreload || isNew, list: allContents);
            // }
            // if (vid.vidData == null) {
            //   // vid.initialVid(context, reload: isreload || isNew, list: allContents);
            //   await initNewHome(context, mounted, forceIndex: 2);
            // }
          });
          break;
        // case 1:
        //   if (!mounted) return;
        //   if (!isreload && isNew && diary.diaryData != null) return;
        //   await diary.initialDiary(Routing.navigatorKey.currentContext ?? context, reload: isreload || isNew, list: allContents);
        //   if (diary.diaryData != null && (Routing.navigatorKey.currentContext ?? context).read<MainNotifier>().tutorialData.isEmpty) {
        //     // (Routing.navigatorKey.currentContext ?? context).read<MainNotifier>().tutorialData = diary.diaryData?.first.tutorial ?? [];
        //   }
        //   break;
        case 1:
          if (!mounted) return;
          if (!isreload && isNew && vid.vidData != null) return;
          await vid.initialVid(Routing.navigatorKey.currentContext ?? context, reload: isreload || isNew, list: allContents);
          if (vid.vidData != null && (Routing.navigatorKey.currentContext ?? context).read<MainNotifier>().tutorialData.isEmpty) {
            // (Routing.navigatorKey.currentContext ?? context).read<MainNotifier>().tutorialData = vid.vidData?.first.tutorial ?? [];
          }
          break;
      }
      isLoadingLoadmore = false;
    }
  }

  Future initHome(BuildContext context, bool mounted, {bool isReload = false}) async {
    // db.initDb();
    // await db.insertFilterCamera('2', 'filter viking', 'viking', 'viking.ong', context);
    // db.checkFilterItemExists();
    // await db.getFilterCamera();

    'init Home'.logger();

    context.read<ReportNotifier>().inPosition = contentPosition.home;
    bool isConnected = await System().checkConnections();
    if (isConnected) {
      int totLoading = 0;
      final profile = Provider.of<MainNotifier>(context, listen: false);
      final vid = Provider.of<PreviewVidNotifier>(context, listen: false);
      final diary = Provider.of<PreviewDiaryNotifier>(context, listen: false);
      final pic = Provider.of<PreviewPicNotifier>(context, listen: false);
      final stories = Provider.of<PreviewStoriesNotifier>(context, listen: false);
      if (isReload) {
        pic.pic = null;
        diary.diaryData = null;
        vid.vidData == null;
      }

      if (vid.vidData == null) {
        _isLoadingVid = true;
      }
      if (diary.diaryData == null) {
        _isLoadingDiary = true;
      }
      if (pic.pic == null) {
        _isLoadingPict = true;
      }

      if (profileImage == '') {
        try {
          await profile.initMain(context, onUpdateProfile: true).then((value) => totLoading += 1);
        } catch (e) {
          'profile.initMain error $e'.logger();
        }
      }

      if (pic.pic == null || diary.diaryData == null || vid.vidData == null) {
        final allContents = await allReload(context);
        // Refresh content
        try {
          await stories.initialStories(context).then((value) => totLoading += 1);
        } catch (e) {
          "Error Load Story : $e".logger();
        }
        try {
          print("masuk vidio");
          await vid.initialVid(context, reload: true, list: allContents.video).then((value) => totLoading += 1);
        } catch (e) {
          "Error Load Video : $e".logger();
        }
        try {
          await diary.initialDiary(context, reload: true, list: allContents.diary).then((value) => totLoading += 1);
        } catch (e) {
          "Error Load Diary : $e".logger();
        }
        try {
          'initialPic : 1'.logger();
          await pic.initialPic(context, reload: true, list: allContents.pict).then((value) => totLoading += 1);
        } catch (e) {
          "Error Load Pic : $e".logger();
        }
        'totLoading $totLoading'.logger();
        if (totLoading >= 3) {
          "is finish shimmer".logger();
          _isLoadingVid = false;
          _isLoadingDiary = false;
          _isLoadingPict = false;
        }

        notifyListeners();
      }
    } else {
      ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
        Routing().moveBack();
        onRefresh(context, 'PUBLIC');
      });
    }
  }

  Future onRefresh(BuildContext context, String visibility) async {
    'home notifier'.logger();
    bool isConnected = await System().checkConnections();
    if (isConnected) {
      int totLoading = 0;

      final profile = Provider.of<MainNotifier>(context, listen: false);
      final vid = Provider.of<PreviewVidNotifier>(context, listen: false);
      final diary = Provider.of<PreviewDiaryNotifier>(context, listen: false);
      final pic = Provider.of<PreviewPicNotifier>(context, listen: false);
      final stories = Provider.of<PreviewStoriesNotifier>(context, listen: false);

      if (vid.vidData == null) {
        _isLoadingVid = true;
      }
      if (diary.diaryData == null) {
        _isLoadingDiary = true;
      }
      if (pic.pic == null) {
        _isLoadingPict = true;
      }
      // Refresh profile
      try {
        await profile.initMain(context, onUpdateProfile: true).then((value) => totLoading += 1);
      } catch (e) {
        'profile.initMain error $e'.logger();
      }

      final allContents = await allReload(context);
      // Refresh content
      try {
        await stories.initialStories(context).then((value) => totLoading += 1);
      } catch (e) {
        "Error Load Story : $e".logger();
      }
      try {
        await vid.initialVid(context, reload: true, list: allContents.video).then((value) => totLoading += 1);
      } catch (e) {
        "Error Load Video : $e".logger();
      }
      try {
        await diary.initialDiary(context, reload: true, list: allContents.diary).then((value) => totLoading += 1);
      } catch (e) {
        "Error Load Diary : $e".logger();
      }
      try {
        'initialPic : 1'.logger();
        await pic.initialPic(context, reload: true, list: allContents.pict).then((value) => totLoading += 1);
      } catch (e) {
        "Error Load Pic : $e".logger();
      }
      'totLoading $totLoading'.logger();
      if (totLoading >= 3) {
        "is finish shimmer".logger();
        _isLoadingVid = false;
        _isLoadingDiary = false;
        _isLoadingPict = false;
      }

      notifyListeners();
    } else {
      ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
        Routing().moveBack();
        onRefresh(context, visibility);
      });
    }
    // isHaveSomethingNew = false;
  }

  Future<List<ContentData>> reload(BuildContext context, Map data) async {
    List<ContentData> res = [];
    final notifierMain = Provider.of<HomeNotifier>(context, listen: false);
    'ambil semua data ${notifierMain.visibilty}'.logger();
    // final notifier = PostsBloc();
    //
    // await notifier.getAllContentsBlocV2(context, pageNumber: page, visibility: notifierMain.visibilty, myContent: myContent, otherContent: otherContent);
    // final fetch = notifier.postsFetch;
    // '${AllContents.fromJson(fetch.data).toJson()}'.logger();
    // res = AllContents.fromJson(fetch.data);
    // return res;
    try {
      final notifier = PostsBloc();

      await notifier.getNewContentsBlocV2(context, data: data);
      final fetch = notifier.postsFetch;
      'AllContents : ${fetch.data}'.logger();

      fetch.data['data'].forEach((v) {
        res.add(ContentData.fromJson(v));
      });

      print("--> HomeNotifier reload res.length:" + res.length.toString());

      await CheckVersion().check(context, fetch.version, fetch.versionIos);

      landingData = res;

      return res;
    } catch (e) {
      'landing page error : $e'.logger();
      return [];
    }
  }

  Future getDataChallengeJoin(BuildContext context) async {
    try {
      String c = SharedPreference().readStorage(SpKeys.challangeData) ?? '';
      if (c == '' || c == '[]') {
        final notifier = ChallangeBloc();
        var data = {"iduser": SharedPreference().readStorage(SpKeys.userID)};
        await notifier.postChallange(context, data: data, url: UrlConstants.getDataMyChallenge);
        final fetch = notifier.userFetch;
        if (fetch.challengeState == ChallengeState.getPostSuccess) {
          SharedPreference().writeStorage(SpKeys.challangeData, jsonEncode(fetch.data));
        }
      }
    } catch (e) {
      'landing page error : $e'.logger();
      return [];
    }
  }

  Future<AllContents> allReload(BuildContext context, {bool myContent = false, bool otherContent = false}) async {
    AllContents? res;
    final notifierMain = Provider.of<HomeNotifier>(context, listen: false);
    'ambil semua data ${notifierMain.visibilty}'.logger();
    // final notifier = PostsBloc();
    //
    // await notifier.getAllContentsBlocV2(context, pageNumber: page, visibility: notifierMain.visibilty, myContent: myContent, otherContent: otherContent);
    // final fetch = notifier.postsFetch;
    // '${AllContents.fromJson(fetch.data).toJson()}'.logger();
    // res = AllContents.fromJson(fetch.data);
    // return res;
    try {
      final notifier = PostsBloc();

      await notifier.getAllContentsBlocV2(context, pageNumber: 1, visibility: notifierMain.visibilty, myContent: myContent, otherContent: otherContent);
      final fetch = notifier.postsFetch;
      'AllContents : ${AllContents.fromJson(fetch.data).toJson()}'.logger();
      res = AllContents.fromJson(fetch.data);
      await CheckVersion().check(context, fetch.version, fetch.versionIos);

      return res;
    } catch (e) {
      'landing page error : $e'.logger();
      return AllContents(story: [], video: [], diary: [], pict: []);
    }
  }

  // Future<ContentData> newLandingPage(BuildContext context, {bool myContent = false, bool otherContent = false}) async {
  //   AllContents? res;
  //   final notifierMain = Provider.of<HomeNotifier>(context, listen: false);
  //   'ambil semua data ${notifierMain.visibilty}'.logger();
  //   // final notifier = PostsBloc();
  //   //
  //   // await notifier.getAllContentsBlocV2(context, pageNumber: page, visibility: notifierMain.visibilty, myContent: myContent, otherContent: otherContent);
  //   // final fetch = notifier.postsFetch;
  //   // '${AllContents.fromJson(fetch.data).toJson()}'.logger();
  //   // res = AllContents.fromJson(fetch.data);
  //   // return res;
  //   try {
  //     final notifier = PostsBloc();

  //     await notifier.getAllContentsBlocV2(context, pageNumber: 1, visibility: notifierMain.visibilty, myContent: myContent, otherContent: otherContent);
  //     final fetch = notifier.postsFetch;
  //     'AllContents : ${AllContents.fromJson(fetch.data).toJson()}'.logger();
  //     res = AllContents.fromJson(fetch.data);
  //     await CheckVersion().check(context, fetch.version);

  //     return res;
  //   } catch (e) {
  //     'landing page error : $e'.logger();
  //     return AllContents(story: [], video: [], diary: [], pict: []);
  //   }
  // }

  void onDeleteSelfPostContent(BuildContext context, {required String postID, required String email, required String content}) {
    final vid = Provider.of<PreviewVidNotifier>(context, listen: false);
    final diary = Provider.of<PreviewDiaryNotifier>(context, listen: false);
    final pic = Provider.of<PreviewPicNotifier>(context, listen: false);
    final stories = Provider.of<PreviewStoriesNotifier>(context, listen: false);
    switch (content) {
      case hyppeVid:
        vid.vidData?.removeWhere((element) => element.postID == postID);
        break;
      case hyppeDiary:
        diary.diaryData?.removeWhere((element) => element.postID == postID);
        break;
      case hyppePic:
        pic.pic?.removeWhere((element) => element.postID == postID);
        break;
      case hyppeStory:
        stories.isloading = true;
        stories.myStoriesData?.removeWhere((element) => element.postID == postID);
        stories.myStoryGroup[email]!.removeWhere((element) => element.postID == postID);
        // stories.initialStories(context);
        stories.isloading = false;
        break;
      default:
        "$content It's Not a content of $postID".logger();
        break;
    }
    notifyListeners();
  }

  void onUpdateSelfPostContent(
    BuildContext context, {
    required String postID,
    required String content,
    String? description,
    String? visibility,
    bool? allowComment,
    bool? certified,
    List<String>? tags,
    List<String>? cats,
    List<TagPeople>? tagPeople,
    String? location,
    String? saleAmount,
    bool? isShared,
    bool? saleLike,
    bool? saleView,
    String? urlLink,
    String? judulLink
  }) {
    ContentData? updatedData;
    ContentData? updatedData2;
    final vid = Provider.of<PreviewVidNotifier>(context, listen: false);
    final vid2 = Provider.of<VidDetailNotifier>(context, listen: false);
    final diary = Provider.of<PreviewDiaryNotifier>(context, listen: false);
    final pic = Provider.of<PreviewPicNotifier>(context, listen: false);
    final pic2 = Provider.of<SlidedPicDetailNotifier>(context, listen: false);
    final stories = Provider.of<PreviewStoriesNotifier>(context, listen: false);

    switch (content) {
      case hyppeVid:
        updatedData = vid.vidData?.firstWhereOrNull((element) => element.postID == postID);
        updatedData2 = vid2.data;
        break;
      case hyppeDiary:
        updatedData = diary.diaryData?.firstWhereOrNull((element) => element.postID == postID);
        break;
      case hyppePic:
        updatedData = pic.pic?.firstWhereOrNull((element) => element.postID == postID);
        updatedData2 = pic2.data;
        break;
      case hyppeStory:
        updatedData = stories.myStoriesData?.firstWhereOrNull((element) => element.postID == postID);
        break;
      default:
        "$content It's Not a content of $postID".logger();
        break;
    }

    if (updatedData != null) {
      updatedData.tags = tags;
      updatedData.description = description;
      updatedData.allowComments = allowComment;
      updatedData.visibility = visibility;
      updatedData.location = location;
      updatedData.saleAmount = num.parse(saleAmount != null
          ? saleAmount != ''
              ? saleAmount
              : '0'
          : '0');
      updatedData.saleLike = saleLike;
      updatedData.saleView = saleView;
      updatedData.urlLink = urlLink;
      updatedData.judulLink = judulLink;
      updatedData.cats = [];
      updatedData.tagPeople = [];
      updatedData.isShared = isShared;
      // _updatedData.tagPeople = tagPeople;
      updatedData.tagPeople?.addAll(tagPeople ?? []);
      if (cats != null) {
        for (var v in cats) {
          updatedData.cats?.add(
            Cats(
              id: v,
              // interestName: v,
            ),
          );
        }
      }
      if (updatedData2 != null) {
        updatedData2.tags = tags;
        updatedData2.description = description;
        updatedData2.allowComments = allowComment;
        updatedData2.visibility = visibility;
        updatedData2.location = location;
        updatedData2.saleAmount = num.parse(saleAmount != null
            ? saleAmount != ''
                ? saleAmount
                : '0'
            : '0');
        updatedData2.saleLike = saleLike;
        updatedData2.saleView = saleView;
        updatedData.urlLink = urlLink;
        updatedData.judulLink = judulLink;
        updatedData2.cats = [];
        updatedData2.tagPeople = [];
        // _updatedData2.tagPeople = tagPeople;
        updatedData2.tagPeople!.addAll(tagPeople ?? []);
        if (cats != null) {
          for (var v in cats) {
            updatedData2.cats!.add(
              Cats(
                id: v,
                // interestName: v,
              ),
            );
          }
        }
      }
      '${updatedData.cats?.length}'.logger();
    }

    notifyListeners();
  }

  void onReport(BuildContext context, {required String postID, required String content, bool? isReport, String? key}) {
    final vid = Provider.of<PreviewVidNotifier>(context, listen: false);
    final diary = Provider.of<PreviewDiaryNotifier>(context, listen: false);
    final pic = Provider.of<PreviewPicNotifier>(context, listen: false);
    final stories = Provider.of<PreviewStoriesNotifier>(context, listen: false);

    ScrollVidNotifier vidScroll = context.read<ScrollVidNotifier>();
    ScrollDiaryNotifier diaryScroll = context.read<ScrollDiaryNotifier>();
    ScrollPicNotifier picScroll = context.read<ScrollPicNotifier>();

    final otherProfile = Provider.of<OtherProfileNotifier>(context, listen: false);
    diaryScroll.diaryData?.removeWhere((element) => element.postID == postID);
    picScroll.pics?.removeWhere((element) => element.postID == postID);
    vidScroll.vidData?.removeWhere((element) => element.postID == postID);

    if (otherProfile.manyUser.isNotEmpty) otherProfile.manyUser.last.vids?.removeWhere((element) => element.postID == postID);
    if (otherProfile.manyUser.isNotEmpty) otherProfile.manyUser.last.diaries?.removeWhere((element) => element.postID == postID);
    if (otherProfile.manyUser.isNotEmpty) otherProfile.manyUser.last.pics?.removeWhere((element) => element.postID == postID);

    vid.vidData?.removeWhere((element) => element.postID == postID);
    diary.diaryData?.removeWhere((element) => element.postID == postID);
    pic.pic?.removeWhere((element) => element.postID == postID);
    stories.peopleStoriesData?.removeWhere((element) => element.postID == postID);

    if (key != null) {
      final search = context.read<SearchNotifier>();
      search.removeInterestItem(key, postID);
    }

    notifyListeners();
  }

  void showContentSensitive(BuildContext context, {required String postID, required String content, bool? isReport}) {
    ContentData? updatedData;

    final vid = Provider.of<PreviewVidNotifier>(context, listen: false);
    final diary = Provider.of<PreviewDiaryNotifier>(context, listen: false);
    final pic = Provider.of<PreviewPicNotifier>(context, listen: false);
    final stories = Provider.of<PreviewStoriesNotifier>(context, listen: false);

    switch (content) {
      case hyppeVid:
        updatedData = vid.vidData?.firstWhereOrNull((element) => element.postID == postID);
        break;
      case hyppeDiary:
        updatedData = diary.diaryData?.firstWhereOrNull((element) => element.postID == postID);
        break;
      case hyppePic:
        // pic.pic?.removeWhere((element) => element.postID == postID);
        updatedData = pic.pic?.firstWhereOrNull((element) => element.postID == postID);
        // _updatedData = pic2.data;
        break;
      case hyppeStory:
        updatedData = stories.peopleStoriesData?.firstWhereOrNull((element) => element.postID == postID);
        break;
      default:
        "$content It's Not a content of $postID".logger();
        break;
    }

    if (updatedData != null) {
      print('buka dong ${updatedData.description}');
      print('${updatedData.description}');
      updatedData.reportedStatus = 'ALL';
    }
    // if (_updatedData2 != null) {
    //   print('buka dong2 ${_updatedData2.description}');
    //   print('${_updatedData2.description}');
    //   _updatedData2.reportedStatus = 'ALL';
    // }

    notifyListeners();
  }

  Future navigateToProfilePage(BuildContext context, {bool whenComplete = false, Function? onWhenComplete}) async {
    if (context.read<OverlayHandlerProvider>().overlayActive) context.read<OverlayHandlerProvider>().removeOverlay(context);

    whenComplete ? Routing().move(Routes.selfProfile, argument: GeneralArgument(isTrue: true)).whenComplete(() => onWhenComplete) : Routing().move(Routes.selfProfile, argument: GeneralArgument(isTrue: true));
  }

  //untuk test aliplayer
  Future navigateToTestAliPlayer(BuildContext context, {bool whenComplete = false, Function? onWhenComplete}) async {
    if (context.read<OverlayHandlerProvider>().overlayActive) context.read<OverlayHandlerProvider>().removeOverlay(context);
    whenComplete ? Routing().move(Routes.testAliPlayer).whenComplete(() => onWhenComplete) : Routing().move(Routes.testAliPlayer);
  }

  bool pickedVisibility(String? tile) {
    notifyListeners();
    if (_visibilty.contains(tile ?? '')) {
      return true;
    } else {
      return false;
    }
  }

  void changeVisibility(BuildContext context, bool mounted, index) {
    _visibilty = _visibiltyList[index]['code'];
    _visibilitySelect = _visibiltyList[index]['code'];
    onRefresh(context, _visibilitySelect);

    notifyListeners();
  }

  void onDeleteSelfTagUserContent(BuildContext context, {required String postID, required String content, required String email}) {
    ContentData? updatedData;
    final vid = Provider.of<PreviewVidNotifier>(context, listen: false);
    final diary = Provider.of<PreviewDiaryNotifier>(context, listen: false);
    final pic = Provider.of<PreviewPicNotifier>(context, listen: false);
    final stories = Provider.of<PreviewStoriesNotifier>(context, listen: false);
    switch (content) {
      case hyppeVid:
        updatedData = vid.vidData?.firstWhereOrNull((element) => element.postID == postID);
        break;
      case hyppeDiary:
        updatedData = diary.diaryData?.firstWhereOrNull((element) => element.postID == postID);
        break;
      case hyppePic:
        updatedData = pic.pic?.firstWhereOrNull((element) => element.postID == postID);
        break;
      case hyppeStory:
        updatedData = stories.myStoriesData?.firstWhereOrNull((element) => element.postID == postID);
        break;
      default:
        "$content It's Not a content of $postID".logger();
        break;
    }

    final index = vid.vidData?.indexWhere((element) => element.postID == postID);
    if (index != null) {
      vid.vidData?[index].tagPeople?.removeWhere((element) => element.email == email);
      vid.vidData?[index].description = 'asdaksdjha jsd';

      print(vid.vidData?[index].tagPeople?.length);
      updatedData?.tagPeople?.removeWhere((element) => element.email == email);
    }

    notifyListeners();
  }

  /// New Pop Ads
  Future getAdsApsara(BuildContext context, isInAppAds) async {
    print('ke iklan yah');
    final ads = await getPopUpAds(context);
    final id = ads.videoId;
    print('ke iklan yah $id');
    print('ke iklan yah ${ads.adsType}');
    if (ads.mediaType?.toLowerCase() == 'image') {
      await System().adsPopUpV2(context, ads, '');
    } else if (id != null && ads.adsType != null) {
      try {
        final notifier = PostsBloc();

        // await notifier.getVideoApsaraBlocV2(context, apsaraId: ads.videoId ?? '');
        await notifier.getAuthApsara(context, apsaraId: ads.videoId ?? '');
        final fetch = notifier.postsFetch;

        if (fetch.postsState == PostsState.videoApsaraSuccess) {
          Map jsonMap = json.decode(fetch.data.toString());
          print('jsonMap video Apsara : $jsonMap');
          final auth = jsonMap['PlayAuth'];
          // _eventType = (_betterPlayerRollUri != null) ? BetterPlayerEventType.showingAds : null;
          print('get Ads Video');
          // if (!isShowAds) {
          await System().adsPopUpV2(context, ads, auth);
          // }

          // widget.videoData?.fullContentPath = jsonMap['PlayUrl'];
        }
      } catch (e) {
        'Failed to fetch ads data $e'.logger();
      }
    }
    //get banner Challange
    Future.delayed(const Duration(milliseconds: 500), () {
      if (isInAppAds) System().popUpChallange(context);
    });
  }

  Future<AdsData> getPopUpAds(BuildContext context) async {
    var data = AdsData();
    try {
      final notifier = AdsDataBloc();
      await notifier.adsVideoBlocV2(context, AdsType.popup);
      final fetch = notifier.adsDataFetch;
      print('video ads');
      if (fetch.adsDataState == AdsDataState.getAdsVideoBlocSuccess) {
        print('data iklan : ${fetch.data.toString()}');
        data = fetch.data?.data;
      }
    } catch (e) {
      'Failed to fetch ads data $e'.logger();
    }
    return data;
  }

  /// Old Pop Ads
  // Future getAdsApsara(BuildContext context, isInAppAds) async {
  //   print('ke iklan yah');
  //   final ads = await getPopUpAds(context);
  //   final id = ads.videoId;
  //   print('ke iklan yah $id');
  //   print('ke iklan yah ${ads.adsType}');
  //   if (id != null && ads.adsType != null) {
  //     try {
  //       final notifier = PostsBloc();

  //       // await notifier.getVideoApsaraBlocV2(context, apsaraId: ads.videoId ?? '');
  //       await notifier.getAuthApsara(context, apsaraId: ads.videoId ?? '');
  //       final fetch = notifier.postsFetch;

  //       if (fetch.postsState == PostsState.videoApsaraSuccess) {
  //         Map jsonMap = json.decode(fetch.data.toString());
  //         print('jsonMap video Apsara : $jsonMap');
  //         final auth = jsonMap['PlayAuth'];
  //         // _eventType = (_betterPlayerRollUri != null) ? BetterPlayerEventType.showingAds : null;
  //         print('get Ads Video');
  //         final isShowAds = SharedPreference().readStorage(SpKeys.isShowPopAds);
  //         // if (!isShowAds) {
  //         System().adsPopUp(context, ads, auth, isInAppAds: isInAppAds);
  //         // }

  //         // widget.videoData?.fullContentPath = jsonMap['PlayUrl'];
  //       }
  //     } catch (e) {
  //       'Failed to fetch ads data ${e}'.logger();
  //     }
  //   }
  // }

  // Future<AdsData> getPopUpAds(BuildContext context) async {
  //   var data = AdsData();
  //   try {
  //     final notifier = AdsDataBloc();
  //     await notifier.appAdsBloc(context);
  //     final fetch = notifier.adsDataFetch;
  //     print('video ads');
  //     if (fetch.adsDataState == AdsDataState.getAdsVideoBlocSuccess) {
  //       print('data iklan : ${fetch.data.toString()}');
  //       data = fetch.data?.data;
  //     }
  //   } catch (e) {
  //     'Failed to fetch ads data $e'.logger();
  //   }
  //   return data;
  // }

  void updateFollowing(BuildContext context, {required String email, bool? statusFollowing}) {
    List<ContentData>? listDataVid = [];
    List<ContentData>? listDataDiary = [];
    List<ContentData>? listDataPic = [];
    final vid = Provider.of<PreviewVidNotifier>(context, listen: false);
    final diary = Provider.of<PreviewDiaryNotifier>(context, listen: false);
    final pic = Provider.of<PreviewPicNotifier>(context, listen: false);

    listDataVid = vid.vidData?.where((element) => element.email == email).toList();

    if (listDataVid?.isNotEmpty ?? [].isEmpty) {
      listDataVid?.forEach((e) {
        e.following = statusFollowing;
      });
    }
    listDataDiary = diary.diaryData?.where((element) => element.email == email).toList();
    if (listDataDiary?.isNotEmpty ?? [].isEmpty) {
      listDataDiary?.forEach((e) => e.following = statusFollowing);
    }

    listDataPic = pic.pic?.where((element) => element.email == email).toList();
    if (listDataPic?.isNotEmpty ?? [].isEmpty) {
      listDataPic?.forEach((e) => e.following = statusFollowing);
    }

    notifyListeners();
  }

  void addCountComment(
    BuildContext context,
    String postID,
    bool add,
    int totChild, {
    String? username,
    String? txtMsg,
    String? gift,
    String? parentID,
    int? indexComment,
    bool pageDetail = false,
    String? email,
  }) async {
    final vid = Provider.of<PreviewVidNotifier>(context, listen: false);
    final diary = Provider.of<PreviewDiaryNotifier>(context, listen: false);
    final pic = Provider.of<PreviewPicNotifier>(context, listen: false);

    ScrollVidNotifier vidScroll = context.read<ScrollVidNotifier>();
    ScrollDiaryNotifier diaryScroll = context.read<ScrollDiaryNotifier>();
    ScrollPicNotifier picScroll = context.read<ScrollPicNotifier>();

    ContentData? updatedData;
    updatedData = vid.vidData?.firstWhereOrNull((element) => element.postID == postID);
    updatedData ??= diary.diaryData?.firstWhereOrNull((element) => element.postID == postID);
    updatedData ??= pic.pic?.firstWhereOrNull((element) => element.postID == postID);

    // _updatedData ??= vidScroll.vidData?.firstWhereOrNull((element) => element.postID == postID);
    // _updatedData ??= diaryScroll.diaryData?.firstWhereOrNull((element) => element.postID == postID);
    // _updatedData ??= picScroll.pics?.firstWhereOrNull((element) => element.postID == postID);

    if (add) {
      Comment comment = Comment(txtMessages: txtMsg, gift: gift, userComment: UserComment(username: username), sender: email);
      print("===-=-=-=-=- parentID $parentID");
      print("===-=-=-=-=- parentID ${vid.vidData?[0].description}");

      if (parentID == null) {
        print("===-=-=-=-=- pageDetail $pageDetail ${updatedData?.description}");

        if (pageDetail) {
          picScroll.pics?.forEach((e) {
            if (e.postID == postID) {
              e.comment?.insert(0, comment);
              e.comments = (e.comments ?? 0) + 1;
            }
          });
          vidScroll.vidData?.forEach((e) {
            if (e.postID == postID) {
              print("vidscrolllll");
              e.comment?.insert(0, comment);
              e.comments = (e.comments ?? 0) + 1;
              context.read<ScrollVidNotifier>().onUpdate();
            }
          });
          diaryScroll.diaryData?.forEach((e) {
            if (e.postID == postID) {
              e.comment?.insert(0, comment);
              e.comments = (e.comments ?? 0) + 1;
            }
          });
        } else {
          if (updatedData?.comment == null) {
            updatedData?.comment = [];
            updatedData?.comment = [comment];
            notifyListeners();
          } else {
            updatedData?.comment?.insert(0, comment);
            notifyListeners();
          }
          updatedData?.comments = (updatedData.comments ?? 0) + 1;
          context.read<PreviewVidNotifier>().onUpdate();
        }
      }

      notifyListeners();
    } else {
      if (pageDetail) {
        picScroll.pics?.forEach((e) {
          if (e.postID == postID) {
            e.comments = (e.comments ?? 0) - (1 + totChild);
            if (parentID == null) {
              if (indexComment != null && e.comment != null) {
                e.comment?.removeAt(indexComment);
              }
            }
          }
        });
        vidScroll.vidData?.forEach((e) {
          if (e.postID == postID) {
            e.comments = (e.comments ?? 0) - (1 + totChild);
            if (parentID == null) {
              if (indexComment != null && e.comment != null) {
                e.comment?.removeAt(indexComment);
              }
            }
            context.read<ScrollVidNotifier>().onUpdate();
          }
        });
        diaryScroll.diaryData?.forEach((e) {
          if (e.postID == postID) {
            e.comments = (e.comments ?? 0) - (1 + totChild);
            if (parentID == null) {
              if (indexComment != null && e.comment != null) {
                e.comment?.removeAt(indexComment);
              }
            }
          }
        });
      } else {
        updatedData?.comments = (updatedData.comments ?? 0) - (1 + totChild);
        if (parentID == null) {
          if (indexComment != null && updatedData?.comment != null) {
            updatedData?.comment?.removeAt(indexComment);
          }
        }
      }

      notifyListeners();
    }
  }

  void onUploadedSelfUserContent({
    required BuildContext context,
    required ContentData contentData,
  }) async {
    print("======-----sukses setelah upload------=========");
    final pic = (Routing.navigatorKey.currentContext ?? context).read<PreviewPicNotifier>();
    final diary = (Routing.navigatorKey.currentContext ?? context).read<PreviewDiaryNotifier>();
    final vid = (Routing.navigatorKey.currentContext ?? context).read<PreviewVidNotifier>();
    final stories = (Routing.navigatorKey.currentContext ?? context).read<PreviewStoriesNotifier>();
    var email = SharedPreference().readStorage(SpKeys.email);
    Map data = {"email": email, "limit": limit};

    switch (contentData.postType) {
      case "pict":
        // if (isreload) {
        //   skipPic = 0;
        //   _isLoadingPict = true;
        //   notifyListeners();
        // }
        data['type'] = 'pict';
        data['skip'] = skipPic;
        break;
      case "diary":
        // if (isreload) {
        //   skipDiary = 0;
        //   _isLoadingDiary = true;
        //   notifyListeners();
        // }
        data['type'] = 'diary';
        data['skip'] = skipDiary;
        break;
      case "vid":
        // if (isreload) {
        //   skipvid = 0;
        //   _isLoadingVid = true;
        //   notifyListeners();
        // }
        data['type'] = 'vid';
        data['skip'] = skipvid;
        break;
    }

    final allContents = await reload(Routing.navigatorKey.currentContext ?? context, data);
    print("======-----sukses setelah upload------=========");
    print(allContents);
    switch (contentData.postType) {
      case 'pict':
        if (pic.pic != null) {
          pic.pic = [contentData] + [...(pic.pic ?? [] as List<ContentData>)];
          pic.pic?[0].isContentLoading = true;
        } else {
          await pic.initialPic(Routing.navigatorKey.currentContext ?? context, list: allContents);
        }
        break;
      case 'diary':
        if (diary.diaryData != null) {
          diary.diaryData = [contentData] + [...(diary.diaryData ?? [] as List<ContentData>)];
          diary.diaryData?[0].isContentLoading = true;
        } else {
          await diary.initialDiary(Routing.navigatorKey.currentContext ?? context, list: allContents);
        }
        break;
      case 'vid':
        if (vid.vidData != null) {
          vid.vidData = [contentData] + [...(vid.vidData ?? [] as List<ContentData>)];
          vid.vidData?[0].isContentLoading = true;
        } else {
          await vid.initialVid(Routing.navigatorKey.currentContext ?? context, list: allContents);
        }
        break;
      case 'story':
        // String email = await SharedPreference().readStorage(SpKeys.email);
        // email.loggerV2();
        // stories.myStoryGroup[email] = [contentData] + [...(stories.myStoryGroup[email] ?? [] as List<ContentData>)];
        stories.initialMyStoryGroup(Routing.navigatorKey.currentContext ?? context);
        break;
      default:
    }
  }

  Timer? _inactivityTimer;
  Timer? get inactivityTimer => _inactivityTimer;
  set inactivityTimer(Timer? state) {
    _inactivityTimer = state;
    notifyListeners();
  }

  removeWakelock() async {
    "=================== remove wakelock".logger();
    _inactivityTimer?.cancel();
    _inactivityTimer = null;
    WakelockPlus.disable();
  }

  void initWakelockTimer({required Function() onShowInactivityWarning}) async {
    // adding delay to prevent if there's another that not disposed yet
    Future.delayed(const Duration(milliseconds: 2000), () {
      "=================== init wakelock".logger();
      WakelockPlus.enable();
      if (_inactivityTimer != null) _inactivityTimer?.cancel();
      _inactivityTimer = Timer(const Duration(seconds: 300), () => onShowInactivityWarning());
    });
  }
}
