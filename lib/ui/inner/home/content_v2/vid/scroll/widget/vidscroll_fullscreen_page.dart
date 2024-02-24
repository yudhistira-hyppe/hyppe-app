import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_aliplayer/flutter_aliplayer.dart';
import 'package:hyppe/core/config/ali_config.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/kyc_status.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/constants/utils.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/entities/like/notifier.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/widget/after_first_layout_mixin.dart';
import 'package:hyppe/ui/constant/widget/button_boost.dart';
import 'package:hyppe/ui/constant/widget/custom_appbar.dart';
import 'package:hyppe/ui/constant/widget/custom_base_cache_image.dart';
import 'package:hyppe/ui/constant/widget/custom_desc_content_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/playlist/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/playlist/comments_detail/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/playlist/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/scroll/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/widget/fullscreen/video_fullscreen_page.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/widget/vid_player_page.dart';
import 'package:hyppe/ui/inner/home/notifier_v2.dart';
import 'package:hyppe/ui/inner/main/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

import 'package:visibility_detector/visibility_detector.dart';

class VidScrollFullScreenPage extends StatefulWidget {
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
  final bool isLanding;
  final bool isVidFormProfile;
  const VidScrollFullScreenPage({
    super.key,
    required this.aliPlayerView,
    required this.data,
    required this.onClose,
    required this.isLanding,
    this.fAliplayer,
    this.isVidFormProfile = false,
    this.slider,
    required this.videoIndicator,
    required this.thumbnail,
    this.vidData,
    this.index,
    this.loadMoreFunction,
    this.clearPostId,
    this.isAutoPlay,
    this.enableWakelock = true,
  });

  @override
  State<VidScrollFullScreenPage> createState() => _VidScrollFullScreenPageState();
}

