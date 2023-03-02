import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hyppe/core/bloc/ads_video/bloc.dart';
import 'package:hyppe/core/bloc/ads_video/state.dart';
import 'package:hyppe/core/bloc/posts_v2/bloc.dart';
import 'package:hyppe/core/bloc/posts_v2/state.dart';
import 'package:hyppe/core/constants/utils.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/advertising/ads_video_data.dart';
import 'package:hyppe/core/models/collection/advertising/view_ads_request.dart';
import 'package:hyppe/core/services/route_observer_service.dart';
import 'package:hyppe/ui/constant/entities/report/notifier.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/widget/after_first_layout_mixin.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/widget/video_thumbnail_report.dart';
import 'package:native_device_orientation/native_device_orientation.dart';

import 'package:better_player/better_player.dart';

import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';

import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';

import 'package:hyppe/core/extension/log_extension.dart';

import 'package:hyppe/core/services/shared_preference.dart';

import 'package:hyppe/ui/inner/home/content_v2/vid/widget/video_thumbnail.dart';
import 'package:screen_protector/screen_protector.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../../core/arguments/other_profile_argument.dart';
import '../../../../../../core/constants/asset_path.dart';
import '../../../../../../core/constants/themes/hyppe_colors.dart';
import '../../../../../../initial/hyppe/translate_v2.dart';
import '../../../../../../ux/path.dart';
import '../../../../../../ux/routing.dart';
import '../../../../../constant/widget/custom_base_cache_image.dart';
import '../../../../../constant/widget/custom_spacer.dart';
import 'package:provider/provider.dart';

class VideoPlayerPage extends StatefulWidget {
  final ContentData? videoData;
  final Function()? afterView;
  final bool onDetail;

  const VideoPlayerPage({
    Key? key,
    this.videoData,
    this.afterView,
    this.onDetail = true,
  }) : super(key: key);

