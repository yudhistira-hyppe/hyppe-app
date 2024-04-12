import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_aliplayer/flutter_aliplayer.dart';
import 'package:flutter_aliplayer/flutter_aliplayer_factory.dart';
import 'package:hyppe/app.dart';
import 'package:hyppe/core/bloc/posts_v2/bloc.dart';
import 'package:hyppe/core/bloc/posts_v2/state.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/kyc_status.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/constants/utils.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/entities/like/notifier.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/widget/ads/ads_player_page.dart';
import 'package:hyppe/ui/constant/widget/after_first_layout_mixin.dart';
import 'package:hyppe/ui/constant/widget/button_boost.dart';
import 'package:hyppe/ui/constant/widget/custom_appbar.dart';
import 'package:hyppe/ui/constant/widget/custom_base_cache_image.dart';
import 'package:hyppe/ui/constant/widget/custom_desc_content_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/playlist/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/playlist/comments_detail/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/playlist/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/widget/fullscreen/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/widget/video_thumbnail.dart';
import 'package:hyppe/ui/inner/home/notifier_v2.dart';
import 'package:hyppe/ui/inner/main/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

import '../../../../../../../core/config/ali_config.dart';
import '../../../../../../../core/constants/shared_preference_keys.dart';
import '../../../../../../../core/models/collection/posts/content_v2/content_data.dart';
import '../../../../../../../core/services/shared_preference.dart';

class VideoFullLandingscreenPage extends StatefulWidget {
  final Function onClose;
  final Widget? slider;
  final VideoIndicator videoIndicator;
  final String? thumbnail;
  final List<ContentData>? vidData;
  final int? index;
  final Function()? loadMoreFunction;
  final Function()? clearPostId; //netral player
  final bool? isAutoPlay;
  final bool enableWakelock;
  final bool isLanding;
  const VideoFullLandingscreenPage({
    Key? key,
    required this.onClose,
    required this.isLanding,
    this.slider,
    required this.videoIndicator,
    required this.thumbnail,
    this.vidData,
    this.index,
    this.loadMoreFunction,
    this.clearPostId,
    this.isAutoPlay,
    this.enableWakelock = true,
  }) : super(key: key);

  @override
  State<VideoFullLandingscreenPage> createState() => _VideoFullLandingscreenPageState();
}

