import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_aliplayer/flutter_aliplayer.dart';
import 'package:flutter_aliplayer/flutter_aliplayer_factory.dart';
import 'package:hyppe/app.dart';
import 'package:hyppe/core/arguments/contents/slided_diary_detail_screen_argument.dart';
import 'package:hyppe/core/bloc/posts_v2/bloc.dart';
import 'package:hyppe/core/bloc/posts_v2/state.dart';
import 'package:hyppe/core/config/ali_config.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/constants/utils.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/models/collection/sticker/sticker_model.dart';
import 'package:hyppe/core/services/route_observer_service.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/entities/like/notifier.dart';
import 'package:hyppe/ui/constant/entities/report/notifier.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/show_general_dialog.dart';
import 'package:hyppe/ui/constant/widget/custom_background_layer.dart';
import 'package:hyppe/ui/constant/widget/custom_base_cache_image.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/decorated_icon_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/playlist/widget/content_violation.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/playlist/widget/diary_sensitive.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/playlist/widget/left_items.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/playlist/widget/right_items.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/playlist/widget/title_playlist_diaries.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/scroll/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/playlist/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/widget/pic_top_item.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/notifier.dart';
import 'package:hyppe/ui/inner/home/notifier_v2.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/services/error_service.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_shimmer.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:hyppe/ui/constant/widget/sticker_overlay.dart';
import 'dart:math' as math;

class ScrollFullDiary extends StatefulWidget {
  final SlidedDiaryDetailScreenArgument? arguments;
  const ScrollFullDiary({
    Key? key,
    this.arguments,
  }) : super(key: key);

  @override
  _ScrollFullDiaryState createState() => _ScrollFullDiaryState();
}

class _ScrollFullDiaryState extends State<ScrollFullDiary> with WidgetsBindingObserver, TickerProviderStateMixin, RouteAware {
  late final AnimationController animatedController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();

  List<ContentData>? diaryData = [];
  FlutterAliplayer? fAliplayer;
  bool isPrepare = false;
  bool isPlay = false;
  bool isPause = false;
  bool _showLoading = false;
  // bool _inSeek = false;
  bool isloading = false;
  bool isMute = false;
  bool toComment = false;

  int _loadingPercent = 0;
  // int _currentPlayerState = 0;
  int _videoDuration = 1;
  // int _currentPosition = 0;
  // int _bufferPosition = 0;
  // int _currentPositionText = 0;
  int _curIdx = 0;
  int _lastCurIndex = -1;

  String auth = '';
  String url = '';
  // final Map _dataSourceMap = {};
  // ModeTypeAliPLayer? _playMode = ModeTypeAliPLayer.auth;
  LocalizationModelV2? lang;
  ContentData? dataSelected;
  String email = '';
  String statusKyc = '';
  double opacityLevel = 0.0;

  final ScrollOffsetController scrollOffsetController = ScrollOffsetController();