class _VidScrollFullScreenPageState extends State<VidScrollFullScreenPage> with AfterFirstLayoutMixin, SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKeyPlayer = GlobalKey<ScaffoldState>();

  PageController controller = PageController();
  late final AnimationController animatedController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();

  int seekValue = 0;
  bool isMute = false;
  bool _inSeek = false;
  int _currentPosition = 0;
  int _currentPositionText = 0;
  int _videoDuration = 1;
  bool isPause = false;
  bool onTapCtrl = false;
  bool _showTipsWidget = false;
  int _currentPlayerState = 0;
  List<ContentData>? vidData;

  LocalizationModelV2? lang;
  String email = '';

  bool isLoadingVid = false;

  int _loadingPercent = 0;

  bool isScrolled = false;
  bool isloadingRotate = false;
  int curentIndex = 0;
  Orientation orientation = Orientation.portrait;

  bool isOnPageTurning = false;
  bool isShowMore = false;
  int _curIdx = -1;
  // int _lastCurIndex = -1;
  int _cardIndex = 0;
  Map<int, FlutterAliplayer> dataAli = {};

  @override
  void afterFirstLayout(BuildContext context) {
    landscape();
    // _initializeTimer();
  }

  void landscape() async {
    widget.fAliplayer?.pause();
    Future.delayed(const Duration(seconds: 1), () {
      widget.fAliplayer?.play();
    });
  }

  @override
  void initState() {
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
    } else {
      orientation = Orientation.portrait;
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
    widget.fAliplayer?.seekTo(changevalue, FlutterAvpdef.ACCURATE);

    widget.fAliplayer?.setOnInfo((infoCode, extraValue, extraMsg, playerId) {
      print(playerId);
      if (infoCode == FlutterAvpdef.CURRENTPOSITION) {
        if (_videoDuration != 0 && (extraValue ?? 0) <= _videoDuration) {
          setState(() {
            _currentPosition = extraValue ?? 0;
          });
        }
        if (!_inSeek) {
          setState(() {
            _currentPositionText = extraValue ?? 0;
          });
        }
      } else if (infoCode == FlutterAvpdef.BUFFEREDPOSITION) {
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
      setState(() {
        isPause = true;
      });
      // nextPage();
    });

    widget.fAliplayer?.setOnLoadingStatusListener(loadingBegin: (playerId) {
      if (mounted) {
        try {
          setState(() {
            _loadingPercent = 0;
            isLoadingVid = true;
          });
        } catch (_) {}
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
      } catch (_) {}
    }, loadingEnd: (playerId) {
      try {
        if (mounted) {
          setState(() {
            isLoadingVid = false;
          });
        } else {
          isLoadingVid = false;
        }
      } catch (_) {}
    });

    controller = PageController(initialPage: widget.index ?? 0);
    context.read<ScrollVidNotifier>().lastScrollIdx = widget.index ?? 0;
    controller.addListener(() {
      widget.fAliplayer?.pause();
      setState(() {
        isScrolled = true;
      });
      // final notifierVid = context.read<PreviewVidNotifier>();
      // if (isOnPageTurning && controller.page == controller.page?.roundToDouble()) {
      //   notifierVid.pageIndex = controller.page?.toInt() ?? 0;
      //   setState(() {
      //     isOnPageTurning = false;
      //   });
      // } else if (!isOnPageTurning) {
      //   if (((notifierVid.pageIndex.toDouble()) - (controller.page ?? 0)).abs() > 0.1) {
      //     setState(() {
      //       isOnPageTurning = true;
      //     });
      //   }
      // }
    });

    curentIndex = widget.index ?? 0;
    // if ((vidData?.length ?? 0) - 1 == curentIndex) {
    //   // getNewData();
    // }

    // _initializeTimer();
    super.initState();
  }

  void scrollPage(height, width) async {
    var lastOrientation = orientation;
    if ((height ?? 0) < (width ?? 0)) {
      orientation = Orientation.landscape;
    } else {
      orientation = Orientation.portrait;
    }
    if (lastOrientation != orientation) {
      setState(() {
        isloadingRotate = true;
      });
      if (orientation == Orientation.landscape) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      } else {
        await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
      }
      Future.delayed(const Duration(milliseconds: 1000), () {
        setState(() {
          isloadingRotate = false;
        });
      });
    } else {}
  }

  _pauseScreen() async {
    (Routing.navigatorKey.currentContext ?? context).read<HomeNotifier>().removeWakelock();
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
        // _initializeTimer();
      },
    );
    Future.delayed(const Duration(seconds: 1), () {
      if (context.read<MainNotifier>().isInactiveState) {
        widget.fAliplayer?.pause();
        isPause = true;
        setState(() {});
      }
    });
  }

  // Future getNewData() async {
  //   // widget.loadMoreFunc yestion?.call();
  //   HomeNotifier hn = context.read<HomeNotifier>();
  //   ScrollVidNotifier vn = context.read<ScrollVidNotifier>();

  //   await hn.initNewHome(context, mounted, isreload: false, isgetMore: true).then((value) {
  //     setState(() {
  //       vn.vidData?.forEach((e) {
  //         print(e.description);
  //       });
  //       vidData = vn.vidData;
  //       vidData?.forEach((e) {
  //         print(e.description);
  //       });
  //       print("========== total ${vidData?.length}");
  //     });
  //   });
  // }

  @override
  void dispose() {
    // _pauseScreen();
    whileDispose();
    animatedController.dispose();
    // closePage();
    super.dispose();
  }

  whileDispose() async {
    widget.fAliplayer?.pause();
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    widget.fAliplayer?.play();
  }

  void closePage() {
    int changevalue;
    changevalue = _currentPosition + 1000;
    if (changevalue > _videoDuration) {
      changevalue = _videoDuration;
    }

    widget.data.isLoading = true;
    Navigator.pop(context, VideoIndicator(videoDuration: _videoDuration, seekValue: changevalue, positionText: _currentPositionText, showTipsWidget: _showTipsWidget, isMute: isMute));
  }

  void nextPage() {
    Future.delayed(const Duration(milliseconds: 500), () {
      controller.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.ease);
    });
  }

  void previousPage() {
    Future.delayed(const Duration(milliseconds: 500), () {
      controller.previousPage(duration: const Duration(milliseconds: 500), curve: Curves.ease);
    });
  }

  @override
  Widget build(BuildContext context) {
    var map = {
      DataSourceRelated.vidKey: widget.data.apsaraId,
      DataSourceRelated.regionKey: DataSourceRelated.defaultRegion,
    };

    return Consumer<ScrollVidNotifier>(builder: (context, notifier, _) {
      return Scaffold(
          key: _scaffoldKeyPlayer,
          body: GestureDetector(
            onHorizontalDragEnd: (dragEndDetails) {
              if (dragEndDetails.primaryVelocity! < 0) {
              } else if (dragEndDetails.primaryVelocity! > 0) {
                if (widget.index == curentIndex) {
                  closePage();
                } else {
                  widget.data.isLoading = true;
                  Navigator.pop(context, VideoIndicator(videoDuration: _videoDuration, seekValue: 0, positionText: _currentPositionText, showTipsWidget: _showTipsWidget, isMute: isMute));
                }

                SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
              }
            },
            child: PageView.builder(
              controller: controller,
              scrollDirection: Axis.vertical,
              itemCount: notifier.vidData?.length ?? 0,
              onPageChanged: (value) async {
                curentIndex = value;
                notifier.lastScrollIdx = value;
                _cardIndex = value;
                if (_curIdx != value) {
                  Future.delayed(const Duration(milliseconds: 400), () {
                    try {
                      if (_curIdx != -1) {
                        print('Vid Landing Page: pause $_curIdx ${vidData?[_curIdx].fAliplayer} ${dataAli[_curIdx]}');
                        if (vidData?[_curIdx].fAliplayer != null) {
                          vidData?[_curIdx].fAliplayer?.pause();
                        } else {
                          dataAli[_curIdx]?.pause();
                        }

                        // vidData?[_curIdx].fAliplayerAds?.pause();
                        // setState(() {
                        //   _curIdx = -1;
                        // });
                      }
                    } catch (e) {
                      e.logger();
                    }
                    // System().increaseViewCount2(context, vidData);
                  });
                  if (vidData?[value].certified ?? false) {
                    System().block(context);
                  } else {
                    System().disposeBlock();
                  }
                }
                scrollPage(notifier.vidData?[value].metadata?.height, notifier.vidData?[value].metadata?.width);
                if ((notifier.vidData?.length ?? 0) - 1 == widget.index) {
                  await notifier.loadMore(context, controller, PageSrc.selfProfile, '');
                  if (mounted) {
                    setState(() {
                      notifier.vidData = notifier.vidData;
                    });
                  } else {
                    notifier.vidData = notifier.vidData;
                  }
                }
              },
              itemBuilder: (context, index) {
                if (index != curentIndex) {
                  return Container(
                    color: Colors.black,
                  );
                }
                if (isScrolled) {
                  return VisibilityDetector(
                    key: Key(widget.data.postID??index.toString()),
                    onVisibilityChanged: (info) {
                      if (info.visibleFraction >= 0.6) {
                        _cardIndex = index;
                        if (_curIdx != index) {
                          Future.delayed(const Duration(milliseconds: 400), () {
                            try {
                              if (_curIdx != -1) {
                                print('Vid Landing Page: pause $_curIdx ${vidData?[_curIdx].fAliplayer} ${dataAli[_curIdx]}');
                                if (vidData?[_curIdx].fAliplayer != null) {
                                  vidData?[_curIdx].fAliplayer?.pause();
                                } else {
                                  dataAli[_curIdx]?.pause();
                                }

                                // vidData?[_curIdx].fAliplayerAds?.pause();
                                // setState(() {
                                //   _curIdx = -1;
                                // });
                              }
                            } catch (e) {
                              e.logger();
                            }
                            // System().increaseViewCount2(context, vidData);
                          });
                          if (vidData?[index].certified ?? false) {
                            System().block(context);
                          } else {
                            System().disposeBlock();
                          }
                        }
                      }
                    },
                    child: isloadingRotate
                        ? Container(
                            color: Colors.black,
                            height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : OrientationBuilder(builder: (context, orientation) {
                            final player = VidPlayerPage(
                              isVidFormProfile: widget.isVidFormProfile,
                              fromFullScreen: true,
                              orientation: orientation,
                              playMode: (notifier.vidData?[index].isApsara ?? false) ? ModeTypeAliPLayer.auth : ModeTypeAliPLayer.url,
                              dataSourceMap: map,
                              data: notifier.vidData?[index],
                              height: MediaQuery.of(context).size.height,
                              width: MediaQuery.of(context).size.width,
                              inLanding: widget.isLanding,
                              fromDeeplink: false,
                              clearPostId: widget.clearPostId,
                              clearing: true,
                              isAutoPlay: true,
                              functionFullTriger: (value) {},
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
                            );
                            if (orientation == Orientation.landscape) {
                              return SizedBox(
                                width: context.getWidth(),
                                height: context.getHeight(),
                                child: player,
                              );
                            }
                            return player;
                          }),
                  );
                } else {
                  return GestureDetector(
                    onTap: () {
                      onTapCtrl = true;
                      setState(() {});
                    },
                    child: Container(
                      height: SizeConfig.screenHeight,
                      width: SizeConfig.screenWidth,
                      foregroundDecoration: const BoxDecoration(
                        color: Colors.transparent,
                      ),
                      child: Stack(
                        children: [
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
                              child: Offstage(offstage: false, child: _buildContentWidget(context, orientation)),
                            ),
                          Align(
                            alignment: Alignment.topCenter,
                            child: _buildController(Colors.transparent, Colors.white, 100, context.getWidth(), SizeConfig.screenHeight! * 0.8, orientation),
                          ),
                          AnimatedOpacity(
                            opacity: onTapCtrl || isPause ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 200),
                            onEnd: _onPlayerHide,
                            child: Container(
                              height: orientation == Orientation.portrait ? kToolbarHeight * 2 : kToolbarHeight * 1.4,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18.0),
                              child: CustomAppBar(
                                  orientation: orientation,
                                  isVidFormProfile: widget.isVidFormProfile,
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
                                    if (res != null && res == true) {
                                      if ((widget.data.metadata?.height ?? 0) < (widget.data.metadata?.width ?? 0)) {
                                        SystemChrome.setPreferredOrientations([
                                          DeviceOrientation.landscapeLeft,
                                          DeviceOrientation.landscapeRight,
                                        ]);
                                      } else {
                                        SystemChrome.setPreferredOrientations([
                                          DeviceOrientation.portraitUp,
                                          DeviceOrientation.portraitDown,
                                        ]);
                                      }
                                    }
                                  },
                                  onTap: () {
                                    context.handleActionIsGuest(() async {
                                      if (widget.data.email != email) {
                                        context.read<PreviewPicNotifier>().reportContent(context, widget.data, fAliplayer: widget.data.fAliplayer, onCompleted: () async {
                                          imageCache.clear();
                                          imageCache.clearLiveImages();
                                          if (notifier.vidData?.isEmpty ?? [].isEmpty) {
                                            Routing().moveBack();
                                            Routing().moveBack();
                                            return;
                                          }
                                          await (Routing.navigatorKey.currentContext ?? context).read<HomeNotifier>().initNewHome(context, mounted, isreload: true, forceIndex: 2);
                                        });
                                      } else {
                                        ShowBottomSheet().onShowOptionContent(
                                          context,
                                          contentData: widget.data,
                                          captionTitle: hyppeVid,
                                          onDetail: false,
                                          isShare: widget.data.isShared,
                                          orientation: orientation,
                                          onUpdate: () {
                                            // if (notifier.vidData?.isEmpty ?? [].isEmpty) {
                                            Routing().moveBack();
                                            Routing().moveBack();
                                            Routing().moveBack();
                                            //   return;
                                            // }
                                            (Routing.navigatorKey.currentContext ?? context).read<HomeNotifier>().initNewHome(context, mounted, isreload: true, forceIndex: 2);
                                          },
                                          fAliplayer: widget.data.fAliplayer,
                                        );
                                        widget.data.fAliplayer?.pause();
                                        isPause = true;
                                        setState(() {});
                                      }
                                    });
                                  }),
                            ),
                          ),
                          if (isLoadingVid)
                            Container(
                              width: context.getWidth(),
                              height: SizeConfig.screenHeight,
                              padding: const EdgeInsets.only(bottom: 20),
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
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
          ));
    });
  }

  _buildContentWidget(BuildContext context, Orientation orientation) {
    return AnimatedOpacity(
      opacity: onTapCtrl || isPause ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
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
                                context.handleActionIsGuest(() {
                                  likeNotifier.likePost(context, widget.data);
                                });
                              },
                              iconData: '${AssetPath.vectorPath}${(widget.data.insight?.isPostLiked ?? false) ? 'liked.svg' : 'love-shadow.svg'}',
                              value: widget.data.insight!.likes! > 0 ? '${widget.data.insight?.likes}' : '${lang?.like}',
                              liked: widget.data.insight?.isPostLiked ?? false)),
                      if (widget.data.allowComments ?? false)
                        buttonVideoRight(
                          onFunctionTap: () {
                            context.handleActionIsGuest(() {
                              Routing().move(Routes.commentsDetail, argument: CommentsArgument(postID: widget.data.postID ?? '', fromFront: true, data: widget.data, pageDetail: true));
                            });
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
                            maxWidth: orientation == Orientation.landscape ? SizeConfig.screenWidth! * .28 : SizeConfig.screenWidth!, maxHeight: isShowMore ? 52 : SizeConfig.screenHeight! * .1),
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        padding: const EdgeInsets.only(left: 8.0, bottom: 12.0),
                        child: SingleChildScrollView(
                          child: CustomDescContent(
                            desc: "${widget.data.description}",
                            trimLines: 2,
                            textAlign: TextAlign.start,
                            callbackIsMore: (val) {
                              setState(() {
                                isShowMore = val;
                              });
                            },
                            seeLess: ' ${lang?.less}',
                            seeMore: ' ${lang?.more}',
                            normStyle: const TextStyle(fontSize: 14, color: kHyppeTextPrimary),
                            hrefStyle: Theme.of(context).textTheme.titleSmall?.copyWith(color: kHyppePrimary),
                            expandStyle: Theme.of(context).textTheme.titleSmall?.copyWith(color: kHyppeTextPrimary, fontWeight: FontWeight.bold),
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
                                      trackHeight: 3.0,
                                      thumbColor: Colors.purple,
                                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
                                    ),
                                    child: Slider(
                                        min: 0,
                                        max: _videoDuration == 0 ? 1 : _videoDuration.toDouble(),
                                        value: _currentPosition.toDouble(),
                                        activeColor: Colors.purple,
                                        thumbColor: Colors.purple,
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
                                          widget.fAliplayer?.seekTo(value.ceil(), FlutterAvpdef.ACCURATE);
                                        },
                                        onChanged: (value) {
                                          widget.fAliplayer?.requestBitmapAtPosition(value.ceil());

                                          setState(() {
                                            _currentPosition = value.ceil();
                                          });
                                        }),
                                  ),
                                ),
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
                                Row(
                                  children: [
                                    const CustomIconWidget(
                                      iconData: "${AssetPath.vectorPath}music_stroke_black.svg",
                                      defaultColor: false,
                                      color: kHyppeLightBackground,
                                      height: 18,
                                    ),
                                    const SizedBox(
                                      width: 12.0,
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
                                  ],
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
              width: widget.data.tagPeople?.isNotEmpty ?? false ? SizeConfig.screenWidth! * .13 : SizeConfig.screenWidth! * .24,
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

  void _onPlayerHide() {
    Future.delayed(const Duration(seconds: 4), () {
      onTapCtrl = false;
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
      duration: const Duration(milliseconds: 200),
      onEnd: _onPlayerHide,
      child: Center(
        child: Container(
          width: orientation == Orientation.landscape ? width * .35 : width * .8,
          decoration: BoxDecoration(
            color: backgroundColor,
          ),
          child: Row(
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
          if (_currentPosition == _videoDuration) {
            _inSeek = false;
            _currentPosition = 0;
            setState(() {
              _showTipsWidget = false;
            });
            widget.fAliplayer?.seekTo(_currentPosition.ceil(), FlutterAvpdef.ACCURATE);
          }

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
}
