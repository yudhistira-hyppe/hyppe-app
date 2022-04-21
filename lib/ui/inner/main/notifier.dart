import 'dart:convert';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hyppe/core/bloc/user_v2/bloc.dart' as userV2;
import 'package:hyppe/core/bloc/user_v2/state.dart';
import 'package:hyppe/core/bloc/utils_v2/bloc.dart';
import 'package:hyppe/core/bloc/utils_v2/state.dart';
import 'package:hyppe/core/config/env.dart';
import 'package:hyppe/core/config/url_constants.dart';
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
import 'package:hyppe/ui/inner/home/screen.dart';
import 'package:hyppe/ui/inner/message_v2/screen.dart';
// import 'package:hyppe/ui/inner/notification_v2/screen.dart';
import 'package:hyppe/ui/inner/notification/screen.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/inner/search_v2/screen.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart';

class MainNotifier with ChangeNotifier {
  final _eventService = EventService();
  SocketService get socketService => _socketService;

  final _socketService = SocketService();

  Reaction? _reactionData;

  Reaction? get reactionData => _reactionData;

  set reactionData(Reaction? val) {
    _reactionData = val;
    notifyListeners();
  }

  Future initMain(
    BuildContext context, {
    bool onUpdateProfile = false,
  }) async {
    // Connect to socket
    _connectAndListenToSocket();

    // Auto follow user if app is install from a dynamic link
    DynamicLinkService.followSender(context);

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
      Provider.of<SelfProfileNotifier>(context, listen: false).user.profile =
          usersFetch.data;
      notifyListeners();
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

  Widget mainScreen(BuildContext context) {
    List pages = [
      const HomeScreen(),
      SearchScreen(),
      NotificationScreen(),
      MessageScreen()
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

  void setNotification() => FcmService().setHaveNotification(false);

  void onShowPostContent(BuildContext context) {
    // System().actionReqiredIdCard(context,
    //    action: () => ShowBottomSheet.onUploadContent(context));
    ShowBottomSheet.onUploadContent(context);
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
          (message) {
            message.logger();
            try {
              final msgData = MessageDataV2.fromJson(json.decode('$message'));
              NotificationService().showNotification(
                RemoteMessage(
                  notification: RemoteNotification(
                    title: "@${msgData.username} (${msgData.fullName})",
                    body: msgData.disqusLogs.firstOrNull?.txtMessages ?? '',
                  ),
                  data: msgData.toJson(),
                ),
              );
              _eventService.notifyMessageReceived(msgData);
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
          .disableAutoConnect()
          .build(),
    );
  }
}
