import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hyppe/core/bloc/posts_v2/bloc.dart';
import 'package:hyppe/core/bloc/posts_v2/state.dart';
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

  int countAds = 0;

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
    print('masuk iklan');
    final email = SharedPreference().readStorage(SpKeys.email);

    try {
      if (_clipsData == null) {
        // / Dummy Data
        final _dummyAds = {
          "postID": "b40d0927-b41d-4702-8da6-f99138675c96",
          "preRoll": [
            // {
            // "preRollDuration": 3,
            // "preRollUri": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
            // "preRollUri": "https://moctobpltc-i.akamaihd.net/hls/live/571329/eight/playlist.m3u8",
            // }
          ],
          "midRoll": [
            {
              "midRollDuration": 5,
              "midRollUri": "https://staging.hyppe.app/stream/784a719c-f67e-46d6-b601-2ee49687655a.m3u8",
              // "midRollUri": "https://moctobpltc-i.akamaihd.net/hls/live/571329/eight/playlist.m3u8",
            }
          ],
          "postRoll": [
            {
              "postRollDuration": 9,
              "postRollUri": "http://www.exit109.com/~dnn/clips/RW20seconds_1.mp4 ",
            }
          ]
        };

        _clipsData = AdvertisingData.fromJson(_dummyAds, widget.videoData?.metadata);

        /// End Dummy Data

        final param = AdvertisingArgument(
          email: email,
          metadata: widget.videoData?.metadata,
          postID: widget.videoData?.postID ?? '',
        );

        final notifier = AdvertisingBloc();
        await notifier.advertisingBlocV2(context, argument: param);

        final fetch = notifier.advertisingFetchFetch;

        // if (fetch.advertisingState == AdvertisingState.getAdvertisingBlocSuccess) {
        //   _clipsData = fetch.data;
        // }

        _eventType = (_clipsData?.preRoll?.isNotEmpty ?? false) ? BetterPlayerEventType.showingAds : null;

        _awaitInitial.value = true;

        // _clipsData = jsonDecode(await http.read(Uri.parse(APIs.baseApi + "/images/videos/clips.json")));
      }
    } catch (e) {
      'Failed to fetch ads data'.logger();
    }
  }

  Future getVideoApsara(String apsaraId) async {
    try {
      final notifier = PostsBloc();
      await notifier.getVideoApsaraBlocV2(context, apsaraId: apsaraId);

      final fetch = notifier.postsFetch;

      if (fetch.postsState == PostsState.videoApsaraSuccess) {
        Map jsonMap = json.decode(fetch.data.toString());
        widget.videoData?.fullContentPath = jsonMap['PlayUrl'];
      }
    } catch (e) {
      'Failed to fetch ads data ${e}'.logger();
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
    'Hyppe Vid Token ${SharedPreference().readStorage(SpKeys.userToken)}'.logger();
    'Hyppe Vid isApsara ${widget.videoData!.isApsara!}'.logger();
    if (widget.videoData!.isApsara!) {
      await getVideoApsara(widget.videoData!.apsaraId!);
    }
    'Hyppe Vid Url ${widget.videoData?.fullContentPath}'.logger();

    // getCountVid();
    print(countAds);
    await _initAds();
    // if (countAds < 1) {
    //   await _initAds();
    // } else {
    //   _clipsData = AdvertisingData.fromJson({}, widget.videoData?.metadata);
    //   _eventType = (_clipsData?.preRoll?.isNotEmpty ?? false) ? BetterPlayerEventType.showingAds : null;
    //   _awaitInitial.value = true;
    // }

    _userVideo(_eventType == null, true);
  }

  void _userVideo(bool autoPlay, bool isAds) async {
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

    BetterPlayerConfiguration betterPlayerConfiguration = BetterPlayerConfiguration(
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
      widget.videoData?.fullContentPath ?? '',
      adsConfiguration: isAds ? BetterPlayerAdsConfiguration(
        postID: widget.videoData?.postID ?? '',
        rolls: _clipsData?.ads.map((e) => BetterPlayerRoll(rollUri: e.rollUri, rollDuration: e.playingAt)).toList(),
      ): BetterPlayerAdsConfiguration(),
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

    print('ini dataSource');
    print(dataSource.adsConfiguration!.postID);
    print(dataSource.adsConfiguration!.rolls);

    _betterPlayerController = BetterPlayerController(betterPlayerConfiguration);

    try {
      await _betterPlayerController?.setupDataSource(dataSource);
      _betterPlayerController?.setOverriddenAspectRatio(_betterPlayerController!.videoPlayerController!.value.aspectRatio);
    } catch (e) {
      'Setup user data source error: $e'.logger();
    }

    _betterPlayerController?.addEventsListener(
      (event) {
        print('ini event');
        print(event.betterPlayerEventType);
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
    print('roll roll');
    print(roll);
    if (roll != null) {
      if (_betterPlayerControllerMap.containsKey(roll.rollUri)) {
        'Ads video controller already exists'.logger();
        return;
      }
      BetterPlayerConfiguration betterPlayerConfigurationAds = BetterPlayerConfiguration(
        autoPlay: true,
        autoDispose: false,
        fit: BoxFit.contain,
        deviceOrientationsAfterFullScreen: [DeviceOrientation.portraitUp],
        controlsConfiguration: BetterPlayerControlsConfiguration(
          enablePip: false,
          enableMute: false,
          enableSkips: false,
          skipAdsButtonAt: 7,
          enableQualities: false,
          enableAudioTracks: false,
          enableProgressBarDrag: false,
          controlBarColor: Colors.black26,
          imagesAdsVid: widget.videoData?.fullThumbPath,
        ),
      );
      BetterPlayerDataSource dataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        roll.rollUri ?? '',
        headers: {
          'post-id': _clipsData!.postID!, //. widget.videoData?.postID ?? '',
          'x-auth-user': SharedPreference().readStorage(SpKeys.email),
          'x-auth-token': SharedPreference().readStorage(SpKeys.userToken),
        },
      );

      _betterPlayerRollUri = roll.rollUri;
      _betterPlayerControllerMap[_betterPlayerRollUri] = BetterPlayerController(betterPlayerConfigurationAds);
      setStateIfMounted(() {
        _eventType = BetterPlayerEventType.showingAds;
        // pause user video
        _betterPlayerController?.pause();
        print('mulai iklan dong');
      });

      try {
        await _betterPlayerControllerMap[_betterPlayerRollUri]?.setupDataSource(dataSource);

        setStateIfMounted(() {
          _betterPlayerControllerMap[_betterPlayerRollUri]?.setOverriddenAspectRatio(_betterPlayerControllerMap[_betterPlayerRollUri]!.videoPlayerController!.value.aspectRatio);
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
          print('skips di click');
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
    setStateIfMounted(() {
      _eventType = null;
      _userVideo(_eventType == null, false);
      _betterPlayerController?.play();
      print('play video');
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
                      return const CircularProgressIndicator();
                    } else {
                      print('_eventType $_eventType');
                      if (_eventType == BetterPlayerEventType.showingAds) {
                        if (_betterPlayerControllerMap[_betterPlayerRollUri] != null && (_betterPlayerControllerMap[_betterPlayerRollUri]?.isVideoInitialized() ?? false)) {
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
