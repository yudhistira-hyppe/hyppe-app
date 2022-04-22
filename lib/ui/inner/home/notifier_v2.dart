import 'package:hyppe/core/constants/utils.dart';
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

class HomeNotifier with ChangeNotifier {
  LocalizationModelV2 language = LocalizationModelV2();
  translate(LocalizationModelV2 translate) {
    language = translate;
    notifyListeners();
  }

  // bool _isHaveSomethingNew = false;
  String? _sessionID;

  // bool get isHaveSomethingNew => _isHaveSomethingNew;
  String? get sessionID => _sessionID;

  // set isHaveSomethingNew(bool val) {
  //   _isHaveSomethingNew = val;
  //   notifyListeners();
  // }

  void setSessionID() {
    _sessionID ??= System().generateUUID();
  }

  void resetSessionID() {
    _sessionID = null;
  }

  void onUpdate() => notifyListeners();

  Future onRefresh(BuildContext context) async {
    bool isConnected = await System().checkConnections();
    if (isConnected) {
      final profile = Provider.of<MainNotifier>(context, listen: false);
      final vid = Provider.of<PreviewVidNotifier>(context, listen: false);
      final diary = Provider.of<PreviewDiaryNotifier>(context, listen: false);
      final pic = Provider.of<PreviewPicNotifier>(context, listen: false);
      final stories =
          Provider.of<PreviewStoriesNotifier>(context, listen: false);

      // Refresh profile
      try {
        profile.initMain(context, onUpdateProfile: true);
      } catch (e) {
        print(e);
      }
      // Refresh content
      try {
        stories.initialStories(context);
      } catch (e) {
        print(e);
      }
      try {
        vid.initialVid(context, reload: true);
      } catch (e) {
        print(e);
      }
      try {
        diary.initialDiary(context, reload: true);
      } catch (e) {
        print(e);
      }
      try {
        pic.initialPic(context, reload: true);
      } catch (e) {
        print(e);
      }
    } else {
      ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
        Routing().moveBack();
        onRefresh(context);
      });
    }
    // isHaveSomethingNew = false;
  }

  void onDeleteSelfPostContent(BuildContext context,
      {required String postID, required String content}) {
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
        stories.myStoriesData!
            .removeWhere((element) => element.postID == postID);
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
    required String description,
    required String visibility,
    required bool allowComment,
    required bool certified,
    List<String>? tags,
  }) {
    ContentData? _updatedData;
    final vid = Provider.of<PreviewVidNotifier>(context, listen: false);
    final diary = Provider.of<PreviewDiaryNotifier>(context, listen: false);
    final pic = Provider.of<PreviewPicNotifier>(context, listen: false);
    final stories = Provider.of<PreviewStoriesNotifier>(context, listen: false);

    switch (content) {
      case hyppeVid:
        _updatedData = vid.vidData!
            .firstWhereOrNull((element) => element.postID == postID);
        break;
      case hyppeDiary:
        _updatedData = diary.diaryData!
            .firstWhereOrNull((element) => element.postID == postID);
        break;
      case hyppePic:
        _updatedData =
            pic.pic!.firstWhereOrNull((element) => element.postID == postID);
        break;
      case hyppeStory:
        _updatedData = stories.myStoriesData!
            .firstWhereOrNull((element) => element.postID == postID);
        break;
      default:
        "$content It's Not a content of $postID".logger();
        break;
    }

    if (_updatedData != null) {
      _updatedData.tags = tags;
      _updatedData.description = description;
      _updatedData.allowComments = allowComment;
    }

    notifyListeners();
  }

  Future navigateToProfilePage(BuildContext context,
      {bool whenComplete = false, Function? onWhenComplete}) async {
    if (context.read<OverlayHandlerProvider>().overlayActive)
      context.read<OverlayHandlerProvider>().removeOverlay(context);
    whenComplete
        ? Routing().move(Routes.selfProfile).whenComplete(() => onWhenComplete)
        : Routing().move(Routes.selfProfile);
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
}
