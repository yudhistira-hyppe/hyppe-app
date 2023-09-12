import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_aliplayer/flutter_aliplayer.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/widget/after_first_layout_mixin.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/widget/vid_player_page.dart';
import 'package:hyppe/ui/inner/home/notifier_v2.dart';
import 'package:hyppe/ui/inner/main/notifier.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:measured_size/measured_size.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/config/ali_config.dart';
import '../../../../../../core/constants/shared_preference_keys.dart';
import '../../../../../../core/models/collection/posts/content_v2/content_data.dart';
import '../../../../../../core/services/shared_preference.dart';
import '../../../../../constant/widget/custom_cache_image.dart';
import '../../../../../constant/widget/custom_text_widget.dart';
import 'fullscreen/notifier.dart';

class VideoFullscreenPage extends StatefulWidget {
  final AliPlayerView aliPlayerView;
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
  const VideoFullscreenPage({
    Key? key,
    required this.aliPlayerView,
    required this.data,
    required this.onClose,
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

class _VideoFullscreenPageState extends State<VideoFullscreenPage> with AfterFirstLayoutMixin {
  PageController controller = PageController();
  int seekValue = 0;
  bool isMute = false;
  bool _inSeek = false;
  int _currentPosition = 0;
  int _currentPositionText = 0;
  int _bufferPosition = 0;
  int _videoDuration = 1;
  bool isPause = false;
  bool onTapCtrl = false;
  bool _showTipsWidget = false;
  int _currentPlayerState = 0;
  List<ContentData>? vidData;

  bool isloading = true;

  bool isLoadingVid = false;

  int _loadingPercent = 0;

  bool isScrolled = false;
  bool isloadingRotate = false;
  int curentIndex = 0;
  Orientation orientation = Orientation.portrait;

  bool isOnPageTurning = false;

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
      if(!isShowing){
        widget.fAliplayer?.play();
      }
      setState(() {
        isloading = false;
      });
    });
  }