  @override
  _VideoPlayerPageState createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> with RouteAware, AfterFirstLayoutMixin {
  BetterPlayerController? _betterPlayerController;
  final ValueNotifier<bool> _awaitInitial = ValueNotifier(false);
  final ValueNotifier<bool> _initializeVideo = ValueNotifier(false);
  var secondsSkip = 0;

  // AdvertisingData? _clipsData;
  AdsVideo? _newClipData;
  String? _betterPlayerRollUri;
  BetterPlayerEventType? _eventType;
  bool _isMostBottomRouteInRouteStack = true;
  BetterPlayerController? _betterPlayerControllerMap;

  bool _startWithOrientationCondition = false;
  bool _isStartFullScreen = false;
  StreamSubscription<NativeDeviceOrientation>? _orientationStream;
  final _nativeDeviceOrientationCommunicator = NativeDeviceOrientationCommunicator();




  void _resetOrintationStream() {
    _orientationStream?.cancel();
    _orientationStream = null;
  }

  void _pauseOrientationListener() {
    _nativeDeviceOrientationCommunicator.pause();
  }

  void _resumeOrientationListener() {
    _nativeDeviceOrientationCommunicator.resume();
  }

  void _orientationCondition(NativeDeviceOrientation orientation) {
    if (orientation == NativeDeviceOrientation.portraitUp) {
      if (_betterPlayerController != null) {
        if (_eventType != BetterPlayerEventType.showingAds) {
          if (_betterPlayerController?.isFullScreen ?? false) {
            // _betterPlayerController?.exitFullScreen();
            _pauseOrientationListener();
            Future.delayed(const Duration(seconds: 2), () {
              _resumeOrientationListener();
            });
            return;
          }
        }
      }
    }

    if (orientation == NativeDeviceOrientation.landscapeLeft || orientation == NativeDeviceOrientation.landscapeRight) {
      if (_betterPlayerController != null) {
        if (_eventType != BetterPlayerEventType.showingAds) {
          if (_betterPlayerController?.isFullScreen == false) {
            print("here's my problem");
            // _betterPlayerController?.enterFullScreen();
            _pauseOrientationListener();
            Future.delayed(const Duration(seconds: 2), () {
              _resumeOrientationListener();
            });
            return;
          }
        }
      }
    }
  }

  void _listenToNativeDeviceOrientation() {
    _orientationStream = _nativeDeviceOrientationCommunicator.onOrientationChanged(useSensor: true).listen((orientation) {
      if (_startWithOrientationCondition && _isMostBottomRouteInRouteStack) {
        _orientationCondition(orientation);
      }
    });
  }

  void _handleOpenFullScreenEvent() {
    if (_orientationStream == null) {
      _listenToNativeDeviceOrientation();
    } else {
      _pauseOrientationListener();
      Future.delayed(const Duration(seconds: 2), () {
        _resumeOrientationListener();
      });
    }

    Future.delayed(const Duration(seconds: 2), () {
      _startWithOrientationCondition = true;
    });
  }

  void _handleHideFullScreenEvent() {
    _pauseOrientationListener();
    Future.delayed(const Duration(seconds: 2), () {
      _resumeOrientationListener();
    });
  }

  Future _newInitAds(bool isContent) async {
    if (isContent) {
      context.setAdsCount(0);
    }
    try {
      if (_newClipData == null) {
        await getAdsVideo(isContent);
      }
    } catch (e) {
      'Failed to fetch ads data : $e'.logger();
    }
  }

  Future getAdsVideo(bool isContent) async {
    try {
      final notifier = AdsDataBloc();
      await notifier.adsVideoBloc(context, isContent);
      final fetch = notifier.adsDataFetch;

      if (fetch.adsDataState == AdsDataState.getAdsVideoBlocSuccess) {
        // print('data : ${fetch.data.toString()}');
        _newClipData = fetch.data;
        'videoId : ${_newClipData?.data?.videoId}'.logger();
        secondsSkip = _newClipData?.data?.adsSkip ?? 0;
        await getAdsVideoApsara(_newClipData?.data?.videoId ?? '');
      }
    } catch (e) {
      'Failed to fetch ads data $e'.logger();
    }
  }

  Future getAdsVideoApsara(String apsaraId) async {
    try {
      final notifier = PostsBloc();
      await notifier.getVideoApsaraBlocV2(context, apsaraId: apsaraId);

      final fetch = notifier.postsFetch;

      if (fetch.postsState == PostsState.videoApsaraSuccess) {
        Map jsonMap = json.decode(fetch.data.toString());
        'jsonMap video Apsara : $jsonMap'.logger();
        _betterPlayerRollUri = jsonMap['PlayUrl'];
        // _eventType = (_betterPlayerRollUri != null) ? BetterPlayerEventType.showingAds : null;
        'get Ads Video'.logger();
        // widget.videoData?.fullContentPath = jsonMap['PlayUrl'];
      }
    } catch (e) {
      'Failed to fetch ads data ${e}'.logger();
    }
  }

  Future getVideoApsara(String apsaraId) async {
    try {
      final notifier = PostsBloc();
      await notifier.getVideoApsaraBlocV2(context, apsaraId: apsaraId);

      final fetch = notifier.postsFetch;

      if (fetch.postsState == PostsState.videoApsaraSuccess) {
        Map jsonMap = json.decode(fetch.data.toString());
        'jsonMap video Apsara : $jsonMap'.logger();
        widget.videoData?.fullContentPath = jsonMap['PlayUrl'];
      }
    } catch (e) {
      'Failed to fetch ads data ${e}'.logger();
    }
  }

  Future adsView(AdsData data, int time) async {
    try {
      final notifier = AdsDataBloc();
      final request = ViewAdsRequest(watchingTime: time, adsId: data.adsId, useradsId: data.useradsId);
      await notifier.viewAdsBloc(context, request);
      final fetch = notifier.adsDataFetch;
      print("ini hasil iklan ${fetch.data}");
      print("ini hasil iklan ${fetch.adsDataState}");

      // final fetch = notifier.adsVideoFetch;
    } catch (e) {
      'Failed hit view ads ${e}'.logger();
    }
  }

  void _initialize() async {
    'Hyppe Vid Post ID ${widget.videoData?.postID}'.logger();
    'Hyppe Vid Url ${widget.videoData?.fullContentPath}'.logger();
    'Hyppe Vid Email ${SharedPreference().readStorage(SpKeys.email)}'.logger();
    'Hyppe Vid Token ${SharedPreference().readStorage(SpKeys.userToken)}'.logger();
    'Hyppe Vid isApsara ${widget.videoData?.isApsara}'.logger();
    if (widget.videoData?.isApsara ?? false) {
      await getVideoApsara(widget.videoData?.apsaraId ?? '');
    }
    'Hyppe Vid Url ${widget.videoData?.fullContentPath}'.logger();

    // getCountVid();
    if (context.getAdsCount() == null) {
      context.setAdsCount(0);
    } else {
      if (context.getAdsCount() == 5) {
        await _newInitAds(true);
      } else if (context.getAdsCount() == 2) {
        await _newInitAds(false);
      }
    }

    'post metadata : ${widget.videoData?.metadata?.toJson().toString()}'.logger();
    // if (countAds < 0) {
    //
    //   await _newInitAds();
    //
    // } else {
    //
    //   _clipsData = AdvertisingData.fromJson({}, widget.videoData?.metadata);
    //   _eventType = (_newClipData != null) ? BetterPlayerEventType.showingAds : null;
    //   print('get Ads Video1');
    // }
    'ready to play'.logger();
    _userVideo(true);
    _awaitInitial.value = true;
  }

  int secondOfAds(AdsData data) {
    var result = 0;
    final mid = widget.videoData?.metadata?.midRoll ?? 0;
    final duration = widget.videoData?.metadata?.duration ?? 2;
    switch (data.adsPlace) {
      case 'First':
        result = widget.videoData?.metadata?.preRoll ?? 0;
        break;
      case 'Mid':
        result = mid != 0 ? 0 : (duration / 2).toInt();
        break;
      case 'End':
        result = (widget.videoData?.metadata?.postRoll ?? 0) != 0 ? widget.videoData?.metadata?.postRoll ?? 0 : duration - 1;
        break;
      default:
        result = 0;
        break;
    }
    print('secondOfAds: $result');
    return result;
  }

  void _userVideo(bool autoPlay) async {
    print('test iklan data');
    print(widget.videoData?.postID);

    if (widget.videoData?.certified ?? false) {
      _preventScreenShootOn();
    } else {
      _preventScreenShootOff();
    }
    // print(_clipsData.ads[0].rollDuration);
    // print(_clipsData.ads[1].rollUri);
    // print(_clipsData.ads[1].playingAt);
    // print(_clipsData.ads[1].playingAt);
    // print(_clipsData.ads[1].rollDuration);
    // print(_clipsData.ads[1].rollUri);
    // print(_clipsData.ads[2].playingAt);
    // print(_clipsData.ads[2].rollDuration);
    // print(_clipsData.ads[2].rollUri);
    // setStateIfMounted(() {
    //   countAds += 1;
    //   if (countAds > 4) {
    //     countAds = 0;
    //   }
    //   SharedPreference().writeStorage(SpKeys.countAds, countAds.toString());
    // });
    final height = widget.videoData?.metadata?.height ?? 0.0;
    final width = widget.videoData?.metadata?.width ?? 0.0;
    BetterPlayerConfiguration betterPlayerConfiguration = BetterPlayerConfiguration(
        videoSize: (height != 0.0 && width != 0.0) ? Size(width.toDouble(), height.toDouble()) : null,
        aspectRatio: 1.0,
        autoDispose: true,
        autoPlay: autoPlay,
        fit: BoxFit.fitHeight,
        showPlaceholderUntilPlay: true,
        deviceOrientationsAfterFullScreen: [DeviceOrientation.portraitUp],
        autoDetectFullscreenAspectRatio: true,
        autoDetectFullscreenDeviceOrientation: !Platform.isIOS,
        controlsConfiguration: const BetterPlayerControlsConfiguration(
          enableFullscreen: true,
          controlBarColor: Color.fromARGB(10, 0, 0, 1),
          enableOverflowMenu: false,
        ),
        eventListener: (event) {
          print('ini event betterPlayerEventType : ${event.betterPlayerEventType}');
          if (event.betterPlayerEventType == BetterPlayerEventType.initialized) {
            context.incrementAdsCount();
          }
        });
    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      widget.videoData?.fullContentPath ??
          'https://outin-c01c93ffe24211ec9bf900163e013357.oss-ap-southeast-5.aliyuncs.com/5d92f36afb3d4a75b7ecef398107278e/780a82f6569143c591c1c2afeca8e968-c4535eb7cbd8313949f96a6a946ef25d-fd.mp4?Expires=1664346280&OSSAccessKeyId=LTAI3DkxtsbUyNYV&Signature=0%2FOBtRvwz06egP4znSAvQ1AfQqE%3D',
      adsConfiguration: _betterPlayerRollUri != null
          ? BetterPlayerAdsConfiguration(
              postID: widget.videoData?.postID ?? '',
              rolls: [BetterPlayerRoll(rollUri: _betterPlayerRollUri, rollDuration: secondOfAds(_newClipData?.data ?? AdsData()))],
            )
          : BetterPlayerAdsConfiguration(),
      headers: {
        'post-id': widget.videoData?.postID ?? '',
        'x-auth-user': SharedPreference().readStorage(SpKeys.email),
        'x-auth-token': SharedPreference().readStorage(SpKeys.userToken),
      },
      drmConfiguration: BetterPlayerDrmConfiguration(drmType: BetterPlayerDrmType.clearKey),
      bufferingConfiguration: const BetterPlayerBufferingConfiguration(
        minBufferMs: BetterPlayerBufferingConfiguration.defaultMinBufferMs,
        maxBufferMs: BetterPlayerBufferingConfiguration.defaultMaxBufferMs,
        bufferForPlaybackMs: BetterPlayerBufferingConfiguration.defaultBufferForPlaybackMs,
        bufferForPlaybackAfterRebufferMs: BetterPlayerBufferingConfiguration.defaultBufferForPlaybackAfterRebufferMs,
      ),
    );

    print('ini dataSource');
    // print(dataSource.adsConfiguration.postID);
    // print(dataSource.adsConfiguration.rolls);

    _betterPlayerController = BetterPlayerController(betterPlayerConfiguration);

    try {
      await _betterPlayerController?.setupDataSource(dataSource);
      // final height = widget.videoData?.metadata?.height ?? 0.0;
      // final width = widget.videoData?.metadata?.width ?? 0.0;
      if (height != 0.0 && width != 0.0) {
        final fixRatio = height / width;
        _betterPlayerController?.setOverriddenAspectRatio(fixRatio);
      } else {
        _betterPlayerController?.setOverriddenAspectRatio(_betterPlayerController?.videoPlayerController?.value.aspectRatio ?? 0);
      }
    } catch (e) {
      'Setup user data source error: $e'.logger();
    }

    _betterPlayerController?.addEventsListener(
      (event) {
        'betterPlay event: ${event.betterPlayerEventType}'.logger();
        if (event.betterPlayerEventType == BetterPlayerEventType.showingAds) {
          print('event ads : ${event.parameters}');
          _initializeAdsBetterPlayerControllerMap(BetterPlayerRoll.fromJson(event.parameters ?? {}));
        } else if (event.betterPlayerEventType == BetterPlayerEventType.openFullscreen) {
          _handleOpenFullScreenEvent();
        } else if (event.betterPlayerEventType == BetterPlayerEventType.hideFullscreen) {
          _handleHideFullScreenEvent();
        } else if (event.betterPlayerEventType == BetterPlayerEventType.pipStop) {
          // _betterPlayerController?.pause();
        }
        if (event.betterPlayerEventType == BetterPlayerEventType.finished) {
          if (widget.afterView != null) {
            widget.afterView!();
          }
        }
      },
    );
  }