  /// Listener that reports the position of items when the list is scrolled.
  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();
  late PageController _pageController;

  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'ScrollDiary');
    final notifier = Provider.of<ScrollDiaryNotifier>(context, listen: false);

    lang = context.read<TranslateNotifierV2>().translate;
    email = SharedPreference().readStorage(SpKeys.email);
    statusKyc = SharedPreference().readStorage(SpKeys.statusVerificationId);
    // stopwatch = new Stopwatch()..start();
    super.initState();
    diaryData = widget.arguments?.diaryData;
    notifier.diaryData = widget.arguments?.diaryData;
    _pageController = PageController(initialPage: widget.arguments?.page ?? 0);
    _curIdx = widget.arguments?.page ?? 0;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      start(diaryData?[widget.arguments?.page ?? 0] ?? ContentData());
      fAliplayer = FlutterAliPlayerFactory.createAliPlayer(playerId: 'diaryFullPlayer');
      WidgetsBinding.instance.addObserver(this);
      fAliplayer?.pause();
      fAliplayer?.setAutoPlay(true);
      fAliplayer?.setLoop(true);

      isMute = widget.arguments?.isTrue ?? false;
      // fAliplayer?.setLoop(true);
      fAliplayer?.setMuted(isMute);

      //Turn on mix mode
      if (Platform.isIOS) {
        FlutterAliplayer.enableMix(true);
        // FlutterAliplayer.setAudioSessionTypeForIOS(AliPlayerAudioSesstionType.mix);
      }

      notifier.checkConnection();

      //set player
      fAliplayer?.setPreferPlayerName(GlobalSettings.mPlayerName);
      fAliplayer?.setEnableHardwareDecoder(GlobalSettings.mEnableHardwareDecoder);
      globalAliPlayer = fAliplayer;
      vidConfig();
      _initListener();
      animatedController.repeat();
    });

    super.initState();
  }

  void checkInet() async {
    var inet = await System().checkConnections();
    if (!inet) {
      TranslateNotifierV2 tn = context.read<TranslateNotifierV2>();
      ShowGeneralDialog.showToastAlert(
        context,
        tn.translate.internetConnectionLost ?? ' Error',
        () async {
          Routing().moveBack();
        },
      );
    }
  }

  _initListener() {
    fAliplayer?.setOnEventReportParams((params, playerId) {
      print("EventReportParams=${params}");
    });
    fAliplayer?.setOnPrepared((playerId) {
      // Fluttertoast.showToast(msg: "OnPrepared ");
      fAliplayer?.getPlayerName().then((value) => print("getPlayerName==${value}"));
      fAliplayer?.getMediaInfo().then((value) {
        setState(() {
          isPrepare = true;
          _showLoading = false;
          isPlay = true;
          dataSelected?.isDiaryPlay = true;
        });
      });

      // _initAds(context);
    });
    fAliplayer?.setOnRenderingStart((playerId) {
      // Fluttertoast.showToast(msg: " OnFirstFrameShow ");
    });
    fAliplayer?.setOnVideoSizeChanged((width, height, rotation, playerId) {});
    fAliplayer?.setOnStateChanged((newState, playerId) {
      // _currentPlayerState = newState;
      print("aliyun : onStateChanged $newState");
      switch (newState) {
        case FlutterAvpdef.AVPStatus_AVPStatusStarted:
          setState(() {
            _showLoading = false;
            isPause = false;
          });
          break;
        case FlutterAvpdef.AVPStatus_AVPStatusPaused:
          isPause = true;
          setState(() {});
          break;
        default:
      }
    });
    fAliplayer?.setOnLoadingStatusListener(loadingBegin: (playerId) {
      setState(() {
        _loadingPercent = 0;
        _showLoading = true;
      });
    }, loadingProgress: (percent, netSpeed, playerId) {
      _loadingPercent = percent;
      if (percent == 100) {
        _showLoading = false;
      }
      setState(() {});
    }, loadingEnd: (playerId) {
      setState(() {
        _showLoading = false;
      });
    });
    fAliplayer?.setOnSeekComplete((playerId) {
      // _inSeek = false;
    });
    fAliplayer?.setOnInfo((infoCode, extraValue, extraMsg, playerId) {
      if (infoCode == FlutterAvpdef.CURRENTPOSITION) {
        if (_videoDuration != 0 && (extraValue ?? 0) <= _videoDuration) {
          // _currentPosition = extraValue ?? 0;
        }
        // if (!_inSeek) {
        //   setState(() {
        //     _currentPositionText = extraValue ?? 0;
        //   });
        // }
      } else if (infoCode == FlutterAvpdef.BUFFEREDPOSITION) {
        // _bufferPosition = extraValue ?? 0;
        // if (mounted) {
        //   setState(() {});
        // }
      } else if (infoCode == FlutterAvpdef.AUTOPLAYSTART) {
        // Fluttertoast.showToast(msg: "AutoPlay");
      } else if (infoCode == FlutterAvpdef.CACHESUCCESS) {
      } else if (infoCode == FlutterAvpdef.CACHEERROR) {
      } else if (infoCode == FlutterAvpdef.LOOPINGSTART) {
        // Fluttertoast.showToast(msg: "Looping Start");
      } else if (infoCode == FlutterAvpdef.SWITCHTOSOFTWAREVIDEODECODER) {
        // Fluttertoast.showToast(msg: "change to soft ware decoder");
        // mOptionsFragment.switchHardwareDecoder();
      }
    });
    fAliplayer?.setOnCompletion((playerId) {
      _showLoading = false;

      isPause = true;
      double index = _curIdx.toDouble();
      _pageController.animateTo(
        index++,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeIn,
      );

      setState(() {
        // _currentPosition = _videoDuration;
      });
    });

    fAliplayer?.setOnSnapShot((path, playerId) {
      print("aliyun : snapShotPath = $path");
      // Fluttertoast.showToast(msg: "SnapShot Save : $path");
    });
    fAliplayer?.setOnError((errorCode, errorExtra, errorMsg, playerId) {
      _showLoading = false;

      setState(() {});
    });

    fAliplayer?.setOnTrackChanged((value, playerId) {
      AVPTrackInfo info = AVPTrackInfo.fromJson(value);
      if ((info.trackDefinition?.length ?? 0) > 0) {
        // trackFragmentKey.currentState.onTrackChanged(info);
        // Fluttertoast.showToast(msg: "${info.trackDefinition}切换成功");
      }
    });
    fAliplayer?.setOnThumbnailPreparedListener(preparedSuccess: (playerId) {}, preparedFail: (playerId) {});

    fAliplayer?.setOnThumbnailGetListener(
        onThumbnailGetSuccess: (bitmap, range, playerId) {
          // _thumbnailBitmap = bitmap;
          var provider = MemoryImage(bitmap);
          precacheImage(provider, context).then((_) {
            setState(() {});
          });
        },
        onThumbnailGetFail: (playerId) {});

    fAliplayer?.setOnSubtitleHide((trackIndex, subtitleID, playerId) {
      if (mounted) {
        setState(() {});
      }
    });

    fAliplayer?.setOnSubtitleShow((trackIndex, subtitleID, subtitle, playerId) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void start(ContentData data) async {
    // if (notifier.listData != null && (notifier.listData?.length ?? 0) > 0 && _curIdx < (notifier.listData?.length ?? 0)) {

    fAliplayer?.stop();
    dataSelected = data;

    isPlay = false;
    dataSelected?.isDiaryPlay = false;
    // fAliplayer?.setVidAuth(
    //   vid: "c1b24d30b2c671edbfcb542280e90102",
    //   region: DataSourceRelated.defaultRegion,
    //   playAuth:
    //       "eyJTZWN1cml0eVRva2VuIjoiQ0FJU2lBTjFxNkZ0NUIyeWZTaklyNURISnUvWnJvZFIrb1d2VlY2SmdHa0RPdFZjaDZMRG96ejJJSDFLZlhadEJPQWN0ZlF3bFdwVDdQNGJsckl1RjhJWkdoR2ZONU10dE1RUHJGL3dKb0hidk5ldTBic0hoWnY5bGNNTHJaaWpqcUhvZU96Y1lJNzMwWjdQQWdtMlEwWVJySkwrY1RLOUphYk1VL21nZ29KbWFkSTZSeFN4YVNFOGF2NWRPZ3BscnIwSVZ4elBNdnIvSFJQMnVtN1pIV3R1dEEwZTgzMTQ1ZmFRejlHaTZ4YlRpM2I5ek9FVXFPYVhKNFMvUGZGb05ZWnlTZjZvd093VUVxL2R5M3hvN3hGYjFhRjRpODRpL0N2YzdQMlFDRU5BK3dtbFB2dTJpOE5vSUYxV2E3UVdJWXRncmZQeGsrWjEySmJOa0lpbDVCdFJFZHR3ZUNuRldLR216c3krYjRIUEROc2ljcXZoTUhuZ3k4MkdNb0tQMHprcGVuVUdMZ2hIQ2JGRFF6MVNjVUZ3RjIyRmQvVDlvQTJRTWwvK0YvbS92ZnRvZ2NvbC9UTEI1c0dYSWxXRGViS2QzQnNETjRVMEIwRlNiRU5JaERPOEwvOWNLRndUSWdrOFhlN01WL2xhYUJGUHRLWFdtaUgrV3lOcDAzVkxoZnI2YXVOcGJnUHIxVVFwTlJxQUFaT3kybE5GdndoVlFObjZmbmhsWFpsWVA0V3paN24wTnVCbjlILzdWZHJMOGR5dHhEdCtZWEtKNWI4SVh2c0lGdGw1cmFCQkF3ZC9kakhYTjJqZkZNVFJTekc0T3pMS1dKWXVzTXQycXcwMSt4SmNHeE9iMGtKZjRTcnFpQ1RLWVR6UHhwakg0eDhvQTV6Z0cvZjVIQ3lFV3pISmdDYjhEeW9EM3NwRUh4RGciLCJBdXRoSW5mbyI6IntcIkNJXCI6XCJmOUc0eExxaHg2Tkk3YThaY1Q2N3hObmYrNlhsM05abmJXR1VjRmxTelljS0VKVTN1aVRjQ29Hd3BrcitqL2phVVRXclB2L2xxdCs3MEkrQTJkb3prd0IvKzc5ZlFyT2dLUzN4VmtFWUt6TT1cIixcIkNhbGxlclwiOlwiV2NKTEpvUWJHOXR5UmM2ZXg3LzNpQXlEcS9ya3NvSldhcXJvTnlhTWs0Yz1cIixcIkV4cGlyZVRpbWVcIjpcIjIwMjMtMDMtMTZUMDk6NDE6MzdaXCIsXCJNZWRpYUlkXCI6XCJjMWIyNGQzMGIyYzY3MWVkYmZjYjU0MjI4MGU5MDEwMlwiLFwiUGxheURvbWFpblwiOlwidm9kLmh5cHBlLmNsb3VkXCIsXCJTaWduYXR1cmVcIjpcIk9pbHhxelNyaVVhOGlRZFhaVEVZZEJpbUhJUT1cIn0iLCJWaWRlb01ldGEiOnsiU3RhdHVzIjoiTm9ybWFsIiwiVmlkZW9JZCI6ImMxYjI0ZDMwYjJjNjcxZWRiZmNiNTQyMjgwZTkwMTAyIiwiVGl0bGUiOiIyODg4MTdkYi1jNzdjLWM0ZTQtNjdmYi0zYjk1MTlmNTc0ZWIiLCJDb3ZlclVSTCI6Imh0dHBzOi8vdm9kLmh5cHBlLmNsb3VkL2MxYjI0ZDMwYjJjNjcxZWRiZmNiNTQyMjgwZTkwMTAyL3NuYXBzaG90cy9jYzM0MjVkNzJiYjM0YTE3OWU5NmMzZTA3NTViZjJjNi0wMDAwNC5qcGciLCJEdXJhdGlvbiI6NTkuMDQ5fSwiQWNjZXNzS2V5SWQiOiJTVFMuTlNybVVtQ1hwTUdEV3g4ZGlWNlpwaGdoQSIsIlBsYXlEb21haW4iOiJ2b2QuaHlwcGUuY2xvdWQiLCJBY2Nlc3NLZXlTZWNyZXQiOiIzU1NRUkdkOThGMU04TkZ0b00xa2NlU01IZlRLNkJvZm93VXlnS1Y5aEpQdyIsIlJlZ2lvbiI6ImFwLXNvdXRoZWFzdC01IiwiQ3VzdG9tZXJJZCI6NTQ1NDc1MzIwNTI4MDU0OX0=",
    // );
    print("============= status ${data.reportedStatus} ======");
    if (data.reportedStatus != 'BLURRED') {
      if (data.isApsara ?? false) {
        // _playMode = ModeTypeAliPLayer.auth;
        await getAuth(data.apsaraId ?? '', data).then((value) {
          print("=============setelah auth======");
          print(value);
        });
      } else {
        // _playMode = ModeTypeAliPLayer.url;
        await getOldVideoUrl(data.postID ?? '', data);
      }
    }

    // fAliplayer?.play();
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
    //// Configure the application.
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

  void vidPrepare(ContentData data) {
    setState(() {
      isPause = false;
      // _isFirstRenderShow = false;
    });

    if (data.reportedStatus != 'BLURRED') {
      fAliplayer?.prepare().then((value) {
        print("===========setelah prepare");
      });
    }
  }

  Future getAuth(String apsaraId, ContentData data) async {
    setState(() {
      isloading = true;
      _showLoading = true;
    });
    try {
      final notifier = PostsBloc();
      await notifier.getAuthApsara(context, apsaraId: apsaraId, check: false);
      final fetch = notifier.postsFetch;
      if (fetch.postsState == PostsState.videoApsaraSuccess) {
        animatedController.repeat();
        Map jsonMap = json.decode(fetch.data.toString());
        setState(() {
          auth = jsonMap['PlayAuth'];
          fAliplayer?.setVidAuth(
            vid: apsaraId,
            region: DataSourceRelated.defaultRegion,
            playAuth: auth,
          );
        });
        print(auth);
        Future.delayed(Duration(milliseconds: 500), () {
          setState(() {
            isloading = false;
          });
        });
        vidPrepare(data);
        // widget.videoData?.fullContentPath = jsonMap['PlayUrl'];
      } else {
        fAliplayer?.setVidAuth(
          vid: '',
          region: DataSourceRelated.defaultRegion,
          playAuth: '',
        );
        fAliplayer?.onRenderingStart;
        getAuth(apsaraId, data);
        setState(() {
          isloading = false;
          _showLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isloading = false;
      });
      // 'Failed to fetch ads data $e'.logger();
    }
  }

  Future getOldVideoUrl(String postId, ContentData data) async {
    setState(() {
      isloading = true;
    });
    try {
      final notifier = PostsBloc();
      await notifier.getOldVideo(context, apsaraId: postId, check: false);
      final fetch = notifier.postsFetch;
      if (fetch.postsState == PostsState.videoApsaraSuccess) {
        Map jsonMap = json.decode(fetch.data.toString());

        fAliplayer?.setUrl(jsonMap['data']['url']);
        setState(() {
          isloading = false;
        });
        vidPrepare(data);
        // widget.videoData?.fullContentPath = jsonMap['PlayUrl'];
      } else {
        fAliplayer?.setUrl('');
        fAliplayer?.onRenderingStart;
        getOldVideoUrl(postId, data);
        setState(() {
          isloading = false;
          _showLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isloading = false;
      });
      // 'Failed to fetch ads data $e'.logger();
    }
  }

  void onViewPlayerCreated(viewId) async {
    fAliplayer?.setPlayerView(viewId);
  }

  // _initAds(BuildContext context) async {
  //   //for ads
  //   // getCountVid();
  //   // await _newInitAds(true);
  //   context.incrementAdsCount();
  //   final adsNotifier = context.read<PreviewDiaryNotifier>();
  //   if (context.getAdsCount() == 2) {
  //     try {
  //       context.read<PreviewDiaryNotifier>().getAdsVideo(context, false);
  //     } catch (e) {
  //       'Failed to fetch ads data 0 : $e'.logger();
  //     }
  //   }
  //   if (context.getAdsCount() == 3 && adsNotifier.adsData != null) {
  //     fAliplayer?.pause();
  //     System().adsPopUp(context, adsNotifier.adsData?.data ?? AdsData(), adsNotifier.adsData?.data?.apsaraAuth ?? '', isInAppAds: false).whenComplete(() {
  //       fAliplayer?.play();
  //     });
  //   }
  // }

  @override
  void didChangeDependencies() {
    CustomRouteObserver.routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    print("========--------dispose fullscreen----=========");
    fAliplayer?.stop();
    fAliplayer?.destroy();
    if (Platform.isIOS) {
      FlutterAliplayer.enableMix(false);
      // FlutterAliplayer.setAudioSessionTypeForIOS(AliPlayerAudioSesstionType.none);
    }

    print("========--------dispose----=========");
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void deactivate() {
    print("====== deactivate dari diary full sc");
    fAliplayer?.stop();
    fAliplayer?.destroy();

    super.deactivate();
  }

  @override
  void didPop() {
    print("====== didpop dari diary");
    super.didPop();
  }

  @override
  void didPopNext() {
    print("======= didPopNext dari diary");
    fAliplayer?.play();

    // System().disposeBlock();
    if (toComment) {
      ScrollDiaryNotifier notifier = context.read<ScrollDiaryNotifier>();
      setState(() {
        diaryData = notifier.diaryData;
        toComment = false;
      });
    }

    super.didPopNext();
  }

  @override
  void didPushNext() {
    print("========= didPushNext dari diary");
    fAliplayer?.pause();
    super.didPushNext();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.inactive:
        fAliplayer?.pause();
        break;
      case AppLifecycleState.resumed:
        if (context.read<PreviewVidNotifier>().canPlayOpenApps) {
          fAliplayer?.play();
        }
        break;
      case AppLifecycleState.paused:
        fAliplayer?.pause();
        break;
      case AppLifecycleState.detached:
        fAliplayer?.pause();
        break;
      default:
        break;
    }
  }

  void play() {
    setState(() {
      isPause = false;
    });

    fAliplayer?.play();
    animatedController.repeat();
  }

  void pause() {
    print('pause pause');
    setState(() {
      isPause = true;
    });

    fAliplayer?.pause();
    animatedController.stop();
  }

  void changeStatusBlur(ContentData? data) {
    setState(() {
      data?.reportedStatus = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    context.select((ErrorService value) => value.getError(ErrorType.pic));
    // AliPlayerView aliPlayerView = AliPlayerView(onCreated: onViewPlayerCreated, x: 0.0, y: 0.0, width: 100, height: 200);

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onHorizontalDragEnd: (dragEndDetails) {
          if (dragEndDetails.primaryVelocity! < 0) {
          } else if (dragEndDetails.primaryVelocity! > 0) {
            // fAliplayer?.pause();
            Routing().moveBack();
          }
        },
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarBrightness: Brightness.light, statusBarIconBrightness: Brightness.light),
          child: Consumer2<ScrollDiaryNotifier, HomeNotifier>(builder: (_, notifier, home, __) {
            return RefreshIndicator(
              onRefresh: () async {
                bool connect = await System().checkConnections();
                if (connect) {
                  setState(() {
                    isloading = true;
                  });
                  await notifier.reload(context, widget.arguments!.pageSrc!, key: widget.arguments?.key ?? '');
                  setState(() {
                    diaryData = notifier.diaryData;
                  });
                } else {
                  if (mounted) {
                    ShowGeneralDialog.showToastAlert(
                      context,
                      lang?.internetConnectionLost ?? ' Error',
                      () async {},
                    );
                  }
                }
              },
              child: PageView.builder(
                scrollDirection: Axis.vertical,
                controller: _pageController,

                // scrollDirection: Axis.horizontal,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: diaryData?.length ?? 0,
                onPageChanged: (index) {
                  print("===asdasdasd $index");
                  _curIdx = index;
                  if (_lastCurIndex != _curIdx) {
                    try {
                      widget.arguments?.scrollController?.jumpTo(System().scrollAuto(_curIdx, widget.arguments?.heightTopProfile ?? 0, widget.arguments?.heightBox?.toInt() ?? 175));
                    } catch (e) {
                      print("ini error $e");
                    }
                    Future.delayed(const Duration(milliseconds: 400), () {
                      start(diaryData?[index] ?? ContentData());
                      System().increaseViewCount2(context, diaryData?[index] ?? ContentData(), check: false);
                    });
                    if (_curIdx == (notifier.diaryData?.length ?? 0) - 1) {
                      Future.delayed(const Duration(milliseconds: 1000), () async {
                        await notifier.loadMoreFullScreen(context, widget.arguments!.pageSrc!, widget.arguments?.key ?? '');
                        setState(() {
                          diaryData = notifier.diaryData;
                        });
                      });
                      if (_curIdx == (notifier.diaryData?.length ?? 0) - 1) {
                        Future.delayed(const Duration(milliseconds: 1000), () async {
                          await notifier.loadMoreFullScreen(context, widget.arguments!.pageSrc!, widget.arguments?.key ?? '');
                          setState(() {
                            diaryData = notifier.diaryData;
                          });
                        });
                      }
                      if (diaryData?[index].certified ?? false) {
                        System().block(context);
                      } else {
                        System().disposeBlock();
                      }
                    }
                    _lastCurIndex = _curIdx;
                  }
                },
                itemBuilder: (context, index) {
                  if (diaryData == null || home.isLoadingDiary) {
                    fAliplayer?.pause();
                    _lastCurIndex = -1;
                    return CustomShimmer(
                      width: (MediaQuery.of(context).size.width - 11.5 - 11.5 - 9) / 2,
                      height: 168,
                      radius: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 10),
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
                    );
                  } else if (index == diaryData?.length) {
                    return UnconstrainedBox(
                      child: Container(
                        alignment: Alignment.center,
                        width: 80 * SizeConfig.scaleDiagonal,
                        height: 80 * SizeConfig.scaleDiagonal,
                        child: const CustomLoading(),
                      ),
                    );
                  }
                  if (_curIdx == 0 && diaryData?[0].reportedStatus == 'BLURRED') {
                    isPlay = false;
                    fAliplayer?.stop();
                  }

                  return itemDiary(notifier, index);
                },
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget itemDiary(ScrollDiaryNotifier notifier, int index) {
    return Stack(
      children: [
        if (_curIdx == index)
          FutureBuilder(
              future: Future.wait([for (StickerModel sticker in diaryData?[index].stickers ?? []) precacheImage(NetworkImage(sticker.image ?? ''), context)]),
              builder: (context, snapshot) {
                return Builder(builder: (context) {
                  // if (!isloading) {
                  //   return AliPlayerView(
                  //     onCreated: onViewPlayerCreated,
                  //     x: 0,
                  //     y: 0,
                  //     height: MediaQuery.of(context).size.width * 16.0 / 9.0,
                  //     width: MediaQuery.of(context).size.width,
                  //   );
                  // }
                  return Stack(
                    children: [
                      AliPlayerView(
                        onCreated: onViewPlayerCreated,
                        x: 0,
                        y: 0,
                        height: MediaQuery.of(context).size.width * 16.0 / 9.0,
                        width: MediaQuery.of(context).size.width,
                      ),
                      Visibility(
                        visible: isPlay,
                        child: StickerOverlay(
                          fullscreen: false,
                          stickers: diaryData?[index].stickers,
                          width: MediaQuery.of(context).size.width,
                          height: (MediaQuery.of(context).size.width) * (16 / 9),
                          isPause: isPause || _showLoading,
                          canPause: true,
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: AnimatedOpacity(
                          opacity: opacityLevel,
                          duration: const Duration(milliseconds: 500),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Opacity(
                              opacity: 0.4,
                              child: Icon(
                                isPause ? Icons.play_arrow_rounded : Icons.pause_rounded,
                                size: 100,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                });
              }),

        // _buildProgressBar(SizeConfig.screenWidth!, 500),
        !notifier.connectionError
            ? Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    fAliplayer?.play();
                    setState(() {
                      isMute = !isMute;
                    });
                    fAliplayer?.setMuted(isMute);
                  },
                  onDoubleTap: () {
                    final _likeNotifier = context.read<LikeNotifier>();
                    if (diaryData?[index] != null) {
                      _likeNotifier.likePost(context, diaryData![index]);
                    }
                  },
                  child: Container(
                    color: Colors.transparent,
                    width: SizeConfig.screenWidth,
                    height: SizeConfig.screenHeight,
                  ),
                ),
              )
            : Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    notifier.checkConnection().then((value) {
                      if (value == true) {
                        fAliplayer?.stop();
                        start(diaryData?[index] ?? ContentData());
                      }
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(color: kHyppeNotConnect, borderRadius: BorderRadius.circular(16)),
                    width: SizeConfig.screenWidth,
                    height: SizeConfig.screenHeight,
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(20),
                    child: diaryData?[index].reportedStatus == 'BLURRED'
                        ? Container()
                        : CustomTextWidget(
                            textToDisplay: lang?.couldntLoadVideo ?? 'Error',
                            maxLines: 3,
                          ),
                  ),
                ),
              ),

        dataSelected?.postID == diaryData?[index].postID && isPlay
            ? Container()
            : !notifier.connectionError
                ? CustomBaseCacheImage(
                    memCacheWidth: 100,
                    memCacheHeight: 100,
                    widthPlaceHolder: 80,
                    heightPlaceHolder: 80,
                    placeHolderWidget: Container(),
                    imageUrl: (diaryData?[index].isApsara ?? false) ? (diaryData?[index].mediaThumbEndPoint ?? "") : "${diaryData?[index].fullThumbPath ?? ''}",
                    imageBuilder: (context, imageProvider) => diaryData?[index].reportedStatus == 'BLURRED'
                        ? ImageFiltered(
                            imageFilter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                            child: Image(
                              height: MediaQuery.of(context).size.height,
                              width: MediaQuery.of(context).size.width,
                              image: imageProvider,
                            ),
                          )
                        : Container(
                            // const EdgeInsets.symmetric(horizontal: 4.5),
                            // height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.contain,
                              ),
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                          ),
                    errorWidget: (context, url, error) {
                      return GestureDetector(
                        onTap: () {
                          notifier.checkConnection();
                        },
                        child: Container(
                            // decoration: BoxDecoration(color: kHyppeNotConnect, borderRadius: BorderRadius.circular(16)),
                            // width: SizeConfig.screenWidth,
                            // height: MediaQuery.of(context).size.width * 16.0 / 9.0,
                            alignment: Alignment.center,
                            child: CustomTextWidget(textToDisplay: lang?.couldntLoadVideo ?? 'Error')),
                      );
                    },
                    emptyWidget: GestureDetector(
                      onTap: () {
                        notifier.checkConnection();
                      },
                      child: Container(
                          // decoration: BoxDecoration(color: kHyppeNotConnect, borderRadius: BorderRadius.circular(16)),
                          // width: SizeConfig.screenWidth,
                          // height: MediaQuery.of(context).size.width * 16.0 / 9.0,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(20),
                          child: CustomTextWidget(
                            textToDisplay: lang?.couldntLoadVideo ?? 'Error',
                            maxLines: 3,
                          )),
                    ),
                  )
                : Container(),
        _showLoading && !notifier.connectionError
            ? const Positioned.fill(
                child: Align(
                alignment: Alignment.center,
                child: CircularProgressIndicator(),
              ))
            : Container(),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          // padding: EdgeInsets.only(bottom: 25.0),
          child: _buildFillDiary(diaryData?[index]),
        ),
        // _buildBody(context, SizeConfig.screenWidth, diaryData?[index] ?? ContentData()),
        // blurContentWidget(context, diaryData?[index] ?? ContentData()),
      ],
    );
  }

  Widget _buildFillDiary(ContentData? data) {
    // print("[DIARY_PLAYER] _buildFillDiary() started. "+stopwatch.elapsed.toString());
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            end: const Alignment(0.0, -1),
            begin: const Alignment(0.0, 1),
            colors: [const Color(0x8A000000), Colors.black12.withOpacity(0.0)],
          ),
        ),
        child: Stack(
          children: [
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // storyComplete(not);
                      if (isPause) {
                        play();
                      } else {
                        pause();
                      }
                      setState(() {
                        opacityLevel = 1.0;
                      });
                      Future.delayed(const Duration(seconds: 1), () {
                        opacityLevel = 0.0;
                        setState(() {});
                      });
                    },
                    onDoubleTap: () {
                      final _likeNotifier = context.read<LikeNotifier>();
                      if (data != null) {
                        _likeNotifier.likePost(context, data);
                      }
                    },
                    onLongPressEnd: (value) => play(),
                    onLongPressStart: (value) => pause(),
                    // onLongPress: () => pause(),
                    child: Container(
                      height: MediaQuery.of(context).size.height,
                      // padding: EdgeInsets.only(bottom: 25.0),
                      color: Colors.transparent,
                    ),
                  ),
                ),
              ],
            ),

            data?.reportedStatus == "BLURRED"
                ? CustomBackgroundLayer(
                    sigmaX: 30,
                    sigmaY: 30,
                    // thumbnail: picData!.content[arguments].contentUrl,
                    thumbnail: (data?.isApsara ?? false) ? (data?.mediaThumbEndPoint ?? '') : (data?.fullThumbPath ?? ''),
                  )
                : Container(),
            (data?.reportedStatus == "BLURRED")
                ? blurContentWidget(context, data!)
                // DiarySensitive(
                //     data: data,
                //     function: () {
                //       changeStatusBlur(data);
                //     },
                //   )
                : Container(),
            data?.reportedStatus == "BLURRED"
                ? Align(
                    alignment: Alignment.topRight,
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: CustomTextButton(
                        style: ButtonStyle(
                          padding: MaterialStateProperty.all(
                            const EdgeInsets.only(left: 0.0),
                          ),
                        ),
                        onPressed: () => Routing().moveBack(),
                        child: const DecoratedIconWidget(
                          Icons.close_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                : TitlePlaylistDiaries(
                    data: data,
                    inProfile: true,
                    callbackReport: () {
                      if (diaryData?.isEmpty ?? [].isEmpty) {
                        Routing().moveBack();
                        Routing().moveBack();
                        Routing().moveBack();
                        return;
                      }
                    },
                    // storyController: _storyController,
                  ),

            // Text(_listData![_curIdx].username!),
            data?.reportedStatus == "BLURRED"
                ? Container()
                : RightItems(
                    data: data ?? ContentData(),
                    pageDetail: true,
                  ),
            data?.reportedStatus == "BLURRED"
                ? Container()
                : LeftItems(
                    aliPlayer: fAliplayer,
                    description: data?.description,
                    // tags: data?.tags?.map((e) => "#${e.replaceFirst('#', '')}").join(" "),
                    music: data?.music,
                    authorName: data?.username,
                    userName: data?.username,
                    location: data?.location,
                    postID: data?.postID,
                    // storyController: _storyController,
                    tagPeople: data?.tagPeople,
                    data: data,
                    animatedController: animatedController,
                  ),

            Align(
              alignment: Alignment.bottomCenter,
              child: data?.email == SharedPreference().readStorage(SpKeys.email) && (data?.reportedStatus == 'OWNED')
                  ? SizedBox(height: 58, child: ContentViolationWidget(data: data ?? ContentData()))
                  : Container(),
            ),
          ],
        ),
      ),
    );
  }

  _buildProgressBar(double width, double height) {
    if (_showLoading) {
      return Positioned(
        left: width / 2 - 20,
        top: height / 2 - 20,
        child: Column(
          children: [
            const CircularProgressIndicator(
              backgroundColor: Colors.white,
              strokeWidth: 3.0,
            ),
            const SizedBox(
              height: 10.0,
            ),
            Text(
              "$_loadingPercent%",
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  Widget _buildBody(BuildContext context, width, ContentData data) {
    return Positioned.fill(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: PicTopItem(data: data),
          ),
          if (data.tagPeople?.isNotEmpty ?? false)
            Positioned(
              bottom: 18,
              left: 12,
              child: GestureDetector(
                onTap: () {
                  context.read<PicDetailNotifier>().showUserTag(context, data.tagPeople, data.postID);
                },
                child: const CustomIconWidget(
                  iconData: '${AssetPath.vectorPath}tag_people.svg',
                  defaultColor: false,
                  height: 24,
                ),
              ),
            ),
          Align(
            alignment: Alignment.bottomRight,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isMute = !isMute;
                });
                fAliplayer?.setMuted(isMute);
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: CustomIconWidget(
                  iconData: isMute ? '${AssetPath.vectorPath}sound-off.svg' : '${AssetPath.vectorPath}sound-on.svg',
                  defaultColor: false,
                  height: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget blurContentWidget(BuildContext context, ContentData data) {
    final transnot = Provider.of<TranslateNotifierV2>(context, listen: false);
    return data.reportedStatus == 'BLURRED'
        ? Positioned.fill(
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
                        color: Colors.white,
                        height: 30,
                      ),
                      Text(transnot.translate.sensitiveContent ?? 'Sensitive Content', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                      Text("HyppeDiary ${transnot.translate.contentContainsSensitiveMaterial}",
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
                                  child: Text(transnot.translate.appealThisWarning ?? 'Appeal This Warning', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600))),
                            )
                          : const SizedBox(),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          data.reportedStatus = '';
                          setState(() {});

                          var notifier = Provider.of<ScrollDiaryNotifier>(context, listen: false);
                          var indexpost = notifier.diaryData?.indexWhere((element) => data.postID == element.postID) ?? 0;
                          print("== index $indexpost");
                          notifier.diaryData?[indexpost].reportedStatus = '';
                          notifier.onUpdate();
                          start(data);
                          context.read<ReportNotifier>().seeContent(context, data, hyppeDiary);
                          fAliplayer?.prepare();
                          fAliplayer?.play();
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
                            "${transnot.translate.see} HyppeDiary",
                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          )
        : Container();
  }
}
