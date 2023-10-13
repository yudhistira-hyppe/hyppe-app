import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:hyppe/app.dart';
import 'package:hyppe/core/arguments/general_argument.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../ui/inner/message_v2/notifier.dart';
import '../../ui/inner/notification/notifier.dart';
import '../../ux/path.dart';
import '../../ux/routing.dart';
import '../arguments/discuss_argument.dart';
import '../arguments/main_argument.dart';
import '../bloc/message_v2/bloc.dart';
import '../models/collection/message_v2/message_data_v2.dart';

// Notification instance
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

class NotificationService {
  NotificationService._private();

  static final NotificationService _instance = NotificationService._private();

  factory NotificationService() {
    return _instance;
  }

  // create initialization settings for specific platform
  static AndroidInitializationSettings initializationSettingsAndroid = const AndroidInitializationSettings('app_icon');

  static MacOSInitializationSettings initializationSettingsMacOS = const MacOSInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
  );

  static IOSInitializationSettings initializationSettingsIOS = const IOSInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
  );

  static AndroidNotificationChannel channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description: 'This channel is used for important notifications.', // description
    playSound: true,
    showBadge: true,
    enableLights: true,
    enableVibration: true,
    importance: Importance.max,
  );

  InitializationSettings initializationSettings = InitializationSettings(
    iOS: initializationSettingsIOS,
    macOS: initializationSettingsMacOS,
    android: initializationSettingsAndroid,
  );

  // create notification details settings for specific platform
  static AndroidNotificationDetails androidPlatformChannelSpecifics = const AndroidNotificationDetails(
    'android_id',
    'android_channel_name',
    channelDescription: 'android_channel_description',
    priority: Priority.max,
    importance: Importance.max,
    largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
  );

  static IOSNotificationDetails iosPlatformChannelSpecifics = const IOSNotificationDetails();

  static NotificationDetails platformChannelSpecifics = NotificationDetails(
    iOS: iosPlatformChannelSpecifics,
    android: androidPlatformChannelSpecifics,
  );

  // initialization service
  Future initializeLocalNotification() async {
    // await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);

    // get payload from push notification when app in background/foreground state
    await flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: (String? payload) async {
      navigateWithPayload(payload);
    });

    // get payload from push notification when app in terminated state
    await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails().then((value) {
      // need delay to work properly
      Future.delayed(const Duration(milliseconds: 300), () {
        navigateWithPayload(value?.payload);
      });
    });
  }

  navigateWithPayload(String? payload) async {
    'notification payload: $payload'.logger();
    try {
      final Map<String, dynamic> map = json.decode(payload ?? '{}');
      if (payload != null) {
        if (map['postID'] != null) {
          final data = NotificationBody.fromJson(map);

          if (data.postType == 'TRANSACTION') {
            Routing().move(Routes.transaction);
          } else if (data.postType == 'CHALLENGE') {
            Routing().move(
              Routes.chalengeDetail,
              argument: GeneralArgument(
                id: data.postId,
                index: (data.winner ?? false) ? 1 : 0, //int.parse(data.index ?? '0'),
                title: data.title,
                body: data.message,
              ),
            );
          } else if (data.postType == 'FOLLOWER' || data.postType == 'FOLLOWING') {
            materialAppKey.currentContext!.read<NotificationNotifier>().checkAndNavigateToProfile(materialAppKey.currentContext!, data.postId);
          } else {
            materialAppKey.currentContext!.read<NotificationNotifier>().navigateToContent(materialAppKey.currentContext!, data.postType, data.postId);
          }
        } else if (map['postType'] != null) {
          final data = NotificationBody.fromJson(map);
          if (data.postType == 'TRANSACTION') {
            Routing().move(Routes.transaction);
          } else {
            throw 'Not recognize the type of the object of the notification ';
          }
        } else if (map['createdAt'] != null) {
          final data = MessageDataV2.fromJson(map);
          final notifier = MessageNotifier();
          final sender = data.disqusLogs[0].sender;
          var result = await getChatRoomByDisqusID(materialAppKey.currentContext!, data.disqusID ?? '');
          final index1 = result.indexWhere((element) => element.disqusLogs[0].sender == sender);
          "array yg di dapat $index1".logger();
          notifier.onClickUser(materialAppKey.currentContext!, result[index1]);
        } else if (map['url'] != null) {
          if (isFromSplash) {
            page = 3;
          } else {
            Routing().moveAndRemoveUntil(Routes.lobby, Routes.lobby, argument: MainArgument(canShowAds: false, page: 3));
          }
        } else {
          throw 'Not recognize the type of the object of the notification ';
        }
      }
    } catch (e) {
      e.logger();
    }
  }

  Future<List<MessageDataV2>> getChatRoomByDisqusID(BuildContext context, String disqusID) async {
    List<MessageDataV2>? res;

    try {
      final param = DiscussArgument(
        receiverParty: '',
        email: SharedPreference().readStorage(SpKeys.email),
      )
        ..isQuery = true
        ..pageRow = 1
        ..pageNumber = 0
        ..withDetail = true;

      final notifier = MessageBlocV2();
      await notifier.getDiscussionBloc(
        context,
        disqusArgument: param,
      );

      final fetch = notifier.messageFetch;

      res = (fetch.data as List<dynamic>?)?.map((e) => MessageDataV2.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      '$e'.logger();
      rethrow;
    }

    return res ?? [];
  }

  // show notification

  Future showNotification(RemoteMessage message, {MessageDataV2? data, String? idNotif, isBackground = false}) async {
    print("===''''-- ${message.hashCode}");
    if (idNotif != null) {
      try {
        await flutterLocalNotificationsPlugin.cancel(0, tag: idNotif);
      } catch (e) {
        print('Error Get rid the notification $e');
        // 'Error Get rid the notification $e'.logger();
      }
    }

    // String? deviceID = SharedPreference().readStorage(SpKeys.fcmToken);

    try {
      if (data != null) {
        print("masuk 1");
        if (message.notification != null) {
          await flutterLocalNotificationsPlugin.show(
            message.hashCode,
            message.notification?.title ?? '',
            message.notification?.body,
            platformChannelSpecifics,
            payload: json.encode(data.toJson()),
          );
        }
      } else {
        print("masuk 2");
        final Map<String, dynamic> jsonNotif = message.data;
        jsonNotif['isBackground'] = isBackground;
        final value = NotificationBody.fromJson(jsonNotif);
        // var body;
        // Platform.isIOS ? body = json.decode(message.notification?.body ?? '') : '';
        await flutterLocalNotificationsPlugin.show(
          message.hashCode,
          value.title ?? message.notification?.title,
          message.data['body'],
          platformChannelSpecifics,
          payload: Platform.isIOS ? json.encode(jsonNotif) : json.encode(jsonNotif),
        );
      }
    } catch (e) {
      print("===error $e");
      if (message.notification != null) {
        print("======= test notif ${message.data}");
        final Map<String, dynamic> jsonNotif = message.data;
        jsonNotif['isBackground'] = isBackground;
        // final Map<String, dynamic> map = json.decode(message.notification?.body ?? '{}');
        var body;
        // Platform.isIOS ? body = json.decode(message.notification?.body ?? '') : '';
        await flutterLocalNotificationsPlugin.show(
          message.hashCode,
          message.notification?.title ?? '',
          message.notification?.body,
          // message.notification?.body,
          platformChannelSpecifics,
          payload: Platform.isIOS ? json.encode(jsonNotif) : json.encode(jsonNotif),
        );
      }
      e.logger();
    }
  }
}

class NotificationBody {
  String? postId;
  String? postType;
  String? message;
  String? title;
  String? index;
  String? url;
  bool? winner;

  NotificationBody({this.postId, this.postType, this.message, this.index, this.url, this.winner});

  NotificationBody.fromJson(Map<String, dynamic> json) {
    postId = json['postID'];
    postType = json['postType'];
    message = json['body'];
    title = json['title'];
    index = json['index'];
    url = json['url'];
    winner = json['winner'] == "true" ? true : false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = <String, dynamic>{};
    result['postID'] = postId;
    result['postType'] = postType;
    result['message'] = message;
    result['index'] = index;
    result['url'] = url;
    return result;
  }
}
