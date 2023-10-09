import 'dart:async' show Timer;
import 'package:flutter/foundation.dart' show kDebugMode;
import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/app.dart';
import 'package:hyppe/core/bloc/device/state.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/extension/log_extension.dart';

import 'package:hyppe/core/bloc/device/bloc.dart';
import 'package:hyppe/core/services/check_version.dart';

import 'package:hyppe/core/services/socket_service.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/services/dynamic_link_service.dart';

import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

import '../../core/bloc/ads_video/bloc.dart';
import '../../core/bloc/ads_video/state.dart';
import '../../core/bloc/posts_v2/bloc.dart';
import '../../core/bloc/posts_v2/state.dart';
import '../../core/constants/enum.dart';
import '../../core/models/collection/advertising/ads_video_data.dart';
import '../../ui/inner/upload/preview_content/notifier.dart';
import '../../ui/outer/opening_logo/screen.dart';

class LifeCycleManager extends StatefulWidget {
  final Widget? child;

  const LifeCycleManager({Key? key, this.child}) : super(key: key);

  @override
  _LifeCycleManagerState createState() => _LifeCycleManagerState();
}

class _LifeCycleManagerState extends State<LifeCycleManager> with WidgetsBindingObserver {
  late Future<void> _initializeFireFuture;

  Timer? _timerLink;
  final _socketService = SocketService();
  // final _isolateService = IsolateService();

  Future<void> _initializeFlutterFire() async {
    if (kDebugMode) {
      // Force disable Crashlytics collection while doing every day development.
      // Temporarily toggle this to true if you want to test crash reporting in your app.
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    } else {
      // Handle Crashlytics enabled status when not in Debug,
      // e.g. allow your users to opt-in to crash reporting.
    }
  }

