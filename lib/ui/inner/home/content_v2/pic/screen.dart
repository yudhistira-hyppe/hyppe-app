import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_aliplayer/flutter_aliplayer.dart';
import 'package:flutter_aliplayer/flutter_aliplayer_factory.dart';
import 'package:hyppe/core/bloc/posts_v2/bloc.dart';
import 'package:hyppe/core/bloc/posts_v2/state.dart';
import 'package:hyppe/core/config/ali_config.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/kyc_status.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/constants/utils.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/services/route_observer_service.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/entities/like/notifier.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/widget/button_boost.dart';
import 'package:hyppe/ui/constant/widget/custom_base_cache_image.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_newdesc_content_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/no_result_found.dart';
import 'package:hyppe/ui/constant/widget/profile_landingpage.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/playlist/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/widget/pic_top_item.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/playlist/comments_detail/screen.dart';
import 'package:hyppe/ui/inner/home/notifier_v2.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/core/services/error_service.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_shimmer.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/notifier.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:pinch_zoom/pinch_zoom.dart';
import '../../../../../ux/path.dart';
import '../../../../constant/entities/report/notifier.dart';

class HyppePreviewPic extends StatefulWidget {
  final ScrollController? scrollController;
  final Function functionZoomTriger;
  const HyppePreviewPic({
    Key? key,
    this.scrollController,
    required this.functionZoomTriger,
  }) : super(key: key);

  @override
  _HyppePreviewPicState createState() => _HyppePreviewPicState();
}

class _HyppePreviewPicState extends State<HyppePreviewPic> with WidgetsBindingObserver, TickerProviderStateMixin, RouteAware {
  FlutterAliplayer? fAliplayer;
  TransformationController _transformationController = TransformationController();

