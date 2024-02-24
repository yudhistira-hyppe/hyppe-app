import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_aliplayer/flutter_aliplayer.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/kyc_status.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/constants/utils.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/entities/like/notifier.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/widget/after_first_layout_mixin.dart';
import 'package:hyppe/ui/constant/widget/button_boost.dart';
import 'package:hyppe/ui/constant/widget/custom_appbar.dart';
import 'package:hyppe/ui/constant/widget/custom_desc_content_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'dart:math' as math;
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/playlist/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/playlist/comments_detail/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/playlist/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/widget/vid_player_page.dart';
import 'package:hyppe/ui/inner/home/notifier_v2.dart';
import 'package:hyppe/ui/inner/main/notifier.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:marquee/marquee.dart';
import 'package:measured_size/measured_size.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../../../core/arguments/other_profile_argument.dart';
import '../../../../../../../core/config/ali_config.dart';
import '../../../../../../../core/constants/shared_preference_keys.dart';
import '../../../../../../../core/models/collection/advertising/ads_video_data.dart';
import '../../../../../../../core/models/collection/posts/content_v2/content_data.dart';
import '../../../../../../../core/services/shared_preference.dart';
import '../../../../../../../ux/path.dart';
import '../../../../../../constant/widget/custom_base_cache_image.dart';
import '../../../../../../constant/widget/custom_cache_image.dart';
import '../../../../../../constant/widget/custom_text_widget.dart';
import 'notifier.dart';

class VideoFullscreenPage extends StatefulWidget {
  final AliPlayerView? aliPlayerView;
  final ContentData data;
  final Function onClose;
  final FlutterAliplayer? fAliplayer;
  final Widget? slider;
  final VideoIndicator videoIndicator;
  final String? thumbnail;
  final List<ContentData>? vidData;
  final int? index;
  final Function()? loadMoreFunction;
  final Function()? clearPostId; //netral player
  final bool? isAutoPlay;
  final bool enableWakelock;
  final bool isLanding;
  const VideoFullscreenPage({
    Key? key,
    this.aliPlayerView,
    required this.data,
    required this.onClose,
    required this.isLanding,
    this.fAliplayer,
    this.slider,
    required this.videoIndicator,
    required this.thumbnail,
    this.vidData,
    this.index,
    this.loadMoreFunction,
    this.clearPostId,
    this.isAutoPlay,
    this.enableWakelock = true,
  }) : super(key: key);

  @override
  State<VideoFullscreenPage> createState() => _VideoFullscreenPageState();
}

