import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_aliplayer/flutter_aliplayer.dart';
import 'package:flutter_aliplayer/flutter_aliplayer_factory.dart';
import 'package:hyppe/app.dart';
import 'package:hyppe/core/arguments/contents/diary_detail_screen_argument.dart';
import 'package:hyppe/core/bloc/posts_v2/bloc.dart';
import 'package:hyppe/core/bloc/posts_v2/state.dart';
import 'package:hyppe/core/config/ali_config.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/constants/utils.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/services/route_observer_service.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/entities/like/notifier.dart';
import 'package:hyppe/ui/constant/entities/report/notifier.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/widget/custom_background_layer.dart';
import 'package:hyppe/ui/constant/widget/custom_base_cache_image.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/decorated_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/sticker_overlay.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/playlist/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/playlist/widget/content_violation.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/playlist/widget/diary_sensitive.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/playlist/widget/left_items.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/playlist/widget/right_items.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/playlist/widget/title_playlist_diaries.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/preview/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/widget/fullscreen/notifier.dart';
import 'package:hyppe/ui/inner/home/notifier_v2.dart';
import 'package:hyppe/ui/inner/main/notifier.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/services/error_service.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_shimmer.dart';
import 'package:visibility_detector/visibility_detector.dart';

class LandingDiaryFullPage extends StatefulWidget {
  final DiaryDetailScreenArgument argument;
  const LandingDiaryFullPage({
    Key? key,
    required this.argument,
  }) : super(key: key);

  @override
  _LandingDiaryFullPageState createState() => _LandingDiaryFullPageState();
}

class _LandingDiaryFullPageState extends State<LandingDiaryFullPage> with WidgetsBindingObserver, TickerProviderStateMixin, WidgetsBindingObserver, RouteAware {
  late final AnimationController animatedController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  FlutterAliplayer? fAliplayer;
  bool isPrepare = false;
  bool isPlay = false;
  bool isPause = false;
  bool _showLoading = false;
  // bool _inSeek = false;
  bool isloading = false;
  bool isMute = false;

  int _loadingPercent = 0;
  // int _currentPlayerState = 0;
  int _videoDuration = 1;
  // int _currentPosition = 0;
  // int _bufferPosition = 0;
  // int _currentPositionText = 0;
  int _curIdx = 0;
  int _lastCurIndex = -1;
  String _curPostId = '';
  String _lastCurPostId = '';

  String auth = '';
  String url = '';
  // final Map _dataSourceMap = {};
  // ModeTypeAliPLayer? _playMode = ModeTypeAliPLayer.auth;
  LocalizationModelV2? lang;
  ContentData? dataSelected;
  String email = '';
  String statusKyc = '';
  double itemHeight = 0;
  double lastOffset = -10;
  MainNotifier? mn;
  int indexKeySell = 0;
  int indexKeyProtection = 0;
  int itemIndex = 0;
  bool scroolUp = false;
  late PageController _pageController;
  double opacityLevel = 0.0;

