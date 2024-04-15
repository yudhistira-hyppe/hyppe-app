import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_aliplayer/flutter_aliplayer.dart';
import 'package:flutter_aliplayer/flutter_aliplayer_factory.dart';
import 'package:hyppe/core/arguments/contents/slided_pic_detail_screen_argument.dart';
import 'package:hyppe/core/bloc/posts_v2/bloc.dart';
import 'package:hyppe/core/bloc/posts_v2/state.dart';
import 'package:hyppe/core/config/ali_config.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/kyc_status.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/constants/utils.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/services/audio_service.dart';
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
import 'package:hyppe/ui/inner/home/content_v2/diary/playlist/widget/content_violation.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/playlist/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/scroll/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/widget/pic_top_item.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/playlist/comments_detail/screen.dart';
import 'package:hyppe/ui/inner/home/notifier_v2.dart';
import 'package:hyppe/core/models/collection/utils/zoom_pic/zoom_pic.dart';
import 'package:hyppe/ui/inner/home/widget/view_like.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_shimmer.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/notifier.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:flutter/gestures.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ScrollPic extends StatefulWidget {
  final SlidedPicDetailScreenArgument? arguments;
  // final ScrollController? scrollController;
  // final Function functionZoomTriger;
  const ScrollPic({
    Key? key,
    this.arguments,
    // this.scrollController,
    // required this.functionZoomTriger,
  }) : super(key: key);

  @override
  _ScrollPicState createState() => _ScrollPicState();
}

class _ScrollPicState extends State<ScrollPic> with WidgetsBindingObserver, TickerProviderStateMixin, RouteAware {
  FlutterAliplayer? fAliplayer;
  List<ContentData>? pics = [];
  int pageIndex = 0;
  final scrollGlobal = GlobalKey<SelfProfileScreenState>();
  final a = SelfProfileScreenState();

  bool isZoom = false;
  bool isActivePage = true;
  bool isPrepare = false;
  bool isPlay = false;
  bool isPause = false;
  // bool _showLoading = false;
  // bool _inSeek = false;
  bool isloading = false;

  // int _loadingPercent = 0;
  // int _currentPlayerState = 0;
  int _videoDuration = 1;
  // int _currentPosition = 0;
  // int _bufferPosition = 0;
  // int _currentPositionText = 0;
  int _curIdx = 0;
  int _lastCurIndex = -1;
  int playIndex = -1;
  int scrollIndex = 0;

  String auth = '';
  String url = '';
  // final Map _dataSourceMap = {};
  // ModeTypeAliPLayer? _playMode = ModeTypeAliPLayer.auth;
  LocalizationModelV2? lang;
  ContentData? dataSelected;
  // bool isMute = false;
  String email = '';
  // String statusKyc = '';
  bool isInPage = true;
  // bool _scroolEnabled = true;
  bool toComment = false;

  final ScrollOffsetController scrollOffsetController = ScrollOffsetController();
  final ScrollOffsetListener scrollOffsetListener = ScrollOffsetListener.create();

  /// Listener that reports the position of items when the list is scrolled.
  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();
  final ScrollController _scrollController = ScrollController();

