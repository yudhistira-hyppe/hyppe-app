import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show PlatformDispatcher;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hyppe/core/config/env.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/services/fcm_service.dart';
import 'package:hyppe/core/services/notification_service.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'core/services/SqliteData.dart';
import 'core/services/api_action.dart';
import 'firebase_options.dart';

final InAppLocalhostServer localhostServer = InAppLocalhostServer();
final GlobalKey<ScaffoldState> materialAppKey = GlobalKey<ScaffoldState>();
AudioPlayer? globalAudioPlayer;
ScrollController? globalScroller;
final globalDB = DatabaseHelper();
bool isHomeScreen = false;
bool isFromSplash = false;

void disposeGlobalAudio() async {
  try {
    await globalAudioPlayer!.stop();
    await globalAudioPlayer!.dispose();
  } catch (e) {
    'globalAudioPlayer error : $e '.logger();
  }
}

void mainApp(EnvType env) async {
  // HttpOverrides.global = MyHttpOverrides();
  isFromSplash = true;
  WidgetsFlutterBinding.ensureInitialized();
  Env.init(env);
  NotificationService().initializeLocalNotification(); //dari sini minta permision
  FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);
  HttpOverrides.global = MyHttpOverrides();
  await globalDB.initDb();
  await SharedPreference.onInitialSharedPreferences();
  await FcmService().firebaseCloudMessagingListeners();
  System().systemUIOverlayTheme();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
//  FirebaseCrashlytics.instance.crash();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // start the localhost server
  await localhostServer.start();

  if (Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
  }
  // SharedPreference().writeStorage(SpKeys.isPreventRoute, false);
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    // If you wish to record a "non-fatal" exception, please remove the "fatal" parameter
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  runApp(Hyppe());
  // runZonedGuarded(() async {
  //   WidgetsFlutterBinding.ensureInitialized();
  //   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
  //
  //   // start the localhost server
  //   await localhostServer.start();
  //
  //   if (Platform.isAndroid) {
  //     await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
  //   }
  //
  //   runApp(Hyppe());
  //   // runApp(ChangeNotifierProvider.value(
  //   //     value: MainNotifier(), // Same object as above
  //   //     child: Hyppe()));
  //
  //   if (kDebugMode) {
  //     // Force disable Crashlytics collection while doing every day development.
  //     // Temporarily toggle this to true if you want to test crash reporting in your app.
  //     await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  //   } else {
  //     // Handle Crashlytics enabled status when not in Debug,
  //     // e.g. allow your users to opt-in to crash reporting.
  //   }
  //   FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  // }, (error, stack) => FirebaseCrashlytics.instance.recordError(error, stack));
}
