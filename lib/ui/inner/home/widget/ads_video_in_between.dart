import 'dart:convert';
import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_aliplayer/flutter_aliplayer.dart';
import 'package:flutter_aliplayer/flutter_aliplayer_factory.dart';
import 'package:hyppe/app.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/advertising/ads_video_data.dart';
import 'package:hyppe/ui/constant/widget/custom_desc_content_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/widget/fullscreen/notifier.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../../core/bloc/posts_v2/bloc.dart';
import '../../../../core/bloc/posts_v2/state.dart';
import '../../../../core/config/ali_config.dart';
import '../../../../core/constants/asset_path.dart';
import '../../../../core/constants/themes/hyppe_colors.dart';
import '../../../../core/constants/utils.dart';
import '../../../../core/services/system.dart';
import '../../../../initial/hyppe/translate_v2.dart';
import '../../../constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import '../../../constant/widget/custom_base_cache_image.dart';
import '../../../constant/widget/custom_icon_widget.dart';
import '../../../constant/widget/custom_loading.dart';
import '../../../constant/widget/custom_spacer.dart';
import '../../../constant/widget/custom_text_widget.dart';

class AdsVideoInBetween extends StatefulWidget {
  final Function(VisibilityInfo)? onVisibility;
  final FlutterAliplayer? player;
  final String postID;
  final AdsData data;
  final double ratio;
  const AdsVideoInBetween({
    Key? key,
    this.onVisibility,
    this.player,
    required this.postID,
    required this.ratio,
    required this.data,
  }) : super(key: key);

  @override
  State<AdsVideoInBetween> createState() => _AdsVideoInBetweenState();
}

