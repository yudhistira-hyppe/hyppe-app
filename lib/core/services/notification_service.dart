import 'dart:convert';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hyppe/core/services/shared_preference.dart';
// import 'package:hyppe/core/arguments/message_detail_argument.dart';
// import 'package:hyppe/core/models/collection/message_v2/message_data_v2.dart';
// import 'package:hyppe/core/services/system.dart';
// import 'package:hyppe/ux/path.dart';
// import 'package:hyppe/ux/routing.dart';

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
    'This channel is used for important notifications.', // description
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
    'android_channel_description',
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
    await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: (String? payload) async {
        print('notification payload: $payload');
        if (payload != null) {
          try {
            // final Map<String, dynamic> mapData = jsonDecode(payload);
            // final msgData = MessageDataV2.fromJson(mapData);
            // Routing().move(messageDetail, argument: MessageDetailArgument(
            //   mate: msgData.mate,
            //   emailReceiver: msgData.email ?? '',
            //   usernameReceiver: msgData.username ?? '',
            //   fullnameReceiver: msgData.fullName ?? '',
            //   photoReceiver: System().showUserPicture(msgData.avatar?.mediaEndpoint) ?? '',
            // ));
          } catch (e) {
            "[ERROR-TAP-NOTIFICATION] = $e".logger();
          }
        }
      },
    );
  }

  // show notification

  Future showNotification(RemoteMessage message) async {
    String? deviceID = SharedPreference().readStorage(SpKeys.fcmToken);
    final data = NotificationBody.fromJson(json.decode(message.notification?.body ?? "{}"));
    if (deviceID != null) {
      if (message.notification != null) {
        await flutterLocalNotificationsPlugin.show(
          message.hashCode,
          message.notification?.title ?? '',
          data.message ?? '',
          platformChannelSpecifics,
          payload: jsonEncode(message.data),
        );
      }
    }
  }
}


class NotificationBody{
  String? postId;
  String? postType;
  String? message;

  NotificationBody({this.postId, this.postType, this.message});

  NotificationBody.fromJson(Map<String, dynamic> json){
    postId = json['postID'];
    postType = json['postType'];
    message = json['message'];
  }

  Map<String, dynamic> toJson(){
    final Map<String, dynamic> result = <String, dynamic>{};
    result['postID'] = postId;
    result['postType'] = postType;
    result['message'] = message;
    return result;
  }
}