import 'dart:convert';
import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_aliplayer/flutter_aliplayer.dart';
import 'package:flutter_aliplayer/flutter_aliplayer_factory.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/advertising/ads_video_data.dart';
import 'package:hyppe/ui/constant/widget/custom_desc_content_widget.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../../core/bloc/posts_v2/bloc.dart';
import '../../../../core/bloc/posts_v2/state.dart';
import '../../../../core/config/ali_config.dart';
import '../../../../core/constants/asset_path.dart';
import '../../../../core/constants/shared_preference_keys.dart';
import '../../../../core/constants/themes/hyppe_colors.dart';
import '../../../../core/models/collection/posts/content_v2/content_data.dart';
import '../../../../core/services/shared_preference.dart';
import '../../../../core/services/system.dart';
import '../../../../initial/hyppe/translate_v2.dart';
import '../../../constant/widget/custom_icon_widget.dart';
import '../../../constant/widget/custom_loading.dart';
import '../../../constant/widget/custom_spacer.dart';
import '../../../constant/widget/custom_text_widget.dart';

class AdsVideoInBetween extends StatefulWidget {
  final Function(VisibilityInfo) onVisibility;
  final FlutterAliplayer? player;
  final AdsData? data;
  final double ratio;
  const AdsVideoInBetween(
      {Key? key,
      required this.onVisibility,
      this.player,
      required this.ratio,
      this.data})
      : super(key: key);

  @override
  State<AdsVideoInBetween> createState() => _AdsVideoInBetweenState();
}

