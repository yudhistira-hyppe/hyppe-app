import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_aliplayer/flutter_aliplayer.dart';
import 'package:flutter_aliplayer/flutter_aliplayer_factory.dart';
import 'package:hyppe/core/arguments/view_streaming_argument.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/streamer/widget/love_lottie.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/view_streaming/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/view_streaming/widget/love_lottie.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/view_streaming/widget/pauseLive.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/view_streaming/widget/title_view_live.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/view_streaming/widget/viewer_comment.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../../../../app.dart';
import '../../../../../../core/config/ali_config.dart';
import '../../../../../../core/constants/asset_path.dart';
import '../../../../../../core/constants/shared_preference_keys.dart';
import '../../../../../../core/services/shared_preference.dart';
import '../../../../../../core/services/system.dart';
import '../../../../../constant/widget/custom_icon_widget.dart';
import '../../../../../constant/widget/custom_loading.dart';
import '../../../../../constant/widget/custom_spacer.dart';
import '../../../../../constant/widget/custom_text_widget.dart';

class ViewStreamingScreen extends StatefulWidget {
  final ViewStreamingArgument args;

  const ViewStreamingScreen({super.key, required this.args});

  @override
  State<ViewStreamingScreen> createState() => _ViewStreamingScreenState();
}

class _ViewStreamingScreenState extends State<ViewStreamingScreen> with WidgetsBindingObserver, TickerProviderStateMixin {
  FocusNode commentFocusNode = FocusNode();

  FlutterAliplayer? fAliplayer;
  // final _sharedPrefs = SharedPreference();
  var secondsSkip = 0;
  var secondsVideo = 0;
  bool loadingAction = false;
  bool isloading = false;
  bool isPrepare = false;
  bool isPause = false;
  bool liveIsPause = false;
  int? bottomIndex;
  List<Widget>? mFramePage;
  Map<String, dynamic>? _dataSourceMap;
  String auth = '';

  bool isPlay = false;
  bool onTapCtrl = false;
  //是否允许后台播放
  bool _mEnablePlayBack = false;

  //当前播放进度
  int _currentPosition = 0;

  //当前播放时间，用于Text展示
  int _currentPositionText = 0;

  //当前buffer进度
  // int _bufferPosition = 0;

  //是否展示loading
  bool _showLoading = false;

  //loading进度
  int _loadingPercent = 0;

  bool loadingBack = false;

  //视频时长
  int _videoDuration = 1;

  //截图保存路径
  String _snapShotPath = '';

  //提示内容
  // String _tipsContent = '';

  //是否展示提示内容
  // bool _showTipsWidget = false;

  //是否有缩略图
  // bool _thumbnailSuccess = false;

  //缩略图
  // Uint8List _thumbnailBitmap;
  // ImageProvider? _imageProvider;

  //当前网络状态
  // ConnectivityResult? _currentConnectivityResult;

  ///seek中
  // bool _inSeek = false;

  // bool _isLock = false;

  //网络状态
  // bool _isShowMobileNetWork = false;

  //当前播放器状态
  // int _currentPlayerState = 0;

  String extSubTitleText = '';

  //网络状态监听
  StreamSubscription? _networkSubscriptiion;

  var loadLaunch = false;

  bool isMute = false;

