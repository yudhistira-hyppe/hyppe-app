import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_aliplayer/flutter_aliplayer.dart';
import 'package:flutter_aliplayer/flutter_aliplayer_factory.dart';
import 'package:hyppe/core/bloc/posts_v2/bloc.dart';
import 'package:hyppe/core/bloc/posts_v2/state.dart';
import 'package:hyppe/core/config/ali_config.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/constants/utils.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/entities/like/notifier.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/widget/custom_base_cache_image.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_newdesc_content_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/no_result_found.dart';
import 'package:hyppe/ui/constant/widget/profile_landingpage.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/preview/notifier.dart';
import 'package:hyppe/ui/inner/home/notifier_v2.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/core/services/error_service.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_shimmer.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/notifier.dart';
import 'package:visibility_detector/visibility_detector.dart';

class LandingDiaryPage extends StatefulWidget {
  const LandingDiaryPage({Key? key}) : super(key: key);

  @override
  _LandingDiaryPageState createState() => _LandingDiaryPageState();
}

class _LandingDiaryPageState extends State<LandingDiaryPage> with WidgetsBindingObserver, TickerProviderStateMixin {
  FlutterAliplayer? fAliplayer;
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

  @override
  void initState() {
    final notifier = Provider.of<PreviewPicNotifier>(context, listen: false);
    lang = context.read<TranslateNotifierV2>().translate;
    notifier.scrollController.addListener(() => notifier.scrollListener(context));
    // stopwatch = new Stopwatch()..start();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      fAliplayer = FlutterAliPlayerFactory.createAliPlayer();

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
    if (data.isApsara ?? false) {
      _playMode = ModeTypeAliPLayer.auth;
      await getAuth(data.apsaraId ?? '');
    } else {
      _playMode = ModeTypeAliPLayer.url;
      await getOldVideoUrl(data.postID ?? '');
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
    fAliplayer?.prepare();
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
  void dispose() {
    if (Platform.isIOS) {
      FlutterAliplayer.enableMix(false);
    }
    fAliplayer?.stop();
    fAliplayer?.destroy();

    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.resumed:
        fAliplayer?.play();
        break;
      case AppLifecycleState.paused:
        fAliplayer?.pause();
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  int _currentItem = 0;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final error = context.select((ErrorService value) => value.getError(ErrorType.pic));
    AliPlayerView aliPlayerView = AliPlayerView(onCreated: onViewPlayerCreated, x: 0.0, y: 0.0, width: 100, height: 200);
    return Consumer2<PreviewDiaryNotifier, HomeNotifier>(
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
                  : NotificationListener<ScrollNotification>(
                      onNotification: (ScrollNotification scrollInfo) {
                        if (scrollInfo is ScrollStartNotification) {
                          Future.delayed(const Duration(milliseconds: 100), () {
                            'initialPic : 5'.logger();
                          });
                        }
                        return true;
                      },
                      child: NotificationListener<OverscrollIndicatorNotification>(
                        onNotification: (overscroll) {
                          overscroll.disallowIndicator();
                          return false;
                        },
                        child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          // controller: notifier.scrollController,
                          // scrollDirection: Axis.horizontal,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: false,
                          itemCount: notifier.diaryData?.length,
                          padding: const EdgeInsets.symmetric(horizontal: 11.5),
                          itemBuilder: (context, index) {
                            if (notifier.diaryData == null || home.isLoadingPict) {
                              return CustomShimmer(
                                width: (MediaQuery.of(context).size.width - 11.5 - 11.5 - 9) / 2,
                                height: 168,
                                radius: 8,
                                margin: const EdgeInsets.symmetric(horizontal: 4.5),
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
                                          username: notifier.diaryData?[index].username,
                                          featureType: FeatureType.other,
                                          // isCelebrity: vidnotifier.diaryData?[index].privacy?.isCelebrity,
                                          isCelebrity: false,
                                          imageUrl: '${System().showUserPicture(notifier.diaryData?[index].avatar?.mediaEndpoint)}',
                                          onTapOnProfileImage: () => System().navigateToProfile(context, notifier.diaryData?[index].email ?? '', isReplaced: false),
                                          createdAt: '2022-02-02',
                                          musicName: notifier.diaryData?[index].music?.musicTitle ?? '',
                                          location: notifier.diaryData?[index].location ?? '',
                                        ),
                                      ),
                                      Consumer<PreviewPicNotifier>(
                                        builder: (context, picNot, child) => Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                          child: GestureDetector(
                                            onTap: () {
                                              if (notifier.diaryData?[index].insight?.isloadingFollow != true) {
                                                picNot.followUser(context, notifier.diaryData?[index] ?? ContentData(),
                                                    isUnFollow: notifier.diaryData?[index].following, isloading: notifier.diaryData?[index].insight!.isloadingFollow ?? false);
                                              }
                                            },
                                            child: notifier.diaryData?[index].insight?.isloadingFollow ?? false
                                                ? Container(
                                                    height: 40,
                                                    width: 30,
                                                    child: Align(
                                                      alignment: Alignment.bottomRight,
                                                      child: CustomLoading(),
                                                    ),
                                                  )
                                                : Text(
                                                    (notifier.diaryData?[index].following ?? false) ? (lang?.following ?? '') : (lang?.follow ?? ''),
                                                    style: TextStyle(color: kHyppePrimary, fontSize: 12, fontWeight: FontWeight.w700, fontFamily: "Lato"),
                                                  ),
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          if (notifier.diaryData?[index].email != SharedPreference().readStorage(SpKeys.email)) {
                                            context.read<PreviewPicNotifier>().reportContent(context, notifier.diaryData?[index] ?? ContentData());
                                          } else {
                                            ShowBottomSheet().onShowOptionContent(
                                              context,
                                              contentData: notifier.diaryData?[index] ?? ContentData(),
                                              captionTitle: hyppeDiary,
                                              onDetail: false,
                                              isShare: notifier.diaryData?[index].isShared,
                                              onUpdate: () => context.read<HomeNotifier>().onUpdate(),
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
                                      print(info.visibleFraction);
                                      if (info.visibleFraction == 1) {
                                        _curIdx = index;
                                        print('ini cur $_curIdx');
                                        if (_lastCurIndex != _curIdx) {
                                          print('ini cur222 $_curIdx');
                                          Future.delayed(const Duration(milliseconds: 400), () {
                                            start(notifier.diaryData?[index] ?? ContentData());
                                          });
                                        }
                                        _lastCurIndex = _curIdx;
                                      }
                                    },
                                    child: Container(
                                      margin: EdgeInsets.only(bottom: 20),
                                      width: MediaQuery.of(context).size.width,
                                      height: 500,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(30),
                                          color: Colors.yellow,
                                        ),
                                        child: Stack(
                                          children: [
                                            isloading
                                                ? CustomLoading()
                                                : _curIdx == index
                                                    ? ClipRRect(
                                                        borderRadius: const BorderRadius.all(Radius.circular(16.0)),
                                                        child: AliPlayerView(
                                                          onCreated: onViewPlayerCreated,
                                                          x: 0,
                                                          y: 0,
                                                          height: MediaQuery.of(context).size.width * 9.0 / 16.0,
                                                          width: MediaQuery.of(context).size.width,
                                                        ),
                                                      )
                                                    : Container(),
                                            _buildProgressBar(SizeConfig.screenWidth!, 500),
                                            dataSelected?.postID == notifier.diaryData?[index].postID && isPlay
                                                ? Container()
                                                : CustomBaseCacheImage(
                                                    memCacheWidth: 100,
                                                    memCacheHeight: 100,
                                                    widthPlaceHolder: 80,
                                                    heightPlaceHolder: 80,
                                                    imageUrl: (notifier.diaryData?[index].isApsara ?? false)
                                                        ? (notifier.diaryData?[index].mediaThumbEndPoint ?? "")
                                                        : "${notifier.diaryData?[index].fullThumbPath}",
                                                    imageBuilder: (context, imageProvider) => Container(
                                                      // const EdgeInsets.symmetric(horizontal: 4.5),
                                                      width: SizeConfig.screenWidth,
                                                      height: 500,
                                                      decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                          image: imageProvider,
                                                          fit: BoxFit.cover,
                                                        ),
                                                        borderRadius: BorderRadius.circular(16.0),
                                                      ),
                                                    ),
                                                    errorWidget: (context, url, error) {
                                                      return Container(
                                                        // const EdgeInsets.symmetric(horizontal: 4.5),
                                                        height: 500,
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

                                                      height: 500,
                                                      decoration: BoxDecoration(
                                                        image: const DecorationImage(
                                                          image: AssetImage('${AssetPath.pngPath}content-error.png'),
                                                          fit: BoxFit.cover,
                                                        ),
                                                        borderRadius: BorderRadius.circular(8.0),
                                                      ),
                                                    ),
                                                  ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Consumer<LikeNotifier>(
                                        builder: (context, likeNotifier, child) => Align(
                                          alignment: Alignment.bottomRight,
                                          child: notifier.diaryData?[index].insight?.isloading ?? false
                                              ? const SizedBox(
                                                  height: 10,
                                                  width: 10,
                                                  child: CircularProgressIndicator(
                                                    color: kHyppePrimary,
                                                    strokeWidth: 2,
                                                  ),
                                                )
                                              : InkWell(
                                                  child: CustomIconWidget(
                                                    defaultColor: false,
                                                    color: (notifier.diaryData?[index].insight?.isPostLiked ?? false) ? kHyppeRed : kHyppeTextLightPrimary,
                                                    iconData: '${AssetPath.vectorPath}${(notifier.diaryData?[index].insight?.isPostLiked ?? false) ? 'liked.svg' : 'none-like.svg'}',
                                                    height: 18,
                                                  ),
                                                  onTap: () {
                                                    if (notifier.diaryData?[index] != null) {
                                                      likeNotifier.likePost(context, notifier.diaryData![index]);
                                                    }
                                                  },
                                                ),
                                        ),
                                      ),
                                      if (notifier.diaryData?[index].allowComments ?? true)
                                        Padding(
                                          padding: EdgeInsets.only(left: 21.0),
                                          child: GestureDetector(
                                            onTap: () {
                                              ShowBottomSheet.onShowCommentV2(context, postID: notifier.diaryData?[index].postID);
                                            },
                                            child: const CustomIconWidget(
                                              defaultColor: false,
                                              color: kHyppeTextLightPrimary,
                                              iconData: '${AssetPath.vectorPath}comment2.svg',
                                              height: 18,
                                            ),
                                          ),
                                        ),
                                      const Padding(
                                        padding: EdgeInsets.only(left: 21.0),
                                        child: CustomIconWidget(
                                          defaultColor: false,
                                          color: kHyppeTextLightPrimary,
                                          iconData: '${AssetPath.vectorPath}share2.svg',
                                          height: 18,
                                        ),
                                      ),
                                      const Expanded(
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: CustomIconWidget(
                                            defaultColor: false,
                                            color: kHyppeTextLightPrimary,
                                            iconData: '${AssetPath.vectorPath}cart.svg',
                                            height: 18,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  twelvePx,
                                  CustomNewDescContent(
                                    // desc: "${data?.description}",
                                    username: notifier.diaryData?[index].username ?? '',
                                    desc: "${notifier.diaryData?[index].description}",
                                    trimLines: 2,
                                    textAlign: TextAlign.start,
                                    seeLess: ' ${lang?.seeLess}', // ${notifier2.translate.seeLess}',
                                    seeMore: '  ${lang?.seeMoreContent}', //${notifier2.translate.seeMoreContent}',
                                    normStyle: const TextStyle(fontSize: 12, color: kHyppeTextLightPrimary),
                                    hrefStyle: Theme.of(context).textTheme.subtitle2?.copyWith(color: kHyppePrimary),
                                    expandStyle: Theme.of(context).textTheme.subtitle2?.copyWith(color: Theme.of(context).colorScheme.primary),
                                  ),
                                  (notifier.diaryData?[index].comment?.length ?? 0) > 2
                                      ? Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                                          child: Text(
                                            "Lihat semua ${notifier.diaryData?[index].comment?.length} komentar",
                                            style: const TextStyle(fontSize: 12, color: kHyppeBurem),
                                          ),
                                        )
                                      : Container(),
                                  (notifier.diaryData?[index].comment?.length ?? 0) > 0
                                      ? Padding(
                                          padding: const EdgeInsets.only(top: 6.0),
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            physics: const NeverScrollableScrollPhysics(),
                                            itemCount: (notifier.diaryData?[index].comment?.length ?? 0) >= 2 ? 2 : 1,
                                            itemBuilder: (context, indexComment) {
                                              return CustomNewDescContent(
                                                // desc: "${notifier.diaryData?[index]?.description}",
                                                username: notifier.diaryData?[index].comment?[indexComment].userComment?.username ?? '',
                                                desc: notifier.diaryData?[index].comment?[indexComment].txtMessages ?? '',
                                                trimLines: 2,
                                                textAlign: TextAlign.start,
                                                seeLess: ' seeLess', // ${notifier2.translate.seeLess}',
                                                seeMore: '  Selengkapnya ', //${notifier2.translate.seeMoreContent}',
                                                normStyle: const TextStyle(fontSize: 12, color: kHyppeTextLightPrimary),
                                                hrefStyle: Theme.of(context).textTheme.subtitle2?.copyWith(color: kHyppePrimary),
                                                expandStyle: Theme.of(context).textTheme.subtitle2?.copyWith(color: Theme.of(context).colorScheme.primary),
                                              );
                                            },
                                          ),
                                        )
                                      : Container(),
                                  Padding(
                                    padding: EdgeInsets.symmetric(vertical: 4.0),
                                    child: Text(
                                      "${System().readTimestamp(
                                        DateTime.parse(System().dateTimeRemoveT(notifier.diaryData?[index].createdAt ?? DateTime.now().toString())).millisecondsSinceEpoch,
                                        context,
                                        fullCaption: true,
                                      )}",
                                      style: TextStyle(fontSize: 12, color: kHyppeBurem),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
            )
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
}