class _AdsVideoInBetweenState extends State<AdsVideoInBetween> with WidgetsBindingObserver {
  FlutterAliplayer? fAliplayer;
  bool isPrepare = false;
  bool isPlay = false;
  bool isPause = false;
  bool _showLoading = false;
  bool _inSeek = false;
  bool isloading = false;
  bool isMute = false;
  bool toComment = false;

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
  String email = '';
  String statusKyc = '';
  bool loadLaunch = false;

  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'AdsVideoBetween');
    email = SharedPreference().readStorage(SpKeys.email);
    statusKyc = SharedPreference().readStorage(SpKeys.statusVerificationId);
    // stopwatch = new Stopwatch()..start();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      fAliplayer = FlutterAliPlayerFactory.createAliPlayer();
      WidgetsBinding.instance.addObserver(this);
      fAliplayer?.pause();
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
          _showLoading = false;
        });
      });
      isPlay = true;
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
    // fAliplayer?.setOnLoadingStatusListener(loadingBegin: (playerId) {
    //   setState(() {
    //     _loadingPercent = 0;
    //     _showLoading = true;
    //   });
    // }, loadingProgress: (percent, netSpeed, playerId) {
    //   _loadingPercent = percent;
    //   if (percent == 100) {
    //     _showLoading = false;
    //   }
    //   setState(() {});
    // }, loadingEnd: (playerId) {
    //   setState(() {
    //     _showLoading = false;
    //   });
    // });
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
    widget.player?.stop();

    isPlay = false;
    // fAliplayer?.setVidAuth(
    //   vid: "c1b24d30b2c671edbfcb542280e90102",
    //   region: DataSourceRelated.defaultRegion,
    //   playAuth:
    //       "eyJTZWN1cml0eVRva2VuIjoiQ0FJU2lBTjFxNkZ0NUIyeWZTaklyNURISnUvWnJvZFIrb1d2VlY2SmdHa0RPdFZjaDZMRG96ejJJSDFLZlhadEJPQWN0ZlF3bFdwVDdQNGJsckl1RjhJWkdoR2ZONU10dE1RUHJGL3dKb0hidk5ldTBic0hoWnY5bGNNTHJaaWpqcUhvZU96Y1lJNzMwWjdQQWdtMlEwWVJySkwrY1RLOUphYk1VL21nZ29KbWFkSTZSeFN4YVNFOGF2NWRPZ3BscnIwSVZ4elBNdnIvSFJQMnVtN1pIV3R1dEEwZTgzMTQ1ZmFRejlHaTZ4YlRpM2I5ek9FVXFPYVhKNFMvUGZGb05ZWnlTZjZvd093VUVxL2R5M3hvN3hGYjFhRjRpODRpL0N2YzdQMlFDRU5BK3dtbFB2dTJpOE5vSUYxV2E3UVdJWXRncmZQeGsrWjEySmJOa0lpbDVCdFJFZHR3ZUNuRldLR216c3krYjRIUEROc2ljcXZoTUhuZ3k4MkdNb0tQMHprcGVuVUdMZ2hIQ2JGRFF6MVNjVUZ3RjIyRmQvVDlvQTJRTWwvK0YvbS92ZnRvZ2NvbC9UTEI1c0dYSWxXRGViS2QzQnNETjRVMEIwRlNiRU5JaERPOEwvOWNLRndUSWdrOFhlN01WL2xhYUJGUHRLWFdtaUgrV3lOcDAzVkxoZnI2YXVOcGJnUHIxVVFwTlJxQUFaT3kybE5GdndoVlFObjZmbmhsWFpsWVA0V3paN24wTnVCbjlILzdWZHJMOGR5dHhEdCtZWEtKNWI4SVh2c0lGdGw1cmFCQkF3ZC9kakhYTjJqZkZNVFJTekc0T3pMS1dKWXVzTXQycXcwMSt4SmNHeE9iMGtKZjRTcnFpQ1RLWVR6UHhwakg0eDhvQTV6Z0cvZjVIQ3lFV3pISmdDYjhEeW9EM3NwRUh4RGciLCJBdXRoSW5mbyI6IntcIkNJXCI6XCJmOUc0eExxaHg2Tkk3YThaY1Q2N3hObmYrNlhsM05abmJXR1VjRmxTelljS0VKVTN1aVRjQ29Hd3BrcitqL2phVVRXclB2L2xxdCs3MEkrQTJkb3prd0IvKzc5ZlFyT2dLUzN4VmtFWUt6TT1cIixcIkNhbGxlclwiOlwiV2NKTEpvUWJHOXR5UmM2ZXg3LzNpQXlEcS9ya3NvSldhcXJvTnlhTWs0Yz1cIixcIkV4cGlyZVRpbWVcIjpcIjIwMjMtMDMtMTZUMDk6NDE6MzdaXCIsXCJNZWRpYUlkXCI6XCJjMWIyNGQzMGIyYzY3MWVkYmZjYjU0MjI4MGU5MDEwMlwiLFwiUGxheURvbWFpblwiOlwidm9kLmh5cHBlLmNsb3VkXCIsXCJTaWduYXR1cmVcIjpcIk9pbHhxelNyaVVhOGlRZFhaVEVZZEJpbUhJUT1cIn0iLCJWaWRlb01ldGEiOnsiU3RhdHVzIjoiTm9ybWFsIiwiVmlkZW9JZCI6ImMxYjI0ZDMwYjJjNjcxZWRiZmNiNTQyMjgwZTkwMTAyIiwiVGl0bGUiOiIyODg4MTdkYi1jNzdjLWM0ZTQtNjdmYi0zYjk1MTlmNTc0ZWIiLCJDb3ZlclVSTCI6Imh0dHBzOi8vdm9kLmh5cHBlLmNsb3VkL2MxYjI0ZDMwYjJjNjcxZWRiZmNiNTQyMjgwZTkwMTAyL3NuYXBzaG90cy9jYzM0MjVkNzJiYjM0YTE3OWU5NmMzZTA3NTViZjJjNi0wMDAwNC5qcGciLCJEdXJhdGlvbiI6NTkuMDQ5fSwiQWNjZXNzS2V5SWQiOiJTVFMuTlNybVVtQ1hwTUdEV3g4ZGlWNlpwaGdoQSIsIlBsYXlEb21haW4iOiJ2b2QuaHlwcGUuY2xvdWQiLCJBY2Nlc3NLZXlTZWNyZXQiOiIzU1NRUkdkOThGMU04TkZ0b00xa2NlU01IZlRLNkJvZm93VXlnS1Y5aEpQdyIsIlJlZ2lvbiI6ImFwLXNvdXRoZWFzdC01IiwiQ3VzdG9tZXJJZCI6NTQ1NDc1MzIwNTI4MDU0OX0=",
    // );
    if (data.reportedStatus != 'BLURRED') {
      await getAuth(data.apsaraId ?? '');
    }

    setState(() {
      isPause = false;
      // _isFirstRenderShow = false;
    });
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
    if (data.reportedStatus == 'BLURRED') {
    } else {
      fAliplayer?.prepare();
    }

    // fAliplayer?.play();
  }

  Future getAuth(String apsaraId) async {
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

  void onViewPlayerCreated(viewId) async {
    fAliplayer?.setPlayerView(viewId);
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(widget.data?.videoId ?? 'ads'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction >= 0.6) {
          // _curIdx = index;
          if (_lastCurIndex != _curIdx) {

            Future.delayed(const Duration(milliseconds: 400), () {
              // start(diaryData[index]);
            });
            // if (diaryData[index].certified ?? false) {
            //   System().block(context);
            // } else {
            //   System().disposeBlock();
            // }
          }
          _lastCurIndex = _curIdx;
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  Row(
                    children: [
                      AspectRatio(
                        aspectRatio: widget.ratio,
                        child: ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(16.0)),
                          child: AliPlayerView(
                            onCreated: onViewPlayerCreated,
                            x: 0,
                            y: 0,
                            height:
                                MediaQuery.of(context).size.width * widget.ratio,
                            width: MediaQuery.of(context).size.width,
                          ),
                        ),
                      ),
                      twelvePx,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomTextWidget(
                              textToDisplay: 'nike.offical',
                              textStyle:
                                  context.getTextTheme().bodyText1?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                            ),
                            CustomTextWidget(
                              textToDisplay: 'Bersponsor',
                              textStyle:
                                  context.getTextTheme().bodyText2?.copyWith(
                                        fontWeight: FontWeight.w400,
                                      ),
                            )
                          ],
                        ),
                      ),
                      twelvePx,
                      const CustomIconWidget(
                        defaultColor: false,
                        iconData: '${AssetPath.vectorPath}more.svg',
                        color: kHyppeTextLightPrimary,
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.only(top: 20, left: 18, right: 18),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          '${AssetPath.pngPath}avatar_ads_exp.png',
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        twelvePx,
                        InkWell(
                          onTap: () async {},
                          child: Builder(builder: (context) {
                            final notifier =
                                context.read<TranslateNotifierV2>();
                            final learnMore =
                                (notifier.translate.learnMore ?? 'Learn More');
                            return Container(
                              alignment: Alignment.center,
                              padding:
                                  const EdgeInsets.only(top: 10, bottom: 10),
                              decoration: const BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5)),
                                  color: KHyppeButtonAds),
                              child: loadLaunch
                                  ? const SizedBox(
                                      width: 40,
                                      height: 20,
                                      child: CustomLoading())
                                  : Text(
                                      learnMore,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            );
                          }),
                        ),
                        twelvePx,
                        Builder(builder: (context) {
                          final notifier = context.read<TranslateNotifierV2>();
                          return CustomDescContent(
                              desc:
                                  'Embrace the iconic Swoosh logo and make a statement wherever you go. Choose Nike, choose excellence. Shop now and step up your shoe game with Nike.',
                              trimLines: 2,
                              textAlign: TextAlign.justify,
                              seeLess: ' ${notifier.translate.seeLess}',
                              seeMore: ' ${notifier.translate.seeMoreContent}',
                              textOverflow: TextOverflow.visible,
                              normStyle: Theme.of(context).textTheme.bodyText2,
                              hrefStyle: Theme.of(context)
                                  .textTheme
                                  .bodyText2
                                  ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                              expandStyle: Theme.of(context)
                                  .textTheme
                                  .bodyText2
                                  ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary));
                        })
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