  @override
  void initState() {
    "++++++++++++++ initState".logger();
    FirebaseCrashlytics.instance.setCustomKey('layout', 'LandingDiaryFullPage');
    final notifier = Provider.of<PreviewDiaryNotifier>(context, listen: false);

    notifier.initAdsCounter();
    lang = context.read<TranslateNotifierV2>().translate;
    notifier.scrollController.addListener(() => notifier.scrollListener(context));
    email = SharedPreference().readStorage(SpKeys.email);
    statusKyc = SharedPreference().readStorage(SpKeys.statusVerificationId);
    lastOffset = -10;
    mn = Provider.of<MainNotifier>(context, listen: false);
    _pageController = PageController(initialPage: widget.argument.index.toInt());

    _curIdx = widget.argument.index.toInt();
    _lastCurIndex = widget.argument.index.toInt();

    // stopwatch = new Stopwatch()..start();

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      WidgetsBinding.instance.addObserver(this);
      if (mn?.tutorialData.isNotEmpty ?? [].isEmpty) {
        indexKeySell = mn?.tutorialData.indexWhere((element) => element.key == 'sell') ?? 0;
        indexKeyProtection = mn?.tutorialData.indexWhere((element) => element.key == 'protection') ?? 0;
      }
      _curPostId = notifier.diaryData?[_curIdx].postID ?? '';

      start(context, notifier.diaryData?[_curIdx] ?? ContentData());

      initAlipayer();
    });

    _initializeTimer();
    super.initState();
  }

  initAlipayer() {
    fAliplayer = FlutterAliPlayerFactory.createAliPlayer(playerId: 'DiaryLandingFullpage');
    globalAliPlayer = fAliplayer;
    fAliplayer?.pause();
    fAliplayer?.setAutoPlay(true);
    vidConfig();
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

  _initListener() {
    fAliplayer?.setOnEventReportParams((params, playerId) {
      print("EventReportParams=${params}");
    });
    fAliplayer?.setOnPrepared((playerId) {
      // Fluttertoast.showToast(msg: "OnPrepared ");
      fAliplayer?.getPlayerName().then((value) => print("getPlayerName==${value}"));
      fAliplayer?.getMediaInfo().then((value) {
        try {
          isPrepare = true;
          _showLoading = false;
          if (mounted) {}
        } catch (e) {
          e.logger();
        }
      });
      isPlay = true;
      dataSelected?.isDiaryPlay = true;
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
          try {
            _showLoading = false;
            isPause = false;
            if (mounted) {
              setState(() {});
            }
            if (globalTultipShow) {
              fAliplayer?.pause();
            }
          } catch (e) {
            e.logger();
          }

          break;
        case FlutterAvpdef.AVPStatus_AVPStatusPaused:
          isPause = true;
          print("---------- streaming pause -----------");
          if (mounted) setState(() {});
          break;
        default:
      }
    });
    fAliplayer?.setOnLoadingStatusListener(loadingBegin: (playerId) {
      try {
        _loadingPercent = 0;
        _showLoading = true;
        if (mounted) {
          setState(() {});
        }
      } catch (e) {
        e.logger();
      }
    }, loadingProgress: (percent, netSpeed, playerId) {
      try {
        _loadingPercent = percent;
        if (percent == 100) {
          _showLoading = false;
        }
        if (mounted) {
          setState(() {});
        }
      } catch (e) {
        e.logger();
      }
    }, loadingEnd: (playerId) {
      try {
        _showLoading = false;
        if (mounted) {
          setState(() {});
        }
      } catch (e) {
        e.logger();
      }
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
      } else if (infoCode == FlutterAvpdef.paused) {
        print("---------- streaming pause -----------");
        // mOptionsFragment.switchHardwareDecoder();
      }
    });
    fAliplayer?.setOnCompletion((playerId) {
      final notifier = context.read<PreviewDiaryNotifier>();
      try {
        _showLoading = false;

        isPause = true;

        print("============ complatet $_curIdx ${_curIdx++} ========");
        _pageController.animateToPage(
          _curIdx++,
          duration: Duration(milliseconds: 350),
          curve: Curves.easeIn,
        );
        // double position = 0.0;
        // for (var i = 0; i <= _curIdx; i++) {
        //   position += notifier.diaryData?[i].height ?? 0.0;
        // }
        if (notifier.diaryData?[_curIdx] != notifier.diaryData?.last) {
          // widget.scrollController?.animateTo(
          //   position,
          //   duration: const Duration(milliseconds: 400),
          //   curve: Curves.easeOut,
          // );
        }
        if (mounted) {
          setState(() {});
        }
      } catch (e) {
        e.logger();
      }
    });

    fAliplayer?.setOnSnapShot((path, playerId) {
      print("aliyun : snapShotPath = $path");
      // Fluttertoast.showToast(msg: "SnapShot Save : $path");
    });
    fAliplayer?.setOnError((errorCode, errorExtra, errorMsg, playerId) {
      try {
        _showLoading = false;

        setState(() {});
      } catch (e) {
        e.logger();
      }
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

  void toPosition(offset) async {
    // _initializeTimer();
    double totItemHeight = 0;
    double totItemHeightParam = 0;
    final notifier = context.read<PreviewDiaryNotifier>();

    if (offset < 10) {
      itemIndex = 0;
    }

    // if (offset > lastOffset) {
    if (!scroolUp) {
      homeClick = false;
      for (var i = 0; i <= itemIndex; i++) {
        if (i == itemIndex) {
          totItemHeightParam += (notifier.diaryData?[i].height ?? 0.0) * 30 / 100;
        } else {
          totItemHeightParam += notifier.diaryData?[i].height ?? 0.0;
        }
        totItemHeight += notifier.diaryData?[i].height ?? 0.0;
      }
      if (offset >= totItemHeightParam) {
        var position = totItemHeight;
        if (itemIndex == 0 && position == 0) {
          position = notifier.diaryData?[1].height ?? 200.0;
        }
        if (mounted) {
          // widget.scrollController?.animateTo(position, duration: const Duration(milliseconds: 200), curve: Curves.ease);
          itemIndex++;
        }
      }
    } else {
      if (!homeClick) {
        for (var i = 0; i < itemIndex; i++) {
          if (i == itemIndex - 1) {
            totItemHeightParam += (notifier.diaryData?[i].height ?? 0.0) * 75 / 100;
          } else if (i == itemIndex) {
          } else {
            totItemHeightParam += notifier.diaryData?[i].height ?? 0.0;
          }
          totItemHeight += notifier.diaryData?[i].height ?? 0.0;
        }
        if (itemIndex > 0) {
          totItemHeight -= notifier.diaryData?[itemIndex - 1].height ?? 0.0;
        }

        if (offset <= totItemHeightParam && offset > 0) {
          // var position = totItemHeight;
          if (mounted) {
            // widget.scrollController?.animateTo(position, duration: const Duration(milliseconds: 200), curve: Curves.ease);
            itemIndex--;
          }
        }
      }
    }
    lastOffset = offset;
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

  Future start(BuildContext context, ContentData data) async {
    // if (notifier.listData != null && (notifier.listData?.length ?? 0) > 0 && _curIdx < (notifier.listData?.length ?? 0)) {

    fAliplayer?.stop();
    fAliplayer?.clearScreen();

    dataSelected = data;

    isPlay = false;
    dataSelected?.isDiaryPlay = false;
    // fAliplayer?.setVidAuth(
    //   vid: "c1b24d30b2c671edbfcb542280e90102",
    //   region: DataSourceRelated.defaultRegion,
    //   playAuth:
    //       "eyJTZWN1cml0eVRva2VuIjoiQ0FJU2lBTjFxNkZ0NUIyeWZTaklyNURISnUvWnJvZFIrb1d2VlY2SmdHa0RPdFZjaDZMRG96ejJJSDFLZlhadEJPQWN0ZlF3bFdwVDdQNGJsckl1RjhJWkdoR2ZONU10dE1RUHJGL3dKb0hidk5ldTBic0hoWnY5bGNNTHJaaWpqcUhvZU96Y1lJNzMwWjdQQWdtMlEwWVJySkwrY1RLOUphYk1VL21nZ29KbWFkSTZSeFN4YVNFOGF2NWRPZ3BscnIwSVZ4elBNdnIvSFJQMnVtN1pIV3R1dEEwZTgzMTQ1ZmFRejlHaTZ4YlRpM2I5ek9FVXFPYVhKNFMvUGZGb05ZWnlTZjZvd093VUVxL2R5M3hvN3hGYjFhRjRpODRpL0N2YzdQMlFDRU5BK3dtbFB2dTJpOE5vSUYxV2E3UVdJWXRncmZQeGsrWjEySmJOa0lpbDVCdFJFZHR3ZUNuRldLR216c3krYjRIUEROc2ljcXZoTUhuZ3k4MkdNb0tQMHprcGVuVUdMZ2hIQ2JGRFF6MVNjVUZ3RjIyRmQvVDlvQTJRTWwvK0YvbS92ZnRvZ2NvbC9UTEI1c0dYSWxXRGViS2QzQnNETjRVMEIwRlNiRU5JaERPOEwvOWNLRndUSWdrOFhlN01WL2xhYUJGUHRLWFdtaUgrV3lOcDAzVkxoZnI2YXVOcGJnUHIxVVFwTlJxQUFaT3kybE5GdndoVlFObjZmbmhsWFpsWVA0V3paN24wTnVCbjlILzdWZHJMOGR5dHhEdCtZWEtKNWI4SVh2c0lGdGw1cmFCQkF3ZC9kakhYTjJqZkZNVFJTekc0T3pMS1dKWXVzTXQycXcwMSt4SmNHeE9iMGtKZjRTcnFpQ1RLWVR6UHhwakg0eDhvQTV6Z0cvZjVIQ3lFV3pISmdDYjhEeW9EM3NwRUh4RGciLCJBdXRoSW5mbyI6IntcIkNJXCI6XCJmOUc0eExxaHg2Tkk3YThaY1Q2N3hObmYrNlhsM05abmJXR1VjRmxTelljS0VKVTN1aVRjQ29Hd3BrcitqL2phVVRXclB2L2xxdCs3MEkrQTJkb3prd0IvKzc5ZlFyT2dLUzN4VmtFWUt6TT1cIixcIkNhbGxlclwiOlwiV2NKTEpvUWJHOXR5UmM2ZXg3LzNpQXlEcS9ya3NvSldhcXJvTnlhTWs0Yz1cIixcIkV4cGlyZVRpbWVcIjpcIjIwMjMtMDMtMTZUMDk6NDE6MzdaXCIsXCJNZWRpYUlkXCI6XCJjMWIyNGQzMGIyYzY3MWVkYmZjYjU0MjI4MGU5MDEwMlwiLFwiUGxheURvbWFpblwiOlwidm9kLmh5cHBlLmNsb3VkXCIsXCJTaWduYXR1cmVcIjpcIk9pbHhxelNyaVVhOGlRZFhaVEVZZEJpbUhJUT1cIn0iLCJWaWRlb01ldGEiOnsiU3RhdHVzIjoiTm9ybWFsIiwiVmlkZW9JZCI6ImMxYjI0ZDMwYjJjNjcxZWRiZmNiNTQyMjgwZTkwMTAyIiwiVGl0bGUiOiIyODg4MTdkYi1jNzdjLWM0ZTQtNjdmYi0zYjk1MTlmNTc0ZWIiLCJDb3ZlclVSTCI6Imh0dHBzOi8vdm9kLmh5cHBlLmNsb3VkL2MxYjI0ZDMwYjJjNjcxZWRiZmNiNTQyMjgwZTkwMTAyL3NuYXBzaG90cy9jYzM0MjVkNzJiYjM0YTE3OWU5NmMzZTA3NTViZjJjNi0wMDAwNC5qcGciLCJEdXJhdGlvbiI6NTkuMDQ5fSwiQWNjZXNzS2V5SWQiOiJTVFMuTlNybVVtQ1hwTUdEV3g4ZGlWNlpwaGdoQSIsIlBsYXlEb21haW4iOiJ2b2QuaHlwcGUuY2xvdWQiLCJBY2Nlc3NLZXlTZWNyZXQiOiIzU1NRUkdkOThGMU04TkZ0b00xa2NlU01IZlRLNkJvZm93VXlnS1Y5aEpQdyIsIlJlZ2lvbiI6ImFwLXNvdXRoZWFzdC01IiwiQ3VzdG9tZXJJZCI6NTQ1NDc1MzIwNTI4MDU0OX0=",
    // );
    if (data.reportedStatus != 'BLURRED') {
      if (data.isApsara ?? false) {
        // _playMode = ModeTypeAliPLayer.auth;
        await getAuth(context, data.apsaraId ?? '');
      } else {
        // _playMode = ModeTypeAliPLayer.url;
        await getOldVideoUrl(data.postID ?? '');
      }
    }
    if (mounted) {
      setState(() {
        isPause = false;
        // _isFirstRenderShow = false;
      });
    }

    if (data.reportedStatus == 'BLURRED') {
    } else {
      print("=====prepare=====");
      fAliplayer?.prepare();
    }
    // this syntax below to prevent video play after changing video
    Future.delayed(const Duration(seconds: 1), () {
      if (context.read<MainNotifier>().isInactiveState) {
        fAliplayer?.pause();
      }
    });

    // fAliplayer?.play();
  }

  Future getAuth(BuildContext context, String apsaraId) async {
    try {
      final fixContext = Routing.navigatorKey.currentContext;
      isloading = true;
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

        fAliplayer?.setVidAuth(
          vid: apsaraId,
          region: DataSourceRelated.defaultRegion,
          playAuth: auth,
          definitionList: [DataSourceRelated.definitionList],
        );

        // fAliplayer?.setUrl("http://live.hyppe.cloud/hyppe-live/657fc76b8ce9ba14df462a6c.m3u8?auth_key=1703736940-0-0-cd08b66600e03a8939d029474f694f55");

        isloading = false;
        if (mounted) {
          setState(() {});
        }
        // widget.videoData?.fullContentPath = jsonMap['PlayUrl'];
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
            isloading = false;
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

  void onViewPlayerCreated(viewId) async {
    fAliplayer?.setPlayerView(viewId);
    // _generatePlayConfigGen();
    // FlutterAliplayer.generatePlayerConfig().then((value) {
    //   fAliplayer?.setVidAuth(
    //       vid: "51b4d7a0adb771edbfb7442380ea0102",
    //       region: DataSourceRelated.regionKey,
    //       playAuth:
    //           "eyJTZWN1cml0eVRva2VuIjoiQ0FJU2lBTjFxNkZ0NUIyeWZTaklyNWJiSTg3d25xd1RocmFSYjBmVzAyb0ZkdVpicmJ6RXNqejJJSDFLZlhadEJPQWN0ZlF3bFdwVDdQNGJsckl1RjhJWkdoR2ZONU10dE1RUHJGL3dKb0hidk5ldTBic0hoWnY5MnZwaGxlU2lqcUhvZU96Y1lJNzMwWjdQQWdtMlEwWVJySkwrY1RLOUphYk1VL21nZ29KbWFkSTZSeFN4YVNFOGF2NWRPZ3BscnIwSVZ4elBNdnIvSFJQMnVtN1pIV3R1dEEwZTgzMTQ1ZmFRejlHaTZ4YlRpM2I5ek9FVXFPYVhKNFMvUGZGb05ZWnlTZjZvd093VUVxL2R5M3hvN3hGYjFhRjRpODRpL0N2YzdQMlFDRU5BK3dtbFB2dTJpOE5vSUYxV2E3UVdJWXRncmZQeGsrWjEySmJOa0lpbDVCdFJFZHR3ZUNuRldLR216c3krYjRIUEROc2ljcXZoTUhuZ3k4MkdNb0tQMHprcGVuVUdMZ2hIQ2JGRFF6MVNjVUZ3RjIyRmQvVDlvQTJRTWwvK0YvbS92ZnRvZ2NvbC9UTEI1c0dYSWxXRGViS2QzQnNETjRVMEIwRlNiRU5JaERPOEwvOWNLRndUSWdrOFhlN01WL2xhYUJGUHRLWFdtaUgrV3lOcDAzVkxoZnI2YXVOcGJnUHIxVVFwTlJxQUFVR3JNU3g0TXhQZ3dGc0ZMYkpNaUdnWG56dWM5UHFEc2lsenVodnpxK0VmNzdsdjFzZzRKcGx1NWhkdCtvR3FwNGQ1QUlWbDFDRTRBaVc3bFZZZGFGS2dpTml6US9TNGdMeGJaUW5vZ2lHUGdLUHJBSTZoeTVibFNvVWRxV0VOcnhqYUxnbEF3b2ttaStBNERLemJhY1ZKdVh1SmFlcEhSZFpJQWhuWXZMMzMiLCJBdXRoSW5mbyI6IntcIkNJXCI6XCJENytSWlo1ek9xYUczMUZxczFjZVpjaVVVWXdhZWZMWHBsQ3dPYTY1b2xxRlVCTkVCQkpHQnJqKzJvQVNraHhXZFk5RlQ3UGF1S3RiUjIxZ3Z5dFFOd2lpdm1Vdlowbzl0K3ZoZHA5dmVTTT1cIixcIkNhbGxlclwiOlwiK3dSWk1ObW55NEhZR205ZTNqNVp5c2F0enZPRU10aGRadWx2czZKd3Nzdz1cIixcIkV4cGlyZVRpbWVcIjpcIjIwMjMtMDctMDdUMDQ6NTU6MjNaXCIsXCJNZWRpYUlkXCI6XCI1MWI0ZDdhMGFkYjc3MWVkYmZiNzQ0MjM4MGVhMDEwMlwiLFwiUGxheURvbWFpblwiOlwidm9kLmh5cHBlLmNsb3VkXCIsXCJTaWduYXR1cmVcIjpcInRvdEhOY1VqUTF5eHVtakVsZEZXbkJ1VUxoaz1cIn0iLCJWaWRlb01ldGEiOnsiU3RhdHVzIjoiTm9ybWFsIiwiVmlkZW9JZCI6IjUxYjRkN2EwYWRiNzcxZWRiZmI3NDQyMzgwZWEwMTAyIiwiVGl0bGUiOiJlZDcyNDk5NC02Y2EzLTM0NGYtYmFlZi02N2Q4NTY1ZDNmMzQiLCJDb3ZlclVSTCI6Imh0dHBzOi8vdm9kLmh5cHBlLmNsb3VkLzUxYjRkN2EwYWRiNzcxZWRiZmI3NDQyMzgwZWEwMTAyL3NuYXBzaG90cy83ZGI1YWQxMWQ5ZGI0MjEwYmJjZGZiODBhZGU0ZDIwYy0wMDAwMi5qcGciLCJEdXJhdGlvbiI6MjUuNDAzfSwiQWNjZXNzS2V5SWQiOiJTVFMuTlVuaHREc3MyMXR6bWFnN2pQeml3QnlvUCIsIlBsYXlEb21haW4iOiJ2b2QuaHlwcGUuY2xvdWQiLCJBY2Nlc3NLZXlTZWNyZXQiOiI5R0xuV1BaZG50YTVOeDV1aTNaTGJkdVlpdDNkVUt3ckEyQUR4ZEFmaXMxWiIsIlJlZ2lvbiI6ImFwLXNvdXRoZWFzdC01IiwiQ3VzdG9tZXJJZCI6NTQ1NDc1MzIwNTI4MDU0OX0=",
    //       // definitionList: _dataSourceMap[DataSourceRelated.DEFINITION_LIST],
    //       playConfig: value);
    // });
  }

  // _generatePlayConfigGen() {
  //   FlutterAliplayer.createVidPlayerConfigGenerator();
  //   FlutterAliplayer.setPreviewTime(0);
  // }

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
  //     _pauseScreen();
  //     System().adsPopUp(context, adsNotifier.adsData?.data ?? AdsData(), adsNotifier.adsData?.data?.apsaraAuth ?? '', isInAppAds: false).whenComplete(() {
  //       fAliplayer?.play();
  //       print("===========dari ads");
  //       _initializeTimer();
  //       print("===========dari ads");
  //     });
  //   }
  // }

  _pauseScreen() async {
    (Routing.navigatorKey.currentContext ?? context).read<HomeNotifier>().removeWakelock();
  }

  void _initializeTimer() async {
    (Routing.navigatorKey.currentContext ?? context).read<HomeNotifier>().initWakelockTimer(onShowInactivityWarning: _handleInactivity);
  }

  void _handleInactivity() {
    if (isHomeScreen) {
      if (mounted) {
        (Routing.navigatorKey.currentContext ?? context).read<PreviewVidNotifier>().canPlayOpenApps = false;

        (Routing.navigatorKey.currentContext ?? context).read<MainNotifier>().isInactiveState = true;
        (Routing.navigatorKey.currentContext ?? context).read<PreviewVidNotifier>().canPlayOpenApps = false;
        fAliplayer?.pause();
        _pauseScreen();
        ShowBottomSheet().onShowColouredSheet(
          (Routing.navigatorKey.currentContext ?? context),
          (Routing.navigatorKey.currentContext ?? context).read<TranslateNotifierV2>().translate.warningInavtivityDiary,
          maxLines: 2,
          color: kHyppeLightBackground,
          textColor: kHyppeTextLightPrimary,
          textButtonColor: kHyppePrimary,
          iconSvg: 'close.svg',
          textButton: (Routing.navigatorKey.currentContext ?? context).read<TranslateNotifierV2>().translate.stringContinue ?? '',
          onClose: () {
            (Routing.navigatorKey.currentContext ?? context).read<MainNotifier>().isInactiveState = false;
            fAliplayer?.play();
            print("===========dari close");
            _initializeTimer();
            context.read<PreviewVidNotifier>().canPlayOpenApps = true;
          },
        );
      }
    }
  }

  @override
  void didChangeDependencies() {
    CustomRouteObserver.routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    if (Platform.isIOS) {
      FlutterAliplayer.enableMix(false);
      // FlutterAliplayer.setAudioSessionTypeForIOS(AliPlayerAudioSesstionType.none);
    }
    fAliplayer?.stop();
    fAliplayer?.destroy();
    _pauseScreen();
    // if (context.read<PreviewVidNotifier>().canPlayOpenApps) {
    //   fAliplayer?.destroy();
    // }
    animatedController.dispose();
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void deactivate() {
    print("=============== deactivate dari diary");
    _pauseScreen();
    super.deactivate();
  }

  @override
  void didPop() {
    print("================ didpop dari diary");
    super.didPop();
  }

  @override
  void didPopNext() {
    isHomeScreen = true;
    fAliplayer?.play();
    _initializeTimer();
    // System().disposeBlock();

    super.didPopNext();
  }

  @override
  void didPushNext() {
    isHomeScreen = false;
    fAliplayer?.pause();
    _pauseScreen();
    super.didPushNext();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.inactive:
        fAliplayer?.pause();
        _pauseScreen();
        break;
      case AppLifecycleState.resumed:
        if (isHomeScreen) _initializeTimer();
        if (context.read<PreviewVidNotifier>().canPlayOpenApps && !context.read<MainNotifier>().isInactiveState) {
          fAliplayer?.play();
        }
        break;
      case AppLifecycleState.paused:
        fAliplayer?.pause();
        _pauseScreen();
        break;
      case AppLifecycleState.detached:
        fAliplayer?.pause();
        _pauseScreen();
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
  }

  void pause() {
    print('pause pause');
    setState(() {
      isPause = true;
    });

    fAliplayer?.pause();
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
      child: Consumer2<PreviewDiaryNotifier, HomeNotifier>(builder: (_, notifier, home, __) {
        return PageView.builder(
          controller: _pageController,
          scrollDirection: Axis.vertical,
          // controller: notifier.scrollController,
          // scrollDirection: Axis.horizontal,
          itemCount: notifier.diaryData?.length,
          onPageChanged: (index) async {
            _curIdx = index;
            if (_lastCurIndex != _curIdx) {
              if (!isShowingDialog) {
                globalAdsPopUp?.pause();
              }
              context.read<VideoNotifier>().currentPostID = notifier.diaryData?[index].postID ?? '';
              _curIdx = index;
              _lastCurPostId = _curPostId;

              _curPostId = notifier.diaryData?[index].postID ?? index.toString();
              // if (_lastCurIndex != _curIdx) {
              final indexList = notifier.diaryData?.indexWhere((element) => element.postID == _curPostId);
              // final latIndexList = notifier.diaryData?.indexWhere((element) => element.postID == _lastCurPostId);

              // fAliplayer?.destroy();
              fAliplayer?.stop();
              fAliplayer?.clearScreen();
              // Wakelock.disable();
              // initAlipayer();

              if (mounted) {
                setState(() {
                  Future.delayed(Duration(milliseconds: 400), () {
                    itemHeight = notifier.diaryData?[indexList ?? 0].height ?? 0;
                  });
                });
              }
              // final totalWithAds = notifier.diaryData?.where((element) => element.inBetweenAds != null).length;

              Future.delayed(const Duration(milliseconds: 700), () {
                start(Routing.navigatorKey.currentContext ?? context, notifier.diaryData?[index] ?? ContentData());
                System().increaseViewCount2(Routing.navigatorKey.currentContext ?? context, notifier.diaryData?[index] ?? ContentData(), check: false);
              });
              if (notifier.diaryData?[index].certified ?? false) {
                System().block(Routing.navigatorKey.currentContext ?? context);
              } else {
                System().disposeBlock();
              }

              if (indexList == (notifier.diaryData?.length ?? 0) - 1) {
                Future.delayed(const Duration(milliseconds: 1000), () async {
                  await context.read<HomeNotifier>().initNewHome(context, mounted, isreload: false, isgetMore: true).then((value) {
                    // notifier.getTemp(indexList, latIndexList, indexList);
                  });
                });
              } else {
                Future.delayed(const Duration(milliseconds: 2000), () {
                  // notifier.getTemp(indexList, latIndexList, indexList);
                });
              }

              ///ADS IN BETWEEN === Hariyanto Lukman ===
              if (!notifier.loadAds) {
                if ((notifier.diaryData?.length ?? 0) > notifier.nextAdsShowed) {
                  notifier.loadAds = true;
                  context.getInBetweenAds().then((value) {
                    if (value != null) {
                      notifier.setAdsData(index, value);
                    } else {
                      notifier.loadAds = false;
                    }
                  });
                }
              }
              // _lastCurIndex = _curIdx;
            }

            _lastCurIndex = _curIdx;
          },
          itemBuilder: (context, index) {
            if (notifier.diaryData == null || home.isLoadingDiary) {
              fAliplayer?.pause();
              // _lastCurIndex = -1;
              _lastCurPostId = '';
              return CustomShimmer(
                width: (MediaQuery.of(context).size.width - 11.5 - 11.5 - 9) / 2,
                height: 168,
                radius: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 10),
                padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
              );
            } else if (index == notifier.diaryData?.length && notifier.hasNext) {
              return UnconstrainedBox(
                child: Container(
                  alignment: Alignment.center,
                  width: 80 * SizeConfig.scaleDiagonal,
                  height: 80 * SizeConfig.scaleDiagonal,
                  child: const CustomLoading(),
                ),
              );
            }
            // if (_curIdx == 0 && notifier.diaryData?[0].reportedStatus == 'BLURRED') {
            if (notifier.diaryData?[0].reportedStatus == 'BLURRED') {
              isPlay = false;
              fAliplayer?.stop();
            }

            return itemDiary(context, notifier, index, home);
          },
        );
      }),
    );
  }

  Widget itemDiary(BuildContext context, PreviewDiaryNotifier notifier, int index, HomeNotifier homeNotifier) {
    var data = notifier.diaryData?[index];
    final isAds = data?.inBetweenAds != null && data?.postID == null;
    return data?.isContentLoading ?? false
        ? Builder(builder: (context) {
            Future.delayed(const Duration(seconds: 1), () {
              setState(() {
                data?.isContentLoading = false;
              });
            });
            return Container();
          })
        : WidgetSize(
            onChange: (Size size) {
              if (mounted) {
                setState(() {
                  data?.height = size.height;
                });
              }
            },
            child: Stack(
              children: [
                /// ADS IN BETWEEN === Hariyanto Lukman ===
                isAds
                    ? VisibilityDetector(
                        key: Key(data?.inBetweenAds?.adsId ?? index.toString()),
                        onVisibilityChanged: (info) {
                          if (info.visibleFraction >= 0.8) {
                            if (!isShowingDialog) {
                              globalAdsPopUp?.pause();
                            }
                            context.read<VideoNotifier>().currentPostID = data?.inBetweenAds?.adsId ?? '';
                            _curIdx = index;

                            _curPostId = data?.inBetweenAds?.adsId ?? index.toString();
                            // if (_lastCurIndex != _curIdx) {
                            final indexList = notifier.diaryData?.indexWhere((element) => element.inBetweenAds?.adsId == _curPostId);
                            // final latIndexList = notifier.diaryData?.indexWhere((element) => element.inBetweenAds?.adsId == _lastCurPostId);
                            if (_lastCurPostId != _curPostId) {
                              // fAliplayer?.destroy();
                              fAliplayer?.stop();
                              fAliplayer?.clearScreen();
                              // Wakelock.disable();
                              // initAlipayer();

                              if (mounted) {
                                setState(() {
                                  Future.delayed(Duration(milliseconds: 400), () {
                                    itemHeight = notifier.diaryData?[indexList ?? 0].height ?? 0;
                                  });
                                });
                              }

                              if (indexList == (notifier.diaryData?.length ?? 0) - 1) {
                                Future.delayed(const Duration(milliseconds: 1000), () async {
                                  await context.read<HomeNotifier>().initNewHome(context, mounted, isreload: false, isgetMore: true).then((value) {
                                    // notifier.getTemp(indexList, latIndexList, indexList);
                                  });
                                });
                              } else {
                                Future.delayed(const Duration(milliseconds: 2000), () {
                                  // notifier.getTemp(indexList, latIndexList, indexList);
                                });
                              }
                            }

                            // _lastCurIndex = _curIdx;
                            _lastCurPostId = _curPostId;
                          }
                        },
                        child: context.getAdsInBetween(notifier.diaryData?[index].inBetweenAds, (info) {}, () {
                          // final hasNotAds = (notifier.diaryData?.where((element) => element.inBetweenAds != null).length ?? 0) == 0;
                          // if(hasNotAds){
                          //
                          // }
                          notifier.setAdsData(index, null);
                        }, (player, id) {}),
                      )
                    : Stack(
                        children: [
                          Stack(
                            children: [
                              // _curIdx == index'
                              _curPostId == (data?.postID ?? index.toString())
                                  ? AliPlayerView(
                                      onCreated: onViewPlayerCreated,
                                      x: 0,
                                      y: 0,
                                      height: MediaQuery.of(context).size.width * 9.0 / 16.0,
                                      width: MediaQuery.of(context).size.width,
                                      aliPlayerViewType: AliPlayerViewTypeForAndroid.surfaceview,
                                    )
                                  : Container(),
                              _curPostId == (data?.postID ?? index.toString())
                                  ? Visibility(
                                      visible: isPlay,
                                      child: StickerOverlay(
                                        fullscreen: true,
                                        stickers: data?.stickers,
                                        width: MediaQuery.of(context).size.width,
                                        height: (MediaQuery.of(context).size.width) * (16 / 9),
                                        isPause: isPause || _showLoading,
                                        canPause: true,
                                      ),
                                    )
                                  : Container(),
                              // _buildProgressBar(SizeConfig.screenWidth!, 500),
                              !notifier.connectionError
                                  ? Positioned.fill(
                                      child: GestureDetector(
                                        onTap: () {
                                          context.read<PreviewDiaryNotifier>().navigateToShortVideoPlayer(context, index);
                                          fAliplayer?.play();
                                          if (mounted) {
                                            setState(() {
                                              isMute = !isMute;
                                            });
                                          }
                                          fAliplayer?.setMuted(isMute);
                                        },
                                        onDoubleTap: () {
                                          final _likeNotifier = context.read<LikeNotifier>();
                                          if (data != null) {
                                            _likeNotifier.likePost(context, data);
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
                                          homeNotifier.checkConnection();
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(color: kHyppeNotConnect, borderRadius: BorderRadius.circular(16)),
                                          width: SizeConfig.screenWidth,
                                          height: SizeConfig.screenHeight,
                                          alignment: Alignment.center,
                                          padding: EdgeInsets.all(20),
                                          child: data?.reportedStatus == 'BLURRED'
                                              ? Container()
                                              : CustomTextWidget(
                                                  textToDisplay: lang?.couldntLoadVideo ?? 'Error',
                                                  maxLines: 3,
                                                ),
                                        ),
                                      ),
                                    ),
                              dataSelected?.postID == data?.postID && isPlay
                                  ? Container()
                                  : CustomBaseCacheImage(
                                      memCacheWidth: 100,
                                      memCacheHeight: 100,
                                      widthPlaceHolder: 80,
                                      heightPlaceHolder: 80,
                                      placeHolderWidget: Container(),
                                      imageUrl: (data?.isApsara ?? false) ? (data?.mediaThumbEndPoint ?? "") : data?.fullThumbPath ?? '',
                                      imageBuilder: (context, imageProvider) => data?.reportedStatus == 'BLURRED'
                                          ? ClipRRect(
                                              borderRadius: BorderRadius.circular(20), // Image border
                                              child: ImageFiltered(
                                                imageFilter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                                                child: Image(
                                                  // width: SizeConfig.screenWidth,
                                                  // height: MediaQuery.of(context).size.width * 16.0 / 11.0,
                                                  image: imageProvider,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            )
                                          : Container(
                                              // const EdgeInsets.symmetric(horizontal: 4.5),
                                              // width: SizeConfig.screenWidth,
                                              // height: MediaQuery.of(context).size.width * 16.0 / 11.0,
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                  image: imageProvider,
                                                  fit: BoxFit.cover,
                                                ),
                                                borderRadius: BorderRadius.circular(16.0),
                                              ),
                                            ),
                                      errorWidget: (context, url, error) {
                                        return GestureDetector(
                                          onTap: () {
                                            homeNotifier.checkConnection();
                                          },
                                          child: Container(
                                              decoration: BoxDecoration(color: kHyppeNotConnect, borderRadius: BorderRadius.circular(16)),
                                              width: SizeConfig.screenWidth,
                                              height: MediaQuery.of(context).size.width * 16.0 / 9.0,
                                              alignment: Alignment.center,
                                              padding: EdgeInsets.all(20),
                                              child: CustomTextWidget(
                                                textToDisplay: lang?.couldntLoadVideo ?? 'Error',
                                                maxLines: 3,
                                              )),
                                        );
                                      },
                                      emptyWidget: GestureDetector(
                                        onTap: () {
                                          homeNotifier.checkConnection();
                                        },
                                        child: Container(
                                            decoration: BoxDecoration(color: kHyppeNotConnect, borderRadius: BorderRadius.circular(16)),
                                            width: SizeConfig.screenWidth,
                                            height: MediaQuery.of(context).size.width * 16.0 / 9.0,
                                            alignment: Alignment.center,
                                            padding: EdgeInsets.all(20),
                                            child: CustomTextWidget(
                                              textToDisplay: lang?.couldntLoadVideo ?? 'Error',
                                              maxLines: 3,
                                            )),
                                      ),
                                    ),
                              _showLoading && !homeNotifier.connectionError
                                  ? const Positioned.fill(
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: CircularProgressIndicator(),
                                      ),
                                    )
                                  : const SizedBox.shrink(),

                              blurContentWidget(context, data ?? ContentData()),
                            ],
                          ),
                        ],
                      ),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  // padding: EdgeInsets.only(bottom: 25.0),
                  child: _buildFillDiary(data),
                ),
              ],
            ),
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
                        print('DiaryPlayer pause');
                      } else {
                        pause();
                        print('DiaryPlayer play');
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
                ? DiarySensitive(
                    data: data,
                    function: () {
                      changeStatusBlur(data);
                    },
                  )
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
                        onPressed: () => context.read<DiariesPlaylistNotifier>().onWillPop(mounted),
                        child: const DecoratedIconWidget(
                          Icons.close_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                : TitlePlaylistDiaries(
                    data: data,
                    // storyController: _storyController,
                  ),

            // Text(_listData![_curIdx].username!),
            data?.reportedStatus == "BLURRED"
                ? Container()
                : RightItems(
                    data: data ?? ContentData(),
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
                      Spacer(),
                      const CustomIconWidget(
                        iconData: "${AssetPath.vectorPath}eye-off.svg",
                        defaultColor: false,
                        height: 30,
                      ),
                      Text(transnot.translate.sensitiveContent ?? 'Sensitive Content', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                      Text("HyppeDiary ${transnot.translate.contentContainsSensitiveMaterial}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          )),
                      // data.email == SharedPreference().readStorage(SpKeys.email)
                      //     ? GestureDetector(
                      //         onTap: () => Routing().move(Routes.appeal, argument: data),
                      //         child: Container(
                      //             padding: const EdgeInsets.all(8),
                      //             margin: const EdgeInsets.all(18),
                      //             decoration: BoxDecoration(border: Border.all(color: Colors.white), borderRadius: BorderRadius.circular(10)),
                      //             child: Text(transnot.translate.appealThisWarning ?? 'Appeal This Warning', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600))),
                      //       )
                      //     : const SizedBox(),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          data.reportedStatus = '';
                          start(context, data);
                          context.read<ReportNotifier>().seeContent(context, data, hyppeDiary);
                          fAliplayer?.prepare();
                          fAliplayer?.play();
                        },
                        child: Container(
                          padding: const EdgeInsets.only(top: 8),
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

class WidgetSize extends StatefulWidget {
  final Widget child;
  final Function onChange;

  const WidgetSize({
    Key? key,
    required this.onChange,
    required this.child,
  }) : super(key: key);

  @override
  State<WidgetSize> createState() => _WidgetSizeState();
}

class _WidgetSizeState extends State<WidgetSize> {
  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback(postFrameCallback);
    return Container(
      key: widgetKey,
      child: widget.child,
    );
  }

  var widgetKey = GlobalKey();
  var oldSize;

  void postFrameCallback(_) {
    var context = widgetKey.currentContext;
    if (context == null) return;

    var newSize = context.size;
    if (oldSize == newSize) return;

    oldSize = newSize;
    widget.onChange(newSize);
  }
}