class _VideoFullLandingscreenPageState extends State<VideoFullLandingscreenPage> with WidgetsBindingObserver, AfterFirstLayoutMixin, SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKeyPlayer = GlobalKey<ScaffoldState>();

  PageController controller = PageController();
  late final AnimationController animatedController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  FlutterAliplayer? fAliplayer;
  ContentData? dataSelected;
  AdsPlayerPage? adsPlayerPage;
  Orientation beforePosition = Orientation.portrait;
  Orientation orientation = Orientation.portrait;
  LocalizationModelV2? lang;

  List<ContentData>? vidData;

  final bool _isLock = false;
  bool isMute = false;
  bool _inSeek = false;
  bool isPause = false;
  bool onTapCtrl = false;
  bool _showTipsWidget = false;
  bool isLoadingVid = false;
  bool isScrolled = false;
  bool isloadingRotate = false;
  bool isOnPageTurning = false;
  bool isShowMore = false;
  bool isPrepare = false;
  bool isPlay = false;
  bool isloading = false;
  bool isPlayAds = false;
  bool scroolUp = false;
  bool afterUploading = false;
  bool _showLoading = false;
  bool _thumbnailSuccess = false;
  bool isActivePage = true;
  bool isActiveAds = false;
  bool isShared = false;

  int seekValue = 0;
  int _currentPosition = 0;
  int _currentPositionText = 0;
  int _videoDuration = 1;
  int _currentPlayerState = 0;
  int _loadingPercent = 0;
  int curentIndex = 0;
  int _lastCurIndex = -1;

  double lastOffset = 0;

  String email = '';
  String auth = '';
  String postIdVisibility = '';
  String postIdVisibilityTemp = '';
  String _curPostId = '';
  String _lastCurPostId = '';
  String _snapShotPath = '';
  String _savePath = '';
  String _tipsContent = '';

  // bool isloading = true;

  @override
  void afterFirstLayout(BuildContext context) {
    // if (fAliplayer == null && fAliplayer?.getPlayerName().toString() != 'FullVideoLandingpage') {
    fAliplayer = FlutterAliPlayerFactory.createAliPlayer(playerId: 'FullVideoLandingpage');
    initAlipayer();
    // }
    landscape();
    var notifier = (Routing.navigatorKey.currentContext ?? context).read<PreviewVidNotifier>();
    if (notifier.vidData?[widget.index ?? 0].certified ?? false) {
      System().block(context);
    } else {
      System().disposeBlock();
    }
    start(context, notifier.vidData?[widget.index ?? 0] ?? ContentData());
    _initializeTimer();
  }

  void landscape() async {
    fAliplayer?.pause();
    Future.delayed(const Duration(seconds: 1), () {
      final notifier = (Routing.navigatorKey.currentContext ?? context).read<VideoNotifier>();
      final isShowing = notifier.isShowingAds;
      if (!isShowing) {
        fAliplayer?.play();
      }
      notifier.loadVideo = false;
      context.read<PreviewVidNotifier>().currIndex = widget.index ?? 0;
      // setState(() {
      //   isloading = false;
      // });
    });
  }

  bool isScrolling = false;
  //Ads Condition == Irfan ==
  bool isScrollAds = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {});
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    controller = PageController(initialPage: widget.index ?? 0);
    controller.addListener(() {
      fAliplayer?.pause();
      setState(() {
        isScrolled = true;
      });
      final _notifier = context.read<PreviewVidNotifier>();
      if (isOnPageTurning && controller.page == controller.page?.roundToDouble()) {
        _notifier.pageIndex = controller.page?.toInt() ?? 0;
        setState(() {
          // current = _controller.page.toInt();
          isOnPageTurning = false;
        });
      } else if (!isOnPageTurning) {
        if (((_notifier.pageIndex.toDouble()) - (controller.page ?? 0)).abs() > 0.1) {
          setState(() {
            isOnPageTurning = true;
          });
        }
      }
    });

    curentIndex = widget.index ?? 0;

    if ((vidData?.length ?? 0) - 1 == curentIndex) {
      getNewData();
    }
    if (vidData?[widget.index ?? 0].inBetweenAds == null && vidData?[widget.index ?? 0].postID != null) {
      _initializeTimer();
    }
  }

  initAlipayer() {
    globalAliPlayer = fAliplayer;
    vidConfig();
    fAliplayer?.pause();
    fAliplayer?.setAutoPlay(true);

    // fAliplayer?.setLoop(true);
    fAliplayer?.setMuted(isMute);

    //Turn on mix mode
    if (Platform.isIOS) {
      FlutterAliplayer.enableMix(true);
      // FlutterAliplayer.setAudioSessionTypeForIOS(AliPlayerAudioSesstionType.mix);
    }

    //set player
    fAliplayer?.setPreferPlayerName(GlobalSettings.mPlayerName);
    fAliplayer?.setEnableHardwareDecoder(GlobalSettings.mEnableHardwareDecoder);
    _initListener();
  }

  void _initListener() {
    _currentPositionText = widget.videoIndicator.positionText ?? 0;
    _currentPosition = widget.videoIndicator.seekValue ?? 0;
    // fAliplayer?.play();
    _videoDuration = widget.videoIndicator.videoDuration ?? 0;
    isMute = widget.videoIndicator.isMute ?? false;
    lang = context.read<TranslateNotifierV2>().translate;
    email = SharedPreference().readStorage(SpKeys.email);

    var notifier = (Routing.navigatorKey.currentContext ?? context).read<PreviewVidNotifier>();
    var data = notifier.vidData?[widget.index ?? 0];

    if ((data?.metadata?.height ?? 0) < (data?.metadata?.width ?? 0)) {
      orientation = Orientation.landscape;
      // beforePosition = orientation;
    } else {
      orientation = Orientation.portrait;
      // beforePosition = orientation;
    }

    int changevalue;
    changevalue = _currentPosition + 1000;
    if (changevalue > _videoDuration) {
      changevalue = _videoDuration;
    }
    fAliplayer?.requestBitmapAtPosition(changevalue);
    setState(() {
      _currentPosition = changevalue;
    });
    _inSeek = false;
    setState(() {
      if (_currentPlayerState == FlutterAvpdef.completion && _showTipsWidget) {
        setState(() {
          _showTipsWidget = false;
        });
      }
    });
    // fAliplayer?.seekTo(changevalue, GlobalSettings.mEnableAccurateSeek ? FlutterAvpdef.ACCURATE : FlutterAvpdef.INACCURATE);
    fAliplayer?.seekTo(changevalue, FlutterAvpdef.ACCURATE);
    fAliplayer?.setOnPrepared((playerId) {
      // Fluttertoast.showToast(msg: "OnPrepared ");
      fAliplayer?.getPlayerName().then((value) => print("getPlayerName==$value"));
      fAliplayer?.getMediaInfo().then((value) {
        print("getMediaInfo==$value");
        _videoDuration = value['duration'];
        if (mounted) {
          setState(() {
            isPrepare = true;
          });
        } else {
          isPrepare = true;
        }
      });
      // isPlay = true;
      // isPause = false;
    });
    fAliplayer?.setOnRenderingStart((playerId) {});
    fAliplayer?.setOnVideoSizeChanged((width, height, rotation, playerId) {
      print('video size changed');
      // configAliplayer();
    });
    fAliplayer?.setOnStateChanged((newState, playerId) {
      _currentPlayerState = newState;
      print("aliyun : onStateChanged $newState ${_currentPlayerState = newState}");
      switch (newState) {
        case FlutterAvpdef.AVPStatus_AVPStatusStarted:
          // Wakelock.enable();
          try {
            setState(() {
              isloading = false;
              _showTipsWidget = false;
              _showLoading = false;
              isPause = false;
              isPlay = true;
            });
            VideoNotifier vidnot = context.read<VideoNotifier>();
            if (vidnot.mapInContentAds[data?.postID ?? ''] != null) {
              fAliplayer?.pause();
            }
          } catch (e) {
            print('error AVPStatus_AVPStatusStarted: $e');
          }

          break;
        case FlutterAvpdef.AVPStatus_AVPStatusPaused:
          isPause = true;
          setState(() {});
          // Wakelock.disable();
          break;
        case FlutterAvpdef.AVPStatus_AVPStatusStopped:
          // isPlay = false;
          try {
            // Wakelock.disable();
            if (mounted) {
              print('aliyun : onStateChanged $_currentPosition');
              if (_currentPosition > 0) {
                isPause = true;
                isPlay = true;
              } else {
                _showLoading = false;
              }
              setState(() {});
            }
          } catch (e) {
            e.logger();
          }

          break;
        case FlutterAvpdef.AVPStatus_AVPStatusCompletion:
          // Wakelock.disable();
          break;
        case FlutterAvpdef.AVPStatus_AVPStatusError:
          // Wakelock.disable();
          break;
        case FlutterAvpdef.AVPStatus_AVPStatusPrepared:
          // Wakelock.enable();
          try {
            if (mounted) {
              setState(() {
                _showLoading = true;
              });
            } else {
              _showLoading = true;
            }
          } catch (e) {
            e.logger();
          }
          break;
        default:
      }
    });

    fAliplayer?.setOnInfo((infoCode, extraValue, extraMsg, playerId) {
      final notifier = (Routing.navigatorKey.currentContext ?? context).read<VideoNotifier>();
      if (infoCode == FlutterAvpdef.CURRENTPOSITION) {
        if (_videoDuration != 0 && (extraValue ?? 0) <= _videoDuration) {
          _currentPosition = extraValue ?? 0;

          final detik = (_currentPosition / 1000).round();
          print("====detik $detik -- ${notifier.adsTime} -- ${notifier.tempAdsData}");
          if (notifier.tempAdsData != null) {
            if (notifier.adsTime == detik) {
              fAliplayer?.pause();
              final tempAds = notifier.tempAdsData;
              if (tempAds != null) {
                notifier.setMapAdsContent(dataSelected?.postID ?? '', tempAds);
                final fixAds = notifier.mapInContentAds[dataSelected?.postID ?? ''];

                if (fixAds != null) {
                  context.read<PreviewVidNotifier>().setAdsData(curentIndex, fixAds, context);
                }
              }
            } else if (detik > notifier.adsTime) {
              if (notifier.adsvideoIsPlay && notifier.mapInContentAds[dataSelected?.postID ?? ''] == null) {
                notifier.isShowingAds = false;
                notifier.adsvideoIsPlay = false;
              }
            }
          }
        }
        if (!_inSeek) {
          setState(() {
            _currentPositionText = extraValue ?? 0;
          });
        }
      } else if (infoCode == FlutterAvpdef.BUFFEREDPOSITION) {
        // _bufferPosition = extraValue ?? 0;
        // if (mounted) {
        //   setState(() {});
        // }
      } else if (infoCode == FlutterAvpdef.AUTOPLAYSTART) {
        // Fluttertoast.showToast(msg: "AutoPlay");
      } else if (infoCode == FlutterAvpdef.CACHESUCCESS) {
        // Fluttertoast.showToast(msg: "Cache Success");
      } else if (infoCode == FlutterAvpdef.CACHEERROR) {
        // Fluttertoast.showToast(msg: "Cache Error $extraMsg");
      } else if (infoCode == FlutterAvpdef.LOOPINGSTART) {
        // Fluttertoast.showToast(msg: "Looping Start");
      } else if (infoCode == FlutterAvpdef.SWITCHTOSOFTWAREVIDEODECODER) {
        // Fluttertoast.showToast(msg: "change to soft ware decoder");
        // mOptionsFragment.switchHardwareDecoder();
      }
    });

    fAliplayer?.setOnCompletion((playerId) {
      _showTipsWidget = true;
      // isPause = true;
      try {
        if (mounted) {
          setState(() {
            _currentPosition = _videoDuration;
          });
        } else {
          _currentPosition = _videoDuration;
        }
      } catch (e) {
        _currentPosition = _videoDuration;
      }

      nextPage();
    });

    fAliplayer?.setOnLoadingStatusListener(loadingBegin: (playerId) {
      if (mounted) {
        try {
          setState(() {
            _loadingPercent = 0;
            isLoadingVid = true;
          });
        } catch (e) {
          print('error setOnLoadingStatusListener: $e');
        }
      }
    }, loadingProgress: (percent, netSpeed, playerId) {
      if (percent == 100) {
        isLoadingVid = false;
      }
      try {
        if (mounted) {
          setState(() {
            _loadingPercent = percent;
          });
        } else {
          _loadingPercent = percent;
        }
      } catch (e) {
        print('error loadingProgress: $e');
      }
    }, loadingEnd: (playerId) {
      try {
        if (mounted) {
          setState(() {
            isLoadingVid = false;
          });
        } else {
          isLoadingVid = false;
        }
      } catch (e) {
        print('error loadingEnd: $e');
      }
    });
  }

  void vidConfig() {
    var configMap = {
      'mStartBufferDuration': GlobalSettings.mStartBufferDuration, // The buffer duration before playback. Unit: milliseconds.
      'mHighBufferDuration': GlobalSettings.mHighBufferDuration, // The duration of high buffer. Unit: milliseconds.
      'mMaxBufferDuration': GlobalSettings.mMaxBufferDuration, // The maximum buffer duration. Unit: milliseconds.
      'mMaxDelayTime': GlobalSettings.mMaxDelayTime, // The maximum latency of live streaming. Unit: milliseconds. You can specify the latency only for live streams.
      'mNetworkTimeout': GlobalSettings.mNetworkTimeout, // The network timeout period. Unit: milliseconds.
      'mNetworkRetryCount': GlobalSettings.mNetworkRetryCount, // The number of retires after a network timeout. Unit: milliseconds.
      'mEnableLocalCache': GlobalSettings.mEnableCacheConfig,
      'mLocalCacheDir': GlobalSettings.mDirController,
      'mClearFrameWhenStop': true
    };
    // Configure the application.
    fAliplayer?.setConfig(configMap);
    var map = {
      "mMaxSizeMB": GlobalSettings.mMaxSizeMBController,

      /// The maximum space that can be occupied by the cache directory.
      "mMaxDurationS": GlobalSettings.mMaxDurationSController,

      /// The maximum cache duration of a single file.
      "mDir": GlobalSettings.mDirController,

      /// The cache directory.
      "mEnable": GlobalSettings.mEnableCacheConfig

      /// Specify whether to enable the cache feature.
    };
    fAliplayer?.setCacheConfig(map);
  }

  _pauseScreen() async {
    (Routing.navigatorKey.currentContext ?? context).read<HomeNotifier>().removeWakelock();
  }

  _initializeTimer() async {
    if (widget.enableWakelock) {
      (Routing.navigatorKey.currentContext ?? context).read<HomeNotifier>().initWakelockTimer(onShowInactivityWarning: _handleInactivity);
    }
  }

  _handleInactivity() {
    context.read<MainNotifier>().isInactiveState = true;
    fAliplayer?.pause();
    isPause = true;
    setState(() {});
    _pauseScreen();
    ShowBottomSheet().onShowColouredSheet(
      context,
      context.read<TranslateNotifierV2>().translate.warningInavtivityVid,
      maxLines: 2,
      color: kHyppeLightBackground,
      textColor: kHyppeTextLightPrimary,
      textButtonColor: kHyppePrimary,
      iconSvg: 'close.svg',
      textButton: context.read<TranslateNotifierV2>().translate.stringContinue ?? '',
      onClose: () {
        context.read<MainNotifier>().isInactiveState = false;
        fAliplayer?.play();
        isPause = false;
        setState(() {});
        _initializeTimer();
      },
    );
    // this syntax below to prevent video play after changing
    Future.delayed(const Duration(seconds: 1), () {
      if (context.read<MainNotifier>().isInactiveState) {
        fAliplayer?.pause();
        isPause = true;
        setState(() {});
      }
    });
  }

  Future getNewData() async {
    print("getnewdata1");
    // widget.loadMoreFunc yestion?.call();
    HomeNotifier hn = context.read<HomeNotifier>();
    PreviewVidNotifier vn = context.read<PreviewVidNotifier>();

    await hn.initNewHome(context, mounted, isreload: false, isgetMore: true).then((value) {
      setState(() {
        vn.vidData?.forEach((e) {
          print(e.description);
        });
        vidData = vn.vidData;
        vidData?.forEach((e) {
          print(e.description);
        });
        print("========== total ${vidData?.length}");
      });
    });
  }

  @override
  void dispose() {
    fAliplayer?.stop();
    print("==============full screen dispose");

    animatedController.dispose();
    whileDispose();
    super.dispose();
  }

  whileDispose() {
    try {
      fAliplayer?.destroy();
      _pauseScreen();
      final notifier = (Routing.navigatorKey.currentContext ?? context).read<VideoNotifier>();
      notifier.adsAliplayer?.stop();
      isActivePage = false;
      // final notifier = (Routing.navigatorKey.currentContext ?? context).read<VideoNotifier>();

      // if (!notifier.isShowingAds) {
      //   fAliplayer?.play();
      // }
      // fAliplayer?.play();
    } catch (e) {
      print("==========error dispose $e ==============");
    }
  }

  void scrollPage(height, width) async {
    var lastOrientation = orientation;
    if ((height ?? 0) < (width ?? 0)) {
      orientation = Orientation.landscape;
    } else {
      orientation = Orientation.portrait;
    }

    print('start step -> height: $height width: $width orientation: $lastOrientation');

    if (lastOrientation != orientation) {
      setState(() {
        isloadingRotate = true;
      });
      print('step 1');
      if (orientation == Orientation.landscape) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
        print('step 2');
      } else {
        // await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
        await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
        print('step 3');
      }
      Future.delayed(const Duration(milliseconds: 1000), () {
        setState(() {
          isloadingRotate = false;
        });
      });
    } else {}
  }

  void nextPage() {
    Future.delayed(Duration(milliseconds: 500), () {
      controller.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.ease);
    });
  }

  void previousPage() {
    Future.delayed(Duration(milliseconds: 500), () {
      controller.previousPage(duration: const Duration(milliseconds: 500), curve: Curves.ease);
    });
  }

  void onViewPlayerCreated(viewId) async {
    fAliplayer?.setPlayerView(viewId);
  }

  void _onPlayerHide() {
    print("========------hideddd----=======");
    Future.delayed(const Duration(seconds: 4), () {
      if (!isScrolling) {
        onTapCtrl = false;
      }
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    print("=====state fullscreen $state =====");
    switch (state) {
      case AppLifecycleState.inactive:
        // isActivePage = false;
        fAliplayer?.pause();
        _pauseScreen();
        break;
      case AppLifecycleState.resumed:
        isActivePage = true;
        // isactivealiplayer = false;
        fAliplayer?.play();
        break;
      case AppLifecycleState.paused:
        fAliplayer?.pause();
        _pauseScreen();
        break;
      case AppLifecycleState.detached:
        _pauseScreen();
        break;
      case AppLifecycleState.hidden:
        isActivePage = false;
        break;
      default:
        break;
    }
  }

  GestureDetector _buildSkipPrev(Color iconColor, double barHeight) {
    return GestureDetector(
      onTap: () {
        if (!onTapCtrl) return;
        previousPage();
      },
      child: const CustomIconWidget(
        iconData: "${AssetPath.vectorPath}previous.svg",
        defaultColor: false,
      ),
    );
  }

  GestureDetector _buildSkipNext(Color iconColor, double barHeight) {
    return GestureDetector(
      onTap: () {
        if (!onTapCtrl) return;
        nextPage();
      },
      child: const CustomIconWidget(
        iconData: "${AssetPath.vectorPath}next.svg",
        defaultColor: false,
      ),
    );
  }

  GestureDetector _buildSkipBack(Color iconColor, double barHeight) {
    return GestureDetector(
      onTap: () {
        if (!onTapCtrl) return;
        int value;
        int changevalue;
        if (_videoDuration > 60000) {
          value = 10000;
        } else {
          value = 5000;
        }

        changevalue = _currentPosition - value;
        if (changevalue < 0) {
          changevalue = 0;
        }
        fAliplayer?.requestBitmapAtPosition(changevalue);
        setState(() {
          _currentPosition = changevalue;
        });
        _inSeek = false;
        setState(() {
          if (_currentPlayerState == FlutterAvpdef.completion && _showTipsWidget) {
            setState(() {
              _showTipsWidget = false;
            });
          }
        });
        // fAliplayer?.seekTo(changevalue, GlobalSettings.mEnableAccurateSeek ? FlutterAvpdef.ACCURATE : FlutterAvpdef.INACCURATE);
        fAliplayer?.seekTo(changevalue, FlutterAvpdef.ACCURATE);
      },
      child: const CustomIconWidget(
        iconData: "${AssetPath.vectorPath}replay10.svg",
        defaultColor: false,
      ),
    );
  }

  GestureDetector _buildSkipForward(Color iconColor, double barHeight) {
    return GestureDetector(
      onTap: () {
        if (!onTapCtrl) return;
        int value;
        int changevalue;
        if (_videoDuration > 60000) {
          value = 10000;
        } else {
          value = 5000;
        }
        changevalue = _currentPosition + value;
        if (changevalue > _videoDuration) {
          changevalue = _videoDuration;
        }
        fAliplayer?.requestBitmapAtPosition(changevalue);
        setState(() {
          _currentPosition = changevalue;
        });
        _inSeek = false;
        setState(() {
          if (_currentPlayerState == FlutterAvpdef.completion && _showTipsWidget) {
            setState(() {
              _showTipsWidget = false;
            });
          }
        });
        // fAliplayer?.seekTo(changevalue, GlobalSettings.mEnableAccurateSeek ? FlutterAvpdef.ACCURATE : FlutterAvpdef.INACCURATE);
        fAliplayer?.seekTo(changevalue, FlutterAvpdef.ACCURATE);
      },
      child: const CustomIconWidget(
        iconData: "${AssetPath.vectorPath}forward10.svg",
        defaultColor: false,
      ),
    );
  }

  GestureDetector _buildPlayPause(
    Color iconColor,
    double barHeight,
  ) {
    return GestureDetector(
      onTap: () {
        if (isPause) {
          // if (_showTipsWidget) fAliplayer?.prepare();
          if (_currentPosition > 0 && _currentPlayerState == FlutterAvpdef.AVPStatus_AVPStatusStopped) {
            fAliplayer?.prepare();
            fAliplayer?.seekTo(_currentPosition, FlutterAvpdef.ACCURATE);
            fAliplayer?.play();
            isPause = false;
            setState(() {});
          } else {
            fAliplayer?.play();
            isPause = false;
            setState(() {});
          }
        } else {
          fAliplayer?.pause();
          isPause = true;
          setState(() {});
        }
        if (_showTipsWidget) {
          fAliplayer?.prepare();
          fAliplayer?.play();
        }
      },
      child: CustomIconWidget(
        iconData: isPause ? "${AssetPath.vectorPath}play3.svg" : "${AssetPath.vectorPath}pause3.svg",
        defaultColor: false,
      ),
      // Icon(
      //   isPause ? Icons.pause : Icons.play_arrow_rounded,
      //   color: iconColor,
      //   size: 200,
      // ),
    );
  }

  Future start(BuildContext context, ContentData data) async {
    // if (notifier.listData != null && (notifier.listData?.length ?? 0) > 0 && _curIdx < (notifier.listData?.length ?? 0)) {
    isPrepare = false;
    fAliplayer?.stop();
    fAliplayer?.clearScreen();

    setState(() {
      isloading = true;
      dataSelected = data;
      isPlay = false;
    });
    // fAliplayer?.setVidAuth(
    //   vid: "c1b24d30b2c671edbfcb542280e90102",
    //   region: DataSourceRelated.defaultRegion,
    //   playAuth:
    //       "eyJTZWN1cml0eVRva2VuIjoiQ0FJU2lBTjFxNkZ0NUIyeWZTaklyNURISnUvWnJvZFIrb1d2VlY2SmdHa0RPdFZjaDZMRG96ejJJSDFLZlhadEJPQWN0ZlF3bFdwVDdQNGJsckl1RjhJWkdoR2ZONU10dE1RUHJGL3dKb0hidk5ldTBic0hoWnY5bGNNTHJaaWpqcUhvZU96Y1lJNzMwWjdQQWdtMlEwWVJySkwrY1RLOUphYk1VL21nZ29KbWFkSTZSeFN4YVNFOGF2NWRPZ3BscnIwSVZ4elBNdnIvSFJQMnVtN1pIV3R1dEEwZTgzMTQ1ZmFRejlHaTZ4YlRpM2I5ek9FVXFPYVhKNFMvUGZGb05ZWnlTZjZvd093VUVxL2R5M3hvN3hGYjFhRjRpODRpL0N2YzdQMlFDRU5BK3dtbFB2dTJpOE5vSUYxV2E3UVdJWXRncmZQeGsrWjEySmJOa0lpbDVCdFJFZHR3ZUNuRldLR216c3krYjRIUEROc2ljcXZoTUhuZ3k4MkdNb0tQMHprcGVuVUdMZ2hIQ2JGRFF6MVNjVUZ3RjIyRmQvVDlvQTJRTWwvK0YvbS92ZnRvZ2NvbC9UTEI1c0dYSWxXRGViS2QzQnNETjRVMEIwRlNiRU5JaERPOEwvOWNLRndUSWdrOFhlN01WL2xhYUJGUHRLWFdtaUgrV3lOcDAzVkxoZnI2YXVOcGJnUHIxVVFwTlJxQUFaT3kybE5GdndoVlFObjZmbmhsWFpsWVA0V3paN24wTnVCbjlILzdWZHJMOGR5dHhEdCtZWEtKNWI4SVh2c0lGdGw1cmFCQkF3ZC9kakhYTjJqZkZNVFJTekc0T3pMS1dKWXVzTXQycXcwMSt4SmNHeE9iMGtKZjRTcnFpQ1RLWVR6UHhwakg0eDhvQTV6Z0cvZjVIQ3lFV3pISmdDYjhEeW9EM3NwRUh4RGciLCJBdXRoSW5mbyI6IntcIkNJXCI6XCJmOUc0eExxaHg2Tkk3YThaY1Q2N3hObmYrNlhsM05abmJXR1VjRmxTelljS0VKVTN1aVRjQ29Hd3BrcitqL2phVVRXclB2L2xxdCs3MEkrQTJkb3prd0IvKzc5ZlFyT2dLUzN4VmtFWUt6TT1cIixcIkNhbGxlclwiOlwiV2NKTEpvUWJHOXR5UmM2ZXg3LzNpQXlEcS9ya3NvSldhcXJvTnlhTWs0Yz1cIixcIkV4cGlyZVRpbWVcIjpcIjIwMjMtMDMtMTZUMDk6NDE6MzdaXCIsXCJNZWRpYUlkXCI6XCJjMWIyNGQzMGIyYzY3MWVkYmZjYjU0MjI4MGU5MDEwMlwiLFwiUGxheURvbWFpblwiOlwidm9kLmh5cHBlLmNsb3VkXCIsXCJTaWduYXR1cmVcIjpcIk9pbHhxelNyaVVhOGlRZFhaVEVZZEJpbUhJUT1cIn0iLCJWaWRlb01ldGEiOnsiU3RhdHVzIjoiTm9ybWFsIiwiVmlkZW9JZCI6ImMxYjI0ZDMwYjJjNjcxZWRiZmNiNTQyMjgwZTkwMTAyIiwiVGl0bGUiOiIyODg4MTdkYi1jNzdjLWM0ZTQtNjdmYi0zYjk1MTlmNTc0ZWIiLCJDb3ZlclVSTCI6Imh0dHBzOi8vdm9kLmh5cHBlLmNsb3VkL2MxYjI0ZDMwYjJjNjcxZWRiZmNiNTQyMjgwZTkwMTAyL3NuYXBzaG90cy9jYzM0MjVkNzJiYjM0YTE3OWU5NmMzZTA3NTViZjJjNi0wMDAwNC5qcGciLCJEdXJhdGlvbiI6NTkuMDQ5fSwiQWNjZXNzS2V5SWQiOiJTVFMuTlNybVVtQ1hwTUdEV3g4ZGlWNlpwaGdoQSIsIlBsYXlEb21haW4iOiJ2b2QuaHlwcGUuY2xvdWQiLCJBY2Nlc3NLZXlTZWNyZXQiOiIzU1NRUkdkOThGMU04TkZ0b00xa2NlU01IZlRLNkJvZm93VXlnS1Y5aEpQdyIsIlJlZ2lvbiI6ImFwLXNvdXRoZWFzdC01IiwiQ3VzdG9tZXJJZCI6NTQ1NDc1MzIwNTI4MDU0OX0=",
    // );
    print("===== --- hit blur status ${data.reportedStatus}");
    // if (data.reportedStatus != 'BLURRED') {
    if (data.isApsara ?? false) {
      // _playMode = ModeTypeAliPLayer.auth;
      await getAuth(data.apsaraId ?? '');
    } else {
      // _playMode = ModeTypeAliPLayer.url;
      await getOldVideoUrl(data.postID ?? '');
    }
    // }
    if (mounted) {
      setState(() {
        isPause = false;
        // _isFirstRenderShow = false;
      });
    }

    if (data.reportedStatus == 'BLURRED') {
    } else {
      if (isActivePage) {
        print("=====prepare=====");
        fAliplayer?.prepare();
        fAliplayer?.play();
      }
    }

    // this syntax below to prevent video play after changing video
    // Future.delayed(const Duration(seconds: 1), () {
    //   if (context.read<MainNotifier>().isInactiveState) {
    //     fAliplayer?.pause();
    //   }
    // });

    // fAliplayer?.play();
  }

  Future getAuth(String apsaraId) async {
    try {
      final fixContext = Routing.navigatorKey.currentContext;

      _showLoading = true;
      if (mounted) {
        setState(() {});
      }
      final notifier = PostsBloc();
      await notifier.getAuthApsara(fixContext ?? context, apsaraId: apsaraId, check: false);
      final fetch = notifier.postsFetch;
      if (fetch.postsState == PostsState.videoApsaraSuccess) {
        Map jsonMap = json.decode(fetch.data.toString());
        auth = jsonMap['PlayAuth'];

        print("==auth == $auth");

        fAliplayer?.setVidAuth(
          vid: apsaraId,
          region: DataSourceRelated.defaultRegion,
          playAuth: auth,
          definitionList: [DataSourceRelated.definitionList],
        );

        final isViewed = dataSelected?.isViewed ?? true;

        final ref = (Routing.navigatorKey.currentContext ?? context).read<VideoNotifier>();
        ref.tempAdsData = null;
        if (!isViewed) {
          ref.hasShowedAds = false;
          ref.getAdsVideo(Routing.navigatorKey.currentContext ?? context, _videoDuration).whenComplete(() {
            // (Routing.navigatorKey.currentContext ?? context).read<PreviewVidNotifier>().setIsViewed(widget.index!);
          });
        }
      }
    } catch (e) {
      isloading = false;
      if (mounted) {
        setState(() {});
      }
      // 'Failed to fetch ads data $e'.logger();
    }
  }

  Future getOldVideoUrl(String postId) async {
    if (mounted) {
      setState(() {
        isloading = true;
      });
    }
    try {
      final notifier = PostsBloc();
      await notifier.getOldVideo(context, apsaraId: postId, check: false);
      final fetch = notifier.postsFetch;
      if (fetch.postsState == PostsState.videoApsaraSuccess) {
        Map jsonMap = json.decode(fetch.data.toString());

        fAliplayer?.setUrl(jsonMap['data']['url']);
        if (mounted) {
          setState(() {
            // isloading = false;
          });
        }
        // widget.videoData?.fullContentPath = jsonMap['PlayUrl'];
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isloading = false;
        });
      }
      // 'Failed to fetch ads data $e'.logger();
    }
  }

  //===================================== WIDGET ===========================================

  @override
  Widget build(BuildContext context) {
    // SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);

    print('view ads: ${widget.isAutoPlay ?? false}');

    return Consumer2<VideoNotifier, PreviewVidNotifier>(builder: (context, notifier, vidNotifier, _) {
      vidData = vidNotifier.vidData;
      // print('view ads: 2 ${vidData}');
      return Scaffold(
        key: _scaffoldKeyPlayer,
        body: GestureDetector(
            onHorizontalDragEnd: (dragEndDetails) {
              print("=======hasil ${notifier.isShowingAds}  -- ${notifier.hasShowedAds}");
              if (dragEndDetails.primaryVelocity! < 0) {
              } else if (dragEndDetails.primaryVelocity! > 0) {
                if (!notifier.isShowingAds && !notifier.adsvideoIsPlay) {
                  int changevalue;
                  changevalue = _currentPosition + 1000;
                  if (changevalue > _videoDuration) {
                    changevalue = _videoDuration;
                  }
                  // whileDispose();
                  vidData?[widget.index ?? 0].isLoading = true;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
                    Navigator.pop(context, VideoIndicator(videoDuration: _videoDuration, seekValue: changevalue, positionText: _currentPositionText, showTipsWidget: _showTipsWidget, isMute: isMute));
                  });
                }
              }
            },
            child: notifier.loadVideo
                ? Container(
                    color: Colors.black,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : PageView.builder(
                    controller: controller,
                    physics: notifier.isShowingAds && notifier.adsvideoIsPlay ? const NeverScrollableScrollPhysics() : const AlwaysScrollableScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    itemCount: vidData?.length ?? 0,
                    onPageChanged: (value) {
                      curentIndex = value;
                      notifier.currIndex = value;
                      isScrollAds = true;
                      if (_lastCurIndex != curentIndex) {
                        fAliplayer?.stop();
                        fAliplayer?.clearScreen();
                        Future.delayed(const Duration(milliseconds: 700), () {
                          start(Routing.navigatorKey.currentContext ?? context, vidData?[curentIndex] ?? ContentData());
                          System().increaseViewCount2(Routing.navigatorKey.currentContext ?? context, vidData?[curentIndex] ?? ContentData(), check: false);
                        });
                        if (vidData?[curentIndex].certified ?? false) {
                          System().block(Routing.navigatorKey.currentContext ?? context);
                        } else {
                          System().disposeBlock();
                        }
                        scrollPage(vidData?[value].metadata?.height, vidData?[value].metadata?.width);
                        if (value > 1) {
                          if ((vidData?[value - 1].metadata?.height ?? 0) < (vidData?[value - 1].metadata?.width ?? 0)) {
                            beforePosition = Orientation.landscape;
                          } else {
                            beforePosition = Orientation.portrait;
                          }
                        }
                        context.read<PreviewVidNotifier>().currIndex = value;

                        if ((vidData?.length ?? 0) - 1 == curentIndex) {
                          //get new data;
                          getNewData();
                        }
                        _lastCurIndex = curentIndex;
                      }
                    },
                    itemBuilder: (context, index) {
                      if (index != curentIndex) {
                        return Container(
                          color: Colors.black,
                        );
                      }
                      "================== isPause $isPause $isScrolled".logger();
                      // return Container(
                      //   height: MediaQuery.of(context).size.height,
                      //   width: MediaQuery.of(context).size.width,
                      //   child: Center(child: Text("data ${index}")),
                      // );
                      print('view ads: 1');
                      final isAds = vidData?[index].inBetweenAds != null && vidData?[index].postID == null;
                      if (isAds) {
                        //fAliplayer stoped === Irfan ====
                        fAliplayer?.pause();
                        isPlay = false;
                        _showLoading = false;
                        if (notifier.adsvideoIsPlay && notifier.mapInContentAds[dataSelected?.postID ?? ''] == null) {
                          notifier.isShowingAds = false;
                          notifier.adsvideoIsPlay = false;
                        }
                      }

                      return isloadingRotate
                          ? Container(
                              color: Colors.black,
                              height: MediaQuery.of(context).size.height,
                              width: MediaQuery.of(context).size.width,
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : isAds
                              ? context.getAdsInBetween(vidData, index, (info) {}, () {
                                  context.read<PreviewVidNotifier>().setInBetweenAds(index, null);
                                }, (player, id) {}, isfull: true, isVideo: true, orientation: beforePosition, isScroll: isScrollAds)
                              : videoPlayerWidget(vidNotifier, vidData![index], index);
                    })),
      );
    });
  }

  Widget videoPlayerWidget(PreviewVidNotifier vidNotifier, ContentData data, int index) {
    VideoNotifier notifier = context.read<VideoNotifier>();

    if (notifier.mapInContentAds[data.postID ?? ''] != null) {
      adsPlayerPage = AdsPlayerPage(
        dataSourceMap: {
          DataSourceRelated.vidKey: notifier.mapInContentAds[data.postID ?? '']?.videoId,
          DataSourceRelated.regionKey: DataSourceRelated.defaultRegion,
        },
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        thumbnail: (data.isApsara ?? false) ? (data.mediaThumbEndPoint ?? '') : '${data.fullThumbPath}',
        data: notifier.mapInContentAds[data.postID ?? ''],
        functionFullTriger: () {},
        getPlayer: (player) {},
        onStop: () {
          notifier.setMapAdsContent(data.postID ?? '', null);
          vidNotifier.setAdsData(index, notifier.mapInContentAds[data.postID ?? ''], context);
        },
        fromFullScreen: true,
        onFullscreen: () async {
          // if (widget.fromFullScreen) {
          // Routing().moveBack();
          // } else {
          // onFullscreen(notifier);
          // }
        },
        onClose: () {
          fAliplayer?.pause();
          if (mounted) {
            notifier.setMapAdsContent(data.postID ?? '', null);
            print("====ini iklan ${notifier.mapInContentAds} =====");
            setState(() {
              isPlay = true;
              // vidNotifier.setAdsData(index, notifier.mapInContentAds[data.postID ?? ''], context);
              isloading = false;
              data.adsData = null;
            });
          } else {
            isPlay = true;
            notifier.setMapAdsContent(data.postID ?? '', null);
            // vidNotifier.setAdsData(index, notifier.mapInContentAds[data.postID ?? ''], context);
            isloading = false;
            data.adsData = null;
          }
        },
        orientation: Orientation.portrait,
      );
    }
    return (data.reportedStatus == 'BLURRED')
        ? blurContentWidget(context, data)
        : GestureDetector(
            onTap: () {
              print("========= wkwkwkwkwkw-========");
              setState(() {
                onTapCtrl = true;
              });
            },
            onDoubleTap: () {
              context.read<LikeNotifier>().likePost(context, data);
            },
            child: Stack(
              children: [
                Container(
                  color: Colors.black,
                  width: SizeConfig.screenWidth,
                  height: SizeConfig.screenHeight,
                  child: AliPlayerView(
                    onCreated: onViewPlayerCreated,
                    x: 0,
                    y: 0,
                    height: MediaQuery.of(context).size.width,
                    width: MediaQuery.of(context).size.width,
                    aliPlayerViewType: AliPlayerViewTypeForAndroid.textureview,
                  ),
                ),
                if (isPause && _currentPlayerState == FlutterAvpdef.AVPStatus_AVPStatusStopped)
                  SizedBox(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: VideoThumbnail(
                      videoData: data,
                      onDetail: false,
                      fn: () {},
                      withMargin: true,
                    ),
                  ),
                // Positioned.fill(child: Center(child: Text("notifier.adsvideoIsPlay ${notifier.adsvideoIsPlay}"))),
                GestureDetector(
                  onTap: () {
                    //// fungsi tap dimana saja
                    onTapCtrl = true;
                    setState(() {});
                  },
                  child: Container(
                    color: Colors.transparent,
                    height: SizeConfig.screenHeight,
                    width: SizeConfig.screenWidth,
                  ),
                ),

                if (isloading)
                  const Positioned.fill(
                    child: Align(
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        color: kHyppePrimary,
                      ),
                    ),
                  ),
                if (isPlay)
                  SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: Offstage(offstage: _isLock, child: _buildContentWidget(Routing.navigatorKey.currentContext ?? context, orientation, data))),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: Offstage(
                    offstage: _isLock,
                    child: _buildTopWidget(data),
                  ),
                ),
                _buildProgressBar(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height),
                if (isPlay)
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.center,
                      child: _buildController(
                        Colors.transparent,
                        Colors.white,
                        120,
                        MediaQuery.of(context).size.width,
                        MediaQuery.of(context).size.height * 0.8,
                      ),
                    ),
                  ),
                if (notifier.mapInContentAds[data.postID ?? ''] != null && isPlay)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(16),
                      ),
                      child: Container(color: Colors.black, width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height, child: adsPlayerPage),
                    ),
                  ),
              ],
            ),
          );
  }

  Widget _buildTopWidget(ContentData data) {
    return AnimatedOpacity(
      // opacity: onTapCtrl || isPause ? 1.0 : 0.0,
      opacity: 1.0,
      duration: const Duration(milliseconds: 300),
      onEnd: _onPlayerHide,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            child: Container(
              height: orientation == Orientation.portrait ? kToolbarHeight * 2 : kToolbarHeight * 1.4,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18.0),
              child: CustomAppBar(
                  isVidFormProfile: false,
                  orientation: orientation,
                  data: data,
                  currentPosition: _currentPosition,
                  currentPositionText: _currentPositionText,
                  showTipsWidget: _showTipsWidget,
                  videoDuration: _videoDuration,
                  email: email,
                  lang: lang ?? LocalizationModelV2(),
                  isMute: isMute,
                  backFunction: () {
                    // if (!notifier.isShowingAds) {
                    int changevalue;
                    changevalue = _currentPosition + 1000;
                    if (changevalue > _videoDuration) {
                      changevalue = _videoDuration;
                    }

                    vidData?[widget.index ?? 0].isLoading = true;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
                      Navigator.pop(
                          context, VideoIndicator(videoDuration: _videoDuration, seekValue: changevalue, positionText: _currentPositionText, showTipsWidget: _showTipsWidget, isMute: isMute));
                    });

                    // }
                  },
                  onTapOnProfileImage: () async {
                    var res = await System().navigateToProfile(context, data.email ?? '');
                    fAliplayer?.pause();
                    isPause = true;
                    setState(() {});
                    print('data result $res');
                    if (res != null && res == true) {
                      if ((data.metadata?.height ?? 0) < (data.metadata?.width ?? 0)) {
                        print('Landscape VidPlayerPage');
                        SystemChrome.setPreferredOrientations([
                          DeviceOrientation.landscapeLeft,
                          DeviceOrientation.landscapeRight,
                        ]);
                      } else {
                        print('Portrait VidPlayerPage');
                        SystemChrome.setPreferredOrientations([
                          DeviceOrientation.portraitUp,
                          DeviceOrientation.portraitDown,
                        ]);
                      }
                    }
                  },
                  onTap: () {
                    context.handleActionIsGuest(() async {
                      fAliplayer?.pause();
                      if (data.email != email) {
                        context.read<PreviewPicNotifier>().reportContent(context, data, fAliplayer: data.fAliplayer, onCompleted: () async {
                          imageCache.clear();
                          imageCache.clearLiveImages();
                          fAliplayer?.play();
                          await (Routing.navigatorKey.currentContext ?? context).read<HomeNotifier>().initNewHome(context, mounted, isreload: true, forceIndex: 2);
                        });
                        isPause = true;
                        setState(() {});
                      } else {
                        // if (_curIdx != -1) {
                        //   "=============== pause 11".logger();
                        //   notifier.vidData?[_curIdx].fAliplayer?.pause();
                        // }
                        ShowBottomSheet().onShowOptionContent(
                          context,
                          contentData: data,
                          captionTitle: hyppeVid,
                          onDetail: false,
                          orientation: orientation,
                          isShare: data.isShared,
                          onUpdate: () {
                            Routing().moveBack();
                            Routing().moveBack();
                            Routing().moveBack();

                            (Routing.navigatorKey.currentContext ?? context).read<HomeNotifier>().initNewHome(context, mounted, isreload: true, forceIndex: 2);
                          },
                          fAliplayer: data.fAliplayer,
                        ).then((value) {
                          fAliplayer?.play();
                        });
                        data.fAliplayer?.pause();
                        isPause = true;
                        setState(() {});
                      }
                    });
                  }),
            ),
          ),
          _buttomBodyRight(data),
        ],
      ),
    );
  }

  Widget _buildController(
    Color backgroundColor,
    Color iconColor,
    double barHeight,
    double width,
    double height,
  ) {
    return AnimatedOpacity(
      opacity: onTapCtrl || isPause ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      onEnd: _onPlayerHide,
      child: Center(
        child: Container(
          width: orientation == Orientation.landscape ? width * .35 : width * .8,
          decoration: BoxDecoration(
            color: backgroundColor,
          ),
          child: _showTipsWidget
              ? Center(
                  child: GestureDetector(
                    onTap: () {
                      fAliplayer?.prepare();
                      fAliplayer?.play();
                      setState(() {
                        isPause = false;
                        _showTipsWidget = false;
                      });
                    },
                    child: const CustomIconWidget(
                      iconData: "${AssetPath.vectorPath}pause3.svg",
                      defaultColor: false,
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // _buildSkipPrev(iconColor, barHeight),
                    // _buildSkipBack(iconColor, barHeight),
                    _buildPlayPause(iconColor, barHeight),
                    // _buildSkipForward(iconColor, barHeight),
                    // _buildSkipNext(iconColor, barHeight),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buttomBodyRight(ContentData data) {
    return Positioned(
      right: 18,
      bottom: 0,
      child: Column(
        children: [
          Consumer<LikeNotifier>(
              builder: (context, likeNotifier, child) => buttonVideoRight(
                  onFunctionTap: () {
                    likeNotifier.likePost(context, data);
                  },
                  iconData: '${AssetPath.vectorPath}${(data.insight?.isPostLiked ?? false) ? 'liked.svg' : 'love-shadow.svg'}',
                  value: data.insight!.likes! > 0 ? '${data.insight?.likes}' : '${lang?.like}',
                  liked: data.insight?.isPostLiked ?? false)),
          if (data.allowComments ?? false)
            buttonVideoRight(
              onFunctionTap: () {
                Routing().move(Routes.commentsDetail, argument: CommentsArgument(postID: data.postID ?? '', fromFront: true, data: data, pageDetail: false));
              },
              iconData: '${AssetPath.vectorPath}comment-shadow.svg',
              value: data.comments! > 0 ? data.comments.toString() : lang?.comments ?? '',
            ),
          if (data.isShared ?? false)
            buttonVideoRight(
                onFunctionTap: () {
                  // setState(() {
                  //   isShared = true;
                  // });
                  fAliplayer?.pause();

                  context.read<VidDetailNotifier>().createdDynamicLink(context, data: data).then((val) {
                    // setState(() {
                    //   isShared = false;
                    // });
                  });
                },
                iconData: '${AssetPath.vectorPath}share-shadow.svg',
                value: lang!.share ?? 'Share'),
          if ((data.saleAmount ?? 0) > 0 && email != data.email)
            buttonVideoRight(
                onFunctionTap: () async {
                  fAliplayer?.pause();
                  await ShowBottomSheet.onBuyContent(context, data: data, fAliplayer: fAliplayer);
                },
                iconData: '${AssetPath.vectorPath}cart-shadow.svg',
                value: lang!.buy ?? 'Buy'),
        ],
      ),
    );
  }

  Widget buttonVideoRight({Function()? onFunctionTap, required String iconData, required String value, bool liked = false}) {
    return InkResponse(
      onTap: onFunctionTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: onFunctionTap,
              child: CustomIconWidget(
                defaultColor: false,
                color: liked ? kHyppeRed : kHyppePrimaryTransparent,
                iconData: iconData,
                height: liked ? 24 : 38,
                width: 38,
              ),
            ),
            if (liked)
              const SizedBox(
                height: 10.0,
              ),
            Container(
              transform: Matrix4.translationValues(0.0, -5.0, 0.0),
              child: Text(
                value,
                style: const TextStyle(shadows: [
                  Shadow(offset: Offset(0.0, 1.0), blurRadius: 2.0, color: Colors.black54),
                  Shadow(offset: Offset(0.0, 1.0), blurRadius: 8.0, color: Colors.black54),
                ], color: kHyppePrimaryTransparent, fontWeight: FontWeight.w500, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildContentWidget(BuildContext context, Orientation orientation, ContentData data) {
    return AnimatedOpacity(
      // opacity: onTapCtrl || isPause ? 1.0 : 0.0,
      opacity: 1.0,
      duration: const Duration(milliseconds: 300),
      onEnd: _onPlayerHide,
      child: SafeArea(
          child: Container(
              decoration: orientation == Orientation.portrait
                  ? BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        end: const Alignment(0.0, -1),
                        begin: const Alignment(0.0, 1),
                        colors: [const Color(0x8A000000), Colors.black12.withOpacity(0.0)],
                      ),
                    )
                  : null,
              child: Container(
                  width: MediaQuery.of(context).size.width * .7,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Stack(children: [
                    Positioned(
                      bottom: orientation == Orientation.portrait ? 28 : 0,
                      left: 0,
                      right: orientation == Orientation.landscape ? SizeConfig.screenHeight! * .2 : SizeConfig.screenHeight! * .08,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Row(
                              children: [
                                Visibility(
                                  visible: data.tagPeople?.isNotEmpty ?? false,
                                  child: Container(
                                    decoration: BoxDecoration(color: kHyppeBackground.withOpacity(.4), borderRadius: BorderRadius.circular(8.0)),
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                                    margin: const EdgeInsets.only(right: 12.0),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                      child: GestureDetector(
                                        onTap: () {
                                          fAliplayer?.pause();
                                          context
                                              .read<PicDetailNotifier>()
                                              .showUserTag(context, data.tagPeople, data.postID, title: lang!.inThisVideo, fAliplayer: fAliplayer, orientation: orientation);
                                        },
                                        child: Row(
                                          children: [
                                            const CustomIconWidget(
                                              iconData: '${AssetPath.vectorPath}tag-people-light.svg',
                                              defaultColor: false,
                                              height: 18,
                                            ),
                                            const SizedBox(
                                              width: 4.0,
                                            ),
                                            Text(
                                              '${data.tagPeople!.length} ${lang!.people}',
                                              style: const TextStyle(color: kHyppeTextPrimary),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: data.location != '',
                                  child: Container(
                                    decoration: BoxDecoration(color: kHyppeBackground.withOpacity(.4), borderRadius: BorderRadius.circular(8.0)),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 6,
                                    ),
                                    child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0,
                                        ),
                                        child: location(data)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            constraints: BoxConstraints(
                                maxWidth: SizeConfig.screenWidth! * .7,
                                maxHeight: data.description!.length > 24
                                    ? isShowMore
                                        ? 54
                                        : SizeConfig.screenHeight! * .1
                                    : 54),
                            alignment: Alignment.centerLeft,
                            margin: const EdgeInsets.symmetric(vertical: 12.0),
                            padding: const EdgeInsets.only(left: 8.0, top: 12),
                            child: SingleChildScrollView(
                              child: CustomDescContent(
                                desc: data.description ?? '',
                                trimLines: 2,
                                textAlign: TextAlign.start,
                                callbackIsMore: (val) {
                                  setState(() {
                                    isShowMore = val;
                                  });
                                },
                                seeLess: ' ${lang?.less}', // ${notifier2.translate.seeLess}',
                                seeMore: ' ${lang?.more}', //${notifier2.translate.seeMoreContent}',
                                normStyle: const TextStyle(fontSize: 14, color: kHyppeTextPrimary),
                                hrefStyle: Theme.of(context).textTheme.subtitle2?.copyWith(color: kHyppePrimary),
                                expandStyle: Theme.of(context).textTheme.subtitle2?.copyWith(color: kHyppeTextPrimary, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          SharedPreference().readStorage(SpKeys.statusVerificationId) == VERIFIED &&
                                  (data.boosted.isEmpty) &&
                                  (data.reportedStatus != 'OWNED' && data.reportedStatus != 'BLURRED' && data.reportedStatus2 != 'BLURRED') &&
                                  data.email == SharedPreference().readStorage(SpKeys.email)
                              ? Container(
                                  width: orientation == Orientation.landscape ? SizeConfig.screenWidth! * .28 : SizeConfig.screenWidth!,
                                  margin: const EdgeInsets.only(bottom: 16),
                                  padding: const EdgeInsets.only(top: 12, left: 8.0, right: 8.0),
                                  child: ButtonBoost(
                                    onDetail: false,
                                    marginBool: true,
                                    contentData: data,
                                    startState: () {
                                      SharedPreference().writeStorage(SpKeys.isShowPopAds, true);
                                    },
                                    afterState: () {
                                      SharedPreference().writeStorage(SpKeys.isShowPopAds, false);
                                    },
                                  ),
                                )
                              : Container(),
                          if (data.email == email && (data.boostCount ?? 0) >= 0 && (data.boosted.isNotEmpty))
                            Container(
                              padding: const EdgeInsets.all(10),
                              margin: const EdgeInsets.only(bottom: 10, left: 18.0),
                              width: MediaQuery.of(context).size.width * .18,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                color: kHyppeGreyLight.withOpacity(.9),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const CustomIconWidget(
                                    iconData: "${AssetPath.vectorPath}reach.svg",
                                    defaultColor: false,
                                    height: 24,
                                    color: kHyppeTextLightPrimary,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 13),
                                    child: CustomTextWidget(
                                      textToDisplay: "${data.boostJangkauan ?? '0'} ${lang?.reach}",
                                      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kHyppeTextLightPrimary),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          Column(
                            children: [
                              Align(
                                alignment: Alignment.centerRight,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Text(
                                    "${System.getTimeformatByMs(_currentPositionText)}/${System.getTimeformatByMs(_videoDuration)}",
                                    textAlign: TextAlign.end,
                                    style: const TextStyle(color: Colors.white, fontSize: 11),
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: SliderTheme(
                                      data: SliderTheme.of(context).copyWith(
                                        overlayShape: SliderComponentShape.noThumb,
                                        activeTrackColor: const Color(0xAA7d7d7d),
                                        inactiveTrackColor: const Color.fromARGB(170, 156, 155, 155),
                                        trackHeight: 3.0,
                                        thumbColor: Colors.purple,
                                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
                                      ),
                                      child: Slider(
                                          min: 0,
                                          max: _videoDuration == 0 ? 1 : _videoDuration.toDouble(),
                                          value: _currentPosition.toDouble(),
                                          activeColor: Colors.purple,
                                          thumbColor: Colors.purple,
                                          onChangeStart: (value) {
                                            _inSeek = true;
                                            setState(() {});
                                          },
                                          onChangeEnd: (value) {
                                            _inSeek = false;
                                            setState(() {
                                              if (_currentPlayerState == FlutterAvpdef.completion && _showTipsWidget) {
                                                setState(() {
                                                  _showTipsWidget = false;
                                                });
                                              }
                                            });
                                            fAliplayer?.seekTo(value.ceil(), FlutterAvpdef.ACCURATE);
                                          },
                                          onChanged: (value) {
                                            fAliplayer?.requestBitmapAtPosition(value.ceil());

                                            setState(() {
                                              _currentPosition = value.ceil();
                                            });
                                          }),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          if (data.music?.musicTitle != '' && data.music?.musicTitle != null)
                            Container(
                              margin: const EdgeInsets.only(top: 0.0, left: 8.0, right: 8.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Row(
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.only(right: 8.0),
                                          child: CustomIconWidget(
                                            iconData: "${AssetPath.vectorPath}music_stroke_black.svg",
                                            defaultColor: false,
                                            color: kHyppeLightBackground,
                                            height: 18,
                                          ),
                                        ),
                                        Expanded(
                                          child: _textSize(data.music?.musicTitle ?? '', const TextStyle(fontWeight: FontWeight.bold)).width > SizeConfig.screenWidth! * .56
                                              ? SizedBox(
                                                  width: SizeConfig.screenWidth! * .56,
                                                  height: kTextTabBarHeight,
                                                  child: Marquee(
                                                    text: '  ${data.music?.musicTitle ?? ''}',
                                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white),
                                                  ),
                                                )
                                              : CustomTextWidget(
                                                  textToDisplay: " ${data.music?.musicTitle ?? ''}",
                                                  maxLines: 1,
                                                  textStyle: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                                                  textAlign: TextAlign.left,
                                                ),
                                        ),
                                        CircleAvatar(
                                          radius: 18,
                                          backgroundColor: kHyppeSurface.withOpacity(.9),
                                          child: CustomBaseCacheImage(
                                            imageUrl: data.music?.apsaraThumnailUrl ?? '',
                                            imageBuilder: (_, imageProvider) {
                                              return Container(
                                                width: 48,
                                                height: 48,
                                                decoration: BoxDecoration(
                                                  color: kDefaultIconDarkColor,
                                                  borderRadius: const BorderRadius.all(Radius.circular(24)),
                                                  image: DecorationImage(
                                                    fit: BoxFit.cover,
                                                    image: imageProvider,
                                                  ),
                                                ),
                                              );
                                            },
                                            errorWidget: (_, __, ___) {
                                              return const CustomIconWidget(
                                                iconData: "${AssetPath.vectorPath}music_stroke_black.svg",
                                                defaultColor: false,
                                                color: kHyppeLightBackground,
                                                height: 18,
                                              );
                                            },
                                            emptyWidget: AnimatedBuilder(
                                              animation: animatedController,
                                              builder: (_, child) {
                                                return Transform.rotate(
                                                  angle: animatedController.value * 2 * -math.pi,
                                                  child: child,
                                                );
                                              },
                                              child: const CustomIconWidget(
                                                iconData: "${AssetPath.vectorPath}music_stroke_black.svg",
                                                defaultColor: false,
                                                color: kHyppeLightBackground,
                                                height: 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            )
                        ],
                      ),
                    ),
                  ])))),
    );
  }

  _buildProgressBar(double width, double height) {
    if (_showLoading) {
      return Positioned.fill(
        child: Align(
          alignment: Alignment.center,
          child: Container(
            height: 40,
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(
                  backgroundColor: Colors.white,
                  strokeWidth: 3.0,
                ),
                fourPx,
                Text(
                  "$_loadingPercent%",
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Container();
  }

  Widget location(ContentData data) {
    switch (orientation) {
      case Orientation.portrait:
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const CustomIconWidget(
              iconData: '${AssetPath.vectorPath}map-light.svg',
              defaultColor: false,
              height: 16,
            ),
            const SizedBox(
              width: 4.0,
            ),
            SizedBox(
              width: data.tagPeople?.isNotEmpty ?? false ? SizeConfig.screenWidth! * .4 : SizeConfig.screenWidth! * .65,
              child: Text(
                '${data.location}',
                maxLines: 1,
                style: const TextStyle(color: kHyppeLightBackground),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );

      default:
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const CustomIconWidget(
              iconData: '${AssetPath.vectorPath}map-light.svg',
              defaultColor: false,
              height: 16,
            ),
            const SizedBox(
              width: 4.0,
            ),
            SizedBox(
              width: data.tagPeople?.isNotEmpty ?? false ? SizeConfig.screenWidth! * .13 : SizeConfig.screenWidth! * .22,
              child: Text(
                '${data.location}',
                maxLines: 1,
                style: const TextStyle(color: kHyppeLightBackground),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
    }
  }

  Widget blurContentWidget(BuildContext context, ContentData data) {
    return Stack(
      children: [
        Positioned.fill(
          child: VideoThumbnail(
            videoData: data,
            onDetail: false,
            fn: () {},
            withMargin: true,
          ),
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            color: kHyppeBackground.withOpacity(.8),
            child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Spacer(),
                      const CustomIconWidget(
                        iconData: "${AssetPath.vectorPath}eye-off.svg",
                        defaultColor: false,
                        height: 30,
                      ),
                      Text(lang!.sensitiveContent ?? 'Sensitive Content', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                      Text("HyppeVid ${lang!.contentContainsSensitiveMaterial}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          )),
                      data.email == SharedPreference().readStorage(SpKeys.email)
                          ? GestureDetector(
                              onTap: () async {
                                System().checkConnections().then((value) {
                                  if (value) {
                                    Routing().move(Routes.appeal, argument: data);
                                  }
                                });
                              },
                              child: Container(
                                  padding: const EdgeInsets.all(8),
                                  margin: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(border: Border.all(color: Colors.white), borderRadius: BorderRadius.circular(10)),
                                  child: Text(lang?.appealThisWarning ?? 'Appeal This Warning', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600))),
                            )
                          : const SizedBox(),
                      const Spacer(),
                      GestureDetector(
                        onTap: () async {
                          System().increaseViewCount2(context, data);
                          setState(() {
                            data.reportedStatus = '';
                          });
                          fAliplayer?.prepare();
                          fAliplayer?.play();
                          isPlay = true;
                          // context.read<ReportNotifier>().seeContent(context, data, hyppePic);
                        },
                        child: Container(
                          padding: const EdgeInsets.only(top: 8),
                          margin: const EdgeInsets.only(bottom: 20, right: 8, left: 8),
                          width: SizeConfig.screenWidth,
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: Colors.white,
                                width: 1,
                              ),
                            ),
                          ),
                          child: Text(
                            "${lang!.see} HyppeVid",
                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ),
        ),
      ],
    );
  }

  Size _textSize(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(text: TextSpan(text: text, style: style), maxLines: 1, textDirection: TextDirection.ltr)..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size;
  }
}

class VideoIndicator {
  final int? videoDuration;
  final int? seekValue;
  final int? positionText;
  final bool? showTipsWidget;
  final bool? isMute;
  VideoIndicator({required this.videoDuration, required this.seekValue, required this.positionText, this.showTipsWidget = false, required this.isMute});
}