  PageSrc pageSrc = PageSrc.otherProfile;

  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'HyppePreviewPic');
    final notifier = Provider.of<ScrollPicNotifier>(context, listen: false);
    lang = context.read<TranslateNotifierV2>().translate;

    email = SharedPreference().readStorage(SpKeys.email);
    // statusKyc = SharedPreference().readStorage(SpKeys.statusVerificationId);
    // stopwatch = new Stopwatch()..start();
    super.initState();
    print("================profile");
    print("${widget.arguments?.picData}");
    pics = widget.arguments?.picData;
    pageIndex = widget.arguments!.page ?? 0;
    notifier.pics = widget.arguments?.picData;
    print("${pics}");

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      fAliplayer = FlutterAliPlayerFactory.createAliPlayer(playerId: 'aliPic-${pics?.first.postID}');
      WidgetsBinding.instance.addObserver(this);

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
      notifier.itemScrollController.jumpTo(index: widget.arguments?.page ?? 0);
      // scrollIndex = widget.arguments?.page ?? 0;
      // _initListener(notifier);
    });

    var index = 0;
    var lastIndex = 0;
    pageSrc = widget.arguments?.pageSrc ?? PageSrc.otherProfile;

    itemPositionsListener.itemPositions.addListener(() async {
      index = itemPositionsListener.itemPositions.value.first.index;

      if (lastIndex != index) {
        bool connect = await System().checkConnections();

        if (index == pics!.length - 2) {
          if (connect) {
            if (!notifier.isLoadingLoadmore) {
              await notifier.loadMore(context, _scrollController, pageSrc, widget.arguments?.key ?? '');
              if (mounted) {
                setState(() {
                  pics = notifier.pics;
                });
              } else {
                pics = notifier.pics;
              }
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
        // itemScrollController.scrollTo(
        //   index: itemPositionsListener.itemPositions.value.last.index,
        //   // alignment:
        //   duration: Duration(milliseconds: 300),
        // );
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

  _initListener(ScrollPicNotifier notifier) {
    fAliplayer?.setOnEventReportParams((params, playerId) {
      print("EventReportParams=${params}");
    });
    fAliplayer?.setOnPrepared((playerId) {
      // Fluttertoast.showToast(msg: "OnPrepared ");
      if (SharedPreference().readStorage(SpKeys.isShowPopAds)) {
        notifier.isMute = true;
        fAliplayer?.pause();
      }

      fAliplayer?.getPlayerName().then((value) => print("getPlayerName==${value}"));
      fAliplayer?.getMediaInfo().then((value) {
        setState(() {
          isPrepare = true;
        });
      });
      isPlay = true;
      dataSelected?.isDiaryPlay = true;
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
            // _showLoading = false;
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
        // _loadingPercent = 0;
        // _showLoading = true;
      });
    }, loadingProgress: (percent, netSpeed, playerId) {
      // _loadingPercent = percent;
      if (percent == 100) {
        // _showLoading = false;
      }
      setState(() {});
    }, loadingEnd: (playerId) {
      setState(() {
        // _showLoading = false;
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
        if (mounted) {
          setState(() {});
        }
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
      // _showLoading = false;

      isPause = true;

      setState(() {
        // _currentPosition = _videoDuration;
      });
    });

    fAliplayer?.setOnSnapShot((path, playerId) {
      print("aliyun : snapShotPath = $path");
      // Fluttertoast.showToast(msg: "SnapShot Save : $path");
    });
    fAliplayer?.setOnError((errorCode, errorExtra, errorMsg, playerId) {
      // _showLoading = false;
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

  void start(ContentData data, ScrollPicNotifier notifier) async {
    // if (notifier.listData != null && (notifier.listData?.length ?? 0) > 0 && _curIdx < (notifier.listData?.length ?? 0)) {

    fAliplayer?.stop();
    MyAudioService.instance.stop();
    dataSelected = data;

    isPlay = false;
    dataSelected?.isDiaryPlay = false;
    // fAliplayer?.setVidAuth(
    //   vid: "c1b24d30b2c671edbfcb542280e90102",
    //   region: DataSourceRelated.defaultRegion,
    //   playAuth:
    //       "eyJTZWN1cml0eVRva2VuIjoiQ0FJU2lBTjFxNkZ0NUIyeWZTaklyNURISnUvWnJvZFIrb1d2VlY2SmdHa0RPdFZjaDZMRG96ejJJSDFLZlhadEJPQWN0ZlF3bFdwVDdQNGJsckl1RjhJWkdoR2ZONU10dE1RUHJGL3dKb0hidk5ldTBic0hoWnY5bGNNTHJaaWpqcUhvZU96Y1lJNzMwWjdQQWdtMlEwWVJySkwrY1RLOUphYk1VL21nZ29KbWFkSTZSeFN4YVNFOGF2NWRPZ3BscnIwSVZ4elBNdnIvSFJQMnVtN1pIV3R1dEEwZTgzMTQ1ZmFRejlHaTZ4YlRpM2I5ek9FVXFPYVhKNFMvUGZGb05ZWnlTZjZvd093VUVxL2R5M3hvN3hGYjFhRjRpODRpL0N2YzdQMlFDRU5BK3dtbFB2dTJpOE5vSUYxV2E3UVdJWXRncmZQeGsrWjEySmJOa0lpbDVCdFJFZHR3ZUNuRldLR216c3krYjRIUEROc2ljcXZoTUhuZ3k4MkdNb0tQMHprcGVuVUdMZ2hIQ2JGRFF6MVNjVUZ3RjIyRmQvVDlvQTJRTWwvK0YvbS92ZnRvZ2NvbC9UTEI1c0dYSWxXRGViS2QzQnNETjRVMEIwRlNiRU5JaERPOEwvOWNLRndUSWdrOFhlN01WL2xhYUJGUHRLWFdtaUgrV3lOcDAzVkxoZnI2YXVOcGJnUHIxVVFwTlJxQUFaT3kybE5GdndoVlFObjZmbmhsWFpsWVA0V3paN24wTnVCbjlILzdWZHJMOGR5dHhEdCtZWEtKNWI4SVh2c0lGdGw1cmFCQkF3ZC9kakhYTjJqZkZNVFJTekc0T3pMS1dKWXVzTXQycXcwMSt4SmNHeE9iMGtKZjRTcnFpQ1RLWVR6UHhwakg0eDhvQTV6Z0cvZjVIQ3lFV3pISmdDYjhEeW9EM3NwRUh4RGciLCJBdXRoSW5mbyI6IntcIkNJXCI6XCJmOUc0eExxaHg2Tkk3YThaY1Q2N3hObmYrNlhsM05abmJXR1VjRmxTelljS0VKVTN1aVRjQ29Hd3BrcitqL2phVVRXclB2L2xxdCs3MEkrQTJkb3prd0IvKzc5ZlFyT2dLUzN4VmtFWUt6TT1cIixcIkNhbGxlclwiOlwiV2NKTEpvUWJHOXR5UmM2ZXg3LzNpQXlEcS9ya3NvSldhcXJvTnlhTWs0Yz1cIixcIkV4cGlyZVRpbWVcIjpcIjIwMjMtMDMtMTZUMDk6NDE6MzdaXCIsXCJNZWRpYUlkXCI6XCJjMWIyNGQzMGIyYzY3MWVkYmZjYjU0MjI4MGU5MDEwMlwiLFwiUGxheURvbWFpblwiOlwidm9kLmh5cHBlLmNsb3VkXCIsXCJTaWduYXR1cmVcIjpcIk9pbHhxelNyaVVhOGlRZFhaVEVZZEJpbUhJUT1cIn0iLCJWaWRlb01ldGEiOnsiU3RhdHVzIjoiTm9ybWFsIiwiVmlkZW9JZCI6ImMxYjI0ZDMwYjJjNjcxZWRiZmNiNTQyMjgwZTkwMTAyIiwiVGl0bGUiOiIyODg4MTdkYi1jNzdjLWM0ZTQtNjdmYi0zYjk1MTlmNTc0ZWIiLCJDb3ZlclVSTCI6Imh0dHBzOi8vdm9kLmh5cHBlLmNsb3VkL2MxYjI0ZDMwYjJjNjcxZWRiZmNiNTQyMjgwZTkwMTAyL3NuYXBzaG90cy9jYzM0MjVkNzJiYjM0YTE3OWU5NmMzZTA3NTViZjJjNi0wMDAwNC5qcGciLCJEdXJhdGlvbiI6NTkuMDQ5fSwiQWNjZXNzS2V5SWQiOiJTVFMuTlNybVVtQ1hwTUdEV3g4ZGlWNlpwaGdoQSIsIlBsYXlEb21haW4iOiJ2b2QuaHlwcGUuY2xvdWQiLCJBY2Nlc3NLZXlTZWNyZXQiOiIzU1NRUkdkOThGMU04TkZ0b00xa2NlU01IZlRLNkJvZm93VXlnS1Y5aEpQdyIsIlJlZ2lvbiI6ImFwLXNvdXRoZWFzdC01IiwiQ3VzdG9tZXJJZCI6NTQ1NDc1MzIwNTI4MDU0OX0=",
    // );
    // await getAuth(data.music?.apsaraMusic ?? '');

    // _playMode = ModeTypeAliPLayer.auth;
    // await getAuth(data.music?.apsaraMusic ?? '');

    setState(() {
      isPause = false;
      // _isFirstRenderShow = false;
    });
    // var configMap = {
    //   'mStartBufferDuration': GlobalSettings.mStartBufferDuration, // The buffer duration before playback. Unit: milliseconds.
    //   'mHighBufferDuration': GlobalSettings.mHighBufferDuration, // The duration of high buffer. Unit: milliseconds.
    //   'mMaxBufferDuration': GlobalSettings.mMaxBufferDuration, // The maximum buffer duration. Unit: milliseconds.
    //   'mMaxDelayTime': GlobalSettings.mMaxDelayTime, // The maximum latency of live streaming. Unit: milliseconds. You can specify the latency only for live streams.
    //   'mNetworkTimeout': GlobalSettings.mNetworkTimeout, // The network timeout period. Unit: milliseconds.
    //   'mNetworkRetryCount': GlobalSettings.mNetworkRetryCount, // The number of retires after a network timeout. Unit: milliseconds.
    //   'mEnableLocalCache': GlobalSettings.mEnableCacheConfig,
    //   'mLocalCacheDir': GlobalSettings.mDirController,
    //   'mClearFrameWhenStop': true
    // };
    // Configure the application.
    // fAliplayer?.setConfig(configMap);
    // var map = {
    //   "mMaxSizeMB": GlobalSettings.mMaxSizeMBController,

    //   /// The maximum space that can be occupied by the cache directory.
    //   "mMaxDurationS": GlobalSettings.mMaxDurationSController,

    //   /// The maximum cache duration of a single file.
    //   "mDir": GlobalSettings.mDirController,

    //   /// The cache directory.
    //   "mEnable": GlobalSettings.mEnableCacheConfig

    //   /// Specify whether to enable the cache feature.
    // };
    // fAliplayer?.setCacheConfig(map);
    if (data.reportedStatus != 'BLURRED') {
      // fAliplayer?.prepare();
      if (!mounted) return;
      await getMusicUrl(context, data.music?.apsaraMusic ?? '');
    }
    fAliplayer?.setMuted(notifier.isMute);
    // fAliplayer?.play();
    MyAudioService.instance.play(
      path: url,
      startedPlaying: () {
        playIndex = _curIdx;
        setState(() {});
      },
      stoppedPlaying: () {
        playIndex = -1;
        setState(() {});
      },
      mute: notifier.isMute,
    );
  }

  Future getMusicUrl(BuildContext context, String apsaraId) async {
    setState(() {
      isloading = true;
    });
    try {
      final fixContext = Routing.navigatorKey.currentContext;
      final notifier = PostsBloc();
      await notifier.getMusic(fixContext ?? context, apsaraId: apsaraId);
      final fetch = notifier.postsFetch;
      if (fetch.postsState == PostsState.videoApsaraSuccess) {
        Map jsonMap = json.decode(fetch.data.toString());

        setState(() {
          url = jsonMap['data']['PlayURL'];
          isloading = false;
        });
        // widget.videoData?.fullContentPath = jsonMap['PlayUrl'];
      }
    } catch (e) {
      setState(() {
        isloading = false;
      });
      // 'Failed to fetch ads data $e'.logger();
    }
  }

  Future getAuth(String apsaraId) async {
    setState(() {
      isloading = true;
    });
    try {
      final notifier = PostsBloc();
      await notifier.getAuthApsara(context, apsaraId: apsaraId, check: false);
      final fetch = notifier.postsFetch;
      if (fetch.postsState == PostsState.videoApsaraSuccess) {
        Map jsonMap = json.decode(fetch.data.toString());
        auth = jsonMap['PlayAuth'];

        fAliplayer?.setVidAuth(
          vid: apsaraId,
          region: DataSourceRelated.defaultRegion,
          playAuth: auth,
        );
        setState(() {
          isloading = false;
        });
        // widget.videoData?.fullContentPath = jsonMap['PlayUrl'];
      }
    } catch (e) {
      setState(() {
        isloading = false;
      });
      // 'Failed to fetch ads data $e'.logger();
    }
  }

  Future getOldVideoUrl(String postId) async {
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
        // widget.videoData?.fullContentPath = jsonMap['PlayUrl'];
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

  @override
  void didChangeDependencies() {
    CustomRouteObserver.routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    print("---=-=-=-=--===-=-=-=-DiSPOSE--=-=-=-=-=-=-=-=-=-=-=----==-=");

    super.dispose();
    // WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void deactivate() {
    print("====== deactivate ");
    fAliplayer?.stop();
    MyAudioService.instance.stop();
    System().disposeBlock();
    if (context.read<PreviewVidNotifier>().canPlayOpenApps) {
      fAliplayer?.destroy();
    }
    if (Platform.isIOS) {
      FlutterAliplayer.enableMix(false);
      // FlutterAliplayer.setAudioSessionTypeForIOS(AliPlayerAudioSesstionType.none);
    }
    super.deactivate();
  }

  @override
  void didPop() {
    print("====== didpop ");
    super.didPop();
  }

  @override
  void didPopNext() async {
    ScrollPicNotifier notifier = context.read<ScrollPicNotifier>();
    if (pageIndex == (notifier.pics?.length ?? 0)) {
      setState(() {
        pageIndex = _curIdx - 1;
        print("=-=-=-=-=-  $pageIndex =-==-=-=-=-=-=");
      });
    }
    isInPage = true;
    fAliplayer?.play();
    if (playIndex == _curIdx) {
      MyAudioService.instance.playagain(notifier.isMute);
    }
    isActivePage = true;
    // System().disposeBlock();

    if (toComment) {
      print("====picnotif======");

      setState(() {
        pics = notifier.pics;
        toComment = false;
      });
    }

    super.didPopNext();
  }

  @override
  void didPush() {
    print("========= didPush");
    super.didPush();
  }

  @override
  void didPushNext() {
    fAliplayer?.pause();
    MyAudioService.instance.pause();
    isInPage = false;
    print("========= didPushNext scroll $isInPage");
    System().disposeBlock();
    super.didPushNext();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.inactive:
        print("========= inactive");
        break;
      case AppLifecycleState.resumed:
        print("========= resumed $isActivePage ");
        if ((Routing.navigatorKey.currentContext ?? context).read<PreviewVidNotifier>().canPlayOpenApps && !SharedPreference().readStorage(SpKeys.isShowPopAds) && isInPage) {
          print("==== hahaha aha ah ah ah ah ah ah  resume $isInPage");
          fAliplayer?.play();
          if (playIndex == _curIdx) {
            final notifier = Provider.of<ScrollPicNotifier>(context, listen: false);
            MyAudioService.instance.playagain(notifier.isMute);
          }
        }
        break;
      case AppLifecycleState.paused:
        print(
            "========= paused scroll ${(Routing.navigatorKey.currentContext ?? context).read<PreviewVidNotifier>().canPlayOpenApps && !SharedPreference().readStorage(SpKeys.isShowPopAds) && isInPage}");
        fAliplayer?.pause();
        MyAudioService.instance.pause();
        break;
      case AppLifecycleState.detached:
        print("========= detached");
        break;
      default:
        break;
    }
  }

  void zoom(val) {
    setState(() {
      isZoom = val;
    });
  }

  // int _currentItem = 0;
  ValueNotifier<int> _networklHasErrorNotifier = ValueNotifier(0);

  // _onStartScroll(ScrollMetrics metrics) {
  //   print("Scroll Start");
  // }
  //
  // _onUpdateScroll(ScrollMetrics metrics) {
  //   print("Scroll Update");
  // }
  //
  // _onEndScroll(ScrollMetrics metrics) {
  //   print("Scroll End");
  // }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    // final error = context.select((ErrorService value) => value.getError(ErrorType.pic));
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
              // Navigator.pop(context, '$_curIdx');
              Routing().moveBack();
              return false;
            },
            child: Consumer2<ScrollPicNotifier, HomeNotifier>(
              builder: (_, notifier, home, __) => SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(margin: const EdgeInsets.symmetric(horizontal: 10), transform: Matrix4.translationValues(-18.0, 0.0, 0.0), child: widget.arguments?.titleAppbar ?? Container()),
                          if (pics?.isNotEmpty ?? false)
                            if (pics?[pageIndex].email != email && (pics?[pageIndex].isNewFollowing ?? false) && (widget.arguments?.isProfile ?? false))
                              Consumer<PreviewPicNotifier>(
                                builder: (context, picNot, child) => Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      context.handleActionIsGuest(() {
                                        if (widget.arguments?.picData?[pageIndex].insight?.isloadingFollow != true) {
                                          picNot.followUser(context, pics?[pageIndex] ?? ContentData(),
                                              isUnFollow: pics?[pageIndex].following, isloading: pics?[pageIndex].insight!.isloadingFollow ?? false);
                                        }
                                      }).then((value) {
                                        if (value) {
                                          MyAudioService.instance.playagain(notifier.isMute);
                                        }
                                      });
                                    },
                                    child: pics?[pageIndex].insight?.isloadingFollow ?? false
                                        ? const SizedBox(
                                            height: 30,
                                            width: 30,
                                            child: Center(
                                              child: CustomLoading(),
                                            ),
                                          )
                                        : SizedBox(
                                            height: 40,
                                            child: Center(
                                              child: Text(
                                                (pics?[pageIndex].following ?? false) ? (lang?.following ?? '') : (lang?.follow ?? ''),
                                                style: const TextStyle(color: kHyppePrimary, fontWeight: FontWeight.w700, fontFamily: "Lato"),
                                              ),
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                        ],
                      ),
                      leading: IconButton(
                          icon: const Icon(
                            Icons.chevron_left,
                            color: kHyppeTextLightPrimary,
                          ),
                          onPressed: () {
                            Future.delayed(Duration.zero, () {
                              // Navigator.pop(context, '$_curIdx');
                              Navigator.pop(context);
                            });
                          }),
                    ),
                    Expanded(
                      child: (pics?.isEmpty ?? [].isEmpty)
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
                                    pics = notifier.pics;
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
                              child: NotificationListener<ScrollNotification>(
                                onNotification: (scrollNotification) {
                                  print("scrollNotification ===== $scrollNotification");
                                  // scrollNotification.disallowIndicator();
                                  if (scrollNotification is ScrollStartNotification) {
                                    print("=======start=======");
                                    // _onStartScroll(scrollNotification.metrics);
                                  } else if (scrollNotification is ScrollUpdateNotification) {
                                    // _onUpdateScroll(scrollNotification.metrics);
                                  } else if (scrollNotification is ScrollEndNotification) {
                                    print("=======end=======");
                                    // _onEndScroll(scrollNotification.metrics);
                                  }

                                  return false;
                                },
                                child: ScrollablePositionedList.builder(
                                  scrollDirection: Axis.vertical,
                                  itemScrollController: notifier.itemScrollController,
                                  itemPositionsListener: itemPositionsListener,
                                  scrollOffsetController: scrollOffsetController,
                                  scrollOffsetListener: scrollOffsetListener,
                                  // scrollDirection: Axis.horizontal,
                                  physics: isZoom ? const NeverScrollableScrollPhysics() : const AlwaysScrollableScrollPhysics(),
                                  shrinkWrap: false,
                                  itemCount: pics?.length ?? 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 11.5),

                                  itemBuilder: (context, index) {
                                    if (pics == null || home.isLoadingPict) {
                                      fAliplayer?.pause();
                                      MyAudioService.instance.pause();
                                      _lastCurIndex = -1;
                                      return CustomShimmer(
                                        width: (MediaQuery.of(context).size.width - 11.5 - 11.5 - 9) / 2,
                                        height: 168,
                                        radius: 8,
                                        margin: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 10),
                                        padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
                                      );
                                    } else if (index == pics?.length) {
                                      return UnconstrainedBox(
                                        child: Container(
                                          alignment: Alignment.center,
                                          width: 80 * SizeConfig.scaleDiagonal,
                                          height: 80 * SizeConfig.scaleDiagonal,
                                          child: const CustomLoading(),
                                        ),
                                      );
                                    }

                                    return itemPict(notifier, index);
                                  },
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  // var initialControllerValue;

  Widget itemPict(ScrollPicNotifier notifier, int index) {
    TranslateNotifierV2 tn = context.read<TranslateNotifierV2>();
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
          ),
          padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 16),
          margin: const EdgeInsets.only(
            top: 18,
            left: 6,
            right: 6,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text("${widget.arguments?.heightTopProfile ?? 0}"),
              // ZoomOverlay(
              //     modalBarrierColor: Colors.black12, // optional
              //     minScale: 0.5, // optional
              //     maxScale: 3.0, // optional
              //     twoTouchOnly: true,
              //     animationDuration: Duration(milliseconds: 300),
              //     animationCurve: Curves.fastOutSlowIn,
              //     onScaleStart: () {
              //       debugPrint('zooming!');
              //     }, // optional
              //     onScaleStop: () {
              //       debugPrint('zooming ended!');
              //     }, // optional
              //     child: CachedNetworkImage(imageUrl: (pics?[index].isApsara ?? false) ? (pics?[index].mediaThumbEndPoint ?? "") : "${pics?[index].fullThumbPath}")),
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
                      username: pics?[index].username,
                      featureType: FeatureType.other,
                      // isCelebrity: vidpics?[index].privacy?.isCelebrity,
                      isCelebrity: false,
                      imageUrl: '${System().showUserPicture(pics?[index].avatar?.mediaEndpoint)}',
                      onTapOnProfileImage: () => System().navigateToProfile(context, pics?[index].email ?? ''),
                      createdAt: '2022-02-02',
                      musicName: pics?[index].music?.musicTitle ?? '',
                      location: pics?[index].location ?? '',
                      isIdVerified: pics?[index].privacy?.isIdVerified,
                      badge: pics?[index].urluserBadge,
                    ),
                  ),
                  if (pics?[index].email != email && (pics?[index].isNewFollowing ?? false) && !(widget.arguments?.isProfile ?? false))
                    Consumer<PreviewPicNotifier>(
                      builder: (context, picNot, child) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            context.handleActionIsGuest(() {
                              if (pics?[index].insight?.isloadingFollow != true) {
                                picNot.followUser(context, pics?[index] ?? ContentData(), isUnFollow: pics?[index].following, isloading: pics?[index].insight!.isloadingFollow ?? false);
                              }
                            }).then((value) {
                              if (value) {
                                MyAudioService.instance.playagain(notifier.isMute);
                              }
                            });
                          },
                          child: pics?[index].insight?.isloadingFollow ?? false
                              ? Container(
                                  height: 40,
                                  width: 30,
                                  child: const Align(
                                    alignment: Alignment.bottomRight,
                                    child: CustomLoading(),
                                  ),
                                )
                              : Text(
                                  (pics?[index].following ?? false) ? (lang?.following ?? '') : (lang?.follow ?? ''),
                                  style: const TextStyle(color: kHyppePrimary, fontSize: 12, fontWeight: FontWeight.w700, fontFamily: "Lato"),
                                ),
                        ),
                      ),
                    ),
                  GestureDetector(
                    onTap: () {
                      fAliplayer?.setMuted(true);
                      fAliplayer?.pause();
                      context.handleActionIsGuest(() async {
                        if (pics?[index].email != email) {
                          context.read<PreviewPicNotifier>().reportContent(context, pics?[index] ?? ContentData(), fAliplayer: fAliplayer, onCompleted: () async {
                            bool connect = await System().checkConnections();
                            if (connect) {
                              setState(() {
                                isloading = true;
                                if (index == (pics?.length ?? 0) - 1) {
                                  pageIndex = index - 1;
                                }
                              });
                              await notifier.reload(Routing.navigatorKey.currentContext ?? context, widget.arguments!.pageSrc!, key: widget.arguments?.key ?? '');
                              setState(() {
                                pics = notifier.pics;
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
                            contentData: pics?[index] ?? ContentData(),
                            captionTitle: hyppePic,
                            onDetail: false,
                            isShare: pics?[index].isShared ?? false,
                            onUpdate: () {
                              if (index == (pics?.length ?? 0 - 1)) {
                                setState(() {
                                  pageIndex = index - 1;
                                });
                              }
                              context.read<HomeNotifier>().onUpdate();
                            },
                            fAliplayer: fAliplayer,
                          );
                        }
                      }).then((value) {
                        if (value) {
                          MyAudioService.instance.playagain(notifier.isMute);
                        }
                      });
                      // fAliplayer?.pause();
                    },
                    child: const Icon(
                      Icons.more_vert,
                      color: kHyppeTextLightPrimary,
                    ),
                  ),
                ],
              ),
              tenPx,
              // Text("${pics?[index].isApsara ?? false}"),
              // SelectableText("${pics?[index].fullContent}"),
              // SelectableText("${(pics?[index].isApsara ?? false) ? (pics?[index].mediaEndpoint ?? "") : "${pics?[index].fullContent}" + '&2'}"),
              // ZoomableCachedNetworkImage(
              //   url: (pics?[index].isApsara ?? false) ? (pics?[index].mediaThumbEndPoint ?? "") : "${pics?[index].fullThumbPath}",
              // ),
              VisibilityDetector(
                key: Key(pics?[index].postID ?? index.toString()),
                onVisibilityChanged: (info) {
                  // print("ada musiknya ${info.visibleFraction}");
                  // a.scrollAuto();
                  if (info.visibleFraction >= 0.6) {
                    _curIdx = index;
                    //=============

                    //=============
                    if (_lastCurIndex != _curIdx) {
                      try {
                        widget.arguments?.scrollController?.jumpTo(System().scrollAuto(_curIdx, widget.arguments?.heightTopProfile ?? 0, widget.arguments?.heightBox?.toInt() ?? 110));
                      } catch (e) {
                        print("ini error $e");
                      }
                      print("==================hihihi 2==============");
                      if (pics?[index].music?.musicTitle != null) {
                        // print("ada musiknya ${pics?[index].music}");
                        Future.delayed(const Duration(milliseconds: 100), () {
                          start(pics?[index] ?? ContentData(), notifier);
                        });
                      } else {
                        fAliplayer?.stop();
                        MyAudioService.instance.stop();
                      }
                      Future.delayed(const Duration(milliseconds: 100), () {
                        System().increaseViewCount2(context, pics?[index] ?? ContentData(), check: false);
                      });
                      if (pics?[index].certified ?? false) {
                        System().block(context);
                      } else {
                        System().disposeBlock();
                      }
                    }
                    _lastCurIndex = _curIdx;
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  width: SizeConfig.screenWidth,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.white,
                    ),
                    child: Stack(
                      children: [
                        // Center(
                        //   child: CustomBaseCacheImage(
                        //     memCacheWidth: 100,
                        //     memCacheHeight: 100,
                        //     widthPlaceHolder: 80,
                        //     heightPlaceHolder: 80,
                        //     imageUrl: (pics?[index].isApsara ?? false) ? (pics?[index].mediaThumbEndPoint ?? "") : "${pics?[index].fullThumbPath}",
                        //     imageBuilder: (context, imageProvider) => ClipRRect(
                        //       borderRadius: BorderRadius.circular(20), // Image border
                        //       child: pics?[index].reportedStatus == 'BLURRED'
                        //           ? ImageFiltered(
                        //               imageFilter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                        //               child: Image(
                        //                 image: imageProvider,
                        //                 fit: BoxFit.fitHeight,
                        //                 width: SizeConfig.screenWidth,
                        //               ),
                        //             )
                        //           : Image(
                        //               image: imageProvider,
                        //               fit: BoxFit.fitHeight,
                        //               width: SizeConfig.screenWidth,
                        //             ),
                        //     ),
                        //     errorWidget: (context, url, error) {
                        //       return Container(
                        //         // const EdgeInsets.symmetric(horizontal: 4.5),
                        //         // height: 500,
                        //         decoration: BoxDecoration(
                        //           image: const DecorationImage(
                        //             image: AssetImage('${AssetPath.pngPath}content-error.png'),
                        //             fit: BoxFit.cover,
                        //           ),
                        //           borderRadius: BorderRadius.circular(8.0),
                        //         ),
                        //       );
                        //     },
                        //     emptyWidget: Container(
                        //       // const EdgeInsets.symmetric(horizontal: 4.5),

                        //       // height: 500,
                        //       decoration: BoxDecoration(
                        //         image: const DecorationImage(
                        //           image: AssetImage('${AssetPath.pngPath}content-error.png'),
                        //           fit: BoxFit.cover,
                        //         ),
                        //         borderRadius: BorderRadius.circular(8.0),
                        //       ),
                        //     ),
                        //   ),
                        // ),

                        !notifier.connectionError
                            ? GestureDetector(
                                onTap: () async {
                                  // if (pics?[index].reportedStatus !=
                                  //     'BLURRED') {
                                  //   fAliplayer?.play();
                                  //   setState(() {
                                  //     notifier.isMute = !isMute;
                                  //   });
                                  //   fAliplayer?.setMuted(isMute);
                                  // }
                                  if (pageSrc == PageSrc.selfProfile || pageSrc == PageSrc.otherProfile) {
                                    var res = await Routing().move(Routes.picScrollFullScreenDetail,
                                        argument: SlidedPicDetailScreenArgument(
                                          isProfile: true,
                                          page: index,
                                          type: TypePlaylist.mine,
                                          titleAppbar: widget.arguments!.titleAppbar,
                                          pageSrc: widget.arguments?.pageSrc ?? PageSrc.otherProfile,
                                          picData: pics,
                                          scrollController: widget.arguments!.scrollController,
                                          heightTopProfile: widget.arguments!.heightTopProfile,
                                        ));
                                    if (res != null || res == null) {
                                      fAliplayer?.play();
                                      fAliplayer?.setMuted(notifier.isMute);
                                      if (playIndex == _curIdx && pics![index].music != null) {
                                        MyAudioService.instance.playagain(notifier.isMute);
                                      } else {
                                        MyAudioService.instance.stop();
                                      }
                                      notifier.itemScrollController.jumpTo(index: notifier.currentIndex);
                                    }
                                  }
                                },
                                onDoubleTap: () {
                                  final _likeNotifier = context.read<LikeNotifier>();
                                  if (pics?[index] != null) {
                                    _likeNotifier.likePost(context, pics?[index] ?? ContentData()).then((value) {
                                      List<ContentData>? pic = context.read<PreviewPicNotifier>().pic;
                                      if (pic?.isNotEmpty ?? false) {
                                        int idx = pic!.indexWhere((e) => e.postID == value['_id']);
                                        pic[idx].insight?.isPostLiked = value['isPostLiked'];
                                        pic[idx].insight?.likes = value['likes'];
                                        pic[idx].isLiked = value['isLiked'];
                                      }
                                    });
                                  }
                                },
                                child: Center(
                                  child: Container(
                                    color: Colors.transparent,
                                    // width: SizeConfig.screenWidth,
                                    // height: SizeConfig.screenHeight,
                                    child: ZoomableImage(
                                      onScaleStart: () {
                                        zoom(true);
                                      },
                                      onScaleStop: () {
                                        zoom(false);
                                      },
                                      child: pics?[index].isLoading ?? false
                                          ? Container()
                                          : ValueListenableBuilder(
                                              valueListenable: _networklHasErrorNotifier,
                                              builder: (BuildContext context, int count, _) {
                                                return CustomBaseCacheImage(
                                                  cacheKey: "${pics?[index].postID}-${_networklHasErrorNotifier.value.toString()}",
                                                  memCacheWidth: 100,
                                                  memCacheHeight: 100,
                                                  widthPlaceHolder: 80,
                                                  heightPlaceHolder: 80,
                                                  imageUrl: (pics?[index].isApsara ?? false) ? (pics?[index].mediaEndpoint ?? "") : "${pics?[index].fullContent ?? ''}" + '&2',
                                                  // imageUrl: "https://mir-s3-cdn-cf.behance.net/project_modules/max_3840/8f37ff162632759.63d906f614037.jpg",
                                                  imageBuilder: (context, imageProvider) => ClipRRect(
                                                    borderRadius: BorderRadius.circular(20), // Image borderr
                                                    child: pics?[index].reportedStatus == 'BLURRED'
                                                        ? ImageFiltered(
                                                            imageFilter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                                                            child: Image(
                                                              image: imageProvider,
                                                              fit: BoxFit.fitHeight,
                                                              width: SizeConfig.screenWidth,
                                                            ),
                                                          )
                                                        : Image(
                                                            image: imageProvider,
                                                            fit: BoxFit.fitHeight,
                                                            width: SizeConfig.screenWidth,
                                                          ),
                                                  ),
                                                  emptyWidget: notifier.connectionError
                                                      ? GestureDetector(
                                                          onTap: () async {
                                                            _networklHasErrorNotifier.value++;
                                                            bool connect = await System().checkConnections();
                                                            if (connect) {
                                                              setState(() {
                                                                isloading = true;
                                                              });
                                                              await notifier.reload(context, widget.arguments!.pageSrc!, key: widget.arguments?.key ?? '');
                                                              setState(() {
                                                                pics = notifier.pics;
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
                                                          child: Container(
                                                              decoration: BoxDecoration(color: kHyppeNotConnect, borderRadius: BorderRadius.circular(16)),
                                                              width: SizeConfig.screenWidth,
                                                              height: 250,
                                                              alignment: Alignment.center,
                                                              padding: const EdgeInsets.all(20),
                                                              child: pics?[index].reportedStatus == 'BLURRED'
                                                                  ? Container()
                                                                  : CustomTextWidget(
                                                                      textToDisplay: lang?.couldntLoadImage ?? 'Error',
                                                                      maxLines: 3,
                                                                    )),
                                                        )
                                                      : Image.network(
                                                          (pics?[index].isApsara ?? false) ? (pics?[index].mediaEndpoint ?? "") : "${pics?[index].fullContent}" + '&2',
                                                          fit: BoxFit.fitHeight,
                                                          width: SizeConfig.screenWidth,
                                                        ),
                                                  errorWidget: (context, url, error) {
                                                    return notifier.connectionError
                                                        ? GestureDetector(
                                                            onTap: () async {
                                                              _networklHasErrorNotifier.value++;
                                                              bool connect = await System().checkConnections();
                                                              if (connect) {
                                                                setState(() {
                                                                  isloading = true;
                                                                });
                                                                await notifier.reload(context, widget.arguments!.pageSrc!, key: widget.arguments?.key ?? '');
                                                                setState(() {
                                                                  pics = notifier.pics;
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
                                                            child: Container(
                                                                decoration: BoxDecoration(color: kHyppeNotConnect, borderRadius: BorderRadius.circular(16)),
                                                                width: SizeConfig.screenWidth,
                                                                height: 250,
                                                                alignment: Alignment.center,
                                                                padding: const EdgeInsets.all(20),
                                                                child: pics?[index].reportedStatus == 'BLURRED'
                                                                    ? Container()
                                                                    : CustomTextWidget(
                                                                        textToDisplay: lang?.couldntLoadImage ?? 'Error',
                                                                        maxLines: 3,
                                                                      )),
                                                          )
                                                        : Image.network(
                                                            (pics?[index].isApsara ?? false) ? (pics?[index].mediaEndpoint ?? "") : "${pics?[index].fullContent}" + '&2',
                                                            fit: BoxFit.fitHeight,
                                                            width: SizeConfig.screenWidth,
                                                          );
                                                  },
                                                );
                                              }),
                                    ),
                                  ),
                                ),
                              )
                            : GestureDetector(
                                onTap: () {
                                  notifier.checkConnection();
                                },
                                child: Container(
                                    decoration: BoxDecoration(color: kHyppeNotConnect, borderRadius: BorderRadius.circular(16)),
                                    width: SizeConfig.screenWidth,
                                    height: 250,
                                    padding: const EdgeInsets.all(20),
                                    alignment: Alignment.center,
                                    child: pics?[index].reportedStatus == 'BLURRED'
                                        ? Container()
                                        : CustomTextWidget(
                                            textToDisplay: lang?.couldntLoadImage ?? 'Error',
                                            maxLines: 3,
                                          )),
                              ),
                        _buildBody(context, SizeConfig.screenWidth, pics?[index] ?? ContentData(), notifier),
                        blurContentWidget(context, pics?[index] ?? ContentData()),
                      ],
                    ),
                  ),
                ),
              ),
              SharedPreference().readStorage(SpKeys.statusVerificationId) == VERIFIED &&
                      pics?[index].statusBoost != 'BERLANGSUNG' &&
                      (pics?[index].reportedStatus != 'OWNED' && pics?[index].reportedStatus != 'BLURRED' && pics?[index].reportedStatus2 != 'BLURRED') &&
                      pics?[index].email == email
                  ? Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ButtonBoost(
                        onDetail: false,
                        marginBool: true,
                        contentData: pics?[index],
                        startState: () {
                          SharedPreference().writeStorage(SpKeys.isShowPopAds, true);
                        },
                        afterState: () {
                          SharedPreference().writeStorage(SpKeys.isShowPopAds, false);
                        },
                      ),
                    )
                  : Container(),
              pics?[index].email == SharedPreference().readStorage(SpKeys.email) && (pics?[index].reportedStatus == 'OWNED')
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 11.0),
                      child: ContentViolationWidget(
                        data: pics?[index] ?? ContentData(),
                        text: lang?.thisHyppeVidisSubjectToModeration ?? '',
                      ),
                    )
                  : Container(),
              if (pics?[index].email == email && (pics?[index].boostCount ?? 0) >= 0 && pics?[index].statusBoost == 'BERLANGSUNG' && (pics?[index].boosted.isNotEmpty ?? [].isEmpty))
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
                        child: CustomTextWidget(
                          textToDisplay: "${pics?[index].boostJangkauan ?? '0'} ${lang?.reach}",
                          textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kHyppeTextLightPrimary),
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
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: pics?[index].insight?.isloading ?? false
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
                                      color: (pics?[index].insight?.isPostLiked ?? false) ? kHyppeRed : kHyppeTextLightPrimary,
                                      iconData: '${AssetPath.vectorPath}${(pics?[index].insight?.isPostLiked ?? false) ? 'liked.svg' : 'none-like.svg'}',
                                      height: 28,
                                    ),
                                    onTap: () {
                                      if (pics?[index] != null) {
                                        likeNotifier.likePost(context, pics![index]).then((value) {
                                          List<ContentData>? pic = context.read<PreviewPicNotifier>().pic;
                                          if (pic?.isNotEmpty ?? false) {
                                            int idx = pic!.indexWhere((e) => e.postID == value['_id']);
                                            pic[idx].insight?.isPostLiked = value['isPostLiked'];
                                            pic[idx].insight?.likes = value['likes'];
                                            pic[idx].isLiked = value['isLiked'];
                                          }
                                        });
                                      }
                                    },
                                  ),
                          ),
                        ),
                        if (pics?[index].allowComments ?? false)
                          Padding(
                            padding: EdgeInsets.only(left: 21.0),
                            child: GestureDetector(
                              onTap: () {
                                toComment = true;
                                Routing().move(Routes.commentsDetail,
                                    argument: CommentsArgument(
                                      postID: pics?[index].postID ?? '',
                                      fromFront: true,
                                      data: pics?[index] ?? ContentData(),
                                      pageDetail: true,
                                    ));
                                // ShowBottomSheet.onShowCommentV2(context, postID: pics?[index].postID);
                              },
                              child: const CustomIconWidget(
                                defaultColor: false,
                                color: kHyppeTextLightPrimary,
                                iconData: '${AssetPath.vectorPath}comment2.svg',
                                height: 24,
                              ),
                            ),
                          ),
                        if ((pics?[index].isShared ?? false))
                          GestureDetector(
                            onTap: () {
                              context.read<PicDetailNotifier>().createdDynamicLink(context, data: pics?[index]);
                            },
                            child: const Padding(
                              padding: EdgeInsets.only(left: 21.0),
                              child: CustomIconWidget(
                                defaultColor: false,
                                color: kHyppeTextLightPrimary,
                                iconData: '${AssetPath.vectorPath}share2.svg',
                                height: 24,
                              ),
                            ),
                          ),
                        if ((pics?[index].saleAmount ?? 0) > 0 && email != pics?[index].email)
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                await context.handleActionIsGuest(() async {
                                  fAliplayer?.pause();
                                  MyAudioService.instance.pause();
                                  notifier.setIsSound(true);
                                  await ShowBottomSheet.onBuyContent(context, data: pics?[index], fAliplayer: fAliplayer);
                                }).then((value) {
                                  if (value) {
                                    MyAudioService.instance.playagain(notifier.isMute);
                                  }
                                });
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
                    RichText(
                      text: TextSpan(children: [
                        TextSpan(
                          text: "${pics?[index].insight?.likes} ${tn.translate.like}",
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => Navigator.push(
                                context,
                                CupertinoPageRoute(
                                    builder: (context) => ViewLiked(
                                          postId: pics?[index].postID ?? '',
                                          eventType: 'LIKE',
                                        ))),
                          style: const TextStyle(color: kHyppeTextLightPrimary, fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                        const TextSpan(
                          text: " • ",
                          style: TextStyle(color: kHyppeTextLightPrimary, fontWeight: FontWeight.w700, fontSize: 16),
                        ),
                        TextSpan(
                          text: "${pics?[index].insight!.views?.getCountShort()} ${tn.translate.views}",
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => Navigator.push(
                                context,
                                CupertinoPageRoute(
                                    builder: (context) => ViewLiked(
                                          postId: pics?[index].postID ?? '',
                                          eventType: 'VIEW',
                                        ))),
                          style: const TextStyle(color: kHyppeTextLightPrimary, fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                      ]),
                    ),
                  ],
                ),
              ),
              fourPx,
              CustomNewDescContent(
                email: pics?[index].email ?? '',
                username: pics?[index].username ?? '',
                desc: "${pics?[index].description}",
                trimLines: 2,
                textAlign: TextAlign.start,
                seeLess: ' ${lang?.less}',
                seeMore: ' ${lang?.more}',
                normStyle: const TextStyle(fontSize: 12, color: kHyppeTextLightPrimary),
                hrefStyle: Theme.of(context).textTheme.subtitle2?.copyWith(color: kHyppePrimary, fontSize: 12),
                expandStyle: const TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.bold),
              ),
              if (pics?[index].allowComments ?? true)
                GestureDetector(
                  onTap: () {
                    toComment = true;
                    Routing().move(Routes.commentsDetail,
                        argument: CommentsArgument(
                          postID: pics?[index].postID ?? '',
                          fromFront: true,
                          data: pics?[index] ?? ContentData(),
                          pageDetail: true,
                        ));
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      "${lang?.viewAll} ${pics?[index].comments} ${lang?.comment}",
                      style: const TextStyle(fontSize: 12, color: kHyppeBurem),
                    ),
                  ),
                ),
              (pics?[index].comment?.length ?? 0) > 0
                  ? Padding(
                      padding: const EdgeInsets.only(top: 0.0),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: (pics?[index].comment?.length ?? 0) >= 2 ? 2 : 1,
                        itemBuilder: (context, indexComment) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6.0),
                            child: CustomNewDescContent(
                              // desc: "${pics?[index]?.description}",
                              email: pics?[index].comment?[indexComment].sender ?? '',
                              username: pics?[index].comment?[indexComment].userComment?.username ?? '',
                              desc: pics?[index].comment?[indexComment].txtMessages ?? '',
                              trimLines: 2,
                              textAlign: TextAlign.start,
                              seeLess: ' ${lang?.less}', // ${notifier2.translate.seeLess}',
                              seeMore: ' ${lang?.more}',
                              normStyle: const TextStyle(fontSize: 12, color: kHyppeTextLightPrimary),
                              hrefStyle: Theme.of(context).textTheme.subtitle2?.copyWith(color: kHyppePrimary),
                              expandStyle: const TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.bold),
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
                    DateTime.parse(System().dateTimeRemoveT(pics?[index].createdAt ?? DateTime.now().toString())).millisecondsSinceEpoch,
                    context,
                    fullCaption: true,
                  )}",
                  style: TextStyle(fontSize: 12, color: kHyppeBurem),
                ),
              ),
            ],
          ),
        ),
        index == pics?.length && notifier.isLoadingLoadmore
            ? const SizedBox(
                height: 50,
                child: Center(child: CustomLoading()),
              )
            : Container(),
      ],
    );
  }

  Widget _buildBody(BuildContext context, width, ContentData data, ScrollPicNotifier notifier) {
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
                  fAliplayer?.pause();
                  context.read<PicDetailNotifier>().showUserTag(context, data.tagPeople, data.postID, fAliplayer: fAliplayer, title: lang!.inthisphoto);
                },
                child: const CustomIconWidget(
                  iconData: '${AssetPath.vectorPath}tag_people.svg',
                  defaultColor: false,
                  height: 24,
                ),
              ),
            ),
          if (data.music?.musicTitle != null)
            Align(
              alignment: Alignment.bottomRight,
              child: GestureDetector(
                onTap: () {
                  notifier.setIsSound(!notifier.isMute);
                  if (playIndex == _curIdx){
                    MyAudioService.instance.playagain(notifier.isMute);
                  }else{
                    start(data, notifier);
                  }
                  
                  fAliplayer?.setMuted(notifier.isMute);
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CustomIconWidget(
                    iconData: notifier.isMute ? '${AssetPath.vectorPath}sound-off.svg' : '${AssetPath.vectorPath}sound-on.svg',
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
                      Spacer(),
                      const CustomIconWidget(
                        iconData: "${AssetPath.vectorPath}eye-off.svg",
                        defaultColor: false,
                        height: 30,
                        color: Colors.white,
                      ),
                      Text(transnot.translate.sensitiveContent ?? 'Sensitive Content', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                      Text("HyppePic ${transnot.translate.contentContainsSensitiveMaterial}",
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
                          if (data.music?.musicTitle != null) {
                            fAliplayer?.prepare();
                            fAliplayer?.play();
                          }
                          System().increaseViewCount2(context, data);
                          setState(() {
                            data.reportedStatus = '';
                          });
                          context.read<ReportNotifier>().seeContent(context, data, hyppePic);
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
                            "${transnot.translate.see} HyppePic",
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

  void reloadImage(index) {
    setState(() {
      pics?[index].isLoading = true;
    });
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        pics?[index].isLoading = false;
      });
    });
  }
}

class AllowMultipleScaleRecognizer extends ScaleGestureRecognizer {
  @override
  void rejectGesture(int pointer) {
    acceptGesture(pointer);
  }
}