class _VideoFullscreenPageState extends State<VideoFullscreenPage> with AfterFirstLayoutMixin, SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKeyPlayer = GlobalKey<ScaffoldState>();

  PageController controller = PageController();
  late final AnimationController animatedController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();

  int seekValue = 0;
  bool isMute = false;
  bool _inSeek = false;
  int _currentPosition = 0;
  int _currentPositionText = 0;
  // int _bufferPosition = 0;
  int _videoDuration = 1;
  bool isPause = false;
  bool onTapCtrl = false;
  bool _showTipsWidget = false;
  int _currentPlayerState = 0;
  List<ContentData>? vidData;
  Orientation beforePosition = Orientation.landscape;

  LocalizationModelV2? lang;
  String email = '';

  // bool isloading = true;

  bool isLoadingVid = false;

  int _loadingPercent = 0;

  bool isScrolled = false;
  bool isloadingRotate = false;
  int curentIndex = 0;
  Orientation orientation = Orientation.portrait;

  bool isOnPageTurning = false;
  bool isShowMore = false;

  @override
  void afterFirstLayout(BuildContext context) {
    landscape();
    _initializeTimer();
  }

  void landscape() async {
    widget.fAliplayer?.pause();
    Future.delayed(const Duration(seconds: 1), () {
      final notifier = (Routing.navigatorKey.currentContext ?? context).read<VideoNotifier>();
      final isShowing = notifier.isShowingAds;
      if (!isShowing) {
        widget.fAliplayer?.play();
      }
      notifier.loadVideo = false;
      // setState(() {
      //   isloading = false;
      // });
    });
  }

  bool isScrolling = false;

  @override
  void initState() {
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    if (widget.data.certified ?? false) {
      System().block(context);
    } else {
      System().disposeBlock();
    }
    _currentPositionText = widget.videoIndicator.positionText ?? 0;
    _currentPosition = widget.videoIndicator.seekValue ?? 0;
    // widget.fAliplayer?.play();
    _videoDuration = widget.videoIndicator.videoDuration ?? 0;
    isMute = widget.videoIndicator.isMute ?? false;
    vidData = widget.vidData;
    lang = context.read<TranslateNotifierV2>().translate;
    email = SharedPreference().readStorage(SpKeys.email);
    super.initState();
    if ((widget.data.metadata?.height ?? 0) < (widget.data.metadata?.width ?? 0)) {
      orientation = Orientation.landscape;
      // beforePosition = orientation;
    } else {
      orientation = Orientation.portrait;
      // beforePosition = orientation;
    }

    int changevalue;
    changevalue = _currentPosition + 1000;
    if (changevalue > _videoDuration) {
      changevalue = _videoDuration;
    }
    widget.fAliplayer?.requestBitmapAtPosition(changevalue);
    setState(() {
      _currentPosition = changevalue;
    });
    _inSeek = false;
    setState(() {
      if (_currentPlayerState == FlutterAvpdef.completion && _showTipsWidget) {
        setState(() {
          _showTipsWidget = false;
        });
      }
    });
    // fAliplayer?.seekTo(changevalue, GlobalSettings.mEnableAccurateSeek ? FlutterAvpdef.ACCURATE : FlutterAvpdef.INACCURATE);
    widget.fAliplayer?.seekTo(changevalue, FlutterAvpdef.ACCURATE);

    widget.fAliplayer?.setOnInfo((infoCode, extraValue, extraMsg, playerId) {
      if (infoCode == FlutterAvpdef.CURRENTPOSITION) {
        if (_videoDuration != 0 && (extraValue ?? 0) <= _videoDuration) {
          _currentPosition = extraValue ?? 0;
        }
        if (!_inSeek) {
          setState(() {
            _currentPositionText = extraValue ?? 0;
          });
        }
      } else if (infoCode == FlutterAvpdef.BUFFEREDPOSITION) {
        // _bufferPosition = extraValue ?? 0;
        // if (mounted) {
        //   setState(() {});
        // }
      } else if (infoCode == FlutterAvpdef.AUTOPLAYSTART) {
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

    widget.fAliplayer?.setOnCompletion((playerId) {
      _showTipsWidget = true;
      // isPause = true;
      try {
        if (mounted) {
          setState(() {
            _currentPosition = _videoDuration;
          });
        } else {
          _currentPosition = _videoDuration;
        }
      } catch (e) {
        _currentPosition = _videoDuration;
      }

      // nextPage();
    });

    widget.fAliplayer?.setOnLoadingStatusListener(loadingBegin: (playerId) {
      if (mounted) {
        try {
          setState(() {
            _loadingPercent = 0;
            isLoadingVid = true;
          });
        } catch (e) {
          print('error setOnLoadingStatusListener: $e');
        }
      }
    }, loadingProgress: (percent, netSpeed, playerId) {
      if (percent == 100) {
        isLoadingVid = false;
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
            isLoadingVid = false;
          });
        } else {
          isLoadingVid = false;
        }
      } catch (e) {
        print('error loadingEnd: $e');
      }
    });

    controller = PageController(initialPage: widget.index ?? 0);
    controller.addListener(() {
      widget.fAliplayer?.pause();
      setState(() {
        isScrolled = true;
      });
      final _notifier = context.read<PreviewVidNotifier>();
      if (isOnPageTurning && controller.page == controller.page?.roundToDouble()) {
        _notifier.pageIndex = controller.page?.toInt() ?? 0;
        setState(() {
          // current = _controller.page.toInt();
          isOnPageTurning = false;
        });
      } else if (!isOnPageTurning) {
        if (((_notifier.pageIndex.toDouble()) - (controller.page ?? 0)).abs() > 0.1) {
          setState(() {
            isOnPageTurning = true;
          });
        }
      }
    });

    curentIndex = widget.index ?? 0;
    if ((vidData?.length ?? 0) - 1 == curentIndex) {
      getNewData();
    }

    _initializeTimer();
  }

  _pauseScreen() async {
    (Routing.navigatorKey.currentContext ?? context).read<HomeNotifier>().removeWakelock();
  }

  _initializeTimer() async {
    if (widget.enableWakelock) {
      (Routing.navigatorKey.currentContext ?? context).read<HomeNotifier>().initWakelockTimer(onShowInactivityWarning: _handleInactivity);
    }
  }

  _handleInactivity() {
    context.read<MainNotifier>().isInactiveState = true;
    widget.fAliplayer?.pause();
    isPause = true;
    setState(() {});
    _pauseScreen();
    ShowBottomSheet().onShowColouredSheet(
      context,
      context.read<TranslateNotifierV2>().translate.warningInavtivityVid,
      maxLines: 2,
      color: kHyppeLightBackground,
      textColor: kHyppeTextLightPrimary,
      textButtonColor: kHyppePrimary,
      iconSvg: 'close.svg',
      textButton: context.read<TranslateNotifierV2>().translate.stringContinue ?? '',
      onClose: () {
        context.read<MainNotifier>().isInactiveState = false;
        widget.fAliplayer?.play();
        isPause = false;
        setState(() {});
        _initializeTimer();
      },
    );
    // this syntax below to prevent video play after changing
    Future.delayed(const Duration(seconds: 1), () {
      if (context.read<MainNotifier>().isInactiveState) {
        widget.fAliplayer?.pause();
        isPause = true;
        setState(() {});
      }
    });
  }

  Future getNewData() async {
    print("getnewdata1");
    // widget.loadMoreFunc yestion?.call();
    HomeNotifier hn = context.read<HomeNotifier>();
    PreviewVidNotifier vn = context.read<PreviewVidNotifier>();

    await hn.initNewHome(context, mounted, isreload: false, isgetMore: true).then((value) {
      setState(() {
        vn.vidData?.forEach((e) {
          print(e.description);
        });
        vidData = vn.vidData;
        vidData?.forEach((e) {
          print(e.description);
        });
        print("========== total ${vidData?.length}");
      });
    });
  }

  @override
  void dispose() {
    _pauseScreen();
    whileDispose();
    animatedController.dispose();
    super.dispose();
  }

  whileDispose() async {
    widget.fAliplayer?.pause();
    final notifier = (Routing.navigatorKey.currentContext ?? context).read<VideoNotifier>();
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    if (!notifier.isShowingAds) {
      widget.fAliplayer?.play();
    }
    // widget.fAliplayer?.play();
  }

  void scrollPage(height, width) async {
    var lastOrientation = orientation;
    if ((height ?? 0) < (width ?? 0)) {
      orientation = Orientation.landscape;
    } else {
      orientation = Orientation.portrait;
    }

    print('start step -> height: $height width: $width orientation: $lastOrientation');

    if (lastOrientation != orientation) {
      setState(() {
        isloadingRotate = true;
      });
      print('step 1');
      if (orientation == Orientation.landscape) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
        print('step 2');
      } else {
        // await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
        await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
        print('step 3');
      }
      Future.delayed(const Duration(milliseconds: 1000), () {
        setState(() {
          isloadingRotate = false;
        });
      });
    } else {}
  }

  void nextPage() {
    Future.delayed(Duration(milliseconds: 500), () {
      controller.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.ease);
    });
  }

  void previousPage() {
    Future.delayed(Duration(milliseconds: 500), () {
      controller.previousPage(duration: const Duration(milliseconds: 500), curve: Curves.ease);
    });
  }

  @override
  Widget build(BuildContext context) {
    // SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    var map = {
      DataSourceRelated.vidKey: widget.data.apsaraId,
      DataSourceRelated.regionKey: DataSourceRelated.defaultRegion,
    };
    print('view ads: ${widget.isAutoPlay ?? false}');

    return Consumer<VideoNotifier>(builder: (context, notifier, _) {
      return Scaffold(
        key: _scaffoldKeyPlayer,
        body: GestureDetector(
          onHorizontalDragEnd: (dragEndDetails) {
            if (dragEndDetails.primaryVelocity! < 0) {
            } else if (dragEndDetails.primaryVelocity! > 0) {
              int changevalue;
              changevalue = _currentPosition + 1000;
              if (changevalue > _videoDuration) {
                changevalue = _videoDuration;
              }

              widget.data.isLoading = true;
              Navigator.pop(context, VideoIndicator(videoDuration: _videoDuration, seekValue: changevalue, positionText: _currentPositionText, showTipsWidget: _showTipsWidget, isMute: isMute));

              SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
            }
          },
          child: notifier.loadVideo
              ? Container(
                  color: Colors.black,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : widget.isAutoPlay ?? false
                  ? PageView.builder(
                      controller: controller,
                      scrollDirection: Axis.vertical,
                      itemCount: vidData?.length ?? 0,
                      onPageChanged: (value) {
                        curentIndex = value;
                        notifier.currIndex = value;
                        scrollPage(vidData?[value].metadata?.height, vidData?[value].metadata?.width);
                        if (value > 1) {
                          if ((vidData?[value - 1].metadata?.height ?? 0) < (vidData?[value - 1].metadata?.width ?? 0)) {
                            beforePosition = Orientation.landscape;
                          } else {
                            beforePosition = Orientation.portrait;
                          }
                        }
                        context.read<PreviewVidNotifier>().currIndex = value;

                        if ((vidData?.length ?? 0) - 1 == curentIndex) {
                          //get new data;
                          getNewData();
                        }
                      },
                      itemBuilder: (context, index) {
                        if (index != curentIndex) {
                          return Container(
                            color: Colors.black,
                          );
                        }
                        "================== isPause $isPause $isScrolled".logger();
                        if (isScrolled) {
                          // return Container(
                          //   height: MediaQuery.of(context).size.height,
                          //   width: MediaQuery.of(context).size.width,
                          //   child: Center(child: Text("data ${index}")),
                          // );
                          print('view ads: 1');
                          print('aliyun : onStateChanged');
                          final isAds = vidData?[index].inBetweenAds != null && vidData?[index].postID == null;

                          return isloadingRotate
                              ? Container(
                                  color: Colors.black,
                                  height: MediaQuery.of(context).size.height,
                                  width: MediaQuery.of(context).size.width,
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : isAds
                                  ? context.getAdsInBetween(vidData, index, (info) {}, () {
                                      context.read<PreviewVidNotifier>().setInBetweenAds(index, null);
                                    }, (player, id) {}, isfull: true, isVideo: true, orientation: beforePosition, isScroll: true)
                                  : OrientationBuilder(builder: (context, orientation) {
                                      final player = VidPlayerPage(
                                        // vidData: notifier.vidData,
                                        fromFullScreen: true,
                                        orientation: orientation,
                                        playMode: (vidData?[index].isApsara ?? false) ? ModeTypeAliPLayer.auth : ModeTypeAliPLayer.url,
                                        dataSourceMap: map,
                                        data: vidData?[index],
                                        height: MediaQuery.of(context).size.height,
                                        width: MediaQuery.of(context).size.width,
                                        inLanding: widget.isLanding,
                                        fromDeeplink: false,
                                        clearPostId: widget.clearPostId,
                                        clearing: true,
                                        isAutoPlay: true,
                                        functionFullTriger: (value) {
                                          print('===========hahhahahahaa===========');
                                        },
                                        isPlaying: !isPause,
                                        onPlay: (exec) {},
                                        getPlayer: (main, id) {},
                                        getAdsPlayer: (ads) {
                                          // notifier.vidData?[index].fAliplayerAds = ads;
                                        },
                                        autoScroll: () {
                                          nextPage();
                                        },
                                        prevScroll: () {
                                          previousPage();
                                        },
                                        // fAliplayer: notifier.vidData?[index].fAliplayer,
                                        // fAliplayerAds: notifier.vidData?[index].fAliplayerAds,
                                      );
                                      if (orientation == Orientation.landscape) {
                                        return Container(
                                          width: context.getWidth(),
                                          height: context.getHeight(),
                                          child: player,
                                        );
                                      }
                                      return player;
                                    });
                        } else {
                          print('view ads: 2 ${notifier.isShowingAds} ${notifier.hasShowedAds}');
                          return GestureDetector(
                            onTap: () {
                              onTapCtrl = true;
                              setState(() {});
                            },
                            child: Container(
                              height: SizeConfig.screenHeight,
                              width: SizeConfig.screenWidth,
                              foregroundDecoration: BoxDecoration(
                                color: Colors.transparent,
                              ),
                              child: Stack(
                                children: [
                                  if (!notifier.isShowingAds)
                                    Positioned.fill(
                                      child: Container(
                                        width: context.getWidth(),
                                        height: SizeConfig.screenHeight,
                                        decoration: const BoxDecoration(color: Colors.black),
                                        child: widget.aliPlayerView,
                                      ),
                                    ),
                                  GestureDetector(
                                    onTap: () {
                                      //// fungsi tap dimana saja
                                      onTapCtrl = true;
                                      setState(() {});
                                    },
                                    child: Container(
                                      color: Colors.transparent,
                                      height: SizeConfig.screenHeight,
                                      width: SizeConfig.screenWidth,
                                    ),
                                  ),
                                  if (!_showTipsWidget)
                                    SizedBox(
                                      width: context.getWidth(),
                                      height: SizeConfig.screenHeight,
                                      // padding: EdgeInsets.only(bottom: 25.0),
                                      child: Offstage(offstage: false, child: _buildContentWidget(context, orientation)),
                                    ),
                                  Align(
                                    alignment: Alignment.topCenter,
                                    child: _buildController(Colors.transparent, Colors.white, 100, context.getWidth(), SizeConfig.screenHeight! * 0.8, orientation),
                                  ),
                                  // if (Platform.isIOS)
                                  AnimatedOpacity(
                                    opacity: onTapCtrl || isPause ? 1.0 : 0.0,
                                    duration: const Duration(milliseconds: 500),
                                    onEnd: _onPlayerHide,
                                    child: Container(
                                      height: orientation == Orientation.portrait ? kToolbarHeight * 2 : kToolbarHeight * 1.4,
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18.0),
                                      child: CustomAppBar(
                                          orientation: orientation,
                                          data: widget.data,
                                          currentPosition: _currentPosition,
                                          currentPositionText: _currentPositionText,
                                          email: email,
                                          lang: lang!,
                                          videoDuration: _videoDuration,
                                          showTipsWidget: _showTipsWidget,
                                          isMute: isMute,
                                          onTapOnProfileImage: () async {
                                            var res = await System().navigateToProfile(context, widget.data.email ?? '');
                                            widget.fAliplayer?.pause();
                                            isPause = true;
                                            setState(() {});
                                            print('data result $res');
                                            // if (mounted){
                                            if ((widget.data.metadata?.height ?? 0) < (widget.data.metadata?.width ?? 0)) {
                                              print('Landscape VidPlayerPage');
                                              SystemChrome.setPreferredOrientations([
                                                DeviceOrientation.landscapeLeft,
                                                DeviceOrientation.landscapeRight,
                                              ]);
                                            } else {
                                              print('Portrait VidPlayerPage');
                                              SystemChrome.setPreferredOrientations([
                                                DeviceOrientation.portraitUp,
                                                DeviceOrientation.portraitDown,
                                              ]);
                                            }
                                            // }
                                          },
                                          onTap: () {
                                            context.handleActionIsGuest(() async {
                                              if (widget.data.email != email) {
                                                // FlutterAliplayer? fAliplayer
                                                context.read<PreviewPicNotifier>().reportContent(context, widget.data, fAliplayer: widget.data.fAliplayer, onCompleted: () async {
                                                  imageCache.clear();
                                                  imageCache.clearLiveImages();
                                                  await (Routing.navigatorKey.currentContext ?? context).read<HomeNotifier>().initNewHome(context, mounted, isreload: true, forceIndex: 2);
                                                });
                                                isPause = true;
                                                setState(() {});
                                              } else {
                                                // if (_curIdx != -1) {
                                                //   "=============== pause 11".logger();
                                                //   notifier.vidData?[_curIdx].fAliplayer?.pause();
                                                // }
                                                widget.data.fAliplayer?.pause();
                                                isPause = true;
                                                setState(() {});
                                                await ShowBottomSheet().onShowOptionContent(
                                                  context,
                                                  contentData: widget.data,
                                                  captionTitle: hyppeVid,
                                                  onDetail: false,
                                                  isShare: widget.data.isShared,
                                                  onUpdate: () {
                                                    (Routing.navigatorKey.currentContext ?? context).read<HomeNotifier>().initNewHome(context, mounted, isreload: true, forceIndex: 2);
                                                  },
                                                  fAliplayer: widget.data.fAliplayer,
                                                );
                                              }
                                            });
                                          }),
                                    ),
                                  ),
                                  if (isLoadingVid)
                                    Container(
                                      width: context.getWidth(),
                                      height: SizeConfig.screenHeight,
                                      padding: EdgeInsets.only(bottom: 20),
                                      color: Colors.transparent,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          const CircularProgressIndicator(),
                                          sixPx,
                                          Text(
                                            "$_loadingPercent%",
                                            style: TextStyle(color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ),
                                  if (notifier.isShowingAds && !notifier.hasShowedAds)
                                    Container(
                                      width: context.getWidth(),
                                      height: SizeConfig.screenHeight,
                                      decoration: const BoxDecoration(color: Colors.black),
                                      child: notifier.adsAliPlayerView,
                                    ),
                                  if (notifier.isShowingAds && !notifier.hasShowedAds)
                                    SizedBox(
                                      width: context.getWidth(),
                                      height: SizeConfig.screenHeight,
                                      // padding: EdgeInsets.only(bottom: 25.0),
                                      child: Offstage(offstage: false, child: _adsBuildContentWidget(context, Orientation.portrait, notifier)),
                                    ),
                                  checkDetail(context, notifier),
                                ],
                              ),
                            ),
                          );
                        }
                      })
                  : GestureDetector(
                      onTap: () {
                        onTapCtrl = true;
                        setState(() {});
                      },
                      child: Stack(
                        children: [
                          Container(
                            width: context.getWidth(),
                            height: SizeConfig.screenHeight,
                            decoration: const BoxDecoration(color: Colors.black),
                            child: widget.aliPlayerView,
                          ),
                          if (!_showTipsWidget)
                            SizedBox(
                              width: context.getWidth(),
                              height: SizeConfig.screenHeight,
                              // padding: EdgeInsets.only(bottom: 25.0),
                              child: Offstage(offstage: false, child: _buildContentWidget(context, orientation)),
                            ),
                          Align(
                            alignment: Alignment.topCenter,
                            child: _buildController(Colors.transparent, Colors.white, 100, context.getWidth(), SizeConfig.screenHeight! * 0.8, orientation),
                          ),
                          // if (Platform.isIOS)
                          Align(
                            alignment: Alignment.topRight,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: IconButton(
                                onPressed: () {
                                  int changevalue;
                                  changevalue = _currentPosition + 1000;
                                  if (changevalue > _videoDuration) {
                                    changevalue = _videoDuration;
                                  }
                                  widget.data.isLoading = true;
                                  setState(() {});
                                  Navigator.pop(context,
                                      VideoIndicator(videoDuration: _videoDuration, seekValue: changevalue, positionText: _currentPositionText, showTipsWidget: _showTipsWidget, isMute: isMute));
                                },
                                padding:
                                    orientation == Orientation.portrait ? const EdgeInsets.symmetric(horizontal: 8.0, vertical: 42.0) : const EdgeInsets.symmetric(horizontal: 46.0, vertical: 8.0),
                                icon: const CustomIconWidget(iconData: "${AssetPath.vectorPath}close.svg", defaultColor: false),
                              ),
                            ),
                          ),
                          if (isLoadingVid)
                            Container(
                              width: context.getWidth(),
                              height: SizeConfig.screenHeight,
                              padding: EdgeInsets.only(bottom: 20),
                              color: Colors.transparent,
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const CircularProgressIndicator(),
                                  sixPx,
                                  Text(
                                    "$_loadingPercent%",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          if (notifier.isShowingAds && !notifier.hasShowedAds)
                            Container(
                              width: context.getWidth(),
                              height: SizeConfig.screenHeight,
                              decoration: const BoxDecoration(color: Colors.black),
                              child: notifier.adsAliPlayerView,
                            ),
                          if (notifier.isShowingAds && !notifier.hasShowedAds)
                            SizedBox(
                              width: context.getWidth(),
                              height: SizeConfig.screenHeight,
                              // padding: EdgeInsets.only(bottom: 25.0),
                              child: Offstage(offstage: false, child: _adsBuildContentWidget(context, Orientation.portrait, notifier)),
                            ),
                          checkDetail(context, notifier),
                        ],
                      ),
                    ),
        ),
      );
    });
    // return WillPopScope(
    //   onWillPop: () async {
    //     widget.fAliplayer?.pause();
    //     return true;
    //   },
    //   child: Material(
    //     child: Container(
    //       width: context.getWidth(),
    //       height: context.getHeight(),
    //       decoration: const BoxDecoration(color: Colors.black),
    //       child: VidPlayerPage(
    //         playMode: (widget.data.isApsara ?? false) ? ModeTypeAliPLayer.auth : ModeTypeAliPLayer.url,
    //         dataSourceMap: map,
    //         data: widget.data,
    //         functionFullTriger: widget.onClose,
    //         inLanding: true,
    //         orientation: Orientation.landscape,
    //         seekValue: widget.seekValue,
    //       ),
    //     ),
    //   ),
    // );
  }

  Widget checkDetail(BuildContext context, VideoNotifier notifier) {
    print('checkDetail: ${notifier.isShowingAds} ${!notifier.hasShowedAds} ${notifier.mapInContentAds[widget.data.postID]?.adsId} ${notifier.tempAdsData?.adsId}');
    if (notifier.isShowingAds && !notifier.hasShowedAds) {
      return detailAdsWidget(context, notifier.mapInContentAds[widget.data.postID] ?? (notifier.tempAdsData ?? AdsData()), notifier);
    } else {
      return const SizedBox.shrink();
    }
  }

  double heightSkip = 0;
  bool loadLaunch = false;
  Widget detailAdsWidget(BuildContext context, AdsData data, VideoNotifier notifier) {
    final isPortrait = orientation == Orientation.portrait;
    final width = isPortrait ? context.getWidth() * 2 / 3 : context.getWidth() * 2 / 5;
    final bottom = isPortrait ? 80.0 : 50.0;
    return Positioned(
      bottom: bottom,
      left: 0,
      child: Container(
        width: width,
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                margin: const EdgeInsets.only(left: 16),
                child: CustomTextWidget(
                  textToDisplay: data.adsDescription ?? '',
                  textStyle: const TextStyle(color: Colors.white, fontSize: 12),
                )),
            twelvePx,
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: const BoxDecoration(color: kHyppeLightSurface),
              child: Row(
                children: [
                  CustomBaseCacheImage(
                    imageUrl: data.avatar?.fullLinkURL,
                    memCacheWidth: 200,
                    memCacheHeight: 200,
                    imageBuilder: (_, imageProvider) {
                      return Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(Radius.circular(12)),
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: imageProvider,
                          ),
                        ),
                      );
                    },
                    errorWidget: (_, url, ___) {
                      if (url.isNotEmpty && url.withHttp()) {
                        return ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Image.network(url, width: 36, height: 36, fit: BoxFit.cover, loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null,
                                  ),
                                ),
                              );
                            }, errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                              return Container(
                                width: 36,
                                height: 36,
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(18)),
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: AssetImage('${AssetPath.pngPath}profile-error.jpg'),
                                  ),
                                ),
                              );
                            }));
                      }
                      return Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: AssetImage('${AssetPath.pngPath}profile-error.jpg'),
                          ),
                        ),
                      );
                    },
                    emptyWidget: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: AssetImage('${AssetPath.pngPath}profile-error.jpg'),
                        ),
                      ),
                    ),
                  ),
                  tenPx,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomTextWidget(
                          textToDisplay: data.fullName ?? '',
                          textStyle: context.getTextTheme().caption?.copyWith(fontWeight: FontWeight.w700, color: Colors.black),
                        ),
                        fourPx,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            CustomTextWidget(
                              textToDisplay: 'Ad ·',
                              textStyle: context.getTextTheme().caption?.copyWith(fontWeight: FontWeight.w700, color: Colors.black),
                            ),
                            Expanded(
                                child: CustomTextWidget(
                              textAlign: TextAlign.start,
                              textToDisplay: ' ${data.adsUrlLink}',
                              textStyle: context.getTextTheme().caption,
                              maxLines: 1,
                              textOverflow: TextOverflow.ellipsis,
                            )),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: Ink(
                      width: 120,
                      decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(5)), color: notifier.secondsSkip <= 0 ? KHyppeButtonAds : context.getColorScheme().secondary),
                      child: InkWell(
                        splashColor: context.getColorScheme().secondary,
                        onTap: () async {
                          if (notifier.secondsSkip <= 0) {
                            final secondsVideo = data.duration?.round() ?? 10;
                            if (!loadLaunch) {
                              if (data.adsUrlLink?.isEmail() ?? false) {
                                final email = data.adsUrlLink!.replaceAll('email:', '');
                                setState(() {
                                  loadLaunch = true;
                                });
                                print('second close ads: $secondsVideo');
                                System().adsView(data, secondsVideo, isClick: true).whenComplete(() {
                                  notifier.adsAliplayer?.stop();
                                  notifier.adsCurrentPosition = 0;
                                  notifier.adsCurrentPositionText = 0;
                                  notifier.hasShowedAds = true;
                                  notifier.tempAdsData = null;
                                  notifier.isShowingAds = false;
                                  widget.onClose();
                                  Future.delayed(const Duration(milliseconds: 800), () {
                                    Routing().move(Routes.otherProfile, argument: OtherProfileArgument(senderEmail: email));
                                  });
                                  setState(() {
                                    loadLaunch = false;
                                  });
                                });
                              } else {
                                if ((data.adsUrlLink ?? '').withHttp()) {
                                  try {
                                    final uri = Uri.parse(data.adsUrlLink ?? '');
                                    print('bottomAdsLayout ${data.adsUrlLink}');
                                    if (await canLaunchUrl(uri)) {
                                      setState(() {
                                        loadLaunch = true;
                                      });
                                      print('second close ads: $secondsVideo');
                                      System().adsView(data, secondsVideo, isClick: true).whenComplete(() async {
                                        notifier.adsAliplayer?.stop();
                                        notifier.adsCurrentPosition = 0;
                                        notifier.adsCurrentPositionText = 0;
                                        notifier.hasShowedAds = true;
                                        notifier.tempAdsData = null;
                                        notifier.isShowingAds = false;
                                        widget.onClose();
                                        await launchUrl(
                                          uri,
                                          mode: LaunchMode.externalApplication,
                                        );
                                      });
                                    } else {
                                      throw "Could not launch $uri";
                                    }
                                    // can't launch url, there is some error
                                  } catch (e) {
                                    setState(() {
                                      loadLaunch = true;
                                    });
                                    print('second close ads: $secondsVideo');
                                    // System().goToWebScreen(data.adsUrlLink ?? '', isPop: true);
                                    System().adsView(data, secondsVideo, isClick: true).whenComplete(() {
                                      notifier.adsAliplayer?.stop();
                                      notifier.adsCurrentPosition = 0;
                                      notifier.adsCurrentPositionText = 0;
                                      notifier.hasShowedAds = true;
                                      notifier.tempAdsData = null;
                                      notifier.isShowingAds = false;
                                      widget.onClose();
                                      System().goToWebScreen(data.adsUrlLink ?? '', isPop: true);
                                    });
                                  } finally {
                                    setState(() {
                                      loadLaunch = false;
                                    });
                                  }
                                }
                              }
                            }
                          }
                        },
                        child: Builder(
                          builder: (context) {
                            return Container(
                              padding: const EdgeInsets.all(10),
                              alignment: Alignment.center,
                              child: Text(
                                data.ctaButton ?? 'Learn More',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  _adsBuildContentWidget(BuildContext context, Orientation orientation, VideoNotifier notifier) {
    // print('ORIENTATION: CHANGING ORIENTATION');
    return SafeArea(
      child: notifier.adsCurrentPosition <= 0
          ? Container()
          : Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(flex: 16, child: SizedBox.shrink()),
                    Expanded(
                      flex: 14,
                      child: InkWell(
                        onTap: () async {
                          if (notifier.secondsSkip <= 0) {
                            notifier.hasShowedAds = true;
                            notifier.adsAliplayer?.stop();
                            notifier.adsCurrentPosition = 0;
                            notifier.adsCurrentPositionText = 0;
                            if (_currentPosition > 0) {
                              await widget.fAliplayer?.seekTo(_currentPosition - 1, FlutterAvpdef.ACCURATE);
                            }
                            widget.onClose();
                            notifier.loadVideo = true;
                            // setState(() {
                            //   isloading = true;
                            // });
                            Future.delayed(const Duration(seconds: 1), () {
                              notifier.loadVideo = false;
                              setState(() {
                                // isloading = false;
                                isPause = false;
                                _showTipsWidget = false;
                              });
                              widget.fAliplayer?.play();
                            });
                          }
                        },
                        child: Row(
                          children: [
                            Expanded(
                              flex: 96,
                              child: MeasuredSize(
                                onChange: (size) {
                                  setState(() {
                                    heightSkip = size.height;
                                  });
                                },
                                child: Container(
                                  color: Colors.black.withOpacity(0.5),
                                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                  child: Builder(builder: (context) {
                                    final language = context.read<TranslateNotifierV2>().translate;
                                    final locale = SharedPreference().readStorage(SpKeys.isoCode);
                                    final isIndo = locale == 'id';
                                    return notifier.secondsSkip <= 0
                                        ? Row(
                                            children: [
                                              Expanded(
                                                  child: CustomTextWidget(
                                                textToDisplay: language.skipAds ?? 'Skip Ads',
                                                textStyle: context.getTextTheme().caption?.copyWith(color: Colors.white),
                                                maxLines: 2,
                                              )),
                                              const Icon(
                                                Icons.skip_next,
                                                color: Colors.white,
                                              )
                                            ],
                                          )
                                        : CustomTextWidget(
                                            textToDisplay: isIndo ? '${language.skipMessage} ${notifier.secondsSkip} ${language.second}' : "${language.skipMessage} ${notifier.secondsSkip}",
                                            textStyle: context.getTextTheme().overline?.copyWith(color: Colors.white),
                                            maxLines: 2,
                                          );
                                  }),
                                ),
                              ),
                            ),
                            Expanded(
                                flex: 40,
                                child: CustomCacheImage(
                                  // imageUrl: picData.content[arguments].contentUrl,
                                  imageUrl: widget.thumbnail,
                                  imageBuilder: (_, imageProvider) {
                                    return Container(
                                      height: heightSkip,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(image: imageProvider, fit: BoxFit.contain),
                                      ),
                                    );
                                  },
                                  errorWidget: (_, __, ___) {
                                    return Container(
                                      height: heightSkip,
                                      decoration: const BoxDecoration(
                                        image: DecorationImage(
                                          fit: BoxFit.contain,
                                          image: AssetImage('${AssetPath.pngPath}content-error.png'),
                                        ),
                                      ),
                                    );
                                  },
                                  emptyWidget: Container(
                                    height: heightSkip,
                                    decoration: const BoxDecoration(
                                      image: DecorationImage(
                                        fit: BoxFit.contain,
                                        image: AssetImage('${AssetPath.pngPath}content-error.png'),
                                      ),
                                    ),
                                  ),
                                ))
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      sixPx,
                      Text(
                        System.getTimeformatByMs(notifier.adsCurrentPositionText),
                        style: const TextStyle(color: Colors.white, fontSize: 11),
                      ),
                      sixPx,
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            overlayShape: SliderComponentShape.noThumb,
                            activeTrackColor: const Color(0xAA7d7d7d),
                            inactiveTrackColor: const Color.fromARGB(170, 156, 155, 155),
                            // trackShape: RectangularSliderTrackShape(),
                            trackHeight: 3.0,
                            thumbColor: Colors.purple,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
                          ),
                          child: Slider(
                              min: 0,
                              max: notifier.adsVideoDuration.toDouble(),
                              value: notifier.adsCurrentPosition.toDouble(),
                              activeColor: kHyppeAdsProgress,
                              thumbColor: kHyppeAdsProgress,
                              onChangeStart: (value) {},
                              onChangeEnd: (value) {},
                              onChanged: (value) {}),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isMute = !isMute;
                          });
                          notifier.adsAliplayer?.setMuted(isMute);
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 2.0),
                          child: CustomIconWidget(
                            iconData: isMute ? '${AssetPath.vectorPath}sound-off.svg' : '${AssetPath.vectorPath}sound-on.svg',
                            defaultColor: false,
                            height: 24,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          int changevalue;
                          changevalue = _currentPosition + 1000;
                          if (changevalue > _videoDuration) {
                            changevalue = _videoDuration;
                          }
                          widget.data.isLoading = true;
                          setState(() {});
                          Navigator.pop(
                              context, VideoIndicator(videoDuration: _videoDuration, seekValue: changevalue, positionText: _currentPositionText, showTipsWidget: _showTipsWidget, isMute: isMute));
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 12.0),
                          child: Icon(
                            orientation == Orientation.portrait ? Icons.fullscreen : Icons.fullscreen_exit,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  _buildContentWidget(BuildContext context, Orientation orientation) {
    // print('ORIENTATION: CHANGING ORIENTATION');
    return AnimatedOpacity(
      opacity: onTapCtrl || isPause ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      onEnd: _onPlayerHide,
      child: SafeArea(
        child: Container(
          decoration: orientation == Orientation.portrait
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    end: const Alignment(0.0, -1),
                    begin: const Alignment(0.0, 1),
                    colors: [const Color(0x8A000000), Colors.black12.withOpacity(0.0)],
                  ),
                )
              : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18.0),
            child: Stack(
              children: [
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Column(
                    children: [
                      Consumer<LikeNotifier>(
                          builder: (context, likeNotifier, child) => buttonVideoRight(
                              onFunctionTap: () {
                                likeNotifier.likePost(context, widget.data);
                              },
                              iconData: '${AssetPath.vectorPath}${(widget.data.insight?.isPostLiked ?? false) ? 'liked.svg' : 'love-shadow.svg'}',
                              value: widget.data.insight!.likes! > 0 ? '${widget.data.insight?.likes}' : '${lang?.like}',
                              liked: widget.data.insight?.isPostLiked ?? false)),
                      if (widget.data.allowComments ?? false)
                        buttonVideoRight(
                          onFunctionTap: () {
                            Routing().move(Routes.commentsDetail, argument: CommentsArgument(postID: widget.data.postID ?? '', fromFront: true, data: widget.data, pageDetail: true));
                          },
                          iconData: '${AssetPath.vectorPath}comment-shadow.svg',
                          value: widget.data.comments! > 0 ? widget.data.comments.toString() : lang?.comments ?? '',
                        ),
                      if (widget.data.isShared ?? false)
                        buttonVideoRight(
                            onFunctionTap: () {
                              widget.fAliplayer?.pause();
                              context.read<VidDetailNotifier>().createdDynamicLink(context, data: widget.data);
                            },
                            iconData: '${AssetPath.vectorPath}share-shadow.svg',
                            value: lang!.share ?? 'Share'),
                      if ((widget.data.saleAmount ?? 0) > 0 && email != widget.data.email)
                        buttonVideoRight(
                            onFunctionTap: () async {
                              widget.data.fAliplayer?.pause();
                              await ShowBottomSheet.onBuyContent(context, data: widget.data, fAliplayer: widget.data.fAliplayer);
                            },
                            iconData: '${AssetPath.vectorPath}cart-shadow.svg',
                            value: lang!.buy ?? 'Buy'),
                    ],
                  ),
                ),

                // Edited Data Next
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: orientation == Orientation.landscape ? SizeConfig.screenHeight! * .2 : SizeConfig.screenHeight! * .07,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          children: [
                            Visibility(
                              visible: widget.data.tagPeople?.isNotEmpty ?? false,
                              child: Container(
                                decoration: BoxDecoration(color: kHyppeBackground.withOpacity(.4), borderRadius: BorderRadius.circular(8.0)),
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                                margin: const EdgeInsets.only(right: 12.0),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      widget.fAliplayer?.pause();
                                      context
                                          .read<PicDetailNotifier>()
                                          .showUserTag(context, widget.data.tagPeople, widget.data.postID, title: lang!.inThisVideo, fAliplayer: widget.fAliplayer, orientation: orientation);
                                      setState(() {
                                        isPause = true;
                                      });
                                    },
                                    child: Row(
                                      children: [
                                        const CustomIconWidget(
                                          iconData: '${AssetPath.vectorPath}tag-people-light.svg',
                                          defaultColor: false,
                                          height: 18,
                                        ),
                                        const SizedBox(
                                          width: 4.0,
                                        ),
                                        Text(
                                          '${widget.data.tagPeople!.length} ${lang!.people}',
                                          style: const TextStyle(color: kHyppeTextPrimary),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Visibility(
                              visible: widget.data.location != '',
                              child: Container(
                                // width: SizeConfig.screenWidth! * .18,
                                decoration: BoxDecoration(color: kHyppeBackground.withOpacity(.4), borderRadius: BorderRadius.circular(8.0)),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
                                child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                    ),
                                    child: location()),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        constraints: BoxConstraints(
                            maxWidth: orientation == Orientation.landscape ? SizeConfig.screenWidth! * .29 : SizeConfig.screenWidth!, maxHeight: isShowMore ? 52 : SizeConfig.screenHeight! * .1),
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        padding: const EdgeInsets.only(left: 8.0, bottom: 12.0),
                        child: SingleChildScrollView(
                          child: CustomDescContent(
                            desc: "${widget.data.description}",
                            trimLines: 2,
                            textAlign: TextAlign.start,
                            callbackIsMore: (val) {
                              setState(() {
                                onTapCtrl = true;
                                isShowMore = val;
                              });
                            },
                            seeLess: ' ${lang?.less}', // ${notifier2.translate.seeLess}',
                            seeMore: ' ${lang?.more}', //${notifier2.translate.seeMoreContent}',
                            normStyle: const TextStyle(fontSize: 14, color: kHyppeTextPrimary),
                            hrefStyle: Theme.of(context).textTheme.subtitle2?.copyWith(color: kHyppePrimary),
                            expandStyle: Theme.of(context).textTheme.subtitle2?.copyWith(color: kHyppeTextPrimary, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      SharedPreference().readStorage(SpKeys.statusVerificationId) == VERIFIED &&
                              (widget.data.boosted.isEmpty) &&
                              (widget.data.reportedStatus != 'OWNED' && widget.data.reportedStatus != 'BLURRED' && widget.data.reportedStatus2 != 'BLURRED') &&
                              widget.data.email == SharedPreference().readStorage(SpKeys.email)
                          ? Container(
                              width: orientation == Orientation.landscape ? SizeConfig.screenWidth! * .28 : SizeConfig.screenWidth!,
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.only(top: 12, left: 8.0, right: 8.0),
                              child: ButtonBoost(
                                onDetail: false,
                                marginBool: true,
                                contentData: widget.data,
                                startState: () {
                                  SharedPreference().writeStorage(SpKeys.isShowPopAds, true);
                                },
                                afterState: () {
                                  SharedPreference().writeStorage(SpKeys.isShowPopAds, false);
                                },
                              ),
                            )
                          : Container(),
                      if (widget.data.email == email && (widget.data.boostCount ?? 0) >= 0 && (widget.data.boosted.isNotEmpty))
                        Container(
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.only(bottom: 10, left: 18.0),
                          width: MediaQuery.of(context).size.width * .75,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: kHyppeGreyLight.withOpacity(.9),
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
                                  textToDisplay: "${widget.data.boostJangkauan ?? '0'} ${lang?.reach}",
                                  textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kHyppeTextLightPrimary),
                                ),
                              )
                            ],
                          ),
                        ),
                      Column(
                        children: [
                          Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 6.0),
                              child: Text(
                                "${System.getTimeformatByMs(_currentPositionText)}/${System.getTimeformatByMs(_videoDuration)}",
                                textAlign: TextAlign.end,
                                style: const TextStyle(color: Colors.white, fontSize: 11),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      overlayShape: SliderComponentShape.noThumb,
                                      activeTrackColor: const Color(0xAA7d7d7d),
                                      inactiveTrackColor: const Color.fromARGB(170, 156, 155, 155),
                                      // trackShape: RectangularSliderTrackShape(),
                                      trackHeight: 3.0,
                                      thumbColor: Colors.purple,
                                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
                                    ),
                                    child: Slider(
                                        min: 0,
                                        max: _videoDuration == 0 ? 1 : _videoDuration.toDouble(),
                                        value: _currentPosition.toDouble(),
                                        activeColor: Colors.purple,
                                        // trackColor: Color(0xAA7d7d7d),
                                        thumbColor: Colors.purple,
                                        onChangeStart: (value) {
                                          _inSeek = true;
                                          // _showLoading = false;
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
                                          // isActiveAds
                                          //     ? fAliplayerAds?.seekTo(value.ceil(), GlobalSettings.mEnableAccurateSeek ? FlutterAvpdef.ACCURATE : FlutterAvpdef.INACCURATE)
                                          //     : fAliplayer?.seekTo(value.ceil(), GlobalSettings.mEnableAccurateSeek ? FlutterAvpdef.ACCURATE : FlutterAvpdef.INACCURATE);
                                          widget.fAliplayer?.seekTo(value.ceil(), FlutterAvpdef.ACCURATE);
                                        },
                                        onChanged: (value) {
                                          print('on change');

                                          widget.fAliplayer?.requestBitmapAtPosition(value.ceil());

                                          setState(() {
                                            _currentPosition = value.ceil();
                                          });
                                        }),
                                  ),
                                ),
                                // GestureDetector(
                                //   onTap: () {
                                //     setState(() {
                                //       isMute = !isMute;
                                //     });
                                //     widget.fAliplayer?.setMuted(isMute);
                                //   },
                                //   child: Padding(
                                //     padding: const EdgeInsets.only(right: 2.0),
                                //     child: CustomIconWidget(
                                //       iconData: isMute ? '${AssetPath.vectorPath}sound-off.svg' : '${AssetPath.vectorPath}sound-on.svg',
                                //       defaultColor: false,
                                //       height: 24,
                                //     ),
                                //   ),
                                // ),
                                // GestureDetector(
                                //   onTap: () async {
                                //     int changevalue;
                                //     changevalue = _currentPosition + 1000;
                                //     if (changevalue > _videoDuration) {
                                //       changevalue = _videoDuration;
                                //     }
                                //     widget.data.isLoading = true;
                                //     setState(() {});
                                //     Navigator.pop(context, VideoIndicator(videoDuration: _videoDuration, seekValue: changevalue, positionText: _currentPositionText, showTipsWidget: _showTipsWidget, isMute: isMute));
                                //   },
                                //   child: const Padding(
                                //     padding: EdgeInsets.only(right: 12.0),
                                //     child: Icon(
                                //       Icons.fullscreen_exit,
                                //       color: Colors.white,
                                //     ),
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (widget.data.music?.musicTitle != '' && widget.data.music?.musicTitle != null)
                        SizedBox(
                          height: 42,
                          width: SizeConfig.screenWidth,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 0.0, left: 8.0, right: 12.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const CustomIconWidget(
                                  iconData: "${AssetPath.vectorPath}music_stroke_black.svg",
                                  defaultColor: false,
                                  color: kHyppeLightBackground,
                                  height: 18,
                                ),
                                SizedBox(
                                  width: SizeConfig.screenWidth! * .55,
                                  child: _textSize(widget.data.music?.musicTitle ?? '', const TextStyle(fontWeight: FontWeight.bold)).width > SizeConfig.screenWidth! * .56
                                      ? Marquee(
                                          text: '  ${widget.data.music?.musicTitle ?? ''}',
                                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white),
                                        )
                                      : CustomTextWidget(
                                          textToDisplay: " ${widget.data.music?.musicTitle ?? ''}",
                                          maxLines: 1,
                                          textStyle: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                                          textAlign: TextAlign.left,
                                        ),
                                ),
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: kHyppeSurface.withOpacity(.9),
                                  child: CustomBaseCacheImage(
                                    imageUrl: widget.data.music?.apsaraThumnailUrl ?? '',
                                    imageBuilder: (_, imageProvider) {
                                      return Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: kDefaultIconDarkColor,
                                          borderRadius: const BorderRadius.all(Radius.circular(24)),
                                          image: DecorationImage(
                                            fit: BoxFit.cover,
                                            image: imageProvider,
                                          ),
                                        ),
                                      );
                                    },
                                    errorWidget: (_, __, ___) {
                                      return const CustomIconWidget(
                                        iconData: "${AssetPath.vectorPath}music_stroke_black.svg",
                                        defaultColor: false,
                                        color: kHyppeLightIcon,
                                        height: 18,
                                      );
                                    },
                                    emptyWidget: AnimatedBuilder(
                                      animation: animatedController,
                                      builder: (_, child) {
                                        return Transform.rotate(
                                          angle: animatedController.value * 2 * -math.pi,
                                          child: child,
                                        );
                                      },
                                      child: const CustomIconWidget(
                                        iconData: "${AssetPath.vectorPath}music_stroke_black.svg",
                                        defaultColor: false,
                                        color: kHyppeLightIcon,
                                        height: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onPlayerHide() {
    Future.delayed(const Duration(seconds: 4), () {
      if (!isScrolling) {
        onTapCtrl = false;
      }
      // setState(() {});
    });
  }

  Widget _buildController(
    Color backgroundColor,
    Color iconColor,
    double barHeight,
    double width,
    double height,
    Orientation orientation,
  ) {
    return AnimatedOpacity(
      opacity: onTapCtrl || isPause ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      onEnd: _onPlayerHide,
      child: Center(
        child: Container(
          width: orientation == Orientation.landscape ? width * .35 : width * .8,
          decoration: BoxDecoration(
            color: backgroundColor,
          ),
          child: _showTipsWidget
              ? Center(
                  child: GestureDetector(
                    onTap: () {
                      widget.fAliplayer?.prepare();
                      widget.fAliplayer?.play();
                      setState(() {
                        isPause = false;
                        _showTipsWidget = false;
                      });
                    },
                    child: const CustomIconWidget(
                      iconData: "${AssetPath.vectorPath}pause3.svg",
                      defaultColor: false,
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSkipPrev(iconColor, barHeight),
                    _buildSkipBack(iconColor, barHeight),
                    _buildPlayPause(iconColor, barHeight),
                    _buildSkipForward(iconColor, barHeight),
                    _buildSkipNext(iconColor, barHeight),
                  ],
                ),
        ),
      ),
    );
  }

  GestureDetector _buildPlayPause(
    Color iconColor,
    double barHeight,
  ) {
    return GestureDetector(
      onTap: () {
        if (isPause) {
          // if (_showTipsWidget) fAliplayer?.prepare();
          widget.fAliplayer?.play();
          isPause = false;
          setState(() {});
        } else {
          widget.fAliplayer?.pause();
          isPause = true;
          setState(() {});
        }
        if (_showTipsWidget) {
          widget.fAliplayer?.prepare();
          widget.fAliplayer?.play();
        }
      },
      child: CustomIconWidget(
        iconData: isPause ? "${AssetPath.vectorPath}play3.svg" : "${AssetPath.vectorPath}pause3.svg",
        defaultColor: false,
      ),
      // Icon(
      //   isPause ? Icons.pause : Icons.play_arrow_rounded,
      //   color: iconColor,
      //   size: 200,
      // ),
    );
  }

  GestureDetector _buildSkipPrev(Color iconColor, double barHeight) {
    return GestureDetector(
      onTap: () {
        if (!onTapCtrl) return;
        previousPage();
      },
      child: const CustomIconWidget(
        iconData: "${AssetPath.vectorPath}previous.svg",
        defaultColor: false,
      ),
    );
  }

  GestureDetector _buildSkipNext(Color iconColor, double barHeight) {
    return GestureDetector(
      onTap: () {
        if (!onTapCtrl) return;
        nextPage();
      },
      child: const CustomIconWidget(
        iconData: "${AssetPath.vectorPath}next.svg",
        defaultColor: false,
      ),
    );
  }

  GestureDetector _buildSkipBack(Color iconColor, double barHeight) {
    return GestureDetector(
      onTap: () {
        if (!onTapCtrl) return;
        int value;
        int changevalue;
        if (_videoDuration > 60000) {
          value = 10000;
        } else {
          value = 5000;
        }

        changevalue = _currentPosition - value;
        if (changevalue < 0) {
          changevalue = 0;
        }
        widget.fAliplayer?.requestBitmapAtPosition(changevalue);
        setState(() {
          _currentPosition = changevalue;
        });
        _inSeek = false;
        setState(() {
          if (_currentPlayerState == FlutterAvpdef.completion && _showTipsWidget) {
            setState(() {
              _showTipsWidget = false;
            });
          }
        });
        // fAliplayer?.seekTo(changevalue, GlobalSettings.mEnableAccurateSeek ? FlutterAvpdef.ACCURATE : FlutterAvpdef.INACCURATE);
        widget.fAliplayer?.seekTo(changevalue, FlutterAvpdef.ACCURATE);
      },
      child: const CustomIconWidget(
        iconData: "${AssetPath.vectorPath}replay10.svg",
        defaultColor: false,
      ),
    );
  }

  GestureDetector _buildSkipForward(Color iconColor, double barHeight) {
    return GestureDetector(
      onTap: () {
        if (!onTapCtrl) return;
        int value;
        int changevalue;
        if (_videoDuration > 60000) {
          value = 10000;
        } else {
          value = 5000;
        }
        changevalue = _currentPosition + value;
        if (changevalue > _videoDuration) {
          changevalue = _videoDuration;
        }
        widget.fAliplayer?.requestBitmapAtPosition(changevalue);
        setState(() {
          _currentPosition = changevalue;
        });
        _inSeek = false;
        setState(() {
          if (_currentPlayerState == FlutterAvpdef.completion && _showTipsWidget) {
            setState(() {
              _showTipsWidget = false;
            });
          }
        });
        // fAliplayer?.seekTo(changevalue, GlobalSettings.mEnableAccurateSeek ? FlutterAvpdef.ACCURATE : FlutterAvpdef.INACCURATE);
        widget.fAliplayer?.seekTo(changevalue, FlutterAvpdef.ACCURATE);
      },
      child: const CustomIconWidget(
        iconData: "${AssetPath.vectorPath}forward10.svg",
        defaultColor: false,
      ),
    );
  }

  Widget buttonVideoRight({Function()? onFunctionTap, required String iconData, required String value, bool liked = false}) {
    return InkResponse(
      onTap: onFunctionTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: onFunctionTap,
              child: CustomIconWidget(
                defaultColor: false,
                color: liked ? kHyppeRed : kHyppePrimaryTransparent,
                iconData: iconData,
                height: liked ? 24 : 38,
                width: 38,
              ),
            ),
            if (liked)
              const SizedBox(
                height: 10.0,
              ),
            Container(
              transform: Matrix4.translationValues(0.0, -5.0, 0.0),
              child: Text(
                value,
                style: const TextStyle(shadows: [
                  Shadow(offset: Offset(0.0, 1.0), blurRadius: 2.0, color: Colors.black54),
                  Shadow(offset: Offset(0.0, 1.0), blurRadius: 8.0, color: Colors.black54),
                ], color: kHyppePrimaryTransparent, fontWeight: FontWeight.w500, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Size _textSize(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(text: TextSpan(text: text, style: style), maxLines: 1, textDirection: TextDirection.ltr)..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size;
  }

  Widget location() {
    switch (orientation) {
      case Orientation.portrait:
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const CustomIconWidget(
              iconData: '${AssetPath.vectorPath}map-light.svg',
              defaultColor: false,
              height: 16,
            ),
            const SizedBox(
              width: 4.0,
            ),
            SizedBox(
              width: widget.data.tagPeople?.isNotEmpty ?? false ? SizeConfig.screenWidth! * .4 : SizeConfig.screenWidth! * .65,
              child: Text(
                '${widget.data.location}',
                maxLines: 1,
                style: const TextStyle(color: kHyppeLightBackground),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );

      default:
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const CustomIconWidget(
              iconData: '${AssetPath.vectorPath}map-light.svg',
              defaultColor: false,
              height: 16,
            ),
            const SizedBox(
              width: 4.0,
            ),
            SizedBox(
              width: widget.data.tagPeople?.isNotEmpty ?? false ? SizeConfig.screenWidth! * .13 : SizeConfig.screenWidth! * .22,
              child: Text(
                '${widget.data.location}',
                maxLines: 1,
                style: const TextStyle(color: kHyppeLightBackground),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
    }
  }
}

class VideoIndicator {
  final int? videoDuration;
  final int? seekValue;
  final int? positionText;
  final bool? showTipsWidget;
  final bool? isMute;
  VideoIndicator({required this.videoDuration, required this.seekValue, required this.positionText, this.showTipsWidget = false, required this.isMute});
}