  @override
  void initState() {
    _currentPositionText = widget.videoIndicator.positionText ?? 0;
    _currentPosition = widget.videoIndicator.seekValue ?? 0;
    // widget.fAliplayer?.play();
    _videoDuration = widget.videoIndicator.videoDuration ?? 0;
    isMute = widget.videoIndicator.isMute ?? false;
    vidData = widget.vidData;
    super.initState();

    if ((widget.data.metadata?.height ?? 0) < (widget.data.metadata?.width ?? 0)) {
      orientation = Orientation.landscape;
    } else {
      orientation = Orientation.portrait;
    }

    int changevalue;
    changevalue = _currentPosition + 1000;
    if (changevalue > _videoDuration) {
      changevalue = _videoDuration;
    }
    print("currSeek: " + _currentPosition.toString() + ", changeSeek: " + changevalue.toString());
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
          // setState(() {
          _currentPositionText = extraValue ?? 0;
          // });
        }
      } else if (infoCode == FlutterAvpdef.BUFFEREDPOSITION) {
        _bufferPosition = extraValue ?? 0;
        if (mounted) {
          setState(() {});
        }
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
      setState(() {
        _currentPosition = _videoDuration;
      });
      nextPage();
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
    super.dispose();
  }

  whileDispose() async {
    widget.fAliplayer?.pause();
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    widget.fAliplayer?.play();
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

  @override
  Widget build(BuildContext context) {
    // SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    var map = {
      DataSourceRelated.vidKey: widget.data.apsaraId,
      DataSourceRelated.regionKey: DataSourceRelated.defaultRegion,
    };
    print('view ads: ${widget.isAutoPlay ?? false}');
    return Consumer<VideoNotifier>(
      builder: (context, notifier, _) {
        return WillPopScope(
          onWillPop: () async {
            widget.data.isLoading = true;
            int changevalue;
            changevalue = _currentPosition + 1000;
            if (changevalue > _videoDuration) {
              changevalue = _videoDuration;
            }
            // widget.fAliplayer?.pause();
            setState(() {});
            Navigator.pop(context, VideoIndicator(videoDuration: _videoDuration, seekValue: changevalue, positionText: _currentPositionText, showTipsWidget: _showTipsWidget, isMute: isMute));
            return false;
          },
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onPanDown: (detail) {
              _initializeTimer();
            },
            child: Scaffold(
              body: isloading
                  ? Container(
                      color: Colors.black,
                      child: Center(
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
                            scrollPage(vidData?[value].metadata?.height, vidData?[value].metadata?.width);
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

                              return isloadingRotate
                                  ? Container(
                                      color: Colors.black,
                                      height: MediaQuery.of(context).size.height,
                                      width: MediaQuery.of(context).size.width,
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    )
                                  : OrientationBuilder(builder: (context, orientation) {
                                      final player = VidPlayerPage(
                                        // vidData: notifier.vidData,
                                        fromFullScreen: true,
                                        orientation: Orientation.portrait,
                                        playMode: (vidData?[index].isApsara ?? false) ? ModeTypeAliPLayer.auth : ModeTypeAliPLayer.url,
                                        dataSourceMap: map,
                                        data: vidData?[index],
                                        height: MediaQuery.of(context).size.height,
                                        width: MediaQuery.of(context).size.width,
                                        inLanding: true,
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
                              print('view ads: 2');
                              return GestureDetector(
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
                                        child: Offstage(offstage: false, child: _buildContentWidget(context, Orientation.portrait)),
                                      ),
                                    Align(
                                      alignment: Alignment.topCenter,
                                      child: _buildController(
                                        Colors.transparent,
                                        Colors.white,
                                        100,
                                        context.getWidth(),
                                        SizeConfig.screenHeight ?? 0,
                                      ),
                                    ),
                                    if(isLoadingVid)
                                      Container(width: context.getWidth(), height: SizeConfig.screenHeight,
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
                                        ),),
                                    if(notifier.isShowingAds && !notifier.hasShowedAds)
                                      Container(width: context.getWidth(), height: SizeConfig.screenHeight, decoration: const BoxDecoration(color: Colors.black), child: notifier.adsAliPlayerView,),
                                    if(notifier.isShowingAds && !notifier.hasShowedAds)
                                      SizedBox(
                                        width: context.getWidth(),
                                        height: SizeConfig.screenHeight,
                                        // padding: EdgeInsets.only(bottom: 25.0),
                                        child: Offstage(offstage: false, child: _adsBuildContentWidget(context, Orientation.portrait, notifier)),
                                      ),
                                  ],
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
                                  child: Offstage(offstage: false, child: _buildContentWidget(context, Orientation.portrait)),
                                ),
                              Align(
                                alignment: Alignment.topCenter,
                                child: _buildController(
                                  Colors.transparent,
                                  Colors.white,
                                  100,
                                  context.getWidth(),
                                  SizeConfig.screenHeight ?? 0,
                                ),
                              ),
                              if(isLoadingVid)
                                Container(width: context.getWidth(), height: SizeConfig.screenHeight,
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
                                  ),),
                              if(notifier.isShowingAds && !notifier.hasShowedAds)
                                Container(width: context.getWidth(), height: SizeConfig.screenHeight, decoration: const BoxDecoration(color: Colors.black), child: notifier.adsAliPlayerView,),
                              if(notifier.isShowingAds && !notifier.hasShowedAds)
                                SizedBox(
                                  width: context.getWidth(),
                                  height: SizeConfig.screenHeight,
                                  // padding: EdgeInsets.only(bottom: 25.0),
                                  child: Offstage(offstage: false, child: _adsBuildContentWidget(context, Orientation.portrait, notifier)),
                                ),
                            ],
                          ),
                        ),
            ),
          ),
        );
      }
    );
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

  double heightSkip = 0;

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
              const Expanded(flex: 16 ,child: SizedBox.shrink()),
              Expanded(
                flex: 14,
                child: InkWell(
                  onTap: () async{
                    if(notifier.secondsSkip <= 0){
                      notifier.hasShowedAds = true;
                      notifier.adsAliplayer?.stop();
                      notifier.adsCurrentPosition = 0;
                      notifier.adsCurrentPositionText = 0;
                      if(_currentPosition > 0){
                        await widget.fAliplayer?.seekTo(_currentPosition - 1, FlutterAvpdef.ACCURATE);
                      }
                      widget.fAliplayer?.play();
                      widget.onClose();
                    }
                  },
                  child: Row(
                    children: [
                      Expanded(
                        flex: 96,
                        child: MeasuredSize(
                          onChange: (size){
                            setState(() {
                              heightSkip = size.height;
                            });
                          },
                          child: Container(
                            color: Colors.black.withOpacity(0.5),
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                            child: Builder(builder: (context){
                              final language = context.read<TranslateNotifierV2>().translate;
                              final locale = SharedPreference().readStorage(SpKeys.isoCode);
                              final isIndo = locale == 'id';
                              return notifier.secondsSkip <= 0 ? Row(
                                children: [
                                  Expanded(child: CustomTextWidget(textToDisplay: language.skipAds ?? 'Skip Ads', textStyle: context.getTextTheme().caption?.copyWith(color: Colors.white), maxLines: 2,)),
                                  const Icon(
                                    Icons.skip_next,
                                    color: Colors.white,
                                  )
                                ],
                              ) : CustomTextWidget(textToDisplay: isIndo ? '${language.skipMessage} ${notifier.secondsSkip} ${language.second}' : "${language.skipMessage} ${notifier.secondsSkip}", textStyle: context.getTextTheme().overline?.copyWith(color: Colors.white), maxLines: 2,);
                            }),
                          ),
                        ),
                      ),
                      Expanded(flex: 40, child: CustomCacheImage(
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
                        onChangeStart: (value) {
                        },
                        onChangeEnd: (value) {
                        },
                        onChanged: (value) {
                        }),
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
                    Routing().moveBack();
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
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                sixPx,
                Text(
                  System.getTimeformatByMs(_currentPositionText),
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
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isMute = !isMute;
                    });
                    widget.fAliplayer?.setMuted(isMute);
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
                    Navigator.pop(context, VideoIndicator(videoDuration: _videoDuration, seekValue: changevalue, positionText: _currentPositionText, showTipsWidget: _showTipsWidget, isMute: isMute));
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(right: 12.0),
                    child: Icon(
                      Icons.fullscreen_exit,
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

  void _onPlayerHide() {
    Future.delayed(const Duration(seconds: 4), () {
      onTapCtrl = false;
      // setState(() {});
    });
  }

  Widget _buildController(
    Color backgroundColor,
    Color iconColor,
    double barHeight,
    double width,
    double height,
  ) {
    return AnimatedOpacity(
      opacity: onTapCtrl || isPause ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      onEnd: _onPlayerHide,
      child: Container(
        height: height * 0.8,
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
                    iconData: "${AssetPath.vectorPath}pause.svg",
                    defaultColor: false,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSkipBack(iconColor, barHeight),
                  _buildPlayPause(iconColor, barHeight),
                  _buildSkipForward(iconColor, barHeight),
                ],
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
        iconData: isPause ? "${AssetPath.vectorPath}pause.svg" : "${AssetPath.vectorPath}play.svg",
        defaultColor: false,
      ),
      // Icon(
      //   isPause ? Icons.pause : Icons.play_arrow_rounded,
      //   color: iconColor,
      //   size: 200,
      // ),
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
}

class VideoIndicator {
  final int? videoDuration;
  final int? seekValue;
  final int? positionText;
  final bool? showTipsWidget;
  final bool? isMute;
  VideoIndicator({required this.videoDuration, required this.seekValue, required this.positionText, this.showTipsWidget = false, required this.isMute});
}