  @override
  void initState() {
    _showLoading = true;

    bool theme = SharedPreference().readStorage(SpKeys.themeData) ?? false;
    super.initState();
    final notifier = (Routing.navigatorKey.currentContext ?? context).read<ViewStreamingNotifier>();
    notifier.initViewStreaming(widget.args.data);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      commentFocusNode.addListener(() {
        print("Has focus: ${commentFocusNode.hasFocus}");
      });
      notifier.startViewStreaming(Routing.navigatorKey.currentContext ?? context, mounted, widget.args.data);
      SharedPreference().writeStorage(SpKeys.isShowPopAds, true);
      // _pageController.addListener(() => notifier.currentPage = _pageController.page);
      fAliplayer = FlutterAliPlayerFactory.createAliPlayer(playerId: widget.args.data.sId);

      WidgetsBinding.instance.addObserver(this);
      bottomIndex = 0;
      fAliplayer?.setAutoPlay(true);

      var configMap = {
        'mClearFrameWhenStop': true,
      };
      fAliplayer?.setConfig(configMap);

      print("Hahahaha $_videoDuration");
      // if (widget.data?.apsaraId != '') {
      // } else {
      //   _playMode = ModeTypeAliPLayer.url;
      // }
      isPlay = false;
      isPrepare = false;
      setState(() {});

      //Turn on mix mode
      if (Platform.isIOS) {
        FlutterAliplayer.enableMix(true);
      }

      //set player
      fAliplayer?.setPreferPlayerName(GlobalSettings.mPlayerName);
      fAliplayer?.setEnableHardwareDecoder(GlobalSettings.mEnableHardwareDecoder);

      if (Platform.isAndroid) {
        getExternalStorageDirectories().then((value) {
          if ((value?.length ?? 0) > 0) {
            _snapShotPath = value![0].path;
            return _snapShotPath;
          }
        });
      }

      _initListener();
    });
  }

  _initListener() {
    Future.delayed(const Duration(milliseconds: 500), () {
      fAliplayer?.prepare();
    });
    fAliplayer?.setOnEventReportParams((params, playerId) {
      print("EventReportParams=${params}");
    });
    fAliplayer?.setOnPrepared((playerId) {
      // Fluttertoast.showToast(msg: "OnPrepared ");
      fAliplayer?.getPlayerName().then((value) => print("getPlayerName==${value}"));
      fAliplayer?.getMediaInfo().then((value) {
        _videoDuration = value['duration'];
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
      print('--aaaaaaa----- $newState');
      // _currentPlayerState = newState;
      try {
        switch (newState) {
          case FlutterAvpdef.AVPStatus_AVPStatusStarted:
            WakelockPlus.enable();

            setState(() {
              // _showTipsWidget = false;
              _showLoading = false;
              isPause = false;
              liveIsPause = false;
            });
            break;
          case FlutterAvpdef.AVPStatus_AVPStatusPaused:
            setState(() {
              liveIsPause = true;
            });
            break;
          case FlutterAvpdef.AVPStatus_AVPStatusStopped:
            WakelockPlus.disable();
            if (mounted) {
              setState(() {
                _showLoading = false;
              });
            }
            break;
          case FlutterAvpdef.AVPStatus_AVPStatusCompletion:
            WakelockPlus.disable();
            context.read<ViewStreamingNotifier>().isOver = true;
            break;
          case FlutterAvpdef.AVPStatus_AVPStatusError:
            WakelockPlus.disable();
            context.read<ViewStreamingNotifier>().isOver = true;
            break;
          default:
        }
      } catch (e) {
        e.logger();
      }
    });
    fAliplayer?.setOnLoadingStatusListener(loadingBegin: (playerId) {
      if (!(context.read<ViewStreamingNotifier>().dataStreaming.pause ?? false)) {
        setState(() {
          _loadingPercent = 0;
          _showLoading = true;
        });
      }
      print("------------isloading ---------");
      if (context.read<ViewStreamingNotifier>().endLive) {
        context.read<ViewStreamingNotifier>().isOver = true;
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
      setState(() {});
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
      context.read<ViewStreamingNotifier>().isOver = true;
    });
    var lastDetik = 0;
    fAliplayer?.setOnInfo((infoCode, extraValue, extraMsg, playerId) {
      print("---------- status $infoCode ");
      if (infoCode == FlutterAvpdef.CURRENTPOSITION) {
        if (_videoDuration != 0 && (extraValue ?? 0) <= _videoDuration) {
          _currentPosition = extraValue ?? 0;
          var detik = (_currentPosition / 1000).round();
          print("*************detik $detik");
          secondsVideo = detik;
          print("*************last $lastDetik");
          print("*************last ${lastDetik != detik}");

          if (lastDetik != detik) {
            secondsSkip -= 1;
          }
          print("*************last ${secondsSkip}");
          lastDetik = detik;
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
        if (mounted) {
          setState(() {});
        }
      } else if (infoCode == FlutterAvpdef.AUTOPLAYSTART) {
        liveIsPause = false;
        setState(() {});
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
      // _showTipsWidget = true;
      _showLoading = false;
      // _tipsContent = "Play Again";
      isPause = true;
      // adsView(widget.data, secondsVideo);
      setState(() {
        _currentPosition = _videoDuration;
      });
    });

    fAliplayer?.setOnSnapShot((path, playerId) {
      print("aliyun : snapShotPath = $path");
      // Fluttertoast.showToast(msg: "SnapShot Save : $path");
    });
    fAliplayer?.setOnError((errorCode, errorExtra, errorMsg, playerId) {
      // _showTipsWidget = true;
      _showLoading = false;
      // _tipsContent = "$errorCode \n $errorMsg";
      setState(() {});
    });

    fAliplayer?.setOnTrackChanged((value, playerId) {
      AVPTrackInfo info = AVPTrackInfo.fromJson(value);
      if ((info.trackDefinition?.length ?? 0) > 0) {
        // trackFragmentKey.currentState.onTrackChanged(info);
        // Fluttertoast.showToast(msg: "${info.trackDefinition}切换成功");
      }
    });

    fAliplayer?.setOnThumbnailPreparedListener(preparedSuccess: (playerId) {
      // _thumbnailSuccess = true;
    }, preparedFail: (playerId) {
      // _thumbnailSuccess = false;
    });

    fAliplayer?.setOnThumbnailGetListener(
        onThumbnailGetSuccess: (bitmap, range, playerId) {
          // _thumbnailBitmap = bitmap;
          var provider = MemoryImage(bitmap);
          precacheImage(provider, context).then((_) {
            setState(() {
              // _imageProvider = provider;
            });
          });
        },
        onThumbnailGetFail: (playerId) {});

    fAliplayer?.setOnSubtitleHide((trackIndex, subtitleID, playerId) {
      if (mounted) {
        setState(() {
          extSubTitleText = '';
        });
      }
    });

    fAliplayer?.setOnSubtitleShow((trackIndex, subtitleID, subtitle, playerId) {
      if (mounted) {
        setState(() {
          extSubTitleText = subtitle;
        });
      }
    });
    globalAdsPopUp = fAliplayer;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.resumed:
        fAliplayer?.play();
        // _setNetworkChangedListener();
        break;
      case AppLifecycleState.paused:
        if (!_mEnablePlayBack) {
          fAliplayer?.pause();
          print('pop up ads pause');
        }
        if (_networkSubscriptiion != null) {
          _networkSubscriptiion?.cancel();
        }
        break;
      case AppLifecycleState.detached:
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    fAliplayer?.stop();
    fAliplayer?.destroy();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    WakelockPlus.disable();
    SharedPreference().writeStorage(SpKeys.isShowPopAds, false);
    if (Platform.isIOS) {
      FlutterAliplayer.enableMix(false);
    }

    super.dispose();
    globalAdsPopUp = null;
    WidgetsBinding.instance.removeObserver(this);
    if (_networkSubscriptiion != null) {
      _networkSubscriptiion?.cancel();
    }
  }

  void onViewPlayerCreated(viewId) async {
    fAliplayer?.setPlayerView(viewId);
    fAliplayer?.setUrl(widget.args.data.urlStream ?? '');
    // fAliplayer?.setVidAuth(
    //     vid: null,
    //     region: DataSourceRelated.defaultRegion,
    //     playAuth: widget.args.data.urlStream,
    //     definitionList: _dataSourceMap?[DataSourceRelated.definitionList],
    //     previewTime: _dataSourceMap?[DataSourceRelated.previewTime]);
  }

  @override
  Widget build(BuildContext context) {
    fAliplayer?.setScalingMode(FlutterAvpdef.AVP_SCALINGMODE_SCALEASPECTFIT);
    return Consumer<ViewStreamingNotifier>(builder: (_, notifier, __) {
      return Scaffold(
        resizeToAvoidBottomInset: false,
        body: WillPopScope(
          child: Container(
            width: SizeConfig.screenWidth,
            height: SizeConfig.screenHeight,
            child: notifier.isOver
                ? Stack(
                    children: [
                      Positioned.fill(
                        child: Container(
                          width: double.infinity,
                          height: context.getHeight(),
                          decoration: BoxDecoration(
                            image: DecorationImage(image: NetworkImage(displayPhotoProfileOriginal(widget.args.data.avatar?.mediaEndpoint ?? '') ?? ''), fit: BoxFit.cover),
                          ),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                            child: Container(
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.0)),
                            ),
                          ),
                        ),
                      ),
                      SafeArea(
                        child: Align(
                          alignment: Alignment.topRight,
                          child: GestureDetector(
                            onTap: () {
                              Routing().moveBack();
                            },
                            child: Padding(
                              padding: EdgeInsets.only(right: 30.0),
                              child: CustomIconWidget(
                                iconData: "${AssetPath.vectorPath}close.svg",
                                defaultColor: false,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomTextWidget(
                              textToDisplay: 'Siaran LIVE telah berakhir',
                              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            twelvePx,
                            CustomTextWidget(
                              textToDisplay: '${notifier.totViews} ${notifier.language.views}',
                              textStyle: const TextStyle(fontSize: 14, color: Color(0xffdadada)),
                            ),
                            twelvePx,
                            SizedBox(
                              width: 80,
                              height: 80,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(40),
                                child: streamerImage(displayPhotoProfileOriginal(widget.args.data.avatar?.mediaEndpoint ?? '') ?? ''),
                              ),
                            ),
                            twelvePx,
                            CustomTextWidget(
                              textToDisplay: widget.args.data.username ?? '',
                              textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xffdadada)),
                            ),
                          ],
                        ),
                      )
                    ],
                  )
                : Stack(
                    children: [
                      Container(
                        color: Colors.black,
                        width: SizeConfig.screenWidth,
                        height: SizeConfig.screenHeight,
                        child: AliPlayerView(
                          onCreated: onViewPlayerCreated,
                          x: 0,
                          y: 0,
                          height: SizeConfig.screenHeight,
                          width: SizeConfig.screenWidth,
                        ),
                      ),
                      if (notifier.dataStreaming.pause ?? false) const PauseLiveView(),
                      // if (liveIsPause) const PauseLiveView(),
                      Positioned.fill(
                        bottom: -60,
                        right: 0,
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: SizedBox(
                            width: 70,
                            child: Stack(
                              children: notifier.animationIndexes.map((e) {
                                return LoveLootie(
                                  onAnimationFinished: () {
                                    // notifier.removeAnimation(e);
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        bottom: -60,
                        right: 0,
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: SizedBox(
                            width: 70,
                            child: Stack(
                              children: notifier.likeList.map((e) {
                                return LoveSingleLootie(
                                  onAnimationFinished: () {
                                    // notifier.removeAnimation(e);
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                      if (_showLoading && !(notifier.dataStreaming.pause ?? false))
                        Positioned.fill(
                          child: Align(
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
                        ),
                      TitleViewLive(data: widget.args.data, totLikes: notifier.totLikes, totViews: notifier.totViews),
                      // Positioned(
                      //   top: 12 + context.getHeightStatusBar(),
                      //   left: 16,
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.start,
                      //     children: [
                      //       CustomProfileImage(
                      //         width: 36,
                      //         height: 36,
                      //         following: true,
                      //         imageUrl: System().showUserPicture(widget.args.data.avatar?.mediaEndpoint ?? ''),
                      //         forStory: false,
                      //       ),
                      //       twelvePx,
                      //       Column(
                      //         mainAxisAlignment: MainAxisAlignment.center,
                      //         crossAxisAlignment: CrossAxisAlignment.start,
                      //         children: [
                      //           Row(
                      //             children: [
                      //               CustomTextWidget(
                      //                 textAlign: TextAlign.left,
                      //                 textToDisplay: widget.args.data.username ?? '',
                      //                 textStyle: context.getTextTheme().bodyText2?.copyWith(fontWeight: FontWeight.w700, color: Colors.white),
                      //               ),
                      //               fourPx,
                      //               const CustomIconWidget(
                      //                 iconData: "${AssetPath.vectorPath}arrow_down.svg",
                      //                 defaultColor: false,
                      //                 color: Colors.white,
                      //                 width: 10,
                      //                 height: 10,
                      //               )
                      //             ],
                      //           ),
                      //           fourPx,
                      //           CustomTextWidget(
                      //             textAlign: TextAlign.left,
                      //             textToDisplay: "${notifier.totLikes.getCountShort()} likes",
                      //             textStyle: context.getTextTheme().caption?.copyWith(fontWeight: FontWeight.w400, color: Colors.white),
                      //           ),
                      //         ],
                      //       ),
                      //       fourPx,
                      //     ],
                      //   ),
                      // ),
                      // Positioned(
                      //   top: 12 + context.getHeightStatusBar(),
                      //   right: 16,
                      //   child: Row(
                      //     children: [
                      //       Container(
                      //         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                      //         decoration: BoxDecoration(color: kHyppeDanger, borderRadius: BorderRadius.circular(3)),
                      //         child: const Text(
                      //           'LIVE',
                      //           style: TextStyle(color: kHyppeTextPrimary, wordSpacing: 10),
                      //         ),
                      //       ),
                      //       eightPx,
                      //       GestureDetector(
                      //         onTap: () {
                      //           print('testing see views');
                      //           final ref = context.read<StreamerNotifier>();
                      //           ref.dataStream = widget.args.data;
                      //           ShowBottomSheet.onStreamWatchersStatus(context, ref);
                      //         },
                      //         child: Container(
                      //           width: 50 * context.getScaleDiagonal(),
                      //           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      //           decoration: BoxDecoration(color: kHyppeTransparent, borderRadius: BorderRadius.circular(3)),
                      //           child: Row(
                      //             mainAxisAlignment: MainAxisAlignment.center,
                      //             children: [
                      //               const Icon(
                      //                 Icons.remove_red_eye_outlined,
                      //                 color: kHyppeTextPrimary,
                      //                 size: 12,
                      //               ),
                      //               sixPx,
                      //               Text(
                      //                 notifier.totViews.getCountShort(),
                      //                 style: const TextStyle(color: kHyppeTextPrimary, fontSize: 10, fontWeight: FontWeight.w700),
                      //               ),
                      //             ],
                      //           ),
                      //         ),
                      //       ),
                      //       CustomIconButtonWidget(
                      //           iconData: "${AssetPath.vectorPath}close.svg",
                      //           defaultColor: false,
                      //           onPressed: () {
                      //             notifier.exitStreaming(context, widget.args.data).whenComplete(() async {
                      //               Routing().moveBack();
                      //               await notifier.destoryPusher();
                      //             });
                      //           })
                      //     ],
                      //   ),
                      // ),
                      Positioned(
                          bottom: 36,
                          left: 16,
                          right: 16,
                          child: ViewerComment(
                            commentFocusNode: commentFocusNode,
                            data: widget.args.data,
                          ))
                    ],
                  ),
          ),
          onWillPop: () async {
            await notifier.exitStreaming(context, widget.args.data);
            await notifier.destoryPusher();
            return true;
          },
        ),
      );
    });
  }

  String? displayPhotoProfileOriginal(String url) {
    try {
      var orginial = url.split('/');
      var endpoint = "/profilepict/orignal/${orginial.last}";
      return System().showUserPicture(endpoint);
    } catch (e) {
      return null;
    }
  }

  Widget streamerImage(String image) {
    return Stack(
      children: [
        const Align(
          alignment: Alignment.center,
          child: CustomLoading(),
        ),
        Positioned.fill(
            child: Image.network(
          image,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        )),
      ],
    );
  }
}
