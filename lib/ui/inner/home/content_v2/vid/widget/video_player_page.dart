import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hyppe/core/services/route_observer_service.dart';
import 'package:hyppe/ui/constant/widget/after_first_layout_mixin.dart';
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

  AdvertisingData? _clipsData;
  String? _betterPlayerRollUri;
  BetterPlayerEventType? _eventType;
  bool _isMostBottomRouteInRouteStack = true;
  final Map<String?, BetterPlayerController?> _betterPlayerControllerMap = {};

  bool _startWithOrientationCondition = false;
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
            _betterPlayerController?.exitFullScreen();
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
            _betterPlayerController?.enterFullScreen();
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

  Future _initAds() async {
    final email = SharedPreference().readStorage(SpKeys.email);

    try {
      if (_clipsData == null) {
        /// Dummy Data
        // final _dummyAds = {
        //   "postID": "cb888306-2827-47b2-90fa-5930e4a9a9b9",
        //   "preRoll": [
        //     {
        //       "preRollDuration": 9,
        //       "preRollUri": "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_fmp4/master.m3u8",
        //     }
        //   ],
        //   "midRoll": [
        //     {
        //       "midRollDuration": 9,
        //       "midRollUri": "https://moctobpltc-i.akamaihd.net/hls/live/571329/eight/playlist.m3u8",
        //     }
        //   ],
        //   "postRoll": [
        //     {
        //       "postRollDuration": 9,
        //       "postRollUri":
        //           "https://multiplatform-f.akamaihd.net/i/multi/will/bunny/big_buck_bunny_,640x360_400,640x360_700,640x360_1000,950x540_1500,.f4v.csmil/master.m3u8",
        //     }
        //   ]
        // };

        // _clipsData = AdvertisingData.fromJson(_dummyAds, widget.videoData?.metadata);
        /// End Dummy Data

        final param = AdvertisingArgument(
          email: email,
          metadata: widget.videoData?.metadata,
          postID: widget.videoData?.postID ?? '',
        );

        final notifier = AdvertisingBloc();
        await notifier.advertisingBlocV2(context, argument: param);

        final fetch = notifier.advertisingFetchFetch;

        if (fetch.advertisingState == AdvertisingState.getAdvertisingBlocSuccess) {
          _clipsData = fetch.data;
        }

        _eventType = (_clipsData?.preRoll?.isNotEmpty ?? false) ? BetterPlayerEventType.showingAds : null;

        _awaitInitial.value = true;

        // _clipsData = jsonDecode(await http.read(Uri.parse(APIs.baseApi + "/images/videos/clips.json")));
      }
    } catch (e) {
      'Failed to fetch ads data'.logger();
    }
  }

  void _initialize() async {
    'Hyppe Vid Post Id ${widget.videoData?.postID}'.logger();
    'Hyppe Vid Url ${widget.videoData?.fullContentPath}'.logger();
    'Hyppe Vid Email ${SharedPreference().readStorage(SpKeys.email)}'.logger();
    'Hyppe Vid Token ${SharedPreference().readStorage(SpKeys.userToken)}'.logger();
    await _initAds();
    _userVideo(_eventType == null);
  }

  void _userVideo(bool autoPlay) async {
    BetterPlayerConfiguration betterPlayerConfiguration = BetterPlayerConfiguration(
      autoDispose: false,
      autoPlay: autoPlay,
      fit: BoxFit.contain,
      showPlaceholderUntilPlay: true,
      deviceOrientationsAfterFullScreen: [DeviceOrientation.portraitUp],
      controlsConfiguration: const BetterPlayerControlsConfiguration(
        enableFullscreen: true,
        controlBarColor: Colors.black26,
      ),
    );
    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      widget.videoData?.fullContentPath ?? '',
      // 'https://multiplatform-f.akamaihd.net/i/multi/will/bunny/big_buck_bunny_,640x360_400,640x360_700,640x360_1000,950x540_1500,.f4v.csmil/master.m3u8',
      adsConfiguration: BetterPlayerAdsConfiguration(
        postID: widget.videoData?.postID ?? '',
        rolls: _clipsData?.ads.map((e) => BetterPlayerRoll(rollUri: e.rollUri, rollDuration: e.playingAt)).toList(),
      ),
      headers: {
        'post-id': widget.videoData?.postID ?? '',
        'x-auth-user': SharedPreference().readStorage(SpKeys.email),
        'x-auth-token': SharedPreference().readStorage(SpKeys.userToken),
      },
      bufferingConfiguration: const BetterPlayerBufferingConfiguration(
        minBufferMs: BetterPlayerBufferingConfiguration.defaultMinBufferMs,
        maxBufferMs: BetterPlayerBufferingConfiguration.defaultMaxBufferMs,
        bufferForPlaybackMs: BetterPlayerBufferingConfiguration.defaultBufferForPlaybackMs,
        bufferForPlaybackAfterRebufferMs: BetterPlayerBufferingConfiguration.defaultBufferForPlaybackAfterRebufferMs,
      ),
    );

    _betterPlayerController = BetterPlayerController(betterPlayerConfiguration);

    try {
      await _betterPlayerController?.setupDataSource(dataSource);
      _betterPlayerController?.setOverriddenAspectRatio(_betterPlayerController!.videoPlayerController!.value.aspectRatio);
    } catch (e) {
      'Setup user data source error: $e'.logger();
    }

    _betterPlayerController?.addEventsListener(
      (event) {
        if (event.betterPlayerEventType == BetterPlayerEventType.showingAds) {
          _initializeAdsBetterPlayerControllerMap(BetterPlayerRoll.fromJson(event.parameters ?? {}));
        } else if (event.betterPlayerEventType == BetterPlayerEventType.openFullscreen) {
          _handleOpenFullScreenEvent();
        } else if (event.betterPlayerEventType == BetterPlayerEventType.hideFullscreen) {
          _handleHideFullScreenEvent();
        }

        if (event.betterPlayerEventType == BetterPlayerEventType.finished) {
          widget.afterView!();
        }
      },
    );
  }

  void _initializeAdsBetterPlayerControllerMap(BetterPlayerRoll? roll) async {
    if (roll != null) {
      if (_betterPlayerControllerMap.containsKey(roll.rollUri)) {
        'Ads video controller already exists'.logger();
        return;
      }
      BetterPlayerConfiguration betterPlayerConfigurationAds = const BetterPlayerConfiguration(
        autoPlay: false,
        autoDispose: false,
        fit: BoxFit.contain,
        deviceOrientationsAfterFullScreen: [DeviceOrientation.portraitUp],
        controlsConfiguration: BetterPlayerControlsConfiguration(
          enablePip: false,
          enableMute: false,
          enableSkips: false,
          skipAdsButtonAt: 5,
          enableQualities: false,
          enableAudioTracks: false,
          enableProgressBarDrag: false,
          controlBarColor: Colors.black26,
        ),
      );
      BetterPlayerDataSource dataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        roll.rollUri ?? '',
        headers: {
          'post-id': widget.videoData?.postID ?? '',
          'x-auth-user': SharedPreference().readStorage(SpKeys.email),
          'x-auth-token': SharedPreference().readStorage(SpKeys.userToken),
        },
      );

      _betterPlayerRollUri = roll.rollUri;

      _betterPlayerControllerMap[_betterPlayerRollUri] = BetterPlayerController(betterPlayerConfigurationAds);

      setState(() {
        _eventType = BetterPlayerEventType.showingAds;
        // pause user video
        _betterPlayerController?.pause();
      });

      try {
        await _betterPlayerControllerMap[_betterPlayerRollUri]?.setupDataSource(dataSource);

        setState(() {
          _betterPlayerControllerMap[_betterPlayerRollUri]
              ?.setOverriddenAspectRatio(_betterPlayerControllerMap[_betterPlayerRollUri]!.videoPlayerController!.value.aspectRatio);
          _betterPlayerControllerMap[_betterPlayerRollUri]?.play();
        });
      } catch (e) {
        'Setup ads video data source error: $e'.logger();
      }

      _betterPlayerControllerMap[_betterPlayerRollUri]?.addEventsListener((event) {
        if (event.betterPlayerEventType == BetterPlayerEventType.showSkipAds) {
          'Show skip ads'.logger();
        }
        if (event.betterPlayerEventType == BetterPlayerEventType.closingAds) {
          'Closing ads'.logger();
          _handleClosingAdsEvent(roll);
        }
        if (event.betterPlayerEventType == BetterPlayerEventType.finished) {
          'Ads finished'.logger();
          'Delaay for 3 second'.logger();
          Future.delayed(const Duration(seconds: 3), () {
            _handleClosingAdsEvent(roll);
          });
        }
      });
    }
  }

  void _handleClosingAdsEvent(BetterPlayerRoll? roll) async {
    _removeAdsBetterPlayerControllerMap();
    // resume user video
    setState(() {
      _eventType = null;
      _betterPlayerController?.play();
    });
  }

  void _removeAdsBetterPlayerControllerMap() async {
    if (_betterPlayerRollUri != null) {
      _betterPlayerController?.deleteAdsByUri(_betterPlayerRollUri ?? '');
      _betterPlayerControllerMap[_betterPlayerRollUri]?.pause();
      if (_betterPlayerControllerMap[_betterPlayerRollUri]?.isFullScreen ?? false) {
        _betterPlayerControllerMap[_betterPlayerRollUri]?.exitFullScreen();
      }
      Future.delayed(Duration.zero, () {
        _betterPlayerControllerMap[_betterPlayerRollUri]?.dispose();
        _betterPlayerControllerMap.clear();
        _betterPlayerRollUri = null;
      });
    }
  }

  void _dispose() {
    _resetOrintationStream();
    _betterPlayerController?.pause();
    _betterPlayerController?.dispose();
    try {
      if (_betterPlayerControllerMap.isNotEmpty) {
        _betterPlayerControllerMap[_betterPlayerRollUri]?.pause();
      }
    } catch (e) {
      'Pause Ads error: $e'.logger();
    }
    for (var e in _betterPlayerControllerMap.values) {
      e?.dispose();
    }
    _betterPlayerControllerMap.clear();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    CustomRouteObserver.routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute<dynamic>);
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
    _isMostBottomRouteInRouteStack = true;
    super.didPopNext();
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
                      return const CircularProgressIndicator();
                    } else {
                      if (_eventType == BetterPlayerEventType.showingAds) {
                        if (_betterPlayerControllerMap[_betterPlayerRollUri] != null &&
                            (_betterPlayerControllerMap[_betterPlayerRollUri]?.isVideoInitialized() ?? false)) {
                          return BetterPlayer(
                            controller: _betterPlayerControllerMap[_betterPlayerRollUri]!,
                          );
                        } else {
                          return Center(
                            child: CircularProgressIndicator(
                              backgroundColor: Theme.of(context).colorScheme.primaryVariant,
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
