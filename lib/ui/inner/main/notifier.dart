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
import 'package:hyppe/core/services/dynamic_link_service.dart';
import 'package:hyppe/core/services/event_service.dart';
import 'package:hyppe/core/services/fcm_service.dart';
import 'package:hyppe/core/services/notification_service.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/services/socket_service.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/notifier.dart';
import 'package:hyppe/ui/inner/home/notifier_v2.dart';
import 'package:hyppe/ui/inner/home/screen.dart';
import 'package:hyppe/ui/inner/message_v2/screen.dart';
import 'package:hyppe/ui/inner/notification/screen.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/inner/search_v2/screen.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart';

class MainNotifier with ChangeNotifier {
  final _eventService = EventService();
  SocketService get socketService => _socketService;

  final _socketService = SocketService();

  Reaction? _reactionData;

  Reaction? get reactionData => _reactionData;

  bool _openValidationIDCamera = false;
  bool get openValidationIDCamera => _openValidationIDCamera;
  Timer? countdownTimer;
  Duration myDuration = const Duration(minutes: 1);

  set openValidationIDCamera(bool val) {
    _openValidationIDCamera = val;
    notifyListeners();
  }

  set reactionData(Reaction? val) {
    _reactionData = val;
    notifyListeners();
  }

  Future initMain(BuildContext context, {bool onUpdateProfile = false, bool isInitSocket = false}) async {
    // Connect to socket
    if (isInitSocket) {
      _connectAndListenToSocket();
    }

    // Auto follow user if app is install from a dynamic link
    DynamicLinkService.followSender(context);

    // final onlineVersion = SharedPreference().readStorage(SpKeys.onlineVersion);
    // await CheckVersion().check(context, onlineVersion);

    if (!onUpdateProfile) {
      final utilsNotifier = UtilsBlocV2();
      await utilsNotifier.getReactionBloc(context);
      final utilsFetch = utilsNotifier.utilsFetch;
      if (utilsFetch.utilsState == UtilsState.getReactionSuccess) {
        reactionData = utilsFetch.data;
      }
    }
    final usersNotifier = userV2.UserBloc();
    await usersNotifier.getUserProfilesBloc(context, withAlertMessage: true);
    final usersFetch = usersNotifier.userFetch;
    if (usersFetch.userState == UserState.getUserProfilesSuccess) {
      context.read<SelfProfileNotifier>().user.profile = usersFetch.data;
      context.read<HomeNotifier>().profileImage = context.read<SelfProfileNotifier>().user.profile?.avatar?.mediaEndpoint ?? '';
      // Provider.of<SelfProfileNotifier>(context, listen: false).user.profile = usersFetch.data;
      final _profile = context.read<SelfProfileNotifier>().user.profile;
      System().userVerified(_profile?.statusKyc);
      SharedPreference().writeStorage(SpKeys.setPin, _profile?.pinVerified.toString());
      // SharedPreference().writeStorage(SpKeys.statusVerificationId, 'sdsd')asdasd
      notifyListeners();
    }

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_openValidationIDCamera) {
        takeSelfie(context);
      }
    });
  }

  Future getReaction(BuildContext context) async {
    final utilsNotifier = UtilsBlocV2();
    await utilsNotifier.getReactionBloc(context);
    final utilsFetch = utilsNotifier.utilsFetch;
    if (utilsFetch.utilsState == UtilsState.getReactionSuccess) {
      reactionData = utilsFetch.data;
    }
  }

  Widget mainScreen(BuildContext context) {
    List pages = [const HomeScreen(), SearchScreen(), NotificationScreen(), MessageScreen()];
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

  void setNotification() => FcmService().setHaveNotification(false);

  Future onShowPostContent(BuildContext context) async {
    // System().actionReqiredIdCard(context,
    //    action: () => ShowBottomSheet.onUploadContent(context));
    await ShowBottomSheet.onUploadContent(context);
    //ShowBottomSheet.onShowSuccessPostContentOwnership(context);
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
              if (msgData.disqusLogs[0].receiver == email) {
                NotificationService().showNotification(
                    RemoteMessage(
                      notification: RemoteNotification(
                        // title: "@${msgData.disqusLogs[0].senderInfo?.fullName}",
                        title: "${msgData.username}",
                        body: msgData.disqusLogs.firstOrNull?.txtMessages ?? '',
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
          .setPath('/v4/socket.io')
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
}
