import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_aliplayer/flutter_aliplayer.dart';
import 'package:flutter_aliplayer/flutter_aliplayer_factory.dart';
import 'package:hyppe/core/arguments/contents/slided_diary_detail_screen_argument.dart';
import 'package:hyppe/core/bloc/posts_v2/bloc.dart';
import 'package:hyppe/core/bloc/posts_v2/state.dart';
import 'package:hyppe/core/config/ali_config.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/kyc_status.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/constants/utils.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/advertising/ads_video_data.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/services/route_observer_service.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/entities/like/notifier.dart';
import 'package:hyppe/ui/constant/entities/report/notifier.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/show_general_dialog.dart';
import 'package:hyppe/ui/constant/widget/button_boost.dart';
import 'package:hyppe/ui/constant/widget/custom_base_cache_image.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_newdesc_content_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/no_result_found.dart';
import 'package:hyppe/ui/constant/widget/profile_landingpage.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/playlist/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/playlist/widget/content_violation.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/preview/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/scroll/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/playlist/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/widget/pic_top_item.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/playlist/comments_detail/screen.dart';
import 'package:hyppe/ui/inner/home/notifier_v2.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/services/error_service.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_shimmer.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/notifier.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ScrollDiary extends StatefulWidget {
  final SlidedDiaryDetailScreenArgument? arguments;
  const ScrollDiary({
    Key? key,
    this.arguments,
  }) : super(key: key);

  @override
  _ScrollDiaryState createState() => _ScrollDiaryState();
}

class _ScrollDiaryState extends State<ScrollDiary> with WidgetsBindingObserver, TickerProviderStateMixin, WidgetsBindingObserver, RouteAware {
  List<ContentData>? diaryData = [];
  FlutterAliplayer? fAliplayer;
  bool isPrepare = false;
  bool isPlay = false;
  bool isPause = false;
  bool _showLoading = false;
  bool _inSeek = false;
  bool isloading = false;
  bool isMute = false;
  bool toComment = false;

  int _loadingPercent = 0;
  int _currentPlayerState = 0;
  int _videoDuration = 1;
  int _currentPosition = 0;
  int _bufferPosition = 0;
  int _currentPositionText = 0;
  int _curIdx = 0;
  int _lastCurIndex = -1;

  String auth = '';
  String url = '';
  final Map _dataSourceMap = {};
  ModeTypeAliPLayer? _playMode = ModeTypeAliPLayer.auth;
  LocalizationModelV2? lang;
  ContentData? dataSelected;
  String email = '';
  String statusKyc = '';

  final ItemScrollController itemScrollController = ItemScrollController();
  final ScrollOffsetController scrollOffsetController = ScrollOffsetController();

  /// Listener that reports the position of items when the list is scrolled.
  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();
  final ScrollController _scrollController = ScrollController();

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
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      fAliplayer = FlutterAliPlayerFactory.createAliPlayer();
      WidgetsBinding.instance.addObserver(this);
      fAliplayer?.pause();
      fAliplayer?.setAutoPlay(true);
      fAliplayer?.setLoop(true);

      //Turn on mix mode
      if (Platform.isIOS) {
        FlutterAliplayer.enableMix(true);
        // FlutterAliplayer.setAudioSessionTypeForIOS(AliPlayerAudioSesstionType.mix);
      }

      notifier.checkConnection();

