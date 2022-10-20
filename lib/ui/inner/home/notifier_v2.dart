import 'package:hyppe/core/constants/utils.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/ui/inner/main/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/core/services/overlay_service/overlay_handler.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/stories/preview/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/preview/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/notifier.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:collection/collection.dart' show IterableExtension;

import '../../../core/bloc/posts_v2/bloc.dart';
import '../../../core/models/hive_box/boxes.dart';

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

  bool get isLoadingVid => _isLoadingVid;
  bool get isLoadingDiary => _isLoadingDiary;
  bool get isLoadingPict => _isLoadingPict;

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

  Future onRefresh(BuildContext context) async {
    bool isConnected = await System().checkConnections();
    if (isConnected) {
      _isLoadingVid = true;
      _isLoadingDiary = true;
      _isLoadingPict = true;
      int totLoading = 0;

      final profile = Provider.of<MainNotifier>(context, listen: false);
      final vid = Provider.of<PreviewVidNotifier>(context, listen: false);
      final diary = Provider.of<PreviewDiaryNotifier>(context, listen: false);
      final pic = Provider.of<PreviewPicNotifier>(context, listen: false);
      final stories = Provider.of<PreviewStoriesNotifier>(context, listen: false);

      // Refresh profile
      try {
        await profile.initMain(context, onUpdateProfile: true).then((value) => totLoading += 1);
      } catch (e) {
        print(e);
      }

      final allContents = await allReload(context);

      // Refresh content
      try {
        await stories.initialStories(context, list: allContents.story).then((value) => totLoading += 1);
      } catch (e) {
        print(e);
      }
      try {
        await vid.initialVid(context, reload: true, list: allContents.video).then((value) => totLoading += 1);
      } catch (e) {
        print(e);
      }
      try {
        await diary.initialDiary(context, reload: true, list: allContents.diary).then((value) => totLoading += 1);
      } catch (e) {
        print(e);
      }
      try {
        await pic.initialPic(context, reload: true, list: allContents.pict).then((value) => totLoading += 1);
      } catch (e) {
        print(e);
      }


      if (totLoading >= 3) {
        print("is finish shimmer");
        _isLoadingVid = false;
        _isLoadingDiary = false;
        _isLoadingPict = false;
      }

      notifyListeners();
    } else {
      ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
        Routing().moveBack();
        onRefresh(context);
      });
    }
    // isHaveSomethingNew = false;
  }

  Future<AllContents> allReload(BuildContext context, {bool myContent = false, bool otherContent = false}) async {
    AllContents? res;
    final notifierMain = Provider.of<HomeNotifier>(context, listen: false);
    print('ambil semua data ${notifierMain.visibilty}');
    const page = 0;
    try {
      final notifier = PostsBloc();

      await notifier.getAllContentsBlocV2(context, pageNumber: page, visibility: notifierMain.visibilty, myContent: myContent, otherContent: otherContent);
      final fetch = notifier.postsFetch;
      '${AllContents.fromJson(fetch.data).toJson()}'.logger();
      res = AllContents.fromJson(fetch.data);
      return res;
    } catch (e) {
      '$e'.logger();
      rethrow;
    }
  }

  bool _availableToHitAgain(AllContents all, int limit) {
    if ((all.story?.length ?? 0) < limit) {
      return true;
    }
    if ((all.diary?.length ?? 0) < limit) {
      return true;
    }
    if ((all.video?.length ?? 0) < limit) {
      return true;
    }
    if ((all.pict?.length ?? 0) < limit) {
      return true;
    }

    return false;
  }

  void onDeleteSelfPostContent(BuildContext context, {required String postID, required String content}) {
    final vid = Provider.of<PreviewVidNotifier>(context, listen: false);
    final diary = Provider.of<PreviewDiaryNotifier>(context, listen: false);
    final pic = Provider.of<PreviewPicNotifier>(context, listen: false);
    final stories = Provider.of<PreviewStoriesNotifier>(context, listen: false);
    switch (content) {
      case hyppeVid:
        vid.vidData!.removeWhere((element) => element.postID == postID);
        break;
      case hyppeDiary:
        diary.diaryData!.removeWhere((element) => element.postID == postID);
        break;
      case hyppePic:
        pic.pic!.removeWhere((element) => element.postID == postID);
        break;
      case hyppeStory:
        stories.myStoriesData!.removeWhere((element) => element.postID == postID);
        break;
      default:
        "$content It's Not a content of $postID".logger();
        break;
    }
    notifyListeners();
  }

  void onUpdateSelfPostContent(BuildContext context,
      {required String postID,
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
      bool? saleLike,
      bool? saleView}) {
    ContentData? _updatedData;
    final vid = Provider.of<PreviewVidNotifier>(context, listen: false);
    final diary = Provider.of<PreviewDiaryNotifier>(context, listen: false);
    final pic = Provider.of<PreviewPicNotifier>(context, listen: false);
    final stories = Provider.of<PreviewStoriesNotifier>(context, listen: false);

    switch (content) {
      case hyppeVid:
        _updatedData = vid.vidData!.firstWhereOrNull((element) => element.postID == postID);
        break;
      case hyppeDiary:
        _updatedData = diary.diaryData!.firstWhereOrNull((element) => element.postID == postID);
        break;
      case hyppePic:
        _updatedData = pic.pic!.firstWhereOrNull((element) => element.postID == postID);
        break;
      case hyppeStory:
        _updatedData = stories.myStoriesData!.firstWhereOrNull((element) => element.postID == postID);
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
      _updatedData.saleAmount = num.parse(saleAmount!);
      _updatedData.saleLike = saleLike;
      _updatedData.saleView = saleView;
      _updatedData.cats = [];
      _updatedData.tagPeople = [];
      // _updatedData.tagPeople = tagPeople;
      _updatedData.tagPeople!.addAll(tagPeople!);
      if (cats != null) {
        for (var v in cats) {
          _updatedData.cats!.add(
            Cats(
              interestName: v,
            ),
          );
        }
      }
      print(_updatedData.cats!.length);
    }

    notifyListeners();
  }

  Future navigateToProfilePage(BuildContext context, {bool whenComplete = false, Function? onWhenComplete}) async {
    if (context.read<OverlayHandlerProvider>().overlayActive) context.read<OverlayHandlerProvider>().removeOverlay(context);
    whenComplete ? Routing().move(Routes.selfProfile).whenComplete(() => onWhenComplete) : Routing().move(Routes.selfProfile);
  }

  Future navigateToWallet(BuildContext context) async {
    if (context.read<SelfProfileNotifier>().user.profile != null) {
      if (context.read<SelfProfileNotifier>().user.profile!.isComplete!) {
        // context.read<WalletNotifier>().syncToDana(fromHome: true);
        ShowBottomSheet.onComingSoonDoku(context);
      } else {
        ShowBottomSheet.onShowIDVerification(context);
      }
    } else {
      ShowBottomSheet.onShowSomethingWhenWrong(context);
    }
  }

  //untuk test aliplayer
  Future navigateToTestAliPlayer(BuildContext context, {bool whenComplete = false, Function? onWhenComplete}) async {
    if (context.read<OverlayHandlerProvider>().overlayActive) context.read<OverlayHandlerProvider>().removeOverlay(context);
    whenComplete ? Routing().move(Routes.testAliPlayer).whenComplete(() => onWhenComplete) : Routing().move(Routes.testAliPlayer);
  }

  bool pickedVisibility(String? tile) {
    notifyListeners();
    if (_visibilty.contains(tile!)) {
      return true;
    } else {
      return false;
    }
  }

  void changeVisibility(BuildContext context, index) {
    _visibilty = _visibiltyList[index]['code'];
    _visibilitySelect = _visibiltyList[index]['code'];
    onRefresh(context);

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
        _updatedData = vid.vidData!.firstWhereOrNull((element) => element.postID == postID);
        break;
      case hyppeDiary:
        _updatedData = diary.diaryData!.firstWhereOrNull((element) => element.postID == postID);
        break;
      case hyppePic:
        _updatedData = pic.pic!.firstWhereOrNull((element) => element.postID == postID);
        break;
      case hyppeStory:
        _updatedData = stories.myStoriesData!.firstWhereOrNull((element) => element.postID == postID);
        break;
      default:
        "$content It's Not a content of $postID".logger();
        break;
    }

    final index = vid.vidData!.indexWhere((element) => element.postID == postID);
    print(vid.vidData![index].tagPeople!.length);
    vid.vidData![index].tagPeople?.removeWhere((element) => element.email == email);
    vid.vidData![index].description = 'asdaksdjha jsd';

    print(vid.vidData![index].tagPeople!.length);
    _updatedData!.tagPeople!.removeWhere((element) => element.email == email);

    notifyListeners();
  }
}
