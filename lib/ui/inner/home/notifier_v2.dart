// import 'dart:js';

import 'dart:async';
import 'dart:convert';

import 'package:hyppe/app.dart';
import 'package:hyppe/core/arguments/general_argument.dart';
import 'package:hyppe/core/arguments/other_profile_argument.dart';
import 'package:hyppe/core/bloc/ads_video/bloc.dart';
import 'package:hyppe/core/bloc/ads_video/state.dart';
import 'package:hyppe/core/bloc/posts_v2/state.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/utils.dart';
import 'package:hyppe/core/models/collection/advertising/ads_video_data.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/services/SqliteData.dart';
import 'package:hyppe/core/services/check_version.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/ui/constant/entities/report/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/scroll/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/playlist/slide/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/scroll/notifier.dart';
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

import '../../../core/bloc/posts_v2/bloc.dart';

class HomeNotifier with ChangeNotifier {
  //for visibilty

  LocalizationModelV2 language = LocalizationModelV2();

  translate(LocalizationModelV2 translate) {
    language = translate;

    notifyListeners();
  }

  bool _isLoadingVid = false;
  bool _isLoadingDiary = false;
  bool _isLoadingPict = false;

  int skipPic = 0;
  int skipDiary = 0;
  int skipvid = 0;
  int limit = 15;

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

  String _profileImageKey = '';
  String get profileImageKey => _profileImageKey;

  String _select = 'PUBLIC';
  String get select => _select;

  int _tabIndex = 0;
  int get tabIndex => _tabIndex;

  int _lastCurIndex = -1;
  int get lastCurIndex => _lastCurIndex;

  set tabIndex(val) {
    _tabIndex = val;
    notifyListeners();
  }

  set lastCurIndex(val) {
    _lastCurIndex = val;
    notifyListeners();
  }

  var db = DatabaseHelper();

  set profileImage(String url) {
    _profileImage = url;
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

  Future initNewHome(BuildContext context, bool mounted, {int? forceIndex, bool isreload = true, bool isgetMore = false, bool isNew = false}) async {
    ReportNotifier rp = Provider.of(Routing.navigatorKey.currentContext ?? context, listen: false);
    rp.inPosition = contentPosition.home;
    bool isConnected = await System().checkConnections();

    if (isConnected) {
      if (!mounted) return;
      final profile = Provider.of<MainNotifier>(context, listen: false);
      final vid = Provider.of<PreviewVidNotifier>(context, listen: false);
      final diary = Provider.of<PreviewDiaryNotifier>(context, listen: false);
      final pic = Provider.of<PreviewPicNotifier>(context, listen: false);
      final stories = Provider.of<PreviewStoriesNotifier>(context, listen: false);

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
        if (index == 1) skipDiary = skipDiary + limit;
        if (index == 2) skipvid = skipvid + limit;
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
        case 1:
          if (isreload) {
            skipDiary = 0;
            _isLoadingDiary = true;
            notifyListeners();
          }
          data['type'] = 'diary';
          data['skip'] = skipDiary;
          break;
        case 2:
          if (isreload) {
            skipvid = 0;
            _isLoadingVid = true;
            notifyListeners();
          }
          data['type'] = 'vid';
          data['skip'] = skipvid;
          break;
      }
      if (stories.peopleStoriesData == null) {
        stories.initialStories(context);
      }
      // if (isreload) {
      //   await stories.initialStories(context);
      // }

      final allContents = await reload(context, data);

      if (profileImage == '') {
        try {
          await profile.initMain(context, onUpdateProfile: true);
        } catch (e) {
          'profile.initMain error $e'.logger();
        }
      }

      isLoadingLoadmore = false;
      _isLoadingPict = false;
      _isLoadingDiary = false;
      _isLoadingVid = false;
      notifyListeners();
      switch (index) {
        case 0:
          if (!mounted) return;
          await pic.initialPic(context, reload: isreload || isNew, list: allContents).then((value) async {
            if (diary.diaryData == null) {
              await initNewHome(context, mounted, forceIndex: 1);
              // diary.initialDiary(context, reload: isreload || isNew, list: allContents);
            }
            if (vid.vidData == null) {
              // vid.initialVid(context, reload: isreload || isNew, list: allContents);
              await initNewHome(context, mounted, forceIndex: 2);
            }
          });
          break;
        case 1:
          if (!mounted) return;
          await diary.initialDiary(context, reload: isreload || isNew, list: allContents);
          break;
        case 2:
          if (!mounted) return;
          await vid.initialVid(context, reload: isreload || isNew, list: allContents);
          break;
      }
    }
  }

