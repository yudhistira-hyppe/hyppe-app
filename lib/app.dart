import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show PlatformDispatcher;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_aliplayer/flutter_aliplayer.dart';
import 'package:hyppe/core/config/env.dart';
import 'package:hyppe/core/constants/enum.dart';
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
import 'package:hyppe/ui/inner/home/content_v2/vid/widget/vid_player_page.dart';

import 'core/services/SqliteData.dart';
import 'core/services/api_action.dart';
import 'firebase_options.dart';

final InAppLocalhostServer localhostServer = InAppLocalhostServer();
final GlobalKey<ScaffoldState> materialAppKey = GlobalKey<ScaffoldState>();
GlobalKey<VidPlayerPageState> vidPlayerState = GlobalKey();

AudioPlayer? globalAudioPlayer;
// ScrollController? globalScroller;
FlutterAliplayer? globalAliPlayer;
FlutterAliplayer? adsGlobalAliPlayer;
FlutterAliplayer? globalAdsInContent;
FlutterAliplayer? globalAdsPopUp;
FlutterAliplayer? globalAdsInBetween;
final globalDB = DatabaseHelper();
bool isHomeScreen = false;
bool isFromSplash = false;
bool isStopVideo = false;
bool isShowingDialog = false;
bool connectInternet = true;
int golbalToOther = 0;
int page = -1;
bool globalInternetConnection = true;
bool globalAfterReport = false;
bool homeClick = false;
bool globalTultipShow = false;
bool globalChallengePopUp = true; //untuk menahan tutorial muncul sebelum challange
bool pagePictLandingFull = false;
bool isMuteAudioPic = true;

int storyMin = 4;
int vidMin = 5;

bool globalPreventAction = false;
bool fromGuest = false;

bool isactivealiplayer = false;

const platform = MethodChannel('app.channel.shared.data');

void disposeGlobalAudio() async {
  try {
    await globalAudioPlayer!.stop();
    // await globalAudioPlayer!.dispose();
    globalAudioPlayer = null;
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
  // FirebaseCrashlytics.instance.crash();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // // For sharing images coming from outside the app while the app is in the memory
  // ReceiveSharingIntent.getMediaStream().listen((List<SharedMediaFile> value) {
  //   debugPrint("ReceiveSharingIntent memory");
  //   print(value[0].path);
  //   // Routing().move(Routes.lobby);
  // }, onError: (err) {
  //   debugPrint("ReceiveSharingIntent memory");
  //   debugPrint("$err");
  // });
  //
  // // For sharing images coming from outside the app while the app is closed
  // ReceiveSharingIntent.getInitialMedia().then((List<SharedMediaFile> value) async {
  //   debugPrint("ReceiveSharingIntent closed 1");
  //   if(value.isNotEmpty){
  //     final file = value[0];
  //     if(file.path.isNotEmpty){
  //       print(value[0].path);
  //       Future.delayed(const Duration(seconds: 5), (){
  //         Routing().move(Routes.root);
  //       });
  //     }
  //   }
  //
  //   // Routing().move(Routes.lobby);
  // }, onError: (err) {
  //   debugPrint("$err");
  // });
  //
  // platform.invokeMethod('getFeatureType').then((value) {
  //   debugPrint("ReceiveSharingIntent closed 2");
  //   print(value);
  //   // Future.delayed(const Duration(seconds: 3), (){
  //   //   Routing().move(Routes.lobby);
  //   // });
  // }).catchError((onError) {
  //   debugPrint("ReceiveSharingIntent closed 2 error");
  //   print(onError);
  // });

  //   platform.invokeMethod('getFeatureType').then((value) {
  //     debugPrint("ReceiveSharingIntent closed 2");
  //   }).catchError((onError) {
  //     debugPrint("ReceiveSharingIntent closed 2 error");
  //     print(onError);
  //   });

  //   try {
  //     final receivedIntent = await ReceiveIntent.getInitialIntent();
  //     if (receivedIntent != null) {
  //       debugPrint("ReceivedIntent");
  //       debugPrint(receivedIntent.data);
  //     }
  //   } on PlatformException {
  //     // Handle exception
  //   }
  // }

  // start the localhost server
  await localhostServer.start();

  if (Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
  }
  // SharedPreference().writeStorage(SpKeys.isPreventRoute, false);
  FlutterError.onError = (errorDetails) {
    try {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    } catch (e) {
      e.logger();
    }
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