  void _initializeAdsBetterPlayerControllerMap(BetterPlayerRoll? roll) async {
    print('roll roll');
    print(roll);
    if (roll != null) {
      _isStartFullScreen = _betterPlayerController?.isFullScreen ?? false;
      BetterPlayerConfiguration betterPlayerConfigurationAds = BetterPlayerConfiguration(
        overlayShownWhenFullScreen: true,
        overlay: _overlayLayout(),
        autoPlay: true,
        fullScreenByDefault: _betterPlayerController?.isFullScreen ?? false,
        autoDispose: false,
        fit: BoxFit.contain,
        deviceOrientationsAfterFullScreen: [DeviceOrientation.portraitUp],
        controlsConfiguration: BetterPlayerControlsConfiguration(
          enablePip: false,
          enableMute: false,
          enableSkips: false,
          skipAdsButtonAt: _newClipData?.data?.adsSkip ?? 3,
          enableQualities: false,
          enableAudioTracks: false,
          enableProgressBarDrag: false,
          controlBarColor: Colors.black26,
          imagesAdsVid: (widget.videoData?.isApsara ?? false) ? widget.videoData?.mediaThumbEndPoint : widget.videoData?.fullThumbPath,
          reportFuntion: () {
            _betterPlayerControllerMap?.pause();
            ShowBottomSheet.onReportSpamContent(context, postData: null, type: adsPopUp, onUpdate: () {
              _betterPlayerControllerMap?.nextVideoTimeStream;
            }, adsData: _newClipData?.data ?? AdsData());
            context.read<ReportNotifier>().adsData = _newClipData?.data;
            context.read<ReportNotifier>().typeContent = adsPopUp;
          },
        ),
      );
      BetterPlayerDataSource dataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        roll.rollUri ?? _betterPlayerRollUri ?? '',
        headers: {
          'post-id': widget.videoData?.postID ?? '', //. widget.videoData?.postID ?? '',
          'x-auth-user': SharedPreference().readStorage(SpKeys.email),
          'x-auth-token': SharedPreference().readStorage(SpKeys.userToken),
        },
      );
      print('rollUri ${roll.rollUri}');
      _betterPlayerRollUri = roll.rollUri;
      _betterPlayerControllerMap = BetterPlayerController(betterPlayerConfigurationAds);
      final ratio = _betterPlayerControllerMap?.videoPlayerController?.value.aspectRatio;
      // final height = _betterPlayerControllerMap?.videoPlayerController?.value.size?.height;
      // final width = _betterPlayerControllerMap?.videoPlayerController?.value.size?.width;
      if (ratio != null) {
        final height = widget.videoData?.metadata?.height ?? 0.0;
        final width = widget.videoData?.metadata?.width ?? 0.0;
        if (height != 0.0 && width != 0.0) {
          final fixRatio = height / width;
          _betterPlayerController?.setOverriddenAspectRatio(fixRatio);
        } else {
          _betterPlayerController?.setOverriddenAspectRatio(ratio);
        }
      }
      setStateIfMounted(() {
        _eventType = BetterPlayerEventType.showingAds;
        // pause user video
        _betterPlayerController?.pause();
        print('mulai iklan dong');
      });

      try {
        await _betterPlayerControllerMap?.setupDataSource(dataSource);

        setStateIfMounted(() async {
          if (_betterPlayerController?.isFullScreen ?? false) {
            print('play iklan fullscreen');
            // _betterPlayerControllerMap?.setOverlay(_overlayLayout());
            _betterPlayerControllerMap?.enterFullScreen();

            Future.delayed(const Duration(seconds: 3), () {
              _betterPlayerControllerMap?.play();
            });
            _pauseOrientationListener();
            Future.delayed(const Duration(seconds: 2), () {
              _resumeOrientationListener();
            });
          } else {
            print('play iklan');
            final height = widget.videoData?.metadata?.height ?? 0.0;
            final width = widget.videoData?.metadata?.width ?? 0.0;
            if (height != 0.0 && width != 0.0) {
              final fixRatio = height / width;
              _betterPlayerController?.setOverriddenAspectRatio(fixRatio);
            } else {
              _betterPlayerController?.setOverriddenAspectRatio(_betterPlayerController?.videoPlayerController?.value.aspectRatio ?? 0);
            }
            // _betterPlayerControllerMap?.setOverriddenAspectRatio(_betterPlayerControllerMap?.videoPlayerController?.value.aspectRatio ?? 0);
            _betterPlayerControllerMap?.play();
          }
        });
      } catch (e) {
        'Setup ads video data source error: $e'.logger();
      }

      _betterPlayerControllerMap?.addEventsListener((event) {
        // final second = _betterPlayerControllerMap?.videoPlayerController?.value.duration?.inSeconds ?? 0;
        final second = _betterPlayerControllerMap?.videoPlayerController?.value.position.inSeconds ?? 0;
        if (event.betterPlayerEventType == BetterPlayerEventType.showSkipAds) {
          'Show skip ads'.logger();

          'second end ads1 $second'.logger();
        }
        if (event.betterPlayerEventType == BetterPlayerEventType.closingAds) {
          print('skips di click');
          'Closing ads'.logger();
          'second end ads2 $second'.logger();
          if ((_newClipData?.data?.adsSkip ?? 2) <= second) {
            adsView(_newClipData?.data ?? AdsData(), second);
            _handleClosingAdsEvent(roll);
          }
        }
        if (event.betterPlayerEventType == BetterPlayerEventType.finished) {
          'Ads finished'.logger();
          'Delaay for 3 second'.logger();
          'second end ads3 $second'.logger();
          // adsView(_newClipData?.data ?? AdsData(), second);
          // Future.delayed(const Duration(seconds: 3), () {
          //   _handleClosingAdsEvent(roll);
          // });
        }
        final position = _betterPlayerControllerMap?.videoPlayerController?.position;
      });
    }
  }

  void getPosition() async {
    final result = await _betterPlayerControllerMap?.videoPlayerController?.value.position;
    // 'duration ${result.inSeconds}'.logger();
  }

  void _handleClosingAdsEvent(BetterPlayerRoll? roll) async {
    _removeAdsBetterPlayerControllerMap();

    // resume user video
    setStateIfMounted(() {
      _eventType = null;
      // _userVideo(_eventType == null);
      _betterPlayerController?.play();
      if (_isStartFullScreen) {
        Future.delayed(Duration(milliseconds: 500), () {
          _betterPlayerController?.enterFullScreen();
          setState(() {
            _isStartFullScreen = false;
          });
        });
      }
      print('play video after ads');
    });
  }

  void _removeAdsBetterPlayerControllerMap() async {
    if (_betterPlayerRollUri != null) {
      _betterPlayerController?.deleteAdsByUri(_betterPlayerRollUri ?? '');
      _betterPlayerControllerMap?.pause();
      if (_betterPlayerControllerMap?.isFullScreen ?? false) {
        // _betterPlayerController?.setOverlay(null);
        _betterPlayerControllerMap?.exitFullScreen();
      }
      Future.delayed(Duration.zero, () {
        _betterPlayerControllerMap?.dispose();
        _betterPlayerRollUri = null;
      });
    }
  }

  void _dispose() {
    _resetOrintationStream();
    _betterPlayerController?.pause();
    _betterPlayerController?.dispose();
    if ((_betterPlayerControllerMap?.isPlaying() ?? false) || (_betterPlayerControllerMap?.isBuffering() ?? false)) {
      _betterPlayerControllerMap?.pause();
    }
    // try {
    //   _betterPlayerControllerMap?.pause();
    // } catch (e) {
    //   'Pause Ads error: $e'.logger();
    // }
    _betterPlayerControllerMap?.dispose();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    CustomRouteObserver.routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute<dynamic>);
  }

  @override
  void deactivate() {
    _dispose();
    super.deactivate();
  }

  @override
  void dispose() {

    CustomRouteObserver.routeObserver.unsubscribe(this);
    _preventScreenShootOff();
    super.dispose();
  }

  @override
  void didPushNext() {
    Future.delayed(Duration.zero, () {
      if (_betterPlayerController?.isFullScreen == false) {
        _isMostBottomRouteInRouteStack = false;
      }
    });
    super.didPushNext();
  }

  @override
  void didPopNext() {
    print('');
    _isMostBottomRouteInRouteStack = true;
    super.didPopNext();
  }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  bool preventScreenShoot = false;
  void _preventScreenShootOn() async => await ScreenProtector.preventScreenshotOn();
  void _preventScreenShootOff() async => await ScreenProtector.preventScreenshotOff();

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return ValueListenableBuilder<bool>(
      valueListenable: _initializeVideo,
      builder: (_, value, __) => !value
          ? (widget.videoData?.reportedStatus == "BLURRED")
              ? VideoThumbnailReport(
                  videoData: widget.videoData,
                )
              : VideoThumbnail(
                  videoData: widget.videoData,
                  onDetail: widget.onDetail,
                  fn: () {
                    _initializeVideo.value = true;
                    _initialize();
                  },
                )
          : Stack(
              children: [
                ValueListenableBuilder<bool>(
                  valueListenable: _awaitInitial,
                  builder: (context, value, child) {
                    if (!value) {
                      print('progressBarVideo false');
                      return Center(
                          child: CircularProgressIndicator(
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      ));
                    } else {
                      print('_eventType $_eventType');
                      if (_eventType == BetterPlayerEventType.showingAds) {
                        print('url ads : ${_betterPlayerControllerMap}');
                        if (_betterPlayerControllerMap != null) {
                          return BetterPlayer(
                            controller: _betterPlayerControllerMap!,
                          );
                        } else {
                          print('progressBarVideo true');
                          return Center(
                            child: CircularProgressIndicator(
                              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                            ),
                          );
                        }
                      }
                      return BetterPlayer(
                        controller: _betterPlayerController!,
                      );
                    }
                  },
                ),
              ],
            ),
    );
  }

  Widget _overlayLayout(){
    return Expanded(
      child: Stack(
        children: [
          Positioned(
            left: 10,
            bottom: 40,
            child: Consumer<TranslateNotifierV2>(
              builder: (context, notifier, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Container(
                    //   width: context.getWidth() * 0.4,
                    //   child: const Text(
                    //     'The FUJIFILM X-T3 features the new X-Trans CMOS 4 sensor and X-Processor 4 image processing engine, ushering in a new, fourth generation of the X Series.',
                    //     style: TextStyle(color: Colors.white, fontSize: 10),
                    //   ),
                    // ),
                    eightPx,
                    Container(
                      padding: EdgeInsets.all(10),
                      color: Colors.white,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CustomBaseCacheImage(
                            imageUrl: _newClipData?.data?.avatar?.fullLinkURL,
                            memCacheWidth: 200,
                            memCacheHeight: 200,
                            imageBuilder: (_, imageProvider) {
                              return Container(
                                width: 27,
                                height: 27,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(Radius.circular(18)),
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: imageProvider,
                                  ),
                                ),
                              );
                            },
                            errorWidget: (_, __, ___) {
                              return Container(
                                width: 27,
                                height: 27,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(Radius.circular(18)),
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: const AssetImage('${AssetPath.pngPath}content-error.png'),
                                  ),
                                ),
                              );
                            },
                            emptyWidget: Container(
                              width: 27,
                              height: 27,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(Radius.circular(18)),
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: const AssetImage('${AssetPath.pngPath}content-error.png'),
                                ),
                              ),
                            ),
                          ),
                          sixteenPx,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _newClipData?.data?.adsDescription ?? '',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              fourPx,
                              Text(
                                _newClipData?.data?.adsUrlLink ?? '',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              )
                            ],
                          ),
                          twelvePx,
                          InkWell(
                            onTap: () async {
                              if(_newClipData?.data?.adsUrlLink?.isEmail() ?? false){
                                final email = _newClipData?.data?.adsUrlLink?.replaceAll('email:', '');
                                Navigator.pop(context);
                                Future.delayed(const Duration(milliseconds: 500), (){
                                  Routing().move(Routes.otherProfile, argument: OtherProfileArgument(senderEmail: email));
                                });
                              }else{
                                final uri = Uri.parse(_newClipData?.data?.adsUrlLink ?? '');
                                final second = _betterPlayerControllerMap?.videoPlayerController?.value.position.inSeconds ?? 0;
                                if (await canLaunchUrl(uri)) {
                                  print('adsView part 1');
                                  adsView(_newClipData?.data ?? AdsData(), second);
                                  await launchUrl(
                                    uri,
                                    mode: LaunchMode.externalApplication,
                                  );
                                } else
                                  // can't launch url, there is some error
                                  throw "Could not launch $uri";
                              }

                            },
                            child: Container(
                              child: Text(
                                notifier.translate.learnMore ?? 'Learn More',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 7,
                                ),
                              ),
                              padding: EdgeInsets.only(left: 16, bottom: 10, top: 10, right: 16),
                              decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)), color: KHyppeButtonAds),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