  Future initHome(BuildContext context, bool mounted) async {
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

      await CheckVersion().check(context, fetch.version, fetch.versionIos);

      return res;
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

  void onDeleteSelfPostContent(BuildContext context, {required String postID, required String content}) {
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
        stories.myStoriesData?.removeWhere((element) => element.postID == postID);
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
  }) {
    ContentData? _updatedData;
    ContentData? _updatedData2;
    final vid = Provider.of<PreviewVidNotifier>(context, listen: false);
    final vid2 = Provider.of<VidDetailNotifier>(context, listen: false);
    final diary = Provider.of<PreviewDiaryNotifier>(context, listen: false);
    final pic = Provider.of<PreviewPicNotifier>(context, listen: false);
    final pic2 = Provider.of<SlidedPicDetailNotifier>(context, listen: false);
    final stories = Provider.of<PreviewStoriesNotifier>(context, listen: false);

    switch (content) {
      case hyppeVid:
        _updatedData = vid.vidData?.firstWhereOrNull((element) => element.postID == postID);
        _updatedData2 = vid2.data;
        break;
      case hyppeDiary:
        _updatedData = diary.diaryData?.firstWhereOrNull((element) => element.postID == postID);
        break;
      case hyppePic:
        _updatedData = pic.pic?.firstWhereOrNull((element) => element.postID == postID);
        _updatedData2 = pic2.data;
        break;
      case hyppeStory:
        _updatedData = stories.myStoriesData?.firstWhereOrNull((element) => element.postID == postID);
        break;
      default:
        "$content It's Not a content of $postID".logger();
        break;
    }

    if (_updatedData != null) {
      _updatedData.tags = tags;
      _updatedData.description = description;
      _updatedData.allowComments = allowComment;
      _updatedData.visibility = visibility;
      _updatedData.location = location;
      _updatedData.saleAmount = num.parse(saleAmount != null
          ? saleAmount != ''
              ? saleAmount
              : '0'
          : '0');
      _updatedData.saleLike = saleLike;
      _updatedData.saleView = saleView;
      _updatedData.cats = [];
      _updatedData.tagPeople = [];
      _updatedData.isShared = isShared;
      // _updatedData.tagPeople = tagPeople;
      _updatedData.tagPeople?.addAll(tagPeople ?? []);
      if (cats != null) {
        for (var v in cats) {
          _updatedData.cats?.add(
            Cats(
              id: v,
              // interestName: v,
            ),
          );
        }
      }
      if (_updatedData2 != null) {
        _updatedData2.tags = tags;
        _updatedData2.description = description;
        _updatedData2.allowComments = allowComment;
        _updatedData2.visibility = visibility;
        _updatedData2.location = location;
        _updatedData2.saleAmount = num.parse(saleAmount != null
            ? saleAmount != ''
                ? saleAmount
                : '0'
            : '0');
        _updatedData2.saleLike = saleLike;
        _updatedData2.saleView = saleView;
        _updatedData2.cats = [];
        _updatedData2.tagPeople = [];
        // _updatedData2.tagPeople = tagPeople;
        _updatedData2.tagPeople!.addAll(tagPeople ?? []);
        if (cats != null) {
          for (var v in cats) {
            _updatedData2.cats!.add(
              Cats(
                id: v,
                // interestName: v,
              ),
            );
          }
        }
      }
      '${_updatedData.cats?.length}'.logger();
    }

    notifyListeners();
  }

