import 'dart:convert';
import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_aliplayer/flutter_aliplayer.dart';
import 'package:flutter_aliplayer/flutter_aliplayer_factory.dart';
import 'package:hyppe/app.dart';
import 'package:hyppe/core/arguments/ads_argument.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/advertising/ads_video_data.dart';
import 'package:hyppe/ui/constant/widget/custom_desc_content_widget.dart';
import 'package:hyppe/ui/constant/widget/profile_component.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/widget/fullscreen/notifier.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../../core/arguments/other_profile_argument.dart';
import '../../../../core/bloc/posts_v2/bloc.dart';
import '../../../../core/bloc/posts_v2/state.dart';
import '../../../../core/config/ali_config.dart';
import '../../../../core/constants/asset_path.dart';
import '../../../../core/constants/themes/hyppe_colors.dart';
import '../../../../core/constants/utils.dart';
import '../../../../core/services/system.dart';
import '../../../../initial/hyppe/translate_v2.dart';
import '../../../../ux/path.dart';
import '../../../../ux/routing.dart';
import '../../../constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import '../../../constant/widget/custom_base_cache_image.dart';
import '../../../constant/widget/custom_icon_widget.dart';
import '../../../constant/widget/custom_loading.dart';
import '../../../constant/widget/custom_spacer.dart';
import '../../../constant/widget/custom_text_widget.dart';

class AdsVideoInBetweenFull extends StatefulWidget {
  final AdsArgument arguments;

  const AdsVideoInBetweenFull({Key? key, required this.arguments}) : super(key: key);

  @override
  State<AdsVideoInBetweenFull> createState() => _AdsVideoInBetweenFullState();
}

class _AdsVideoInBetweenFullState extends State<AdsVideoInBetweenFull> with WidgetsBindingObserver {
  // FlutterAliplayer? fAliplayer;

  bool loadLaunch = false;
  bool isShowMore = false;

