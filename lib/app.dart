import 'dart:async';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
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

// void mainApp(EnvType env) async {
//   WidgetsFlutterBinding.ensureInitialized();
//   Env.init(env);
//   NotificationService().initializeLocalNotification();
//   FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);
//   await SharedPreference.onInitialSharedPreferences();
//   await FcmService().firebaseCloudMessagingListeners();
//   System().systemUIOverlayTheme();
//   await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
//   runApp(Hyppe());
  
//   FirebaseCrashlytics.instance.crash();
//   if (kDebugMode) {
//   // Force disable Crashlytics collection while doing every day development.
//   // Temporarily toggle this to true if you want to test crash reporting in your app.
//   await FirebaseCrashlytics.instance
//       .setCrashlyticsCollectionEnabled(true);
// } else {
//   // Handle Crashlytics enabled status when not in Debug,
//   // e.g. allow your users to opt-in to crash reporting.
// }
// }




void mainApp(EnvType env) async {
  WidgetsFlutterBinding.ensureInitialized();
  Env.init(env);
  NotificationService().initializeLocalNotification();
  FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);
  await SharedPreference.onInitialSharedPreferences();
  await FcmService().firebaseCloudMessagingListeners();
  System().systemUIOverlayTheme();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
//  FirebaseCrashlytics.instance.crash();
  runZonedGuarded(()async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
   runApp(Hyppe());
 if (kDebugMode) {
  // Force disable Crashlytics collection while doing every day development.
  // Temporarily toggle this to true if you want to test crash reporting in your app.
  await FirebaseCrashlytics.instance
      .setCrashlyticsCollectionEnabled(true);
} else {
  // Handle Crashlytics enabled status when not in Debug,
  // e.g. allow your users to opt-in to crash reporting.
}
   FlutterError.onError=FirebaseCrashlytics.instance.recordFlutterError;
 }, (error,stack)=>FirebaseCrashlytics.instance.recordError(error, stack));
 
}