  void onReport(BuildContext context, {required String postID, required String content, bool? isReport}) {
    ContentData? _updatedData;
    ContentData? _updatedData2;
    final vid = Provider.of<PreviewVidNotifier>(context, listen: false);
    final diary = Provider.of<PreviewDiaryNotifier>(context, listen: false);
    final pic = Provider.of<PreviewPicNotifier>(context, listen: false);
    final pic2 = Provider.of<SlidedPicDetailNotifier>(context, listen: false);
    final stories = Provider.of<PreviewStoriesNotifier>(context, listen: false);

    switch (content) {
      case hyppeVid:
        vid.vidData?.removeWhere((element) => element.postID == postID);
        // _updatedData = vid.vidData?.firstWhereOrNull((element) => element.postID == postID);
        break;
      case hyppeDiary:
        diary.diaryData?.removeWhere((element) => element.postID == postID);
        // _updatedData = diary.diaryData?.firstWhereOrNull((element) => element.postID == postID);
        break;
      case hyppePic:
        pic.pic?.removeWhere((element) => element.postID == postID);
        // _updatedData = pic.pic?.firstWhereOrNull((element) => element.postID == postID);
        // _updatedData = pic.pic?.firstWhereOrNull((element) => element.postID == postID);
        _updatedData2 = pic2.data;
        break;
      case hyppeStory:
        stories.peopleStoriesData?.removeWhere((element) => element.postID == postID);
        // _updatedData = stories.peopleStoriesData?.firstWhereOrNull((element) => element.postID == postID);
        break;
      default:
        "$content It's Not a content of $postID".logger();
        break;
    }

    // print('kesini story');
    // print(_updatedData);

    // if (_updatedData != null) {
    //   _updatedData.delete();
    //   // _updatedData.isReport = isReport;
    // }
    // if (_updatedData2 != null) {
    //   _updatedData2.delete();
    //   _updatedData2.isReport = isReport;
    // }

    notifyListeners();
  }