  double ratio = 16 / 9;

  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'AdsVideoBetween');

    var data = widget.arguments.data;
    ratio = data.heightPortrait != null && data.widthPortrait != null ? data.widthPortrait! / data.heightPortrait! : 16 / 9;

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {});

    globalAdsInContent?.pause();
  }

  @override
  Widget build(BuildContext context) {
    final language = context.read<TranslateNotifierV2>().translate;
    AdsData data = widget.arguments.data;
    return Consumer<VideoNotifier>(builder: (context, notifier, _) {
      return Stack(
        children: [
          Positioned.fill(
            child: VisibilityDetector(
              key: Key(data.videoId ?? 'ads'),
              onVisibilityChanged: (info) {
                if (widget.arguments.onVisibility != null) {
                  widget.arguments.onVisibility!(info);
                }
                if (info.visibleFraction >= 0.9) {
                  notifier.currentPostID = data.adsId ?? '';
                  globalAdsInBetween?.play();
                }
              },
              child: AspectRatio(
                aspectRatio: ratio,
                child: notifier.currentPostID == data.adsId
                    ? InBetweenScreen(
                        adsData: data,
                        player: widget.arguments.player,
                        ratio: ratio,
                        onRatioChanged: (fix) {
                          setState(
                            () {
                              ratio = fix;
                            },
                          );
                        },
                        getPlayer: widget.arguments.getPlayer!,
                      )
                    : Container(
                        decoration: const BoxDecoration(color: Colors.black, borderRadius: BorderRadius.all(Radius.circular(16.0))),
                        alignment: Alignment.center,
                        child: const CustomLoading(),
                      ),
              ),
            ),
          ),
          _buildBody(context, SizeConfig.screenWidth, data),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.only(top: kTextTabBarHeight - 12, left: 12.0),
              padding: const EdgeInsets.symmetric(vertical: 18.0),
              width: double.infinity,
              height: kToolbarHeight * 1.6,
              child: appBar(data),
            ),
          ),
        ],
      );
    });
  }

  Widget appBar(AdsData data) {
    final lang = context.read<TranslateNotifierV2>().translate;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 30,
              child: IconButton(
                padding: const EdgeInsets.all(0.0),
                onPressed: () {
                  Routing().moveBack();
                },
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  shadows: <Shadow>[Shadow(color: Colors.black54, blurRadius: 8.0)],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ProfileComponent(
                isFullscreen: true,
                show: true,
                following: true,
                onFollow: () {},
                username: data.username ?? 'No Name',
                textColor: kHyppeLightBackground,
                spaceProfileAndId: eightPx,
                haveStory: false,
                isCelebrity: false,
                isUserVerified: false,
                onTapOnProfileImage: () {
                  // fAliplayer?.pause();
                  System().navigateToProfile(context, data.email ?? '');
                },
                featureType: FeatureType.pic,
                imageUrl: '${System().showUserPicture(data.avatar?.mediaEndpoint)}',
                createdAt: lang.sponsored ?? 'Sponsored',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, width, AdsData data) {
    final lang = context.read<TranslateNotifierV2>().translate;
    return Positioned(
      bottom: kToolbarHeight,
      left: 0,
      right: 0,
      child: Align(
        alignment: Alignment.topLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(
                  maxWidth: SizeConfig.screenWidth ?? 0,
                  maxHeight: data.adsDescription!.length > 24
                      ? isShowMore
                          ? 58
                          : SizeConfig.screenHeight! * .4
                      : 58),
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
              padding: const EdgeInsets.only(left: 8.0, top: 20),
              child: SingleChildScrollView(
                child: CustomDescContent(
                  desc: "${data.adsDescription}",
                  // desc:                      "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum",
                  trimLines: 2,
                  textAlign: TextAlign.start,
                  callbackIsMore: (val) {
                    setState(() {
                      isShowMore = val;
                    });
                  },
                  seeLess: ' ${lang.less}',
                  seeMore: ' ${lang.more}',
                  normStyle: const TextStyle(fontSize: 14, color: kHyppeTextPrimary),
                  hrefStyle: Theme.of(context).textTheme.subtitle2?.copyWith(color: kHyppePrimary),
                  expandStyle: const TextStyle(fontSize: 14, color: kHyppeTextPrimary, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            InkWell(
              onTap: () async {
                if (data.adsUrlLink?.isEmail() ?? false) {
                  final email = data.adsUrlLink!.replaceAll('email:', '');
                  setState(() {
                    loadLaunch = true;
                  });
                  System().adsView(data, data.duration?.round() ?? 10, isClick: true).whenComplete(() {
                    if (widget.arguments.afterReport != null) {
                      widget.arguments.afterReport!();
                    }

                    Future.delayed(const Duration(milliseconds: 800), () {
                      Routing().move(Routes.otherProfile, argument: OtherProfileArgument(senderEmail: email));
                    });
                  });
                } else {
                  if ((data.adsUrlLink ?? '').withHttp()) {
                    print("=====mauk uooooyyy");
                    try {
                      final uri = Uri.parse(data.adsUrlLink ?? '');
                      print('bottomAdsLayout ${data.adsUrlLink}');
                      if (await canLaunchUrl(uri)) {
                        setState(() {
                          loadLaunch = true;
                        });
                        System().adsView(data, data.duration?.round() ?? 10, isClick: true).whenComplete(() async {
                          if (widget.arguments.afterReport != null) {
                            widget.arguments.afterReport!();
                          }
                          await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          );
                        });
                      } else {
                        throw "Could not launch $uri";
                      }
                    } catch (e) {
                      setState(() {
                        loadLaunch = true;
                      });
                      System().adsView(data, data.duration?.round() ?? 10, isClick: true).whenComplete(() {
                        if (widget.arguments.afterReport != null) {
                          widget.arguments.afterReport!();
                        }
                        System().goToWebScreen(data.adsUrlLink ?? '', isPop: true);
                      });
                    }
                  }
                }
              },
              child: Container(
                width: SizeConfig.screenWidth,
                alignment: Alignment.center,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)), color: KHyppeButtonAds),
                child: loadLaunch
                    ? const SizedBox(width: 40, height: 20, child: CustomLoading())
                    : Text(
                        data.ctaButton ?? 'Learn More',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InBetweenScreen extends StatefulWidget {
  final AdsData adsData;
  final FlutterAliplayer? player;
  final double ratio;
  final Function(double) onRatioChanged;
  final Function(FlutterAliplayer, String) getPlayer;
  const InBetweenScreen({Key? key, required this.adsData, this.player, required this.ratio, required this.onRatioChanged, required this.getPlayer}) : super(key: key);

  @override
  State<InBetweenScreen> createState() => _InBetweenScreenState();
}

class _InBetweenScreenState extends State<InBetweenScreen> with WidgetsBindingObserver {
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

  bool _showTipsWidget = false;

  String auth = '';
  String url = '';
  // final Map _dataSourceMap = {};
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
      fAliplayer = FlutterAliPlayerFactory.createAliPlayer(playerId: widget.adsData.adsId);
      WidgetsBinding.instance.addObserver(this);
      fAliplayer?.pause();
      fAliplayer?.setAutoPlay(true);
      fAliplayer?.setLoop(false);
      // System().adsView(widget.adsData, widget.adsData.duration?.round() ?? 10);

      //Turn on mix mode
      if (Platform.isIOS) {
        FlutterAliplayer.enableMix(true);
      }

      //set player
      fAliplayer?.setPreferPlayerName(GlobalSettings.mPlayerName);
      fAliplayer?.setEnableHardwareDecoder(GlobalSettings.mEnableHardwareDecoder);
      if (fAliplayer != null) {
        widget.getPlayer(fAliplayer!, widget.adsData.adsId ?? '');
      }
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
          _videoDuration = value['duration'];
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
      // _currentPlayerState = newState;
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
    fAliplayer?.setOnSeekComplete((playerId) {
      // _inSeek = false;
    });
    fAliplayer?.setOnInfo((infoCode, extraValue, extraMsg, playerId) {
      print("===detik $infoCode");
      if (infoCode == FlutterAvpdef.CURRENTPOSITION) {
        if (_videoDuration != 0 && (extraValue ?? 0) <= _videoDuration) {
          setState(() {
            _currentPosition = extraValue ?? 0;
          });

          final detik = (_currentPosition / 1000).round();
          print("===detik $detik");
        }
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
    globalAdsInContent = fAliplayer;
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
    await getAuth(data.videoIdPortrait ?? data.videoId ?? '476cf7a01e7371ee9612442380ea0102');
    if (mounted) {
      setState(() {
        isPause = false;
        // _isFirstRenderShow = false;
      });
    } else {
      isPause = false;
    }

    globalAdsInBetween = fAliplayer;
    await fAliplayer?.prepare();

    // fAliplayer?.play();
  }

  Future getAuth(String apsaraId) async {
    try {
      if (mounted) {
        setState(() {
          isloading = true;
          _showLoading = true;
        });
      } else {
        isloading = true;
        _showLoading = true;
      }
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
        if (mounted) {
          setState(() {
            isloading = false;
            _showLoading = false;
          });
        } else {
          isloading = false;
          _showLoading = false;
        }

        // widget.videoData?.fullContentPath = jsonMap['PlayUrl'];
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isloading = false;
          _showLoading = false;
        });
      } else {
        isloading = false;
        _showLoading = false;
      }

      // 'Failed to fetch ads data $e'.logger();
    }
  }

  void onViewPlayerCreated(viewId) async {
    if (fAliplayer != null) {
      widget.getPlayer(fAliplayer!, widget.adsData.adsId ?? '');
    }
    fAliplayer?.setPlayerView(viewId);
  }

  @override
  void dispose() {
    fAliplayer?.stop();
    fAliplayer?.destroy();
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    globalAdsInBetween = null;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          // borderRadius: const BorderRadius.all(Radius.circular(16.0)),
          child: AliPlayerView(
            onCreated: onViewPlayerCreated,
            x: 0,
            y: 0,
            height: MediaQuery.of(context).size.width * widget.ratio,
            width: MediaQuery.of(context).size.width,
            aliPlayerViewType: AliPlayerViewTypeForAndroid.surfaceview,
          ),
        ),
        if (_showLoading)
          Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
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
          ),
        Positioned(
          top: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: Colors.black.withOpacity(0.5)),
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
              child: SizedBox(
                width: SizeConfig.screenWidth,
                child: Row(
                  children: [
                    twentyFourPx,
                    Text(
                      "${System.getTimeformatByMs(_currentPositionText)}/${System.getTimeformatByMs(_videoDuration)}",
                      style: TextStyle(color: Colors.white),
                    ),
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          overlayShape: SliderComponentShape.noThumb,
                          activeTrackColor: const Color(0xAA7d7d7d),
                          inactiveTrackColor: const Color.fromARGB(170, 156, 155, 155),
                          trackHeight: 1.0,
                          thumbColor: Colors.purple,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
                        ),
                        child: AbsorbPointer(
                          child: Slider(
                              min: 0,
                              max: _videoDuration == 0 ? 1 : _videoDuration.toDouble(),
                              value: _currentPosition.toDouble(),
                              activeColor: Colors.yellow,
                              thumbColor: Colors.transparent,
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
                    ),
                    CustomIconWidget(
                      iconData: isMute ? '${AssetPath.vectorPath}sound-off.svg' : '${AssetPath.vectorPath}sound-on.svg',
                      defaultColor: false,
                      height: 24,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