class _AdsVideoInBetweenState extends State<AdsVideoInBetween>
    with WidgetsBindingObserver {
  // FlutterAliplayer? fAliplayer;

  bool loadLaunch = false;

  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'AdsVideoBetween');

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {});

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final language = context.read<TranslateNotifierV2>().translate;
    return Consumer<VideoNotifier>(builder: (context, notifier, _) {
      return Container(
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
                      CustomBaseCacheImage(
                        imageUrl: widget.data.avatar?.fullLinkURL,
                        memCacheWidth: 200,
                        memCacheHeight: 200,
                        imageBuilder: (_, imageProvider) {
                          return Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(18)),
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: imageProvider,
                              ),
                            ),
                          );
                        },
                        errorWidget: (_, __, ___) {
                          return Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(18)),
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: AssetImage(
                                    '${AssetPath.pngPath}content-error.png'),
                              ),
                            ),
                          );
                        },
                        emptyWidget: Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(18)),
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: AssetImage(
                                  '${AssetPath.pngPath}content-error.png'),
                            ),
                          ),
                        ),
                      ),
                      twelvePx,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomTextWidget(
                              textToDisplay: widget.data.fullName ?? '',
                              textStyle:
                                  context.getTextTheme().bodyText1?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                            ),
                            CustomTextWidget(
                              textToDisplay: language.sponsored ?? 'Sponsored',
                              textStyle:
                                  context.getTextTheme().bodyText2?.copyWith(
                                        fontWeight: FontWeight.w400,
                                      ),
                            )
                          ],
                        ),
                      ),
                      twelvePx,
                      GestureDetector(
                        onTap: () {
                          ShowBottomSheet().onReportContent(
                            context,
                            adsData: widget.data,
                            type: adsPopUp,
                            postData: null,
                            onUpdate: () {
                              setState(() {
                                widget.data.isReport = true;
                              });
                            },
                          );
                        },
                        child: const CustomIconWidget(
                          defaultColor: false,
                          iconData: '${AssetPath.vectorPath}more.svg',
                          color: kHyppeTextLightPrimary,
                        ),
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
                        // Image.asset(
                        //   '${AssetPath.pngPath}avatar_ads_exp.png',
                        //   width: double.infinity,
                        //   fit: BoxFit.cover,
                        // ),
                        VisibilityDetector(
                          key: Key(widget.data.videoId ?? 'ads'),
                          onVisibilityChanged: (info) {
                            if (info.visibleFraction >= 0.6) {
                              // _curIdx = index;
                              if (notifier.currentPostID != widget.postID) {
                                notifier.betweenPlayer?.pause();

                                // if (diaryData[index].certified ?? false) {
                                //   System().block(context);
                                // } else {
                                //   System().disposeBlock();
                                // }
                              }
                              notifier.currentPostID = widget.postID;
                              if (widget.onVisibility != null) {
                                widget.onVisibility!(info);
                              }
                            }
                          },
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: notifier.currentPostID == widget.postID
                                ? InBetweenScreen(
                                    postID: widget.postID,
                                    adsData: widget.data,
                                    player: widget.player,
                                  )
                                : Container(
                                    decoration: const BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(16.0))),
                                    alignment: Alignment.center,
                                    child: const CustomLoading(),
                                  ),
                          ),
                        ),
                        twelvePx,
                        InkWell(
                          onTap: () async {},
                          child: Builder(builder: (context) {
                            final learnMore =
                                (language.learnMore ?? 'Learn More');
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
                        if (widget.data.adsDescription != null)
                          Builder(builder: (context) {
                            final notifier =
                                context.read<TranslateNotifierV2>();
                            return CustomDescContent(
                                desc: widget.data.adsDescription ?? '',
                                trimLines: 2,
                                textAlign: TextAlign.justify,
                                seeLess: ' ${notifier.translate.seeLess}',
                                seeMore:
                                    ' ${notifier.translate.seeMoreContent}',
                                textOverflow: TextOverflow.visible,
                                normStyle:
                                    Theme.of(context).textTheme.bodyText2,
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
      );
    });
  }
}

class InBetweenScreen extends StatefulWidget {
  final String postID;
  final AdsData adsData;
  final FlutterAliplayer? player;
  const InBetweenScreen(
      {Key? key, required this.postID, required this.adsData, this.player})
      : super(key: key);

  @override
  State<InBetweenScreen> createState() => _InBetweenScreenState();
}

class _InBetweenScreenState extends State<InBetweenScreen>
    with WidgetsBindingObserver {
  FlutterAliplayer? fAliplayer;
  bool isPrepare = false;
  bool isPlay = false;
  bool isPause = false;

  int _loadingPercent = 0;
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

  @override
  void initState() {
    _showLoading = true;
    FirebaseCrashlytics.instance.setCustomKey('layout', 'InBetweenScreen');
    // email = SharedPreference().readStorage(SpKeys.email);
    // statusKyc = SharedPreference().readStorage(SpKeys.statusVerificationId);

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // final ref = (Routing.navigatorKey.currentContext ?? context).read<VideoNotifier>();
      fAliplayer =
          FlutterAliPlayerFactory.createAliPlayer(playerId: widget.postID);
      WidgetsBinding.instance.addObserver(this);
      fAliplayer?.pause();
      fAliplayer?.setAutoPlay(true);
      fAliplayer?.setLoop(false);

      //Turn on mix mode
      if (Platform.isIOS) {
        FlutterAliplayer.enableMix(true);
      }

      //set player
      fAliplayer?.setPreferPlayerName(GlobalSettings.mPlayerName);
      fAliplayer
          ?.setEnableHardwareDecoder(GlobalSettings.mEnableHardwareDecoder);
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
      fAliplayer
          ?.getPlayerName()
          .then((value) => print("getPlayerName==${value}"));
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
          if (mounted) {
            setState(() {
              _showLoading = false;
              isPause = false;
            });
          }

          break;
        case FlutterAvpdef.AVPStatus_AVPStatusStopped:
          if (mounted) {
            setState(() {
              _showLoading = false;
            });
          }

          break;
        case FlutterAvpdef.AVPStatus_AVPStatusPaused:
          isPause = true;
          setState(() {});
          break;
        default:
      }
    });
    fAliplayer?.setOnLoadingStatusListener(loadingBegin: (playerId) {
      if (mounted) {
        try {
          setState(() {
            _loadingPercent = 0;
            _showLoading = true;
          });
        } catch (e) {
          print('error setOnLoadingStatusListener: $e');
        }
      }
    }, loadingProgress: (percent, netSpeed, playerId) {
      if (percent == 100) {
        _showLoading = false;
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
            _showLoading = false;
          });
        } else {
          _showLoading = false;
        }
      } catch (e) {
        print('error loadingEnd: $e');
      }
    });
    ;
    fAliplayer?.setOnSeekComplete((playerId) {
      _inSeek = false;
    });
    fAliplayer?.setOnInfo((infoCode, extraValue, extraMsg, playerId) {
      if (infoCode == FlutterAvpdef.CURRENTPOSITION) {
        try {
          if (mounted) {
            setState(() {
              _currentPositionText = extraValue ?? 0;
            });
          } else {
            _currentPositionText = extraValue ?? 0;
          }
        } catch (e) {
          print('error setOnInfo: $e');
        }
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
    fAliplayer?.setOnThumbnailPreparedListener(
        preparedSuccess: (playerId) {}, preparedFail: (playerId) {});

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
    adsGlobalAliPlayer = fAliplayer;
    Future.delayed(const Duration(milliseconds: 700), () {
      start(widget.adsData);
    });
  }

  void start(AdsData data) async {
    // if (notifier.listData != null && (notifier.listData?.length ?? 0) > 0 && _curIdx < (notifier.listData?.length ?? 0)) {

    fAliplayer?.stop();
    widget.player?.stop();

    // isPlay = false;
    // fAliplayer?.setVidAuth(
    //   vid: "c1b24d30b2c671edbfcb542280e90102",
    //   region: DataSourceRelated.defaultRegion,
    //   playAuth:
    //       "eyJTZWN1cml0eVRva2VuIjoiQ0FJU2lBTjFxNkZ0NUIyeWZTaklyNURISnUvWnJvZFIrb1d2VlY2SmdHa0RPdFZjaDZMRG96ejJJSDFLZlhadEJPQWN0ZlF3bFdwVDdQNGJsckl1RjhJWkdoR2ZONU10dE1RUHJGL3dKb0hidk5ldTBic0hoWnY5bGNNTHJaaWpqcUhvZU96Y1lJNzMwWjdQQWdtMlEwWVJySkwrY1RLOUphYk1VL21nZ29KbWFkSTZSeFN4YVNFOGF2NWRPZ3BscnIwSVZ4elBNdnIvSFJQMnVtN1pIV3R1dEEwZTgzMTQ1ZmFRejlHaTZ4YlRpM2I5ek9FVXFPYVhKNFMvUGZGb05ZWnlTZjZvd093VUVxL2R5M3hvN3hGYjFhRjRpODRpL0N2YzdQMlFDRU5BK3dtbFB2dTJpOE5vSUYxV2E3UVdJWXRncmZQeGsrWjEySmJOa0lpbDVCdFJFZHR3ZUNuRldLR216c3krYjRIUEROc2ljcXZoTUhuZ3k4MkdNb0tQMHprcGVuVUdMZ2hIQ2JGRFF6MVNjVUZ3RjIyRmQvVDlvQTJRTWwvK0YvbS92ZnRvZ2NvbC9UTEI1c0dYSWxXRGViS2QzQnNETjRVMEIwRlNiRU5JaERPOEwvOWNLRndUSWdrOFhlN01WL2xhYUJGUHRLWFdtaUgrV3lOcDAzVkxoZnI2YXVOcGJnUHIxVVFwTlJxQUFaT3kybE5GdndoVlFObjZmbmhsWFpsWVA0V3paN24wTnVCbjlILzdWZHJMOGR5dHhEdCtZWEtKNWI4SVh2c0lGdGw1cmFCQkF3ZC9kakhYTjJqZkZNVFJTekc0T3pMS1dKWXVzTXQycXcwMSt4SmNHeE9iMGtKZjRTcnFpQ1RLWVR6UHhwakg0eDhvQTV6Z0cvZjVIQ3lFV3pISmdDYjhEeW9EM3NwRUh4RGciLCJBdXRoSW5mbyI6IntcIkNJXCI6XCJmOUc0eExxaHg2Tkk3YThaY1Q2N3hObmYrNlhsM05abmJXR1VjRmxTelljS0VKVTN1aVRjQ29Hd3BrcitqL2phVVRXclB2L2xxdCs3MEkrQTJkb3prd0IvKzc5ZlFyT2dLUzN4VmtFWUt6TT1cIixcIkNhbGxlclwiOlwiV2NKTEpvUWJHOXR5UmM2ZXg3LzNpQXlEcS9ya3NvSldhcXJvTnlhTWs0Yz1cIixcIkV4cGlyZVRpbWVcIjpcIjIwMjMtMDMtMTZUMDk6NDE6MzdaXCIsXCJNZWRpYUlkXCI6XCJjMWIyNGQzMGIyYzY3MWVkYmZjYjU0MjI4MGU5MDEwMlwiLFwiUGxheURvbWFpblwiOlwidm9kLmh5cHBlLmNsb3VkXCIsXCJTaWduYXR1cmVcIjpcIk9pbHhxelNyaVVhOGlRZFhaVEVZZEJpbUhJUT1cIn0iLCJWaWRlb01ldGEiOnsiU3RhdHVzIjoiTm9ybWFsIiwiVmlkZW9JZCI6ImMxYjI0ZDMwYjJjNjcxZWRiZmNiNTQyMjgwZTkwMTAyIiwiVGl0bGUiOiIyODg4MTdkYi1jNzdjLWM0ZTQtNjdmYi0zYjk1MTlmNTc0ZWIiLCJDb3ZlclVSTCI6Imh0dHBzOi8vdm9kLmh5cHBlLmNsb3VkL2MxYjI0ZDMwYjJjNjcxZWRiZmNiNTQyMjgwZTkwMTAyL3NuYXBzaG90cy9jYzM0MjVkNzJiYjM0YTE3OWU5NmMzZTA3NTViZjJjNi0wMDAwNC5qcGciLCJEdXJhdGlvbiI6NTkuMDQ5fSwiQWNjZXNzS2V5SWQiOiJTVFMuTlNybVVtQ1hwTUdEV3g4ZGlWNlpwaGdoQSIsIlBsYXlEb21haW4iOiJ2b2QuaHlwcGUuY2xvdWQiLCJBY2Nlc3NLZXlTZWNyZXQiOiIzU1NRUkdkOThGMU04TkZ0b00xa2NlU01IZlRLNkJvZm93VXlnS1Y5aEpQdyIsIlJlZ2lvbiI6ImFwLXNvdXRoZWFzdC01IiwiQ3VzdG9tZXJJZCI6NTQ1NDc1MzIwNTI4MDU0OX0=",
    // );
    await getAuth(data.videoId ?? '476cf7a01e7371ee9612442380ea0102');

    setState(() {
      isPause = false;
      // _isFirstRenderShow = false;
    });

    fAliplayer?.prepare();

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
          definitionList: [DataSourceRelated.definitionList],
        );
        setState(() {
          isloading = false;
        });
        // widget.videoData?.fullContentPath = jsonMap['PlayUrl'];
      }
    } catch (e) {
      setState(() {
        isloading = false;
        _showLoading = false;
      });
      // 'Failed to fetch ads data $e'.logger();
    }
  }

  void onViewPlayerCreated(viewId) async {
    fAliplayer?.setPlayerView(viewId);
  }

  @override
  void dispose() {
    fAliplayer?.stop();
    fAliplayer?.destroy();
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    adsGlobalAliPlayer = null;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(16.0)),
            child: AliPlayerView(
              onCreated: onViewPlayerCreated,
              x: 0,
              y: 0,
              height: 600,
              width: 600,
              aliPlayerViewType: AliPlayerViewTypeForAndroid.surfaceview,
            ),
          ),
        ),
        if (_showLoading)
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    backgroundColor: Colors.white,
                    strokeWidth: 3.0,
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    "$_loadingPercent%",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        Positioned(
          top: 12,
          right: 12,
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.black.withOpacity(0.5)),
            child: Text(
              System.getTimeformatByMs(_currentPositionText),
              style: const TextStyle(color: Colors.white, fontSize: 11),
            ),
          ),
        ),
        Positioned(
          bottom: 12,
          right: 12,
          child: GestureDetector(
            onTap: () {
              setState(() {
                isMute = !isMute;
              });
              fAliplayer?.setMuted(isMute);
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 2.0),
              child: CustomIconWidget(
                iconData: isMute
                    ? '${AssetPath.vectorPath}sound-off.svg'
                    : '${AssetPath.vectorPath}sound-on.svg',
                defaultColor: false,
                height: 24,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
