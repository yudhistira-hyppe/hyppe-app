import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
// import 'package:hive_flutter/hive_flutter.dart';
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
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

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

final InAppLocalhostServer localhostServer = InAppLocalhostServer();
final GlobalKey<ScaffoldState> materialAppKey = GlobalKey<ScaffoldState>();
AudioPlayer? globalAudioPlayer;

void mainApp(EnvType env) async {
  // HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  Env.init(env);
  NotificationService().initializeLocalNotification();
  FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);
  // await Hive.initFlutter();
  // Hive.registerAdapter(AllContentsAdapter());
  // Hive.registerAdapter(ContentDataAdapter());
  // Hive.registerAdapter(MetadataAdapter());
  // Hive.registerAdapter(ContentDataInsightAdapter());
  // Hive.registerAdapter(PrivacyAdapter());
  // Hive.registerAdapter(InsightLogsAdapter());
  // Hive.registerAdapter(UserProfileAvatarModelAdapter());
  // Hive.registerAdapter(CatsAdapter());
  // Hive.registerAdapter(TagPeopleAdapter());
  // Hive.registerAdapter(AvatarAdapter());
  //
  // await Hive.openBox<AllContents>('data_contents');
  await SharedPreference.onInitialSharedPreferences();
  await FcmService().firebaseCloudMessagingListeners();
  System().systemUIOverlayTheme();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
//  FirebaseCrashlytics.instance.crash();
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    // start the localhost server
    await localhostServer.start();

    if (Platform.isAndroid) {
      await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
    }

    runApp(Hyppe());
    // runApp(ChangeNotifierProvider.value(
    //     value: MainNotifier(), // Same object as above
    //     child: Hyppe()));

    if (kDebugMode) {
      // Force disable Crashlytics collection while doing every day development.
      // Temporarily toggle this to true if you want to test crash reporting in your app.
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    } else {
      // Handle Crashlytics enabled status when not in Debug,
      // e.g. allow your users to opt-in to crash reporting.
    }
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  }, (error, stack) => FirebaseCrashlytics.instance.recordError(error, stack));
}