      //set player
      fAliplayer?.setPreferPlayerName(GlobalSettings.mPlayerName);
      fAliplayer?.setEnableHardwareDecoder(GlobalSettings.mEnableHardwareDecoder);
      vidConfig();
      itemScrollController.jumpTo(index: widget.arguments!.page!);
      _initListener();
    });
    var index = 0;
    var lastIndex = 0;
    itemPositionsListener.itemPositions.addListener(() async {
      index = itemPositionsListener.itemPositions.value.first.index;
      if (lastIndex != index) {
        if (index == diaryData!.length - 2) {
          bool connect = await System().checkConnections();
          if (connect) {
            print("ini reload harusnya");
            if (!notifier.isLoadingLoadmore) {
              await notifier.loadMore(context, _scrollController, widget.arguments!.pageSrc!, widget.arguments?.key ?? '');
              setState(() {
                diaryData = notifier.diaryData;
              });
            }
          } else {
            if (mounted) {
              ShowGeneralDialog.showToastAlert(
                context,
                lang?.internetConnectionLost ?? ' Error',
                () async {},
              );
            }
          }
        }
        lastIndex = index;
      }
    });
    checkInet();

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
        });
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
      _currentPlayerState = newState;
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
      _inSeek = false;
    });
    fAliplayer?.setOnInfo((infoCode, extraValue, extraMsg, playerId) {
      if (infoCode == FlutterAvpdef.CURRENTPOSITION) {
        if (_videoDuration != 0 && (extraValue ?? 0) <= _videoDuration) {
          _currentPosition = extraValue ?? 0;
        }
        // if (!_inSeek) {
        //   setState(() {
        //     _currentPositionText = extraValue ?? 0;
        //   });
        // }
      } else if (infoCode == FlutterAvpdef.BUFFEREDPOSITION) {
        _bufferPosition = extraValue ?? 0;
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

      setState(() {
        _currentPosition = _videoDuration;
      });
    });

    fAliplayer?.setOnSnapShot((path, playerId) {
      print("aliyun : snapShotPath = $path");
      // Fluttertoast.showToast(msg: "SnapShot Save : $path");
    });
    fAliplayer?.setOnError((errorCode, errorExtra, errorMsg, playerId) {
      print("=======error =========");
      print(errorCode);
      print(errorExtra);
      print(playerId);
      _showLoading = false;

      setState(() {});
    });

    fAliplayer?.setOnTrackChanged((value, playerId) {
      AVPTrackInfo info = AVPTrackInfo.fromJson(value);
      if (info != null && (info.trackDefinition?.length ?? 0) > 0) {
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
    if (data.reportedStatus != 'BLURRED') {
      if (data.isApsara ?? false) {
        _playMode = ModeTypeAliPLayer.auth;
        await getAuth(data.apsaraId ?? '', data).then((value) {
          print("=============setelah auth======");
          print(value);
        });
      } else {
        _playMode = ModeTypeAliPLayer.url;
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

  _initAds(BuildContext context) async {
    //for ads
    // getCountVid();
    // await _newInitAds(true);
    context.incrementAdsCount();
    if (context.getAdsCount() == null) {
      context.setAdsCount(0);
    } else {
      final adsNotifier = context.read<PreviewDiaryNotifier>();
      if (context.getAdsCount() == 2) {
        try {
          context.read<PreviewDiaryNotifier>().getAdsVideo(context, false);
        } catch (e) {
          'Failed to fetch ads data 0 : $e'.logger();
        }
      }
      if (context.getAdsCount() == 3 && adsNotifier.adsData != null) {
        fAliplayer?.pause();
        System().adsPopUp(context, adsNotifier.adsData?.data ?? AdsData(), adsNotifier.adsData?.data?.apsaraAuth ?? '', isInAppAds: false).whenComplete(() {
          fAliplayer?.play();
        });
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
    // if (context.read<PreviewVidNotifier>().canPlayOpenApps) {
    //   fAliplayer?.destroy();
    // }
    fAliplayer?.destroy();
    print("========--------dispose----=========");
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void deactivate() {
    print("====== deactivate dari diary");

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
    }
  }

  int _currentItem = 0;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final error = context.select((ErrorService value) => value.getError(ErrorType.pic));
    // AliPlayerView aliPlayerView = AliPlayerView(onCreated: onViewPlayerCreated, x: 0.0, y: 0.0, width: 100, height: 200);
    return ShowCaseWidget(
      onStart: (index, key) {
        print('onStart: $index, $key');
      },
      onComplete: (index, key) {
        print('onComplete: $index, $key');
      },
      blurValue: 0,
      disableBarrierInteraction: true,
      disableMovingAnimation: true,
      builder: Builder(builder: (context) {
        return Scaffold(
          backgroundColor: kHyppeLightSurface,
          body: WillPopScope(
            onWillPop: () async {
              Navigator.pop(context, '$_curIdx');
              return false;
            },
            child: Consumer2<ScrollDiaryNotifier, HomeNotifier>(builder: (_, notifier, home, __) {
              return SafeArea(
                child: SizedBox(
                  // margin: const EdgeInsets.only(top: 16.0, bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: Align(
                          alignment: const Alignment(-1.2, 0),
                          child: Container(margin: const EdgeInsets.symmetric(horizontal: 10), child: widget.arguments?.titleAppbar ?? Container()),
                        ),
                        leading: IconButton(
                            icon: const Icon(
                              Icons.chevron_left,
                              color: kHyppeTextLightPrimary,
                            ),
                            onPressed: () {
                              Navigator.pop(context, '$_curIdx');
                            }),
                      ),
                      Expanded(
                        child: diaryData?.isEmpty ?? [].isEmpty
                            ? const NoResultFound()
                            : RefreshIndicator(
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
                                child: NotificationListener<OverscrollIndicatorNotification>(
                                  onNotification: (overscroll) {
                                    overscroll.disallowIndicator();
                                    return false;
                                  },
                                  child: RefreshIndicator(
                                    onRefresh: () async {},
                                    child: ScrollablePositionedList.builder(
                                      scrollDirection: Axis.vertical,
                                      itemScrollController: itemScrollController,
                                      itemPositionsListener: itemPositionsListener,
                                      scrollOffsetController: scrollOffsetController,
                                      // controller: notifier.scrollController,
                                      // scrollDirection: Axis.horizontal,
                                      physics: const AlwaysScrollableScrollPhysics(),
                                      shrinkWrap: false,
                                      itemCount: diaryData?.length ?? 0,
                                      padding: const EdgeInsets.symmetric(horizontal: 11.5),
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
                                  ),
                                ),
                              ),
                      ),
                      notifier.isLoadingLoadmore
                          ? const SizedBox(
                              height: 50,
                              child: Center(child: CustomLoading()),
                            )
                          : Container(),
                    ],
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }

  Widget itemDiary(ScrollDiaryNotifier notifier, int index) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
      ),
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 16),
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SelectableText("isApsara : ${diaryData?[index].isApsara}"),
          // SelectableText("post id : ${diaryData?[index].postID})"),
          // sixteenPx,
          // SelectableText((diaryData?[index].isApsara ?? false) ? (diaryData?[index].mediaThumbEndPoint ?? "") : "${diaryData?[index].fullThumbPath}"),
          // sixteenPx,
          // SelectableText((diaryData?[index].isApsara ?? false) ? (diaryData?[index].apsaraId ?? "") : "${UrlConstants.oldVideo + diaryData![index].postID!}"),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: ProfileLandingPage(
                  show: true,
                  // cacheKey: vidData?.email == email ? homeNotifier.profileImageKey : null,
                  onFollow: () {},
                  following: true,
                  haveStory: false,
                  textColor: kHyppeTextLightPrimary,
                  username: diaryData?[index].username,
                  featureType: FeatureType.other,
                  // isCelebrity: viddiaryData?[index].privacy?.isCelebrity,
                  isCelebrity: false,
                  imageUrl: '${System().showUserPicture(diaryData?[index].avatar?.mediaEndpoint)}',
                  onTapOnProfileImage: () => System().navigateToProfile(context, diaryData?[index].email ?? ''),
                  createdAt: '2022-02-02',
                  musicName: diaryData?[index].music?.musicTitle ?? '',
                  location: diaryData?[index].location ?? '',
                  isIdVerified: diaryData?[index].privacy?.isIdVerified,
                  badge: diaryData?[index].urluserBadge,
                ),
              ),
              if (diaryData?[index].email != email && (diaryData?[index].isNewFollowing ?? false))
                Consumer<PreviewPicNotifier>(
                  builder: (context, picNot, child) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        if (diaryData?[index].insight?.isloadingFollow != true) {
                          picNot.followUser(context, diaryData?[index] ?? ContentData(), isUnFollow: diaryData?[index].following, isloading: diaryData?[index].insight!.isloadingFollow ?? false);
                        }
                      },
                      child: diaryData?[index].insight?.isloadingFollow ?? false
                          ? Container(
                              height: 40,
                              width: 30,
                              child: Align(
                                alignment: Alignment.bottomRight,
                                child: CustomLoading(),
                              ),
                            )
                          : Text(
                              (diaryData?[index].following ?? false) ? (lang?.following ?? '') : (lang?.follow ?? ''),
                              style: TextStyle(color: kHyppePrimary, fontSize: 12, fontWeight: FontWeight.w700, fontFamily: "Lato"),
                            ),
                    ),
                  ),
                ),
              GestureDetector(
                onTap: () {
                  if (diaryData?[index].email != email) {
                    // FlutterAliplayer? fAliplayer
                    context.read<PreviewPicNotifier>().reportContent(context, diaryData?[index] ?? ContentData(), fAliplayer: fAliplayer, onCompleted: () async {
                      bool connect = await System().checkConnections();
                      if (connect) {
                        setState(() {
                          isloading = true;
                        });
                        await notifier.reload(Routing.navigatorKey.currentContext ?? context, widget.arguments!.pageSrc!, key: widget.arguments?.key ?? '');
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
                    });
                  } else {
                    fAliplayer?.setMuted(true);
                    fAliplayer?.pause();
                    ShowBottomSheet().onShowOptionContent(
                      context,
                      contentData: diaryData?[index] ?? ContentData(),
                      captionTitle: hyppeDiary,
                      onDetail: false,
                      isShare: diaryData?[index].isShared,
                      onUpdate: () => context.read<HomeNotifier>().onUpdate(),
                      fAliplayer: fAliplayer,
                    );
                  }
                },
                child: const Icon(
                  Icons.more_vert,
                  color: kHyppeTextLightPrimary,
                ),
              ),
            ],
          ),
          tenPx,
          VisibilityDetector(
            key: Key(index.toString()),
            onVisibilityChanged: (info) {
              if (info.visibleFraction >= 0.6) {
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
                  if (diaryData?[index].certified ?? false) {
                    System().block(context);
                  } else {
                    System().disposeBlock();
                  }
                }
                _lastCurIndex = _curIdx;
              }
            },
            child: Container(
              margin: EdgeInsets.only(bottom: 20),
              // width: MediaQuery.of(context).size.width,
              // height: 500,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                // color: Colors.yellow,
              ),
              child: AspectRatio(
                aspectRatio: 9 / 16,
                child: Stack(
                  children: [
                    _curIdx == index
                        ? ClipRRect(
                            borderRadius: const BorderRadius.all(Radius.circular(16.0)),
                            child: Builder(builder: (context) {
                              // if (!isloading) {
                              //   return AliPlayerView(
                              //     onCreated: onViewPlayerCreated,
                              //     x: 0,
                              //     y: 0,
                              //     height: MediaQuery.of(context).size.width * 16.0 / 9.0,
                              //     width: MediaQuery.of(context).size.width,
                              //   );
                              // }
                              return AliPlayerView(
                                onCreated: onViewPlayerCreated,
                                x: 0,
                                y: 0,
                                height: MediaQuery.of(context).size.width * 16.0 / 9.0,
                                width: MediaQuery.of(context).size.width,
                              );
                            }),
                          )
                        : Container(),
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
                                imageUrl: (diaryData?[index].isApsara ?? false) ? (diaryData?[index].mediaThumbEndPoint ?? "") : "${diaryData?[index].fullThumbPath}",
                                imageBuilder: (context, imageProvider) => diaryData?[index].reportedStatus == 'BLURRED'
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(20), // Image border
                                        child: ImageFiltered(
                                          imageFilter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                                          child: Image(
                                            height: MediaQuery.of(context).size.width * 16.0 / 9.0,
                                            width: MediaQuery.of(context).size.width,
                                            image: imageProvider,
                                          ),
                                        ),
                                      )
                                    : Container(
                                        // const EdgeInsets.symmetric(horizontal: 4.5),
                                        height: MediaQuery.of(context).size.width * 16.0 / 9.0,
                                        width: MediaQuery.of(context).size.width,
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
                                      notifier.checkConnection();
                                    },
                                    child: Container(
                                        decoration: BoxDecoration(color: kHyppeNotConnect, borderRadius: BorderRadius.circular(16)),
                                        width: SizeConfig.screenWidth,
                                        height: MediaQuery.of(context).size.width * 16.0 / 9.0,
                                        alignment: Alignment.center,
                                        child: CustomTextWidget(textToDisplay: lang?.couldntLoadVideo ?? 'Error')),
                                  );
                                },
                                emptyWidget: GestureDetector(
                                  onTap: () {
                                    notifier.checkConnection();
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
                              )
                            : Container(),
                    _showLoading && !notifier.connectionError
                        ? Positioned.fill(
                            child: Align(
                            alignment: Alignment.center,
                            child: CircularProgressIndicator(),
                          ))
                        : Container(),
                    _buildBody(context, SizeConfig.screenWidth, diaryData?[index] ?? ContentData()),
                    blurContentWidget(context, diaryData?[index] ?? ContentData()),
                  ],
                ),
              ),
            ),
          ),
          SharedPreference().readStorage(SpKeys.statusVerificationId) == VERIFIED &&
                  (diaryData?[index].boosted.isEmpty ?? [].isEmpty) &&
                  (diaryData?[index].reportedStatus != 'OWNED' && diaryData?[index].reportedStatus != 'BLURRED' && diaryData?[index].reportedStatus2 != 'BLURRED') &&
                  diaryData?[index].email == email
              ? Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ButtonBoost(
                    onDetail: false,
                    marginBool: true,
                    contentData: diaryData?[index],
                    startState: () {
                      SharedPreference().writeStorage(SpKeys.isShowPopAds, true);
                    },
                    afterState: () {
                      SharedPreference().writeStorage(SpKeys.isShowPopAds, false);
                    },
                  ),
                )
              : Container(),
          diaryData?[index].email == SharedPreference().readStorage(SpKeys.email) && (diaryData?[index].reportedStatus == 'OWNED')
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 11.0),
                  child: ContentViolationWidget(
                    data: diaryData?[index] ?? ContentData(),
                    text: lang?.thisHyppeVidisSubjectToModeration ?? '',
                  ),
                )
              : Container(),
          if (diaryData?[index].email == email && (diaryData?[index].boostCount ?? 0) >= 0 && (diaryData?[index].boosted.isNotEmpty ?? [].isEmpty))
            Container(
              padding: const EdgeInsets.all(10),
              margin: EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: kHyppeGreyLight,
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
                    child: Text(
                      "${diaryData?[index].boostJangkauan ?? '0'} ${lang?.reach}",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kHyppeTextLightPrimary),
                    ),
                  )
                ],
              ),
            ),
          Consumer<LikeNotifier>(
            builder: (context, likeNotifier, child) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 30,
                      child: Consumer<LikeNotifier>(
                        builder: (context, likeNotifier, child) => Align(
                          alignment: Alignment.bottomRight,
                          child: diaryData?[index].insight?.isloading ?? false
                              ? const SizedBox(
                                  height: 28,
                                  width: 28,
                                  child: CircularProgressIndicator(
                                    color: kHyppePrimary,
                                    strokeWidth: 2,
                                  ),
                                )
                              : InkWell(
                                  child: CustomIconWidget(
                                    defaultColor: false,
                                    color: (diaryData?[index].insight?.isPostLiked ?? false) ? kHyppeRed : kHyppeTextLightPrimary,
                                    iconData: '${AssetPath.vectorPath}${(diaryData?[index].insight?.isPostLiked ?? false) ? 'liked.svg' : 'none-like.svg'}',
                                    height: 28,
                                  ),
                                  onTap: () {
                                    if (diaryData?[index] != null) {
                                      likeNotifier.likePost(context, diaryData![index]);
                                    }
                                  },
                                ),
                        ),
                      ),
                    ),
                    if (diaryData?[index].allowComments ?? false)
                      Padding(
                        padding: const EdgeInsets.only(left: 21.0),
                        child: GestureDetector(
                          onTap: () {
                            toComment = true;
                            Routing().move(Routes.commentsDetail,
                                argument: CommentsArgument(
                                  postID: diaryData?[index].postID ?? '',
                                  fromFront: true,
                                  data: diaryData?[index] ?? ContentData(),
                                  pageDetail: true,
                                ));
                          },
                          child: const CustomIconWidget(
                            defaultColor: false,
                            color: kHyppeTextLightPrimary,
                            iconData: '${AssetPath.vectorPath}comment2.svg',
                            height: 24,
                          ),
                        ),
                      ),
                    if ((diaryData?[index].isShared ?? false))
                      Padding(
                        padding: EdgeInsets.only(left: 21.0),
                        child: GestureDetector(
                          onTap: () {
                            context.read<DiariesPlaylistNotifier>().createdDynamicLink(context, data: diaryData?[index]);
                          },
                          child: CustomIconWidget(
                            defaultColor: false,
                            color: kHyppeTextLightPrimary,
                            iconData: '${AssetPath.vectorPath}share2.svg',
                            height: 24,
                          ),
                        ),
                      ),
                    if ((diaryData?[index].saleAmount ?? 0) > 0 && email != diaryData?[index].email)
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            fAliplayer?.pause();
                            await ShowBottomSheet.onBuyContent(context, data: diaryData?[index], fAliplayer: fAliplayer);
                            // fAliplayer?.play();
                          },
                          child: const Align(
                            alignment: Alignment.centerRight,
                            child: CustomIconWidget(
                              defaultColor: false,
                              color: kHyppeTextLightPrimary,
                              iconData: '${AssetPath.vectorPath}cart.svg',
                              height: 24,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                twelvePx,
                Text(
                  "${diaryData?[index].insight?.likes}  ${lang?.like}",
                  style: const TextStyle(color: kHyppeTextLightPrimary, fontWeight: FontWeight.w700, fontSize: 14),
                ),
              ],
            ),
          ),
          twelvePx,
          CustomNewDescContent(
            // desc: "${data?.description}",
            username: diaryData?[index].username ?? '',
            desc: "${diaryData?[index].description}",
            trimLines: 2,
            textAlign: TextAlign.start,
            seeLess: ' ${lang?.seeLess}', // ${notifier2.translate.seeLess}',
            seeMore: '  ${lang?.seeMoreContent}', //${notifier2.translate.seeMoreContent}',
            normStyle: const TextStyle(fontSize: 12, color: kHyppeTextLightPrimary),
            hrefStyle: Theme.of(context).textTheme.subtitle2?.copyWith(color: kHyppePrimary),
            expandStyle: Theme.of(context).textTheme.subtitle2?.copyWith(color: Theme.of(context).colorScheme.primary),
          ),
          GestureDetector(
            onTap: () {
              toComment = true;
              Routing().move(Routes.commentsDetail,
                  argument: CommentsArgument(
                    postID: diaryData?[index].postID ?? '',
                    fromFront: true,
                    data: diaryData?[index] ?? ContentData(),
                    pageDetail: true,
                  ));
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text(
                "${lang?.seeAll} ${diaryData?[index].comments} ${lang?.comment}",
                style: const TextStyle(fontSize: 12, color: kHyppeBurem),
              ),
            ),
          ),
          (diaryData?[index].comment?.length ?? 0) > 0
              ? Padding(
                  padding: const EdgeInsets.only(top: 0.0),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: (diaryData?[index].comment?.length ?? 0) >= 2 ? 2 : 1,
                    itemBuilder: (context, indexComment) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6.0),
                        child: CustomNewDescContent(
                          // desc: "${diaryData?[index]?.description}",
                          username: diaryData?[index].comment?[indexComment].userComment?.username ?? '',
                          desc: diaryData?[index].comment?[indexComment].txtMessages ?? '',
                          trimLines: 2,
                          textAlign: TextAlign.start,
                          seeLess: ' ${lang?.seeLess}', // ${notifier2.translate.seeLess}',
                          seeMore: ' ${lang?.seeMoreContent}', //${notifier2.translate.seeMoreContent}',
                          normStyle: const TextStyle(fontSize: 12, color: kHyppeTextLightPrimary),
                          hrefStyle: Theme.of(context).textTheme.subtitle2?.copyWith(color: kHyppePrimary),
                          expandStyle: Theme.of(context).textTheme.subtitle2?.copyWith(color: Theme.of(context).colorScheme.primary),
                        ),
                      );
                    },
                  ),
                )
              : Container(),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 4.0),
            child: Text(
              "${System().readTimestamp(
                DateTime.parse(System().dateTimeRemoveT(diaryData?[index].createdAt ?? DateTime.now().toString())).millisecondsSinceEpoch,
                context,
                fullCaption: true,
              )}",
              style: TextStyle(fontSize: 12, color: kHyppeBurem),
            ),
          ),
        ],
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
