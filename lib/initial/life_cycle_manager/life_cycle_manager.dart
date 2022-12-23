import 'dart:async' show Timer;
import 'dart:convert';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/app.dart';
import 'package:hyppe/core/bloc/device/state.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/extension/log_extension.dart';

import 'package:hyppe/core/bloc/device/bloc.dart';
import 'package:hyppe/core/services/check_version.dart';

import 'package:hyppe/core/services/socket_service.dart';
import 'package:hyppe/core/services/isolate_service.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/services/dynamic_link_service.dart';

import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:provider/provider.dart';

import '../../core/bloc/ads_video/bloc.dart';
import '../../core/bloc/ads_video/state.dart';
import '../../core/bloc/posts_v2/bloc.dart';
import '../../core/bloc/posts_v2/state.dart';
import '../../core/models/collection/advertising/ads_video_data.dart';
import '../../ui/inner/home/content_v2/pic/playlist/slide/notifier.dart';
import '../../ui/inner/upload/preview_content/notifier.dart';

class LifeCycleManager extends StatefulWidget {
  final Widget? child;

  const LifeCycleManager({Key? key, this.child}) : super(key: key);

  @override
  _LifeCycleManagerState createState() => _LifeCycleManagerState();
}

class _LifeCycleManagerState extends State<LifeCycleManager> with WidgetsBindingObserver {
  Timer? _timerLink;
  final _socketService = SocketService();
  final _isolateService = IsolateService();

  @override
  void initState() {
    WidgetsBinding.instance?.addObserver(this);
    _timerLink = Timer(const Duration(seconds: 2), () => DynamicLinkService.handleDynamicLinks());
    _isolateService.turnOnWorkers();
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
    _timerLink?.cancel();
    if (_socketService.isRunning) _socketService.closeSocket();
    if (_isolateService.workerActive()) _isolateService.turnOffWorkers();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    final activity = DeviceBloc();

    print("Status Lifecycle: $state");
    final notifier = materialAppKey.currentContext!.read<PreviewContentNotifier>();
    final picNotifier = materialAppKey.currentContext!.read<SlidedPicDetailNotifier>();
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

      final _userToken = SharedPreference().readStorage(SpKeys.userToken);

      if (_userToken != null) {
        try {
          await activity.activityAwake(context);
          final fetch = activity.deviceFetch;
          // if (fetch.deviceState == DeviceState.activityAwakeSuccess) {
          //   print('ini device activity ${fetch.data}');
          //   await getDevice();
          //
          //   if (fetch.data.contains(SharedPreference().readStorage(SpKeys.brand))) {
          //     SharedPreference().writeStorage(SpKeys.brand, "${device['manufacturer'] - device['model']}");
          //   } else {
          //     SharedPreference().writeStorage(SpKeys.brand, "${device['manufacturer'] - device['model']}");
          //   }
          // }

          final isOnHomeScreen = SharedPreference().readStorage(SpKeys.isOnHomeScreen);
          if (isOnHomeScreen) {
            print("isOnHomeScreen hit ads");
            await getAdsApsara();
          }

          //cek version aplikasi
          await CheckVersion().check(context, activity.deviceFetch.version);
        } catch (e) {
          e.logger();
        }
      }
      _timerLink = Timer(const Duration(milliseconds: 1000), () => DynamicLinkService.handleDynamicLinks());
    }
  }

  Future getDevice() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    Map device = System().readAndroidBuildData(await deviceInfo.androidInfo);
    SharedPreference().writeStorage(SpKeys.brand, "${device['manufacturer'] - device['model']}");
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

  Future getAdsApsara() async {
    final ads = await getPopUpAds();
    final id = ads.videoId;
    if (id != null && ads.adsType != null) {
      try {
        final notifier = PostsBloc();
        await notifier.getVideoApsaraBlocV2(context, apsaraId: ads.videoId ?? '');

        final fetch = notifier.postsFetch;

        if (fetch.postsState == PostsState.videoApsaraSuccess) {
          Map jsonMap = json.decode(fetch.data.toString());
          print('jsonMap video Apsara : $jsonMap');
          final adsUrl = jsonMap['PlayUrl'];
          // _eventType = (_betterPlayerRollUri != null) ? BetterPlayerEventType.showingAds : null;
          print('get Ads Video');
          final isShowAds = SharedPreference().readStorage(SpKeys.isShowPopAds);
          if (!isShowAds) {
            System().adsPopUp(context, ads, adsUrl);
          }

          // widget.videoData?.fullContentPath = jsonMap['PlayUrl'];
        }
      } catch (e) {
        'Failed to fetch ads data ${e}'.logger();
      }
    }
  }

  @override
  Widget build(_) => widget.child ?? Container();
}
