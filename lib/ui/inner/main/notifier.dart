import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hyppe/core/bloc/user_v2/bloc.dart' as userV2;
import 'package:hyppe/core/bloc/user_v2/state.dart';
import 'package:hyppe/core/bloc/utils_v2/bloc.dart';
import 'package:hyppe/core/bloc/utils_v2/state.dart';
import 'package:hyppe/core/config/env.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/models/collection/message_v2/message_data_v2.dart';
import 'package:hyppe/core/models/collection/utils/reaction/reaction.dart';
import 'package:hyppe/core/services/event_service.dart';
import 'package:hyppe/core/services/fcm_service.dart';
import 'package:hyppe/core/services/notification_service.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/services/socket_service.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/screen.dart';
import 'package:hyppe/ui/inner/home/notifier_v2.dart';
import 'package:hyppe/ui/inner/home/screen.dart';
import 'package:hyppe/ui/inner/notification/screen.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/inner/search_v2/screen.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:wakelock/wakelock.dart';

class MainNotifier with ChangeNotifier {

  GlobalKey<NestedScrollViewState> _globalKey = GlobalKey();
  GlobalKey<NestedScrollViewState> get globalKey => _globalKey;
  set globalKey(val) {
    _globalKey = val;
    notifyListeners();
  }

  final _eventService = EventService();
  SocketService get socketService => _socketService;

  final _socketService = SocketService();

  Reaction? _reactionData;

  Reaction? get reactionData => _reactionData;

  bool _openValidationIDCamera = false;
  bool get openValidationIDCamera => _openValidationIDCamera;
  Timer? countdownTimer;
  Duration myDuration = const Duration(minutes: 1);

  ScrollController _scrollController = ScrollController();
  ScrollController get scrollController => _scrollController;
  set scrollController(val) {
    _scrollController = val;
    notifyListeners();
  }

  set openValidationIDCamera(bool val) {
    _openValidationIDCamera = val;
    notifyListeners();
  }

  set reactionData(Reaction? val) {
    _reactionData = val;
    notifyListeners();
  }