  bool isPrepare = false;
  bool isPlay = false;
  bool isPause = false;
  bool _showLoading = false;
  bool _inSeek = false;
  bool isloading = false;

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
  bool isMute = false;
  String email = '';
  // String statusKyc = '';
  bool isInPage = true;
  bool _scroolEnabled = true;

  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'HyppePreviewPic');
    final notifier = Provider.of<PreviewPicNotifier>(context, listen: false);
    lang = context.read<TranslateNotifierV2>().translate;
    notifier.scrollController.addListener(() => notifier.scrollListener(context));
    email = SharedPreference().readStorage(SpKeys.email);
    // statusKyc = SharedPreference().readStorage(SpKeys.statusVerificationId);
    // stopwatch = new Stopwatch()..start();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      fAliplayer = FlutterAliPlayerFactory.createAliPlayer(playerId: 'aliPic');
      WidgetsBinding.instance.addObserver(this);

      fAliplayer?.setAutoPlay(true);
      fAliplayer?.setLoop(true);

      //Turn on mix mode
      if (Platform.isIOS) {
        FlutterAliplayer.enableMix(true);
      }

      //set player
      fAliplayer?.setPreferPlayerName(GlobalSettings.mPlayerName);
      fAliplayer?.setEnableHardwareDecoder(GlobalSettings.mEnableHardwareDecoder);
      _initListener();
    });

    super.initState();
  }

  _initListener() {
    fAliplayer?.setOnEventReportParams((params, playerId) {
      print("EventReportParams=${params}");
    });
    fAliplayer?.setOnPrepared((playerId) {
      // Fluttertoast.showToast(msg: "OnPrepared ");
      if (SharedPreference().readStorage(SpKeys.isShowPopAds)) {
        isMute = true;
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

    _playMode = ModeTypeAliPLayer.auth;
    // await getAuth(data.music?.apsaraMusic ?? '');
    if (data.reportedStatus != 'BLURRED') {
      _playMode = ModeTypeAliPLayer.auth;
      await getAuth(data.music?.apsaraMusic ?? '');
    }

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
    print("sedang prepare");
    print("sedang prepare $isMute");
    fAliplayer?.prepare();
    if (isMute) {
      fAliplayer?.setMuted(true);
    }
    // fAliplayer?.play();
  }

  Future getAuth(String apsaraId) async {
    setState(() {
      isloading = true;
    });
    try {
      final notifier = PostsBloc();
      await notifier.getAuthApsara(context, apsaraId: apsaraId);
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
      await notifier.getOldVideo(context, apsaraId: postId);
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
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void deactivate() {
    print("====== deactivate ");
    fAliplayer?.stop();
    System().disposeBlock();
    if (context.read<PreviewVidNotifier>().canPlayOpenApps) {
      fAliplayer?.destroy();
    }
    if (Platform.isIOS) {
      FlutterAliplayer.enableMix(false);
    }
    super.deactivate();
  }

  @override
  void didPop() {
    print("====== didpop ");
    super.didPop();
  }

  @override
  void didPopNext() {
    print("======= didPopNext");
    isInPage = true;
    fAliplayer?.play();
    // System().disposeBlock();
    super.didPopNext();
  }

  @override
  void didPush() {
    print("========= didPush");
    super.didPush();
  }

  @override
  void didPushNext() {
    print("========= didPushNext");
    fAliplayer?.pause();
    System().disposeBlock();
    isInPage = false;
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
        print("========= resumed");
        if (context.read<PreviewVidNotifier>().canPlayOpenApps && !SharedPreference().readStorage(SpKeys.isShowPopAds)) {
          fAliplayer?.play();
        }
        break;
      case AppLifecycleState.paused:
        print("========= paused");
        fAliplayer?.pause();
        break;
      case AppLifecycleState.detached:
        print("========= detached");
        break;
    }
  }

  int _currentItem = 0;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final error = context.select((ErrorService value) => value.getError(ErrorType.pic));
    AliPlayerView aliPlayerView = AliPlayerView(onCreated: onViewPlayerCreated, x: 0.0, y: 0.0, width: 100, height: 200);
    return Consumer2<PreviewPicNotifier, HomeNotifier>(
      builder: (_, notifier, home, __) => Container(
        width: SizeConfig.screenWidth,
        height: SizeWidget.barHyppePic,
        // margin: const EdgeInsets.only(top: 16.0, bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: notifier.itemCount == 0
                  ? const NoResultFound()
                  : NotificationListener<OverscrollIndicatorNotification>(
                      onNotification: (overscroll) {
                        overscroll.disallowIndicator();
                        return false;
                      },
                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        controller: widget.scrollController,
                        // scrollDirection: Axis.horizontal,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: false,
                        itemCount: notifier.pic?.length,
                        padding: const EdgeInsets.symmetric(horizontal: 11.5),
                        itemBuilder: (context, index) {
                          if (notifier.pic == null || home.isLoadingPict) {
                            fAliplayer?.pause();
                            _lastCurIndex = -1;
                            return CustomShimmer(
                              width: (MediaQuery.of(context).size.width - 11.5 - 11.5 - 9) / 2,
                              height: 168,
                              radius: 8,
                              margin: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 10),
                              padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
                            );
                          } else if (index == notifier.pic?.length && notifier.hasNext) {
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
            home.isLoadingLoadmore
                ? const SizedBox(
                    height: 50,
                    child: Center(child: CustomLoading()),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  var initialControllerValue;

  Widget itemPict(PreviewPicNotifier notifier, int index) {
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
          // Text("$_lastCurIndex"),
          // Text("$_curIdx"),
          // GestureDetector(
          //   onScaleStart: (details) {
          //     widget.functionZoomTriger();
          //     print("***************** dua jari ***************");
          //     print(details.pointerCount);
          //   },
          //   onScaleEnd: (details) {
          //     print("***************** satu jari ***************");
          //   },

          //   child: Container(
          //     width: 500,
          //     height: 200,
          //     color: Colors.red,
          //   ),
          // ),
          // GestureDetector(
          //   onTap: () {
          //     Routing().move(Routes.testImage);
          //   },
          //   child: Text('hahahah'),
          // ),
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
                  username: notifier.pic?[index].username,
                  featureType: FeatureType.other,
                  // isCelebrity: vidnotifier.pic?[index].privacy?.isCelebrity,
                  isCelebrity: false,
                  imageUrl: '${System().showUserPicture(notifier.pic?[index].avatar?.mediaEndpoint)}',
                  onTapOnProfileImage: () => System().navigateToProfile(context, notifier.pic?[index].email ?? ''),
                  createdAt: '2022-02-02',
                  musicName: notifier.pic?[index].music?.musicTitle ?? '',
                  location: notifier.pic?[index].location ?? '',
                  isIdVerified: notifier.pic?[index].privacy?.isIdVerified,
                ),
              ),
              if (notifier.pic?[index].email != email && (notifier.pic?[index].isNewFollowing ?? false))
                Consumer<PreviewPicNotifier>(
                  builder: (context, picNot, child) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        if (notifier.pic?[index].insight?.isloadingFollow != true) {
                          picNot.followUser(context, notifier.pic?[index] ?? ContentData(),
                              isUnFollow: notifier.pic?[index].following, isloading: notifier.pic?[index].insight!.isloadingFollow ?? false);
                        }
                      },
                      child: notifier.pic?[index].insight?.isloadingFollow ?? false
                          ? Container(
                              height: 40,
                              width: 30,
                              child: Align(
                                alignment: Alignment.bottomRight,
                                child: CustomLoading(),
                              ),
                            )
                          : Text(
                              (notifier.pic?[index].following ?? false) ? (lang?.following ?? '') : (lang?.follow ?? ''),
                              style: TextStyle(color: kHyppePrimary, fontSize: 12, fontWeight: FontWeight.w700, fontFamily: "Lato"),
                            ),
                    ),
                  ),
                ),
              GestureDetector(
                onTap: () {
                  // fAliplayer?.pause();
                  if (notifier.pic?[index].email != email) {
                    context.read<PreviewPicNotifier>().reportContent(context, notifier.pic?[index] ?? ContentData(), fAliplayer: fAliplayer);
                  } else {
                    fAliplayer?.pause();
                    ShowBottomSheet().onShowOptionContent(
                      context,
                      contentData: notifier.pic?[index] ?? ContentData(),
                      captionTitle: hyppePic,
                      onDetail: false,
                      isShare: notifier.pic?[index].isShared,
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
          // Stack(
          //   children: [
          //     Positioned.fill(
          //       child: InteractiveViewer(
          //         child: Image.network(
          //           'https://flutterservice.com/wp-content/uploads/2022/10/3-1.jpg',
          //           height: 300,
          //           width: double.infinity,
          //           fit: BoxFit.cover,
          //         ),
          //       ),
          //     ),
          //   ],
          // ),

          VisibilityDetector(
            key: Key(index.toString()),
            onVisibilityChanged: (info) {
              print("ada musiknya ${info.visibleFraction}");
              if (info.visibleFraction >= 0.6) {
                _curIdx = index;
                if (_lastCurIndex != _curIdx) {
                  if (notifier.pic?[index].music != null) {
                    print("ada musiknya ${notifier.pic?[index].music}");
                    Future.delayed(const Duration(milliseconds: 100), () {
                      start(notifier.pic?[index] ?? ContentData());
                    });
                  } else {
                    fAliplayer?.stop();
                  }
                  Future.delayed(const Duration(milliseconds: 100), () {
                    System().increaseViewCount2(context, notifier.pic?[index] ?? ContentData());
                  });
                  if (notifier.pic?[index].certified ?? false) {
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
                    Center(
                      child: CustomBaseCacheImage(
                        memCacheWidth: 100,
                        memCacheHeight: 100,
                        widthPlaceHolder: 80,
                        heightPlaceHolder: 80,
                        imageUrl: (notifier.pic?[index].isApsara ?? false) ? (notifier.pic?[index].mediaThumbEndPoint ?? "") : "${notifier.pic?[index].fullThumbPath}",
                        imageBuilder: (context, imageProvider) => ClipRRect(
                          borderRadius: BorderRadius.circular(20), // Image border
                          child: notifier.pic?[index].reportedStatus == 'BLURRED'
                              ? ImageFiltered(
                                  imageFilter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                                  child: Image(
                                    image: imageProvider,
                                  ),
                                )
                              : Image(
                                  image: imageProvider,
                                  fit: BoxFit.fitHeight,
                                  width: SizeConfig.screenWidth,
                                ),
                        ),
                        errorWidget: (context, url, error) {
                          return Container(
                            // const EdgeInsets.symmetric(horizontal: 4.5),
                            // height: 500,
                            decoration: BoxDecoration(
                              image: const DecorationImage(
                                image: AssetImage('${AssetPath.pngPath}content-error.png'),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          );
                        },
                        emptyWidget: Container(
                          // const EdgeInsets.symmetric(horizontal: 4.5),

                          // height: 500,
                          decoration: BoxDecoration(
                            image: const DecorationImage(
                              image: AssetImage('${AssetPath.pngPath}content-error.png'),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: () {
                          if (notifier.pic?[index].reportedStatus != 'BLURRED') {
                            fAliplayer?.play();
                            setState(() {
                              isMute = !isMute;
                            });
                            fAliplayer?.setMuted(isMute);
                          }
                        },
                        onDoubleTap: () {
                          final _likeNotifier = context.read<LikeNotifier>();
                          if (notifier.pic?[index] != null) {
                            _likeNotifier.likePost(context, notifier.pic![index]);
                          }
                        },
                        child: Container(
                          color: Colors.transparent,
                          width: SizeConfig.screenWidth,
                          height: SizeConfig.screenHeight,
                          child: PinchZoom(
                            onZoomStart: () {
                              widget.functionZoomTriger();
                            },
                            onZoomEnd: () {
                              widget.functionZoomTriger();
                            },
                            child: CustomBaseCacheImage(
                              memCacheWidth: 100,
                              memCacheHeight: 100,
                              widthPlaceHolder: 80,
                              heightPlaceHolder: 80,
                              imageUrl: (notifier.pic?[index].isApsara ?? false) ? (notifier.pic?[index].mediaThumbEndPoint ?? "") : "${notifier.pic?[index].fullThumbPath}",
                              imageBuilder: (context, imageProvider) => ClipRRect(
                                borderRadius: BorderRadius.circular(20), // Image border
                                child: notifier.pic?[index].reportedStatus == 'BLURRED'
                                    ? ImageFiltered(
                                        imageFilter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                                        child: Image(
                                          image: imageProvider,
                                        ),
                                      )
                                    : Image(
                                        image: imageProvider,
                                        fit: BoxFit.fitHeight,
                                        width: SizeConfig.screenWidth,
                                      ),
                              ),
                              emptyWidget: Container(
                                // const EdgeInsets.symmetric(horizontal: 4.5),

                                // height: 500,
                                decoration: BoxDecoration(
                                  image: const DecorationImage(
                                    image: AssetImage('${AssetPath.pngPath}content-error.png'),
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    _buildBody(context, SizeConfig.screenWidth, notifier.pic?[index] ?? ContentData()),
                    blurContentWidget(context, notifier.pic?[index] ?? ContentData()),
                  ],
                ),
              ),
            ),
          ),
          SharedPreference().readStorage(SpKeys.statusVerificationId) == VERIFIED &&
                  (notifier.pic?[index].boosted.isEmpty ?? [].isEmpty) &&
                  (notifier.pic?[index].reportedStatus != 'OWNED' && notifier.pic?[index].reportedStatus != 'BLURRED' && notifier.pic?[index].reportedStatus2 != 'BLURRED') &&
                  notifier.pic?[index].email == email
              ? Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ButtonBoost(
                    onDetail: false,
                    marginBool: true,
                    contentData: notifier.pic?[index],
                    startState: () {
                      SharedPreference().writeStorage(SpKeys.isShowPopAds, true);
                    },
                    afterState: () {
                      SharedPreference().writeStorage(SpKeys.isShowPopAds, false);
                    },
                  ),
                )
              : Container(),
          if (notifier.pic?[index].email == email && (notifier.pic?[index].boostCount ?? 0) >= 0 && (notifier.pic?[index].boosted.isNotEmpty ?? [].isEmpty))
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
                      textToDisplay: "${notifier.pic?[index].boostJangkauan ?? '0'} ${lang?.reach}",
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
                    Align(
                      alignment: Alignment.bottomRight,
                      child: notifier.pic?[index].insight?.isloading ?? false
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
                                color: (notifier.pic?[index].insight?.isPostLiked ?? false) ? kHyppeRed : kHyppeTextLightPrimary,
                                iconData: '${AssetPath.vectorPath}${(notifier.pic?[index].insight?.isPostLiked ?? false) ? 'liked.svg' : 'none-like.svg'}',
                                height: 28,
                              ),
                              onTap: () {
                                if (notifier.pic?[index] != null) {
                                  likeNotifier.likePost(context, notifier.pic![index]);
                                }
                              },
                            ),
                    ),
                    if (notifier.pic?[index].allowComments ?? true)
                      Padding(
                        padding: EdgeInsets.only(left: 21.0),
                        child: GestureDetector(
                          onTap: () {
                            Routing().move(Routes.commentsDetail, argument: CommentsArgument(postID: notifier.pic?[index].postID ?? '', fromFront: true, data: notifier.pic?[index] ?? ContentData()));
                            // ShowBottomSheet.onShowCommentV2(context, postID: notifier.pic?[index].postID);
                          },
                          child: const CustomIconWidget(
                            defaultColor: false,
                            color: kHyppeTextLightPrimary,
                            iconData: '${AssetPath.vectorPath}comment2.svg',
                            height: 24,
                          ),
                        ),
                      ),
                    if ((notifier.pic?[index].isShared ?? false))
                      GestureDetector(
                        onTap: () {
                          context.read<PicDetailNotifier>().createdDynamicLink(context, data: notifier.pic?[index]);
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
                    if ((notifier.pic?[index].saleAmount ?? 0) > 0 && email != notifier.pic?[index].email)
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            fAliplayer?.pause();
                            await ShowBottomSheet.onBuyContent(context, data: notifier.pic?[index], fAliplayer: fAliplayer);
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
                  "${notifier.pic?[index].insight?.likes}  ${notifier.language.like}",
                  style: const TextStyle(color: kHyppeTextLightPrimary, fontWeight: FontWeight.w700, fontSize: 14),
                ),
              ],
            ),
          ),
          fourPx,
          CustomNewDescContent(
            // desc: "${data?.description}",
            username: notifier.pic?[index].username ?? '',
            desc: "${notifier.pic?[index].description}",
            trimLines: 2,
            textAlign: TextAlign.start,
            seeLess: ' ${lang?.seeLess}', // ${notifier2.translate.seeLess}',
            seeMore: '  ${lang?.seeMoreContent}', //${notifier2.translate.seeMoreContent}',
            normStyle: const TextStyle(fontSize: 12, color: kHyppeTextLightPrimary),
            hrefStyle: Theme.of(context).textTheme.subtitle2?.copyWith(color: kHyppePrimary),
            expandStyle: Theme.of(context).textTheme.subtitle2?.copyWith(color: Theme.of(context).colorScheme.primary),
          ),
          if (notifier.pic?[index].allowComments ?? true)
            GestureDetector(
              onTap: () {
                Routing().move(Routes.commentsDetail, argument: CommentsArgument(postID: notifier.pic?[index].postID ?? '', fromFront: true, data: notifier.pic?[index] ?? ContentData()));
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  "${lang?.seeAll} ${notifier.pic?[index].comments} ${lang?.comment}",
                  style: const TextStyle(fontSize: 12, color: kHyppeBurem),
                ),
              ),
            ),
          (notifier.pic?[index].comment?.length ?? 0) > 0
              ? Padding(
                  padding: const EdgeInsets.only(top: 0.0),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: (notifier.pic?[index].comment?.length ?? 0) >= 2 ? 2 : 1,
                    itemBuilder: (context, indexComment) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6.0),
                        child: CustomNewDescContent(
                          // desc: "${notifier.pic?[index]?.description}",
                          username: notifier.pic?[index].comment?[indexComment].userComment?.username ?? '',
                          desc: notifier.pic?[index].comment?[indexComment].txtMessages ?? '',
                          trimLines: 2,
                          textAlign: TextAlign.start,
                          seeLess: ' seeLess', // ${notifier2.translate.seeLess}',
                          seeMore: '  Selengkapnya ', //${notifier2.translate.seeMoreContent}',
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
                DateTime.parse(System().dateTimeRemoveT(notifier.pic?[index].createdAt ?? DateTime.now().toString())).millisecondsSinceEpoch,
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
          if (data.music != null)
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
                    Text("HyppePic ${transnot.translate.contentContainsSensitiveMaterial}",
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
                        System().increaseViewCount2(context, data);
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
                )),
          )
        : Container();
  }
}