  // Future<AdsData> getPopUpAds() async {
  //   var data = AdsData();
  //   try {
  //     final notifier = AdsDataBloc();
  //     await notifier.adsVideoBlocV2(context, AdsType.popup);
  //     final fetch = notifier.adsDataFetch;
  //
  //     if (fetch.adsDataState == AdsDataState.getAdsVideoBlocSuccess) {
  //       // print('data : ${fetch.data.toString()}');
  //       data = fetch.data?.data;
  //     }
  //   } catch (e) {
  //     'Failed to fetch ads data $e'.logger();
  //   }
  //   return data;
  // }

  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'LifeCycleManager');
    _initializeFireFuture = _initializeFlutterFire();
    WidgetsBinding.instance.addObserver(this);
    _timerLink = Timer(const Duration(seconds: 2), () {
      FirebaseCrashlytics.instance.log('Log: from init');
      // SharedPreference().writeStorage(SpKeys.isPreventRoute, true);
      DynamicLinkService.handleDynamicLinks();
    });
    // _isolateService.turnOnWorkers();
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
    _timerLink?.cancel();
    if (_socketService.isRunning) _socketService.closeSocket();
    // if (_isolateService.workerActive()) _isolateService.turnOffWorkers();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    final activity = DeviceBloc();

    print("Status Lifecycle: $state");
    try {
      final notifier = Routing.navigatorKey.currentContext!.read<PreviewContentNotifier>();
      if (state == AppLifecycleState.inactive) {
        if (notifier.listMusics.isNotEmpty || notifier.listExpMusics.isNotEmpty) {
          notifier.forceResetPlayer(true);
        }
        notifier.pauseAudioPreview();
        // picNotifier.pauseAudioPlayer();
        if (globalAudioPlayer != null) {
          print('globalAudioPlayer!.pause');
          globalAudioPlayer!.pause();
        }

        if (globalAliPlayer != null) {
          if (isStopVideo) {
            globalAliPlayer?.stop();
          } else {
            globalAliPlayer?.pause();
          }
        }
        if (adsGlobalAliPlayer != null) {
          adsGlobalAliPlayer?.pause();
        }

        if (adsGlobalAliPlayer != null) {
          adsGlobalAliPlayer?.pause();
        }
        if (globalAdsInContent != null) {
          globalAdsInContent?.pause();
        }

        "App Inactive".logger();
        final _userToken = SharedPreference().readStorage(SpKeys.userToken);
        if (_userToken != null) {
          try {
            await activity.activitySleep(context);
          } catch (e) {
            e.logger();
          }
        }
      }
      if (state == AppLifecycleState.resumed) {
        "App Resumed".logger();
        notifier.resumeAudioPreview();
        if (globalAudioPlayer != null) {
          print('globalAudioPlayer!.resume');
          globalAudioPlayer!.resume();
        }
        if (adsGlobalAliPlayer != null) {
          adsGlobalAliPlayer?.play();
        }
        if (globalAdsInContent != null) {
          globalAdsInContent?.play();
        }

        final _userToken = SharedPreference().readStorage(SpKeys.userToken);

        if (_userToken != null) {
          print('hahahahahahahaha');
          try {
            await activity.activityAwake(context);
            final fetch = activity.deviceFetch;
            if (fetch.deviceState == DeviceState.activityAwakeSuccess) {
              if (Platform.isAndroid) {
                await getDevice();
              }

              print('cek version loh ini ${activity.deviceFetch.version.runtimeType}');
              //cek version aplikasi

              await CheckVersion().check(
                context,
                activity.deviceFetch.version,
                activity.deviceFetch.versionIos,
              );
              if (fetch.data.contains(SharedPreference().readStorage(SpKeys.brand))) {
                SharedPreference().writeStorage(SpKeys.canDeppAr, 'true');
              } else {
                SharedPreference().writeStorage(SpKeys.canDeppAr, 'false');
              }
            }

            // final isOnHomeScreen = SharedPreference().readStorage(SpKeys.isOnHomeScreen);
            print('isOnHomeScreen: $isHomeScreen');
            if (isHomeScreen) {
              print("isOnHomeScreen hit ads");
              await getAdsApsara();
            }

            print('cek version loh ini');
          } catch (e) {
            e.logger();
          }
        }
        _timerLink = Timer(const Duration(milliseconds: 1000), () {
          FirebaseCrashlytics.instance.log('Log: from resume');
          DynamicLinkService.handleDynamicLinks();
        });
      }
    } catch (e, s) {
      'error lifecycle: $e --- $s'.logger();
    }

    if (state == AppLifecycleState.paused) {
      // Show custom alert message or perform action
      print('capture capture');
    }

    if (state == AppLifecycleState.detached) {
      // isAppOn = false;
    }
  }

  Future getDevice() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    Map device = System().readAndroidBuildData(await deviceInfo.androidInfo);

    var nameDevice = "${device['manufacturer']}-${device['model']}";
    print("device aku $nameDevice");
    SharedPreference().writeStorage(SpKeys.brand, nameDevice);
  }

  Future<AdsData> getPopUpAds() async {
    var data = AdsData();
    try {
      final notifier = AdsDataBloc();
      await notifier.appAdsBloc(context);
      final fetch = notifier.adsDataFetch;

      if (fetch.adsDataState == AdsDataState.getAdsVideoBlocSuccess) {
        // print('data : ${fetch.data.toString()}');
        data = fetch.data?.data;
      }
    } catch (e) {
      'Failed to fetch ads data $e'.logger();
    }
    return data;
  }

  // Future getAdsApsara() async {
  //   final ads = await getPopUpAds();
  //   final id = ads.videoId;
  //   if(ads.mediaType?.toLowerCase() == 'image'){
  //     await System().adsPopUpV2(context, ads, '');
  //   }else if (id != null && ads.adsType != null) {
  //     try {
  //       final notifier = PostsBloc();
  //       await notifier.getAuthApsara(context, apsaraId: ads.videoId ?? '');
  //
  //       final fetch = notifier.postsFetch;
  //       if (fetch.postsState == PostsState.videoApsaraSuccess) {
  //         Map jsonMap = json.decode(fetch.data.toString());
  //         print('jsonMap video Apsara : $jsonMap');
  //         final auth = jsonMap['PlayAuth'];
  //         // _eventType = (_betterPlayerRollUri != null) ? BetterPlayerEventType.showingAds : null;
  //         print('get Ads Video');
  //         final isShowAds = SharedPreference().readStorage(SpKeys.isShowPopAds);
  //         print("---------- $isShowAds");
  //         if (!isShowAds) {
  //           // System().adsPopUp(context, ads, auth, isInAppAds: true);
  //           System().adsPopUpV2(context, ads, auth);
  //         }
  //
  //         // widget.videoData?.fullContentPath = jsonMap['PlayUrl'];
  //       }
  //     } catch (e) {
  //       'Failed to fetch ads data ${e}'.logger();
  //     }
  //   }
  // }

  Future getAdsApsara() async {
    final ads = await getPopUpAds();
    final id = ads.videoId;
    if (id != null && ads.adsType != null) {
      try {
        // final notifier = PostsBloc();
        // await notifier.getVideoApsaraBlocV2(context, apsaraId: ads.videoId ?? '');

        // final fetch = notifier.postsFetch;

        // if (fetch.postsState == PostsState.videoApsaraSuccess) {
        //   Map jsonMap = json.decode(fetch.data.toString());
        //   print('jsonMap video Apsara : $jsonMap');
        //   final adsUrl = jsonMap['PlayUrl'];
        //   // _eventType = (_betterPlayerRollUri != null) ? BetterPlayerEventType.showingAds : null;
        //   print('get Ads Video');
        //   final isShowAds = SharedPreference().readStorage(SpKeys.isShowPopAds);
        //   if (!isShowAds) {
        //     System().adsPopUp(context, ads, adsUrl);
        //   }

        //   // widget.videoData?.fullContentPath = jsonMap['PlayUrl'];
        // }
        final notifier = PostsBloc();
        await notifier.getAuthApsara(context, apsaraId: ads.videoId ?? '');

        final fetch = notifier.postsFetch;
        if (fetch.postsState == PostsState.videoApsaraSuccess) {
          Map jsonMap = json.decode(fetch.data.toString());
          print('jsonMap video Apsara : $jsonMap');
          final auth = jsonMap['PlayAuth'];
          // _eventType = (_betterPlayerRollUri != null) ? BetterPlayerEventType.showingAds : null;
          print('get Ads Video');
          final isShowAds = SharedPreference().readStorage(SpKeys.isShowPopAds);
          print("---------- $isShowAds");
          if (!isShowAds) {
            System().adsPopUp(context, ads, auth, isInAppAds: true);
          }

          // widget.videoData?.fullContentPath = jsonMap['PlayUrl'];
        }
      } catch (e) {
        'Failed to fetch ads data ${e}'.logger();
      }
    }
  }

  @override
  Widget build(_) {
    return FutureBuilder(
        future: _initializeFireFuture,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              if (snapshot.hasError) {
                return ErrorWidget(snapshot.error ?? Exception('Failed launched'));
              }
              return widget.child ?? const SizedBox.shrink();
            default:
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                builder: (context, child) {
                  return OpeningLogo(
                    isLaunch: false,
                  );
                },
              );
          }
          // return widget.child ?? const SizedBox.shrink();
        });
  }
}
