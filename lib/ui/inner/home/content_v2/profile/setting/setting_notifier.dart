import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hyppe/core/models/combination_v2/get_user_profile.dart';
import 'package:hyppe/core/services/stream_service.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/other_profile/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/notifier.dart';
import 'package:hyppe/ui/inner/search_v2/notifier.dart';
import 'package:hyppe/ui/outer/login/notifier.dart';
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
    if (!isLoading) {
      setLoading(true);
      final notifier = UserBloc();
      _resetData(context);
      await notifier.logOut(context, withAlertMessage: false);
      setLoading(false);

      // final fetch = notifier.userFetch;
      // if (fetch.userState == UserState.logoutSuccess) {
      //   _resetData(context);
      // }
    }
  }

  void _resetData(BuildContext context) async {
    _routing.moveAndRemoveUntil(Routes.welcomeLogin, Routes.lobby);

    await _googleSignInService.handleSignOut();
    await SharedPreference().logOutStorage();

    context.read<SelfProfileNotifier>().user = UserInfoModel();
    context.read<OtherProfileNotifier>().user = UserInfoModel();
    context.read<SearchNotifier>().allContents = UserInfoModel();

    context.read<PreviewStoriesNotifier>().myStoriesData = null;
    context.read<PreviewStoriesNotifier>().peopleStoriesData = null;
    context.read<PreviewDiaryNotifier>().diaryData = null;
    context.read<PreviewVidNotifier>().vidData = null;
    context.read<PreviewPicNotifier>().pic = null;

    context.read<UserInterestNotifier>().interestData = [];
    context.read<NotificationNotifier>().resetNotificationData();
    context.read<ErrorService>().clearErrorData();
    context.read<HomeNotifier>().resetSessionID();
    context.read<TransactionNotifier>().dataTransaction = [];
    context.read<TransactionNotifier>().dataAllTransaction = [];
    context.read<TransactionNotifier>().dataAcccount = [];
    _eventService.cleanUp();
    _streamService.reset();
    context.read<WelcomeLoginNotifier>().signOutGoogle.handleSignOut();
  }

  @override
  void setLoading(bool val, {bool setState = true, Object? loadingObject}) {
    super.setLoading(val, loadingObject: loadingObject);
    if (setState) notifyListeners();
  }
}
