import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hyppe/core/bloc/ads_video/bloc.dart';
import 'package:hyppe/core/bloc/ads_video/state.dart';
import 'package:hyppe/core/bloc/posts_v2/bloc.dart';
import 'package:hyppe/core/bloc/posts_v2/state.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/advertising/ads_video_data.dart';
import 'package:hyppe/core/models/collection/advertising/view_ads_request.dart';
import 'package:hyppe/core/services/route_observer_service.dart';
import 'package:hyppe/ui/constant/widget/after_first_layout_mixin.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:native_device_orientation/native_device_orientation.dart';

import 'package:better_player/better_player.dart';

import 'package:hyppe/core/bloc/advertising/bloc.dart';
import 'package:hyppe/core/bloc/advertising/state.dart';

import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';

import 'package:hyppe/core/models/collection/advertising/advertising_data.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';

import 'package:hyppe/core/extension/log_extension.dart';

import 'package:hyppe/core/services/shared_preference.dart';

import 'package:hyppe/core/arguments/advertising_argument.dart';

import 'package:hyppe/ui/inner/home/content_v2/vid/widget/video_thumbnail.dart';

import '../../../../../../core/constants/asset_path.dart';
import '../../../../../../core/constants/themes/hyppe_colors.dart';

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

class _VideoPlayerPageState extends State<VideoPlayerPage>
    with RouteAware, AfterFirstLayoutMixin {
  BetterPlayerController? _betterPlayerController;
  final ValueNotifier<bool> _awaitInitial = ValueNotifier(false);
  final ValueNotifier<bool> _initializeVideo = ValueNotifier(false);

  // AdvertisingData? _clipsData;
  AdsVideo? _newClipData;
  String? _betterPlayerRollUri;
  BetterPlayerEventType? _eventType;
  bool _isMostBottomRouteInRouteStack = true;
  BetterPlayerController? _betterPlayerControllerMap;

  bool _startWithOrientationCondition = false;
  StreamSubscription<NativeDeviceOrientation>? _orientationStream;
  final _nativeDeviceOrientationCommunicator =
      NativeDeviceOrientationCommunicator();

  int countAds = 0;

  @override
  void initState() {
    super.initState();
  }

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

  void _orientationCondition(NativeDeviceOrientation orientation, bool isAds) {
    final controller =
        (isAds ? _betterPlayerControllerMap : _betterPlayerController);
    if (orientation == NativeDeviceOrientation.portraitUp) {
      if (controller != null) {
        if (_eventType != BetterPlayerEventType.showingAds) {
          if (controller.isFullScreen) {
            controller.exitFullScreen();
            _pauseOrientationListener();
            Future.delayed(const Duration(seconds: 2), () {
              _resumeOrientationListener();
            });
            return;
          }
        }
      }
    }

    if (orientation == NativeDeviceOrientation.landscapeLeft ||
        orientation == NativeDeviceOrientation.landscapeRight) {
      if (controller != null) {
        if (_eventType != BetterPlayerEventType.showingAds) {
          if (controller.isFullScreen == false) {
            controller.enterFullScreen();
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

  void _listenToNativeDeviceOrientation(bool isAds) {
    _orientationStream = _nativeDeviceOrientationCommunicator
        .onOrientationChanged(useSensor: true)
        .listen((orientation) {
      if (_startWithOrientationCondition && _isMostBottomRouteInRouteStack) {
        _orientationCondition(orientation, isAds);
      }
    });
  }

  void _handleOpenFullScreenEvent(bool isAds) {
    if (_orientationStream == null) {
      _listenToNativeDeviceOrientation(isAds);
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

  Future _newInitAds() async {
    try {
      if (_newClipData == null) {
        await getAdsVideo();
      }
    } catch (e) {
      'Failed to fetch ads data : $e'.logger();
    }
  }

  Future getAdsVideo() async {
    try {
      final notifier = AdsVideoBloc();
      await notifier.adsVideoBloc(context);
      final fetch = notifier.adsVideoFetch;

      if (fetch.adsVideoState == AdsVideoState.getAdsVideoBlocSuccess) {
        // print('data : ${fetch.data.toString()}');
        _newClipData = fetch.data;
        print('videoId : ${_newClipData?.data?.videoId}');
        await getAdsVideoApsara(_newClipData!.data!.videoId!);
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
        print('jsonMap video Apsara : $jsonMap');
        _betterPlayerRollUri = jsonMap['PlayUrl'];
        print('get Ads Video');
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
        print('jsonMap video Apsara : $jsonMap');
        widget.videoData?.fullContentPath = jsonMap['PlayUrl'];
      }
    } catch (e) {
      'Failed to fetch ads data ${e}'.logger();
    }
  }

  Future adsView(AdsData data, int time) async {
    try {
      final notifier = AdsVideoBloc();
      final request = ViewAdsRequest(
          watchingTime: time, adsId: data.adsId, useradsId: data.useradsId);
      await notifier.viewAdsBloc(context, request);

      // final fetch = notifier.adsVideoFetch;

    } catch (e) {
      'Failed hit view ads ${e}'.logger();
    }
  }

  void getCountVid() async {
    String _countAds = SharedPreference().readStorage(SpKeys.countAds);
    if (_countAds == null) {
      print('kesini video');
      SharedPreference().writeStorage(SpKeys.countAds, '0');
      countAds = 0;
    } else {
      print('kesono');
      countAds = int.parse(_countAds);
    }
  }

  void _initialize() async {
    'Hyppe Vid Post ID ${widget.videoData?.postID}'.logger();
    'Hyppe Vid Url ${widget.videoData?.fullContentPath}'.logger();
    'Hyppe Vid Email ${SharedPreference().readStorage(SpKeys.email)}'.logger();
    'Hyppe Vid Token ${SharedPreference().readStorage(SpKeys.userToken)}'
        .logger();
    'Hyppe Vid isApsara ${widget.videoData!.isApsara!}'.logger();
    if (widget.videoData!.isApsara!) {
      await getVideoApsara(widget.videoData!.apsaraId!);
    }
    'Hyppe Vid Url ${widget.videoData?.fullContentPath}'.logger();

    // getCountVid();
    print('count Ads $countAds');
    await _newInitAds();
    print('post metadata : ${widget.videoData?.metadata?.toJson().toString()}');
    // if (countAds < 0) {
    //
    //   await _newInitAds();
    //
    // } else {
    //
    //   _clipsData = AdvertisingData.fromJson({}, widget.videoData?.metadata);
    // _eventType = (_newClipData != null) ? BetterPlayerEventType.showingAds : null;
    //   print('get Ads Video1');
    // }
    print('ready to play');
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
        result = (widget.videoData?.metadata?.postRoll ?? 0) != 0
            ? widget.videoData!.metadata!.postRoll!
            : duration - 1;
        break;
      default:
        result = 0;
        break;
    }
    return result;
  }

  void _userVideo(bool autoPlay) async {
    print('test iklan data');
    print(widget.videoData?.postID);
    // print(_clipsData!.ads[0].rollDuration);
    // print(_clipsData!.ads[1].rollUri);
    // print(_clipsData!.ads[1].playingAt);
    // print(_clipsData!.ads[1].playingAt);
    // print(_clipsData!.ads[1].rollDuration);
    // print(_clipsData!.ads[1].rollUri);
    // print(_clipsData!.ads[2].playingAt);
    // print(_clipsData!.ads[2].rollDuration);
    // print(_clipsData!.ads[2].rollUri);
    // setStateIfMounted(() {
    //   countAds += 1;
    //   if (countAds > 4) {
    //     countAds = 0;
    //   }
    //   SharedPreference().writeStorage(SpKeys.countAds, countAds.toString());
    // });
    final keyAdsOverlay = GlobalKey();
    BetterPlayerConfiguration betterPlayerConfiguration =
        BetterPlayerConfiguration(
          overlay: (_betterPlayerController?.isFullScreen ?? false) ? Expanded(
            child: Stack(
              children: [
                Positioned(
                  left: 10,
                  bottom: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: context.getWidth() * 0.5,
                        child: const Text(
                          'The FUJIFILM X-T3 features the new X-Trans CMOS 4 sensor and X-Processor 4 image processing engine, ushering in a new, fourth generation of the X Series.',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                      eightPx,
                      Container(
                        key: keyAdsOverlay,
                        padding: EdgeInsets.all(10),
                        color: Colors.white,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const CustomIconWidget(
                              iconData: '${AssetPath.vectorPath}fujifilm.svg',
                              width: 27,
                              height: 27,
                            ),
                            sixteenPx,
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text('Fujifilm', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),),
                                fourPx,
                                Text('fujifilmindonesia.co.id', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),)
                              ],
                            ),
                            twelvePx,
                            InkWell(
                              onTap: (){

                              },
                              child: Container(
                                child: Text('Learn more', style: TextStyle(color: Colors.white, fontSize: 7,),),
                                padding: EdgeInsets.only(left: 16, bottom: 4, top: 4, right: 16),
                                decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)), color: KHyppeButtonAds),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ) : null,
      autoDispose: true,
      autoPlay: autoPlay,
      fit: BoxFit.contain,
      showPlaceholderUntilPlay: true,
      deviceOrientationsAfterFullScreen: [DeviceOrientation.portraitUp],
      autoDetectFullscreenAspectRatio: true,
      autoDetectFullscreenDeviceOrientation: true,
      controlsConfiguration: const BetterPlayerControlsConfiguration(
        enableFullscreen: true,
        controlBarColor: Color.fromARGB(10, 0, 0, 1),
      ),
    );
    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      widget.videoData?.fullContentPath ??
          'https://outin-c01c93ffe24211ec9bf900163e013357.oss-ap-southeast-5.aliyuncs.com/5d92f36afb3d4a75b7ecef398107278e/780a82f6569143c591c1c2afeca8e968-c4535eb7cbd8313949f96a6a946ef25d-fd.mp4?Expires=1664346280&OSSAccessKeyId=LTAI3DkxtsbUyNYV&Signature=0%2FOBtRvwz06egP4znSAvQ1AfQqE%3D',
      adsConfiguration: BetterPlayerAdsConfiguration(
        postID: widget.videoData?.postID ?? '',
        rolls: [
          if(_betterPlayerRollUri != null)
          BetterPlayerRoll(
              rollUri: _betterPlayerRollUri,
              rollDuration: secondOfAds(_newClipData?.data ?? AdsData()))
        ],
      ),
      headers: {
        'post-id': widget.videoData?.postID ?? '',
        'x-auth-user': SharedPreference().readStorage(SpKeys.email),
        'x-auth-token': SharedPreference().readStorage(SpKeys.userToken),
      },
      bufferingConfiguration: const BetterPlayerBufferingConfiguration(
        minBufferMs: BetterPlayerBufferingConfiguration.defaultMinBufferMs,
        maxBufferMs: BetterPlayerBufferingConfiguration.defaultMaxBufferMs,
        bufferForPlaybackMs:
            BetterPlayerBufferingConfiguration.defaultBufferForPlaybackMs,
        bufferForPlaybackAfterRebufferMs: BetterPlayerBufferingConfiguration
            .defaultBufferForPlaybackAfterRebufferMs,
      ),
    );

    print('ini dataSource');
    // print(dataSource.adsConfiguration!.postID);
    // print(dataSource.adsConfiguration!.rolls);

    _betterPlayerController = BetterPlayerController(betterPlayerConfiguration);

    try {
      await _betterPlayerController?.setupDataSource(dataSource);
      _betterPlayerController?.setOverriddenAspectRatio(
          _betterPlayerController!.videoPlayerController!.value.aspectRatio);
    } catch (e) {
      'Setup user data source error: $e'.logger();
    }

    _betterPlayerController?.addEventsListener(
      (event) {
        print('ini event');
        print(event.betterPlayerEventType);
        if (event.betterPlayerEventType == BetterPlayerEventType.showingAds) {
          print('event ads : ${event.parameters}');
          _initializeAdsBetterPlayerControllerMap(
              BetterPlayerRoll.fromJson(event.parameters ?? {}));
        } else if (event.betterPlayerEventType ==
            BetterPlayerEventType.openFullscreen) {
          _handleOpenFullScreenEvent(false);
        } else if (event.betterPlayerEventType ==
            BetterPlayerEventType.hideFullscreen) {
          _handleHideFullScreenEvent();
        }

        if (event.betterPlayerEventType == BetterPlayerEventType.finished) {
          widget.afterView!();
        }
      },
    );
  }

  void _initializeAdsBetterPlayerControllerMap(BetterPlayerRoll? roll) async {
    print('roll roll');
    print(roll);
    if (roll != null) {
      BetterPlayerConfiguration betterPlayerConfigurationAds =
          BetterPlayerConfiguration(

        autoPlay: true,
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
          imagesAdsVid: (widget.videoData?.isApsara ?? false)
              ? widget.videoData?.mediaThumbEndPoint
              : widget.videoData?.fullThumbPath,
        ),
      );
      BetterPlayerDataSource dataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        roll.rollUri ?? _betterPlayerRollUri ?? '',
        headers: {
          'post-id':
              widget.videoData!.postID!, //. widget.videoData?.postID ?? '',
          'x-auth-user': SharedPreference().readStorage(SpKeys.email),
          'x-auth-token': SharedPreference().readStorage(SpKeys.userToken),
        },
      );
      print('rollUri ${roll.rollUri}');
      _betterPlayerRollUri = roll.rollUri;
      _betterPlayerControllerMap =
          BetterPlayerController(betterPlayerConfigurationAds);
      setStateIfMounted(() {
        _eventType = BetterPlayerEventType.showingAds;
        // pause user video
        _betterPlayerController?.pause();
        print('mulai iklan dong');
      });

      try {
        await _betterPlayerControllerMap?.setupDataSource(dataSource);

        setStateIfMounted(() {
          if (_betterPlayerController?.isFullScreen ?? false) {
            print('play iklan fullscreen');
            _betterPlayerControllerMap?.play();
            _pauseOrientationListener();
            Future.delayed(const Duration(seconds: 2), () {
              _resumeOrientationListener();
            });
          } else {
            print('play iklan');
            _betterPlayerControllerMap?.setOverriddenAspectRatio(
                _betterPlayerControllerMap!
                    .videoPlayerController!.value.aspectRatio);
            _betterPlayerControllerMap?.play();
          }
        });
      } catch (e) {
        'Setup ads video data source error: $e'.logger();
      }

      _betterPlayerControllerMap?.addEventsListener((event) {
        // final second = _betterPlayerControllerMap?.videoPlayerController?.value.duration?.inSeconds ?? 0;
        final second = _betterPlayerControllerMap
                ?.videoPlayerController?.value.position.inSeconds ??
            0;
        if (event.betterPlayerEventType ==
            BetterPlayerEventType.openFullscreen) {
          _handleOpenFullScreenEvent(true);
        }
        if (event.betterPlayerEventType == BetterPlayerEventType.showSkipAds) {
          'Show skip ads'.logger();

          'second end ads1 $second'.logger();
        }
        if (event.betterPlayerEventType == BetterPlayerEventType.closingAds) {
          print('skips di click');
          'Closing ads'.logger();
          _handleClosingAdsEvent(roll);
          'second end ads2 $second'.logger();
          adsView(_newClipData?.data ?? AdsData(), second);
        }
        if (event.betterPlayerEventType == BetterPlayerEventType.finished) {
          'Ads finished'.logger();
          'Delaay for 3 second'.logger();
          'second end ads3 $second'.logger();
          adsView(_newClipData?.data ?? AdsData(), second);
          Future.delayed(const Duration(seconds: 3), () {
            _handleClosingAdsEvent(roll);
          });
        }
        final position =
            _betterPlayerControllerMap?.videoPlayerController?.position;
      });
    }
  }

  void getPosition() async {
    final result =
        await _betterPlayerControllerMap?.videoPlayerController?.value.position;
    // 'duration ${result.inSeconds}'.logger();
  }

  void _handleClosingAdsEvent(BetterPlayerRoll? roll) async {
    _removeAdsBetterPlayerControllerMap();
    // resume user video
    setStateIfMounted(() {
      _eventType = null;
      // _userVideo(_eventType == null);
      _betterPlayerController?.play();
      print('play video');
    });
  }

  void _removeAdsBetterPlayerControllerMap() async {
    if (_betterPlayerRollUri != null) {
      _betterPlayerController?.deleteAdsByUri(_betterPlayerRollUri ?? '');
      _betterPlayerControllerMap?.pause();
      if (_betterPlayerControllerMap?.isFullScreen ?? false) {
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
    try {
      _betterPlayerControllerMap?.pause();
    } catch (e) {
      'Pause Ads error: $e'.logger();
    }
    _betterPlayerControllerMap?.dispose();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    CustomRouteObserver.routeObserver
        .subscribe(this, ModalRoute.of(context) as PageRoute<dynamic>);
  }

  @override
  void dispose() {
    _dispose();
    CustomRouteObserver.routeObserver.unsubscribe(this);
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

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return ValueListenableBuilder<bool>(
      valueListenable: _initializeVideo,
      builder: (_, value, __) => !value
          ? VideoThumbnail(
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
                      return const CircularProgressIndicator();
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
                              backgroundColor:
                                  Theme.of(context).colorScheme.primaryVariant,
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
}
