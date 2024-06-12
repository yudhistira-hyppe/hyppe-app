import 'package:hyppe/core/constants/kyc_status.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/models/combination_v2/get_user_profile.dart';
import 'package:hyppe/core/services/fcm_service.dart';
import 'package:hyppe/core/services/stream_service.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/other_profile/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/stories/playlist/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/notifier.dart';
import 'package:hyppe/ui/inner/main/notifier.dart';
import 'package:hyppe/ui/inner/search_v2/notifier.dart';
import 'package:hyppe/ui/outer/sign_up/contents/user_interest/user_interest_notifier.dart';
import 'package:hyppe/ui/outer/welcome_login/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:hyppe/core/bloc/user_v2/bloc.dart';

import 'package:hyppe/core/services/error_service.dart';
import 'package:hyppe/core/services/event_service.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/services/google_sign_in_service.dart';
import 'package:hyppe/ui/constant/entities/loading/notifier.dart';
import 'package:hyppe/ui/inner/home/notifier_v2.dart';
import 'package:hyppe/ui/inner/notification/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/stories/preview/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/preview/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/notifier.dart';

class SettingNotifier extends ChangeNotifier with LoadingNotifier {
  final _routing = Routing();
  final _eventService = EventService();
  final _streamService = StreamService();
  final _googleSignInService = GoogleSignInService();

  String? appPackage = "";

  Future logOut(BuildContext context) async {
    '--> setting/setting_notifier.dart logOut:isLoading ${isLoading}'.logger();
    // if (!isLoading) {
    setLoading(true);
    final notifier = UserBloc();
    context.read<SelfProfileNotifier>().user.profile = null;
    context.read<TransactionNotifier>().accountBalance = null;
    context.read<HomeNotifier>().profileImage = '';
    final vid = Provider.of<PreviewVidNotifier>(Routing.navigatorKey.currentContext ?? context, listen: false);
    final diary = Provider.of<PreviewDiaryNotifier>(Routing.navigatorKey.currentContext ?? context, listen: false);
    final pic = Provider.of<PreviewPicNotifier>(Routing.navigatorKey.currentContext ?? context, listen: false);
    final stories = Provider.of<PreviewStoriesNotifier>(Routing.navigatorKey.currentContext ?? context, listen: false);
    stories.storiesGroups = [];
    vid.vidData = null;
    diary.diaryData = null;
    pic.pic = null;
    _resetData(context);
    await notifier.logOut(context, withAlertMessage: false);
    setLoading(false);

    // final fetch = notifier.userFetch;
    // if (fetch.userState == UserState.logoutSuccess) {
    //   _resetData(context);
    // }
    // }
  }

  void _resetData(BuildContext context) async {
    try {
      _routing.moveAndRemoveUntil(Routes.welcomeLogin, Routes.lobby);

      await _googleSignInService.handleSignOut();
      await SharedPreference().logOutStorage();

      context.read<SelfProfileNotifier>().user = UserInfoModel();
      context.read<SelfProfileNotifier>().onUpdate();
      context.read<OtherProfileNotifier>().user = UserInfoModel();
      context.read<OtherProfileNotifier>().manyUser = [];
      context.read<SearchNotifier>().allContents = UserInfoModel();
      context.read<HomeNotifier>().profileImage = '';
      context.read<HomeNotifier>().profileBadge = null;

      context.read<PreviewStoriesNotifier>().myStoriesData = null;
      context.read<PreviewStoriesNotifier>().peopleStoriesData = null;
      context.read<PreviewStoriesNotifier>().myStoryGroup = {};
      context.read<PreviewStoriesNotifier>().storiesGroups = [];
      context.read<PreviewStoriesNotifier>().otherStoryGroup = {};

      context.read<StoriesPlaylistNotifier>().groupUserStories = [];
      context.read<PreviewDiaryNotifier>().diaryData = null;
      context.read<PreviewDiaryNotifier>().onUpdate();
      context.read<PreviewVidNotifier>().vidData = null;
      context.read<PreviewPicNotifier>().pic = null;

      context.read<UserInterestNotifier>().interestData = [];
      context.read<NotificationNotifier>().resetNotificationData();
      context.read<ErrorService>().clearErrorData();
      context.read<HomeNotifier>().resetSessionID();
      context.read<TransactionNotifier>().dataTransaction = [];
      context.read<TransactionNotifier>().dataAllTransaction = [];
      context.read<TransactionNotifier>().dataAcccount = [];

      context.read<ChallangeNotifier>().achievementData = [];
      context.read<ChallangeNotifier>().badgeUser = null;

      context.read<MainNotifier>().tutorialData = [];
      context.read<MainNotifier>().receivedMsg = false;
      context.read<MainNotifier>().receivedReaction = false;
      FcmService().haveNotification = ValueNotifier(false);

      _eventService.cleanUp();
      _streamService.reset();
      context.read<WelcomeLoginNotifier>().signOutGoogle.handleSignOut();
    } catch (e) {
      'Reset Data Error: $e'.logger();
    }
  }

  @override
  void setLoading(bool val, {bool setState = true, Object? loadingObject}) {
    super.setLoading(val, loadingObject: loadingObject);
    if (setState) notifyListeners();
  }

  Future validateUser(context, TranslateNotifierV2 language) async {
    final userKyc = SharedPreference().readStorage(SpKeys.statusVerificationId);
    // final userPin = SharedPreference().readStorage(SpKeys.setPin);

    // if (userPin != 'true') {
    //   return ShowBottomSheet.onShowStatementPin(context, onCancel: () {}, onSave: () {
    //     Routing().moveAndPop(Routes.homePageSignInSecurity);
    //   }, title: language.translate.addYourHyppePinFirst, bodyText: language.translate.toAccessTransactionPageYouNeedToSetYourPin);
    // }

    if (userKyc != VERIFIED) {
      return ShowBottomSheet.onShowStatementPin(context, onCancel: () {}, onSave: () {
        Routing().moveAndPop(Routes.homePageSignInSecurity);
      }, title: language.translate.verificationYourIDFirst, bodyText: language.translate.toAccessTransactionPageYouNeedToVerificationYourID);
    }

    Routing().move(Routes.transaction);
  }

  Future validateUserGif(context, TranslateNotifierV2 language) async {
    final userKyc = SharedPreference().readStorage(SpKeys.statusVerificationId);
    if (userKyc != VERIFIED) {
      return ShowBottomSheet.onShowStatementPin(context, onCancel: () {}, onSave: () {
        Routing().moveAndPop(Routes.homePageSignInSecurity);
      }, title: language.translate.verificationYourIDFirst, bodyText: language.translate.toAccessTransactionPageYouNeedToVerificationYourID);
    }

    Routing().move(Routes.contentgift);
  }

  Future validateUserCoins(context, TranslateNotifierV2 language) async {
    final userKyc = SharedPreference().readStorage(SpKeys.statusVerificationId);
    if (userKyc != VERIFIED) {
      return ShowBottomSheet.onShowStatementPin(context, onCancel: () {}, onSave: () {
        Routing().moveAndPop(Routes.homePageSignInSecurity);
      }, title: language.translate.verificationYourIDFirst, bodyText: language.translate.toAccessTransactionPageYouNeedToVerificationYourID);
    }

    Routing().move(Routes.saldoCoins);
  }
}
