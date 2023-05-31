import 'dart:io';
import 'package:flutter/foundation.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';

import 'package:hyppe/core/extension/log_extension.dart';

import 'package:hyppe/core/services/event_service.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/services/notification_service.dart';

// handling background message
@pragma('vm:entry-point')
Future<void> onBackgroundMessage(RemoteMessage message) async {
  final _notificationService = NotificationService();

  await Firebase.initializeApp();
  """ 
            Background incoming message data => ${message.data},
            Background incoming message category => ${message.category},
            Background incoming message category => ${message.category},
            Background incoming message messageId => ${message.messageId},
            Background incoming message messageType => ${message.messageType},
            Background incoming message senderId => ${message.senderId},
            Background incoming message sentTime => ${message.sentTime},
            Background incoming message threadId => ${message.threadId},
            Background incoming message ttl => ${message.ttl},
            Background incoming message notification => ${message.notification?.title} ${message.notification?.body}
            Background incoming message tag => ${message.notification?.android?.tag}
            """
      .logger();
  print('Background incoming message tag => ${message.notification?.android?.tag}');

  // notificationData.value = NotificationsData(
  //     type: 'user',
  //     isRead: false,
  //     notificationCategory: NotificationCategory.user,
  //     timestamp: message.sentTime?.millisecondsSinceEpoch.toString() ?? null,
  //     message: '${message.notification?.title ?? ''} ${message.notification?.body ?? ''}');

  _notificationService.showNotification(message, idNotif: message.notification?.android?.tag);
}

// listenable value
// ValueNotifier<NotificationsData?> notificationData = ValueNotifier<NotificationsData?>(null);

// @pragma('vm:entry-point')
class FcmService {
  FcmService._private();

  static final FcmService _instance = FcmService._private();

  factory FcmService() {
    return _instance;
  }

  // services
  final _eventService = EventService();
  final _sharedPreferences = SharedPreference();
  final _notificationService = NotificationService();

  static FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  ValueNotifier<bool> haveNotification = ValueNotifier<bool>(false);

  // fcm listener
  Future firebaseCloudMessagingListeners() async {
    try {
      // initialize firebase
      print('ini kesini ga yah1');
      await Firebase.initializeApp().then((value) {
        print('ini kesini ga yah');
        'Name ${value.name}'.logger();
        'option ${value.options.asMap}'.logger();
      });
      print('ini kesini ga yah2');

      // request notification listener
      if (Platform.isIOS) requestNotificationPermission();

      // on refresh token
      firebaseMessaging.onTokenRefresh.listen(
        (token) {
          'Refresh token: $token'.logger();
          _eventService.notifyCloudFcmTokenRefresh(token);
        },
        cancelOnError: true,
      );

      // getting token
      await firebaseMessaging.getToken().then((token) {
        '[FCM Token] => $token'.logger();
        _sharedPreferences.writeStorage(SpKeys.fcmToken, token);
      });

      // foreground incoming message
      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        RemoteNotification? notification = message.notification;
        """ 
            Foreground incoming message data => ${message.data},
            Foreground incoming message category => ${message.category},
            Foreground incoming message category => ${message.category},
            Foreground incoming message messageId => ${message.messageId},
            Foreground incoming message messageType => ${message.messageType},
            Foreground incoming message senderId => ${message.senderId},
            Foreground incoming message sentTime => ${message.sentTime},
            Foreground incoming message threadId => ${message.threadId},
            Foreground incoming message ttl => ${message.ttl},
            Foreground incoming message notification => ${message.notification?.title} ${message.notification?.body}
            """
            .logger();

        // notificationData.value = NotificationsData(
        //     type: 'user',
        //     isRead: false,
        //     notificationCategory: NotificationCategory.user,
        //     timestamp: message.sentTime?.millisecondsSinceEpoch.toString() ?? null,
        //     message: '${message.notification?.title ?? ''} ${message.notification?.body ?? ''}');
        // isHaveNotification.value = true;

        _notifyApp(message, () => _eventService.notifyForegroundMessage(message));
        _notificationService.showNotification(message);
        // if (notification != null) {
        //
        // }
      });

      // when app opened from tapping message
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
        RemoteNotification? notification = message.notification;
        """ 
            When app opened from tapping message data => ${message.data},
            When app opened from tapping message category => ${message.category},
            When app opened from tapping message category => ${message.category},
            When app opened from tapping message messageId => ${message.messageId},
            When app opened from tapping message messageType => ${message.messageType},
            When app opened from tapping message senderId => ${message.senderId},
            When app opened from tapping message sentTime => ${message.sentTime},
            When app opened from tapping message threadId => ${message.threadId},
            When app opened from tapping message ttl => ${message.ttl},
            When app opened from tapping message notification => ${message.notification?.title} ${message.notification?.body}
            """
            .logger();

        // notificationData.value = NotificationsData(
        //     type: 'user',
        //     isRead: false,
        //     notificationCategory: NotificationCategory.user,
        //     timestamp: message.sentTime?.millisecondsSinceEpoch.toString() ?? null,
        //     message: '${message.notification?.title ?? ''} ${message.notification?.body ?? ''}');
        // isHaveNotification.value = true;

        _notifyApp(message, () => _eventService.notifyMessageOpenedApp(message));
        _notificationService.showNotification(message, idNotif: message.notification?.android?.tag);
      });
    } catch (e) {
      '[INFO] => Failed to initialize [firebaseCloudMessagingListeners] with error ${e.toString()}'.logger();
    }
  }

  Future initializeFcmIfNot() async {
    final _fcmToken = SharedPreference().readStorage(SpKeys.fcmToken);

    if (_fcmToken == null) {
      await firebaseCloudMessagingListeners();
    }
  }

  // request notification listener
  Future<void> requestNotificationPermission() async {
    await firebaseMessaging.requestPermission(sound: true, badge: true, alert: true).then(
      (value) {
        'Notification settings ${value.alert}, ${value.announcement}, ${value.authorizationStatus}, ${value.badge}, ${value.sound}, ${value.lockScreen}'.logger();
      },
    );
  }

  void _notifyApp(RemoteMessage message, VoidCallback notifyCallback) {
    setHaveNotification(true);
    notifyCallback();
  }

  void setHaveNotification(bool value) {
    haveNotification.value = value;
  }
}