  void showContentSensitive(BuildContext context, {required String postID, required String content, bool? isReport}) {
    ContentData? _updatedData;
    ContentData? _updatedData2;
    final vid = Provider.of<PreviewVidNotifier>(context, listen: false);
    final diary = Provider.of<PreviewDiaryNotifier>(context, listen: false);
    final pic = Provider.of<PreviewPicNotifier>(context, listen: false);
    final pic2 = Provider.of<SlidedPicDetailNotifier>(context, listen: false);
    final stories = Provider.of<PreviewStoriesNotifier>(context, listen: false);

    switch (content) {
      case hyppeVid:
        _updatedData = vid.vidData?.firstWhereOrNull((element) => element.postID == postID);
        break;
      case hyppeDiary:
        _updatedData = diary.diaryData?.firstWhereOrNull((element) => element.postID == postID);
        break;
      case hyppePic:
        // pic.pic?.removeWhere((element) => element.postID == postID);
        _updatedData = pic.pic?.firstWhereOrNull((element) => element.postID == postID);
        // _updatedData = pic2.data;
        break;
      case hyppeStory:
        _updatedData = stories.peopleStoriesData?.firstWhereOrNull((element) => element.postID == postID);
        break;
      default:
        "$content It's Not a content of $postID".logger();
        break;
    }

    if (_updatedData != null) {
      print('buka dong ${_updatedData.description}');
      print('${_updatedData.description}');
      _updatedData.reportedStatus = 'ALL';
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

    whenComplete
        ? Routing().move(Routes.selfProfile, argument: GeneralArgument(isTrue: true)).whenComplete(() => onWhenComplete)
        : Routing().move(Routes.selfProfile, argument: GeneralArgument(isTrue: true));
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
    ContentData? _updatedData;
    final vid = Provider.of<PreviewVidNotifier>(context, listen: false);
    final diary = Provider.of<PreviewDiaryNotifier>(context, listen: false);
    final pic = Provider.of<PreviewPicNotifier>(context, listen: false);
    final stories = Provider.of<PreviewStoriesNotifier>(context, listen: false);
    switch (content) {
      case hyppeVid:
        _updatedData = vid.vidData?.firstWhereOrNull((element) => element.postID == postID);
        break;
      case hyppeDiary:
        _updatedData = diary.diaryData?.firstWhereOrNull((element) => element.postID == postID);
        break;
      case hyppePic:
        _updatedData = pic.pic?.firstWhereOrNull((element) => element.postID == postID);
        break;
      case hyppeStory:
        _updatedData = stories.myStoriesData?.firstWhereOrNull((element) => element.postID == postID);
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
      _updatedData?.tagPeople?.removeWhere((element) => element.email == email);
    }

    notifyListeners();
  }

  Future getAdsApsara(BuildContext context, isInAppAds) async {
    print('ke iklan yah');
    final ads = await getPopUpAds(context);
    final id = ads.videoId;
    print('ke iklan yah $id');
    print('ke iklan yah ${ads.adsType}');
    if (id != null && ads.adsType != null) {
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
          final isShowAds = SharedPreference().readStorage(SpKeys.isShowPopAds);
          // if (!isShowAds) {
          System().adsPopUp(context, ads, auth, isInAppAds: isInAppAds);
          // }

          // widget.videoData?.fullContentPath = jsonMap['PlayUrl'];
        }
      } catch (e) {
        'Failed to fetch ads data ${e}'.logger();
      }
    }
  }

  Future<AdsData> getPopUpAds(BuildContext context) async {
    var data = AdsData();
    try {
      final notifier = AdsDataBloc();
      await notifier.appAdsBloc(context);
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
    String? parentID,
    int? indexComment,
    bool pageDetail = false,
  }) async {
    final vid = Provider.of<PreviewVidNotifier>(context, listen: false);
    final diary = Provider.of<PreviewDiaryNotifier>(context, listen: false);
    final pic = Provider.of<PreviewPicNotifier>(context, listen: false);

    ScrollVidNotifier vidScroll = context.read<ScrollVidNotifier>();
    ScrollDiaryNotifier diaryScroll = context.read<ScrollDiaryNotifier>();
    ScrollPicNotifier picScroll = context.read<ScrollPicNotifier>();

    ContentData? _updatedData;
    _updatedData = vid.vidData?.firstWhereOrNull((element) => element.postID == postID);
    _updatedData ??= diary.diaryData?.firstWhereOrNull((element) => element.postID == postID);
    _updatedData ??= pic.pic?.firstWhereOrNull((element) => element.postID == postID);

    // _updatedData ??= vidScroll.vidData?.firstWhereOrNull((element) => element.postID == postID);
    // _updatedData ??= diaryScroll.diaryData?.firstWhereOrNull((element) => element.postID == postID);
    // _updatedData ??= picScroll.pics?.firstWhereOrNull((element) => element.postID == postID);

    if (add) {
      Comment comment = Comment(txtMessages: txtMsg, userComment: UserComment(username: username));
      print("===-=-=-=-=- parentID ${parentID}");

      if (parentID == null) {
        if (pageDetail) {
          picScroll.pics?.forEach((e) {
            if (e.postID == postID) {
              e.comment?.insert(0, comment);
              e.comments = (e.comments ?? 0) + 1;
            }
          });
          vidScroll.vidData?.forEach((e) {
            if (e.postID == postID) {
              e.comment?.insert(0, comment);
              e.comments = (e.comments ?? 0) + 1;
            }
          });
          diaryScroll.diaryData?.forEach((e) {
            if (e.postID == postID) {
              e.comment?.insert(0, comment);
              e.comments = (e.comments ?? 0) + 1;
            }
          });
        } else {
          if (_updatedData?.comment == null) {
            _updatedData?.comment = [];
            _updatedData?.comment = [comment];
            notifyListeners();
          } else {
            _updatedData?.comment?.insert(0, comment);
            notifyListeners();
          }
          _updatedData?.comments = (_updatedData.comments ?? 0) + 1;
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
        _updatedData?.comments = (_updatedData.comments ?? 0) - (1 + totChild);
        if (parentID == null) {
          if (indexComment != null && _updatedData?.comment != null) {
            _updatedData?.comment?.removeAt(indexComment);
          }
        }
      }

      notifyListeners();
    }
  }
}
