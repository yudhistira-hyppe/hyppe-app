import 'package:hyppe/core/config/env.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/services/fcm_service.dart';
import 'package:hyppe/core/services/notification_service.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void mainApp(EnvType env) async {
  WidgetsFlutterBinding.ensureInitialized();
  Env.init(env);
  NotificationService().initializeLocalNotification();
  FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);
  await SharedPreference.onInitialSharedPreferences();
  await FcmService().firebaseCloudMessagingListeners();
  System().systemUIOverlayTheme();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(Hyppe());
}