  Future initMain(BuildContext context, {bool onUpdateProfile = false, bool isInitSocket = false, bool updateProfilePict = false}) async {
    // Connect to socket
    if (isInitSocket) {
      _connectAndListenToSocket();
      _connectAndListenToSocketAds();
    }
    // _pageIndex = 0;

    // Auto follow user if app is install from a dynamic link
    // DynamicLinkService.followSender(context);

    // final onlineVersion = SharedPreference().readStorage(SpKeys.onlineVersion);
    // await CheckVersion().check(context, onlineVersion);

    if (!onUpdateProfile) {
      // context.read<HomeNotifier>().getAdsApsara(context, false);

      final utilsNotifier = UtilsBlocV2();
      await utilsNotifier.getReactionBloc(context);
      final utilsFetch = utilsNotifier.utilsFetch;
      if (utilsFetch.utilsState == UtilsState.getReactionSuccess) {
        reactionData = utilsFetch.data;
      }
    }
    final usersNotifier = userV2.UserBloc();
    await usersNotifier.getUserProfilesBloc(context, withAlertMessage: true);
    var keyImageCache = key(onUpdateProfile, updateProfilePict);
    print("image key $keyImageCache");
    final usersFetch = usersNotifier.userFetch;
    if (usersFetch.userState == UserState.getUserProfilesSuccess) {
      var selfProfile = context.read<SelfProfileNotifier>();
      selfProfile.user.profile = usersFetch.data;
      selfProfile.user.profile?.avatar?.imageKey = keyImageCache;

      selfProfile.onUpdate();
      print(selfProfile.user.profile?.bio);
      print("profile?.avatar ${selfProfile.user.profile?.avatar?.imageKey}");
      context.read<SelfProfileNotifier>().user.profile = usersFetch.data;
      context.read<HomeNotifier>().profileImage = context.read<SelfProfileNotifier>().user.profile?.avatar?.mediaEndpoint ?? '';
      context.read<HomeNotifier>().profileBadge = context.read<SelfProfileNotifier>().user.profile?.urluserBadge;
      // context.read<HomeNotifier>().profileImageKey = context.read<SelfProfileNotifier>().user.profile?.avatar?.imageKey ?? '';
      context.read<HomeNotifier>().profileImageKey = keyImageCache;

      // Provider.of<SelfProfileNotifier>(context, listen: false).user.profile = usersFetch.data;

      System().userVerified(selfProfile.user.profile?.statusKyc);
      SharedPreference().writeStorage(SpKeys.setPin, selfProfile.user.profile?.pinVerified.toString());
      // SharedPreference().writeStorage(SpKeys.statusVerificationId, 'sdsd')asdasd
      notifyListeners();
    }

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_openValidationIDCamera) {
        takeSelfie(context);
      }
    });
  }

  String key(bool onUpdateProfile, bool updateProfilePict) {
    var uniq = SharedPreference().readStorage(SpKeys.uniqueKey);
    print('ini ke key $uniq');
    print('ini ke key $updateProfilePict');
    if (uniq == null) {
      uniq = UniqueKey().toString();
      SharedPreference().writeStorage(SpKeys.uniqueKey, uniq);
      return uniq;
    } else {
      if (onUpdateProfile && updateProfilePict) {
        uniq = UniqueKey().toString();
        SharedPreference().writeStorage(SpKeys.uniqueKey, uniq);
      }
      return uniq;
    }
  }

  Future getReaction(BuildContext context) async {
    final utilsNotifier = UtilsBlocV2();
    await utilsNotifier.getReactionBloc(context);
    final utilsFetch = utilsNotifier.utilsFetch;
    if (utilsFetch.utilsState == UtilsState.getReactionSuccess) {
      reactionData = utilsFetch.data;
    }
  }

  Widget mainScreen(BuildContext context, bool canShowAds) {
    List pages = [
      HomeScreen(
        canShowAds: canShowAds,
      ),
      SearchScreen(),
      NotificationScreen(),
      const SelfProfileScreen()
    ];
    late Widget screen;

    switch (pageIndex) {
      case 0:
        return screen = pages[0];
      case 1:
        return screen = pages[1];
      case 3:
        {
          setNotification();
          screen = pages[2];
        }
        break;
      case 4:
        return screen = pages[3];
    }
    return screen;
  }

  int _pageIndex = 0;
  int get pageIndex => _pageIndex;
  set pageIndex(int val) {
    if (val != _pageIndex) {
      _pageIndex = val;
      notifyListeners();
    }
  }

  setPageIndex(int index){
    _pageIndex = index;
  }

  void setNotification() => FcmService().setHaveNotification(false);

  Future onShowPostContent(BuildContext context) async {
    // System().actionReqiredIdCard(context,
    //    action: () => ShowBottomSheet.onUploadContent(context));
    await ShowBottomSheet.onUploadContent(context);
    //ShowBottomSheet.onShowSuccessPostContentOwnership(context);
  }

  bool _receivedMsg = false;
  bool get receivedMsg => _receivedMsg;
  set receivedMsg(bool state) {
    _receivedMsg = state;
    notifyListeners();
  }

  bool _receivedReaction = false;
  bool get receivedReaction => _receivedReaction;
  set receivedReaction(bool state) {
    _receivedReaction = state;
    notifyListeners();
  }

  void _connectAndListenToSocket() async {
    String? token = SharedPreference().readStorage(SpKeys.userToken);
    String? email = SharedPreference().readStorage(SpKeys.email);

    if (_socketService.isRunning) {
      _socketService.closeSocket();
    }

    _socketService.connectToSocket(
      () {
        _socketService.events(
          SocketService.eventDiscuss,
          // '2b595aa7-f3d2-0a76-dd91-9bcec1d10098',
          (message) {
            print('ini message dari socket');
            message.logger();
            try {
              final msgData = MessageDataV2.fromJson(json.decode('$message'));
              print('ini message dari socket ${msgData.disqusID}');
              if (token != null) {
                if (msgData.disqusLogs[0].receiver == email) {
                  NotificationService().showNotification(
                      RemoteMessage(
                        notification: RemoteNotification(
                          title: "${msgData.disqusLogs[0].username}",
                          // title: "${msgData.username}",
                          body: msgData.fcmMessage ?? msgData.disqusLogs.firstOrNull?.txtMessages ?? '',
                        ),
                        data: msgData.toJson(),
                      ),
                      data: msgData);

                  if (msgData.type == 'REACTION') {
                    receivedReaction = true;
                    receivedMsg = true;
                  } else {
                    receivedMsg = true;
                  }

                  _eventService.notifyMessageReceived(msgData);
                }
              }
            } catch (e) {
              e.toString().logger();
            }
          },
        );
      },
      host: Env.data.baseUrl,
      options: OptionBuilder()
          .setAuth({
            "x-auth-user": "$email",
            "x-auth-token": "$token",
          })
          .setTransports(
            ['websocket'],
          )
          .setPath('${Env.data.versionApi}/socket.io')
          .disableAutoConnect()
          .build(),
    );
  }

  void _connectAndListenToSocketAds() async {
    String? token = SharedPreference().readStorage(SpKeys.userToken);
    String? email = SharedPreference().readStorage(SpKeys.email);

    if (_socketService.isRunning) {
      _socketService.closeSocket();
    }

    _socketService.connectToSocket(
      () {
        _socketService.events(
          SocketService.eventAds,
          // '2b595aa7-f3d2-0a76-dd91-9bcec1d10098',
          (message) {
            print('ini message dari socket');
            message.logger();
            try {
              final msgData = MessageDataV2.fromJson(json.decode('$message'));
              print('ini message dari socket ${msgData.disqusID}');
              if (msgData.disqusLogs[0].receiver == email) {
                NotificationService().showNotification(
                    RemoteMessage(
                      notification: RemoteNotification(
                        // title: "@${msgData.disqusLogs[0].senderInfo?.fullName}",
                        title: "${msgData.username}",
                        body: msgData.fcmMessage ?? msgData.disqusLogs.firstOrNull?.txtMessages ?? '',
                      ),
                      data: msgData.toJson(),
                    ),
                    data: msgData);
                _eventService.notifyMessageReceived(msgData);
              }
            } catch (e) {
              e.toString().logger();
            }
          },
        );
      },
      host: Env.data.baseUrl,
      options: OptionBuilder()
          .setAuth({
            "x-auth-user": "$email",
            "x-auth-token": "$token",
          })
          .setTransports(
            ['websocket'],
          )
          .setPath('${Env.data.versionApi}socket.io')
          .disableAutoConnect()
          .build(),
    );
  }

  Future takeSelfie(BuildContext context) async {
    _openValidationIDCamera = false;
    Routing().move(Routes.verificationIDStep1);
    // final _statusPermission = await System().requestPrimaryPermission(context);
    // final _makeContentNotifier = Provider.of<MakeContentNotifier>(context, listen: false);
    // if (_statusPermission) {
    //   _makeContentNotifier.featureType = null;
    //   _makeContentNotifier.isVideo = false;

    //   // Routing().move(Routes.makeContent);
    // } else {
    //   return ShowGeneralDialog.permanentlyDeniedPermission(context);
    // }
  }

  void startTimer() {
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) => setCountDown());
  }

  void stopTimer() {
    countdownTimer!.cancel();
    notifyListeners();
  }

  void resetTimer() {
    stopTimer();
    myDuration = const Duration(minutes: 1);
  }

  void setCountDown() {
    const reduceSecondsBy = 1;
    final seconds = myDuration.inSeconds - reduceSecondsBy;
    if (seconds < 0) {
      resetTimer();
      'seconds of the timer : $seconds'.logger();
    } else {
      myDuration = Duration(seconds: seconds);
    }
  }

  bool _isInactiveState = false;
  bool get isInactiveState => _isInactiveState;
  set isInactiveState(bool state) {
    _isInactiveState = state;
    notifyListeners();
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
    if (await Wakelock.enabled) Wakelock.disable();
  }

  void initWakelockTimer({required Function() onShowInactivityWarning}) async {
    "=================== init wakelock".logger();
    if (!(await Wakelock.enabled)) Wakelock.enable();
    if (_inactivityTimer != null) _inactivityTimer?.cancel();
    _inactivityTimer = Timer(const Duration(seconds: 30), () => onShowInactivityWarning());
  }
}
