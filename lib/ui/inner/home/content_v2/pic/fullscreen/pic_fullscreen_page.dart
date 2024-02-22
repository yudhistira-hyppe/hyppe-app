import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_aliplayer/flutter_aliplayer.dart';
import 'package:flutter_aliplayer/flutter_aliplayer_factory.dart';
import 'package:hyppe/app.dart';
import 'package:hyppe/core/arguments/pic_fullscreen_argument.dart';
import 'package:hyppe/core/bloc/posts_v2/bloc.dart';
import 'package:hyppe/core/bloc/posts_v2/state.dart';
import 'package:hyppe/core/config/ali_config.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/kyc_status.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/constants/utils.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/models/collection/utils/zoom_pic/zoom_pic.dart';
import 'package:hyppe/core/services/route_observer_service.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/entities/like/notifier.dart';
import 'package:hyppe/ui/constant/entities/report/notifier.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/widget/button_boost.dart';
import 'package:hyppe/ui/constant/widget/custom_base_cache_image.dart';
import 'package:hyppe/ui/constant/widget/custom_desc_content_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_shimmer.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/profile_component.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/playlist/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/widget/offline_mode.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/playlist/comments_detail/screen.dart';
import 'package:hyppe/ui/inner/home/notifier_v2.dart';
import 'package:hyppe/ui/inner/main/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'dart:math' as math;

import '../screen.dart';

class PicFullscreenPage extends StatefulWidget {
  final PicFullscreenArgument? argument;

  const PicFullscreenPage({super.key, this.argument});

  @override
  State<PicFullscreenPage> createState() => _PicFullscreenPageState();
}

class _PicFullscreenPageState extends State<PicFullscreenPage> with WidgetsBindingObserver, SingleTickerProviderStateMixin, RouteAware {
  PageController controller = PageController();
  late final AnimationController animatedController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();

  ValueNotifier<int> networklHasErrorNotifier = ValueNotifier(0);

  FlutterAliplayer? fAliplayer;
  bool isPrepare = false;
  bool isPlay = false;
  bool isPause = false;
  bool isloading = false;
  bool isShowMore = true;
  bool isShowShowcase = false;
  double opacityLevel = 0.0;

  List<ContentData>? picData;
  ContentData? selectedData;
  String auth = '';
  int indexPic = 0;
  LocalizationModelV2? lang;
  String email = '';

  int _curIdx = 0;
  int _lastCurIndex = -1;
  String _curPostId = '';
  String _lastCurPostId = '';
  double itemHeight = 0;

  bool isZoom = false;

  MainNotifier? mn;
  int indexKeySell = 0;
  int indexKeyProtection = 0;

  @override
  void initState() {
    initialPage();
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    picData = widget.argument?.picData;
    indexPic = widget.argument!.index;

    if (picData![indexPic].certified ?? false) {
      System().block(context);
    } else {
      System().disposeBlock();
    }
    CustomRouteObserver.routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
    super.didChangeDependencies();
  }

  Future<void> initialPage() async {
    //Ads
    final notifier = Provider.of<PreviewPicNotifier>(context, listen: false);
    mn = Provider.of<MainNotifier>(context, listen: false);
    notifier.initialPicConnection(context);
    notifier.initAdsCounter();
    lang = context.read<TranslateNotifierV2>().translate;
    email = SharedPreference().readStorage(SpKeys.email);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      fAliplayer = FlutterAliPlayerFactory.createAliPlayer(playerId: 'aliPicFullScreen');
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
    });
    controller = PageController(initialPage: widget.argument?.index ?? 0);
    notifier.currIndex = widget.argument?.index ?? 0;
  }

  @override
  void dispose() {
    fAliplayer?.stop();
    fAliplayer!.destroy();
    animatedController.dispose();
    super.dispose();
  }

  //Start Music
  void startMusic(BuildContext context, ContentData data, PreviewPicNotifier notifier) async {
    fAliplayer?.stop();
    selectedData = data;

    isPlay = false;
    selectedData?.isDiaryPlay = false;
    if (data.reportedStatus != 'BLURRED') {
      await getAuth(context, data.music?.apsaraMusic ?? '');
    }

    setState(() {
      isPause = false;
    });
    fAliplayer?.prepare();
    fAliplayer?.setMuted(notifier.isMute);
    if (notifier.isMute) {
      animatedController.stop();
    } else {
      animatedController.repeat();
    }
    // notifier.isMute = !notifier.isMute;
  }

  Future getAuth(BuildContext context, String apsaraId) async {
    setState(() {
      isloading = true;
    });
    try {
      final fixContext = Routing.navigatorKey.currentContext;
      final notifier = PostsBloc();
      await notifier.getAuthApsara(fixContext ?? context, apsaraId: apsaraId);
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
      }
    } catch (e) {
      setState(() {
        isloading = false;
      });
    }
  }

  @override
  void didPop() {
    print("====== didpop ");
    super.didPop();
  }

  @override
  void didPopNext() {
    print("======= didPopNext");

    fAliplayer?.play();
    fAliplayer?.setMuted(false);
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
        // if (context.read<PreviewVidNotifier>().canPlayOpenApps && !SharedPreference().readStorage(SpKeys.isShowPopAds)) {
        fAliplayer?.play();
        // }
        break;
      case AppLifecycleState.paused:
        print("========= paused");
        fAliplayer?.pause();
        break;
      case AppLifecycleState.detached:
        print("========= detached");
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onHorizontalDragEnd: (dragEndDetails) {
          if (dragEndDetails.primaryVelocity! < 0) {
          } else if (dragEndDetails.primaryVelocity! > 0) {
            fAliplayer?.pause();
            Routing().moveBack();
          }
        },
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarBrightness: Brightness.light, statusBarIconBrightness: Brightness.light),
          child: Consumer2<PreviewPicNotifier, HomeNotifier>(builder: (_, notifier, home, __) {
            if (notifier.pic == null && home.isLoadingPict) {
              return CustomShimmer(
                width: (MediaQuery.of(context).size.width - 11.5 - 11.5 - 9) / 2,
                height: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 10),
                padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
              );
            }
            return PageView.builder(
                controller: controller,
                physics: isZoom ? const NeverScrollableScrollPhysics() : const AlwaysScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                itemCount: notifier.pic?.length ?? 0,
                onPageChanged: (value) {
                  indexPic = value;
                  notifier.currIndex = value;
                  if ((notifier.pic?.length ?? 0) - 1 == indexPic) {
                    //This loadmore data
                    notifier.initialPic(context);
                  }
                },
                itemBuilder: (context, index) {
                  if (notifier.pic == null || home.isLoadingPict) {
                    fAliplayer?.pause();
                    _lastCurPostId = '';
                    return const CustomShimmer(
                      width: double.infinity,
                      height: double.infinity,
                      margin: EdgeInsets.symmetric(horizontal: 4.5, vertical: 10),
                      padding: EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
                    );
                  }

                  return notifier.pic![index].reportedStatus == 'BLURRED'
                      ? blurContentWidget(context, notifier.pic![index])
                      : imagePic(notifier.pic??[], index: index, notifier: notifier, homeNotifier: home);
                });
          }),
        ),
      ),
    );
  }

  Widget imagePic(List<ContentData> picData, {int index = 0, PreviewPicNotifier? notifier, HomeNotifier? homeNotifier}) {
    final isAds = picData[index].inBetweenAds != null && picData[index].postID == null;
    return picData[index].isContentLoading ?? false
        ? Builder(builder: (context) {
            Future.delayed(const Duration(seconds: 1), () {
              setState(() {
                picData[index].isContentLoading = false;
              });
            });
            return Container();
          })
        : isAds
            ? VisibilityDetector(
                key: Key(index.toString()),
                onVisibilityChanged: (info) async {
                  if (info.visibleFraction >= 0.8) {
                    _curIdx = index;
                    _curPostId = picData[index].inBetweenAds?.adsId ?? index.toString();

                    if (_lastCurPostId != _curPostId) {
                      if (mounted) {
                        setState(() {
                          isShowShowcase = false;
                        });
                      }
                      final indexList = widget.argument!.picData.indexWhere((element) => element.inBetweenAds?.adsId == _curPostId);

                      if (indexList == (widget.argument!.picData.length) - 1) {
                        context.read<HomeNotifier>().initNewHome(context, mounted, isreload: false, isgetMore: true).then((value) {});
                      }
                      fAliplayer?.stop();
                      Future.delayed(const Duration(milliseconds: 500), () {
                        System().increaseViewCount2(context, picData[index], check: false);
                        if ((picData[index].saleAmount ?? 0) > 0 || ((picData[index].certified ?? false) && (picData[index].saleAmount ?? 0) == 0)) {
                          if (mounted) {
                            setState(() {
                              isShowShowcase = true;
                            });
                          }
                        }
                      });

                      if (picData[index].certified ?? false) {
                        System().block(context);
                      } else {
                        System().disposeBlock();
                      }
                      setState(() {
                        Future.delayed(const Duration(milliseconds: 400), () {
                          itemHeight = widget.argument!.picData[indexList].height ?? 0;
                        });
                      });
                    }
                    _lastCurIndex = _curIdx;
                    _lastCurPostId = _curPostId;
                  }
                },
                child: context.getAdsInBetween(picData, index, (info) {}, () {
                  notifier?.setAdsData(index, null);
                }, (player, id) {}, isfull: true),
              )
            : Stack(
                children: [
                  Positioned.fill(
                    child: VisibilityDetector(
                      key: Key(index.toString()),
                      onVisibilityChanged: (info) {
                        if (info.visibleFraction == 1) {
                          if (!isShowingDialog) {
                            globalAdsPopUp?.pause();
                          }
                        }
                        if (info.visibleFraction == 1 || info.visibleFraction >= 0.6) {
                          _curIdx = index;
                          _curPostId = picData[index].postID ?? index.toString();
                          if (_lastCurIndex > _curIdx) {}

                          if (_lastCurPostId != _curPostId) {
                            if (mounted) {
                              setState(() {
                                isShowShowcase = false;
                              });
                            }
                            final indexList = notifier!.pic?.indexWhere((element) => element.postID == _curPostId);

                            if (indexList == (notifier.pic?.length ?? 0) - 1) {
                              context.read<HomeNotifier>().initNewHome(context, mounted, isreload: false, isgetMore: true).then((value) {});
                            }
                            if (picData[index].music != null) {
                              print("ada musiknya ${picData[index].music}");
                              Future.delayed(const Duration(milliseconds: 100), () {
                                startMusic(context, picData[index], notifier);
                              });
                            } else {
                              fAliplayer?.stop();
                            }

                            Future.delayed(const Duration(milliseconds: 100), () {
                              if (mn?.tutorialData.isNotEmpty ?? [].isEmpty) {
                                indexKeySell = mn?.tutorialData.indexWhere((element) => element.key == 'sell') ?? 0;
                                indexKeyProtection = mn?.tutorialData.indexWhere((element) => element.key == 'protection') ?? 0;
                                if ((picData[index].saleAmount ?? 0) > 0) {
                                  if (mn?.tutorialData[indexKeySell].status == false && !globalChallengePopUp) {
                                    ShowCaseWidget.of(context).startShowCase([picData[index].keyGlobalSell ?? GlobalKey()]);
                                  }
                                }
                                if (((picData[index].certified ?? false) && (picData[index].saleAmount ?? 0) == 0)) {
                                  if (mn?.tutorialData[indexKeyProtection].status == false && !globalChallengePopUp) {
                                    ShowCaseWidget.of(context).startShowCase([picData[index].keyGlobalOwn ?? GlobalKey()]);
                                  }
                                }
                              }
                            });

                            Future.delayed(const Duration(milliseconds: 500), () {
                              System().increaseViewCount2(context, picData[index], check: false);
                            });

                            if (picData[index].certified ?? false) {
                              System().block(context);
                            } else {
                              System().disposeBlock();
                            }
                            setState(() {
                              Future.delayed(const Duration(milliseconds: 400), () {
                                itemHeight = notifier.pic?[indexList ?? 0].height ?? 0;
                              });
                            });

                            ///ADS IN BETWEEN === Hariyanto Lukman ===
                            if (!notifier.loadAds) {
                              if ((notifier.pic?.length ?? 0) > notifier.nextAdsShowed) {
                                notifier.loadAds = true;
                                context.getInBetweenAds().then((value) {
                                  if (value != null) {
                                    notifier.setAdsData(index, value);
                                  } else {
                                    notifier.loadAds = false;
                                  }
                                });
                              }
                            }
                          }

                          _lastCurIndex = _curIdx;
                          _lastCurPostId = _curPostId;
                        }
                      },
                      child: Center(child: image(picData[index], index: index, notifier: notifier)),
                    ),
                  ),
                  _buildBody(context, SizeConfig.screenWidth, picData[index]),
                  _buttomBodyRight(picData: picData[index], notifier: notifier, index: index),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                        margin: const EdgeInsets.only(top: kTextTabBarHeight - 12, left: 12.0),
                        padding: const EdgeInsets.symmetric(vertical: 18.0),
                        width: double.infinity,
                        height: kToolbarHeight * 1.6,
                        child: appBar(picData[index], notifier!)),
                  ),
                  if (picData[index].music != null)
                    Positioned(
                      top: 0,
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: AnimatedOpacity(
                        opacity: opacityLevel,
                        duration: const Duration(milliseconds: 500),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: CustomIconWidget(
                            iconData: notifier.isMute ? '${AssetPath.vectorPath}sound-off.svg' : '${AssetPath.vectorPath}sound-on.svg',
                            defaultColor: false,
                            height: 32,
                          ),
                        ),
                      ),
                    ),
                ],
              );
  }

  Widget image(ContentData picData, {int index = 0, PreviewPicNotifier? notifier}) {
    return ValueListenableBuilder(
      valueListenable: networklHasErrorNotifier,
      builder: (BuildContext context, int count, _) {
        return ZoomableImage(
          enable: true,
          onScaleStart: () {
            setState(() {
              isZoom = true;
            });
          }, // optional
          onScaleStop: () {
            setState(() {
              isZoom = false;
            });
          },
          child: CustomBaseCacheImage(
            memCacheWidth: 100,
            memCacheHeight: 100,
            widthPlaceHolder: 80,
            heightPlaceHolder: 80,
            imageUrl: (picData.isApsara ?? false) ? ("${picData.mediaEndpoint}?key=${picData.valueCache}") : ("${picData.fullThumbPath}&key=${picData.valueCache}"),
            imageBuilder: (context, imageProvider) {
              return GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTapDown: (details) {
                  var position = details.globalPosition;
                  notifier!.positionDxDy = position;
                },
                onDoubleTap: () {
                  context.read<LikeNotifier>().likePost(context, notifier!.pic![index]);
                },
                onTap: () {
                  setState(() {
                    notifier!.isMute = !notifier.isMute;
                    opacityLevel = 1.0;
                  });
                  fAliplayer?.setMuted(notifier!.isMute);
                  if (notifier!.isMute) {
                    animatedController.stop();
                  } else {
                    animatedController.repeat();
                  }
                  Future.delayed(const Duration(seconds: 1), () {
                    opacityLevel = 0.0;
                    setState(() {});
                  });
                },
                child: ImageSize(
                  onChange: (Size size) {
                    if ((picData.imageHeightTemp ?? 0) == 0) {
                      setState(() {
                        picData.imageHeightTemp = size.height;
                      });
                    }
                  },
                  child: picData.reportedStatus == 'BLURRED'
                      ? ImageFiltered(
                          imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                          child: Image(
                            image: imageProvider,
                            fit: BoxFit.cover,
                            width: SizeConfig.screenWidth,
                            // height: picData?.imageHeightTemp == 0 ? null : picData?.imageHeightTemp,
                          ),
                        )
                      : Image(
                          image: imageProvider,
                          fit: BoxFit.cover,
                          width: SizeConfig.screenWidth,
                          // height: picData?.imageHeightTemp == 0 || (picData?.imageHeightTemp ?? 0) <= 100 ? null : picData?.imageHeightTemp,
                        ),
                ),
              );
            },
            emptyWidget: Container(
                decoration: BoxDecoration(color: kHyppeNotConnect, borderRadius: BorderRadius.circular(16)),
                width: SizeConfig.screenWidth,
                height: 250,
                padding: const EdgeInsets.all(20),
                alignment: Alignment.center,
                child: CustomTextWidget(
                  textToDisplay: lang?.couldntLoadImage ?? 'Error',
                  maxLines: 3,
                )),
            errorWidget: (context, url, error) {
              if (!notifier!.isConnect) {
                return OfflineMode(
                  fullscreen: true,
                  function: () async {
                    var connect = await System().checkConnections();
                    if (connect) {
                      Random random = Random();
                      int randomNumber = random.nextInt(100);
                      networklHasErrorNotifier.value++;
                      picData.valueCache = randomNumber.toString();
                      setState(() {});
                    }
                  },
                );
              } else {
                return GestureDetector(
                  onTap: () {
                    Random random = Random();
                    int randomNumber = random.nextInt(100);
                    networklHasErrorNotifier.value++;
                    picData.valueCache = randomNumber.toString();
                    setState(() {});
                    // reloadImage(index);
                  },
                  child: Container(
                      decoration: BoxDecoration(color: kHyppeNotConnect, borderRadius: BorderRadius.circular(16)),
                      width: SizeConfig.screenWidth,
                      height: 250,
                      padding: const EdgeInsets.all(20),
                      alignment: Alignment.center,
                      child: CustomTextWidget(
                        textToDisplay: lang?.couldntLoadImage ?? 'Error',
                        maxLines: 3,
                      )),
                );
              }
            },
          ),
        );
      },
    );
  }

  Widget blurContentWidget(BuildContext context, ContentData data, {int index = 0, PreviewPicNotifier? notifier}) {
    return Stack(
      children: [
        Positioned.fill(
          child: image(data, index: index, notifier: notifier),
        ),
        Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Spacer(),
                  const CustomIconWidget(
                    iconData: "${AssetPath.vectorPath}eye-off.svg",
                    defaultColor: false,
                    height: 30,
                  ),
                  Text(lang!.sensitiveContent ?? 'Sensitive Content', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                  Text("${lang!.contentContainsSensitiveMaterialNew}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                      )),
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
                        "${lang!.see} Pic",
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildBody(BuildContext context, width, ContentData data) {
    return Positioned(
      bottom: kToolbarHeight,
      left: 0,
      right: 0,
      child: Align(
        alignment: Alignment.topLeft,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: Row(
                    children: [
                      Visibility(
                        visible: data.tagPeople?.isNotEmpty ?? false,
                        child: Container(
                          decoration: BoxDecoration(color: kHyppeBackground.withOpacity(.4), borderRadius: BorderRadius.circular(8.0)),
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                          margin: const EdgeInsets.only(right: 12.0),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: GestureDetector(
                              onTap: () {
                                fAliplayer?.pause();
                                context.read<PicDetailNotifier>().showUserTag(context, data.tagPeople, data.postID, title: lang!.inthisphoto, fAliplayer: fAliplayer);
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
                                    '${data.tagPeople!.length} ${lang!.people}',
                                    style: const TextStyle(color: kHyppeTextPrimary),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: data.location != '',
                        child: Container(
                          decoration: BoxDecoration(color: kHyppeBackground.withOpacity(.4), borderRadius: BorderRadius.circular(8.0)),
                          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              const CustomIconWidget(
                                iconData: '${AssetPath.vectorPath}map-light.svg',
                                defaultColor: false,
                                height: 16,
                              ),
                              const SizedBox(
                                width: 4.0,
                              ),
                              Container(
                                constraints: BoxConstraints(
                                  maxWidth: data.tagPeople?.isNotEmpty ?? false ? SizeConfig.screenWidth! * .4 : SizeConfig.screenWidth! * .65,
                                ),
                                child: Text(
                                  '${data.location}',
                                  maxLines: 1,
                                  style: const TextStyle(color: kHyppeLightBackground),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  constraints: BoxConstraints(
                      maxWidth: SizeConfig.screenWidth! * .7,
                      maxHeight: data.description!.length > 24
                          ? isShowMore
                              ? 54
                              : SizeConfig.screenHeight! * .1
                          : 54),
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  padding: const EdgeInsets.only(left: 8.0, top: 20),
                  child: SingleChildScrollView(
                    child: CustomDescContent(
                      desc: "${data.description}",
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
                      hrefStyle: Theme.of(context).textTheme.subtitle2?.copyWith(color: kHyppePrimary),
                      expandStyle: const TextStyle(fontSize: 14, color: kHyppeTextPrimary, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SharedPreference().readStorage(SpKeys.statusVerificationId) == VERIFIED &&
                        (data.boosted.isEmpty) &&
                        (data.reportedStatus != 'OWNED' && data.reportedStatus != 'BLURRED' && data.reportedStatus2 != 'BLURRED') &&
                        data.email == email
                    ? Container(
                        width: SizeConfig.screenWidth,
                        margin: const EdgeInsets.only(bottom: 16, top: 18),
                        padding: const EdgeInsets.only(left: 18.0, right: 74),
                        child: ButtonBoost(
                          onDetail: false,
                          marginBool: true,
                          contentData: data,
                          startState: () {
                            SharedPreference().writeStorage(SpKeys.isShowPopAds, true);
                          },
                          afterState: () {
                            SharedPreference().writeStorage(SpKeys.isShowPopAds, false);
                          },
                        ),
                      )
                    : Container(),
                if (data.email == email && (data.boostCount ?? 0) >= 0 && (data.boosted.isNotEmpty))
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
                            textToDisplay: "${data.boostJangkauan ?? '0'} ${lang?.reach}",
                            textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kHyppeTextLightPrimary),
                          ),
                        )
                      ],
                    ),
                  ),
                Visibility(
                  visible: data.music != null,
                  child: Container(
                    width: SizeConfig.screenWidth! * .7,
                    height: SizeConfig.screenHeight! * .05,
                    margin: const EdgeInsets.only(left: 16.0),
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: kHyppeSurface.withOpacity(.9),
                          child: AnimatedBuilder(
                            animation: animatedController,
                            builder: (_, child) {
                              return Transform.rotate(
                                angle: animatedController.value * 2 * -math.pi,
                                child: child,
                              );
                            },
                            child: CustomBaseCacheImage(
                              imageUrl: data.music?.apsaraThumnailUrl ?? '',
                              imageBuilder: (_, imageProvider) {
                                return Container(
                                  width: 32,
                                  height: 32,
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
                              emptyWidget: const CustomIconWidget(
                                iconData: "${AssetPath.vectorPath}music_stroke_black.svg",
                                defaultColor: false,
                                color: kHyppeTextPrimary,
                                height: 18,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 12.0,
                        ),
                        SizedBox(
                          width: SizeConfig.screenWidth! * .56,
                          child: _textSize(data.music?.musicTitle ?? '', const TextStyle(fontWeight: FontWeight.normal)).width > SizeConfig.screenWidth! * .56
                              ? Marquee(
                                  text: '  ${data.music?.musicTitle ?? ''}',
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white),
                                )
                              : CustomTextWidget(
                                  textToDisplay: " ${data.music?.musicTitle ?? ''}",
                                  maxLines: 1,
                                  textStyle: const TextStyle(color: kHyppeTextPrimary, fontSize: 12),
                                  textAlign: TextAlign.left,
                                ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buttomBodyRight({ContentData? picData, PreviewPicNotifier? notifier, int index = -1}) {
    return Positioned(
      bottom: kToolbarHeight - 18,
      left: 0,
      right: 12,
      child: Align(
        alignment: Alignment.bottomRight,
        child: Column(
          children: [
            Consumer<LikeNotifier>(
              builder: (context, likeNotifier, child) => buttonRight(
                  onFunctionTap: () {
                    likeNotifier.likePost(context, notifier!.pic![index]);
                  },
                  iconData: '${AssetPath.vectorPath}${(picData?.insight?.isPostLiked ?? false) ? 'liked.svg' : 'love-shadow.svg'}',
                  value: picData!.insight!.likes! > 0 ? '${picData.insight?.likes}' : '${lang!.like}',
                  liked: picData.insight?.isPostLiked ?? false),
            ),
            if (picData!.allowComments ?? false)
              buttonRight(
                onFunctionTap: () {
                  Routing().move(Routes.commentsDetail, argument: CommentsArgument(postID: picData.postID ?? '', fromFront: true, data: picData));
                },
                iconData: '${AssetPath.vectorPath}comment-shadow.svg',
                value: picData.comments! > 0 ? picData.comments.toString() : lang?.comments ?? '',
              ),
            if ((picData.isShared ?? false))
              buttonRight(
                  onFunctionTap: () async {
                    context.read<PicDetailNotifier>().createdDynamicLink(context, data: picData);
                  },
                  iconData: '${AssetPath.vectorPath}share-shadow.svg',
                  value: lang!.share ?? 'Share'),
            if ((picData.saleAmount ?? 0) > 0 && email != picData.email)
              buttonRight(
                  onFunctionTap: () async {
                    fAliplayer?.pause();
                    await ShowBottomSheet.onBuyContent(context, data: picData, fAliplayer: fAliplayer);
                  },
                  iconData: '${AssetPath.vectorPath}ic-cart-shadow.svg',
                  value: lang!.buy ?? 'Buy'),
          ],
        ),
      ),
    );
  }

  Widget buttonRight({Function()? onFunctionTap, required String iconData, required String value, bool liked = false}) {
    return InkResponse(
      onTap: onFunctionTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: onFunctionTap,
              child: CustomIconWidget(
                defaultColor: false,
                color: liked ? kHyppeRed : kHyppePrimaryTransparent,
                iconData: iconData,
                height: liked ? 28 : 42,
                width: 38,
              ),
            ),
            if (liked)
              const SizedBox(
                height: 10.0,
              ),
            if (value == lang!.buy)
              const SizedBox(
                height: 8.0,
              ),
            Container(
              transform: Matrix4.translationValues(0.0, -5.0, 0.0),
              child: Text(
                value,
                textAlign: TextAlign.start,
                style: const TextStyle(shadows: [
                  Shadow(offset: Offset(0.0, 1.0), blurRadius: 2.0, color: Colors.black54),
                  Shadow(offset: Offset(0.0, 1.0), blurRadius: 2.0, color: Colors.black54),
                ], color: kHyppePrimaryTransparent, fontWeight: FontWeight.w500, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget appBar(ContentData data, PreviewPicNotifier notifier) {
    double widthUsername = _textSize(data.username ?? '', const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)).width;
    double widthDate = _textSize(
            '${System().readTimestamp(
              DateTime.parse(System().dateTimeRemoveT(data.createdAt ?? '')).millisecondsSinceEpoch,
              context,
              fullCaption: true,
            )}',
            const TextStyle(fontSize: 12))
        .width;
    if (data.privacy?.isIdVerified ?? false) {
      widthUsername += 50;
    }
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
                  fAliplayer?.pause();
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
                widthText: (data.username?.length ?? 0) >= 10
                    ? data.privacy?.isIdVerified ?? false
                        ? 112
                        : 100
                    : widthUsername > widthDate
                        ? widthUsername
                        : widthDate,
                username: data.username ?? 'No Name',
                textColor: kHyppeLightBackground,
                spaceProfileAndId: eightPx,
                haveStory: false,
                isCelebrity: false,
                isUserVerified: data.privacy!.isIdVerified ?? false,
                onTapOnProfileImage: () {
                  fAliplayer?.setMuted(true);
                  // fAliplayer?.pause();
                  System().navigateToProfile(context, data.email ?? '');
                  setState(() {
                    notifier.isMute = true;
                  });
                },
                featureType: FeatureType.pic,
                imageUrl: '${System().showUserPicture(data.avatar?.mediaEndpoint)}',
                badge: data.urluserBadge,
                createdAt: '${System().readTimestamp(
                  DateTime.parse(System().dateTimeRemoveT(data.createdAt ?? '')).millisecondsSinceEpoch,
                  context,
                  fullCaption: true,
                )}',
              ),
            ),
            if (data.email != email && (data.isNewFollowing ?? false))
              Consumer<PreviewPicNotifier>(
                builder: (context, picNot, child) => GestureDetector(
                  onTap: () {
                    context.handleActionIsGuest(() {
                      if (data.insight?.isloadingFollow != true) {
                        picNot.followUser(context, data, isUnFollow: data.following, isloading: data.insight!.isloadingFollow ?? false);
                      }
                    });
                  },
                  child: data.insight?.isloadingFollow ?? false
                      ? const SizedBox(
                          height: 40,
                          width: 30,
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: CustomLoading(),
                          ),
                        )
                      : Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                            decoration: BoxDecoration(border: Border.all(color: Colors.white), borderRadius: BorderRadius.circular(8.0)),
                            // transform: Matrix4.translationValues(-40.0, 0.0, 0.0),
                            child: Text(
                              (data.following ?? false) ? (lang?.following ?? '') : (lang?.follow ?? ''),
                              style: const TextStyle(color: kHyppeLightButtonText, fontSize: 12, fontWeight: FontWeight.w700, fontFamily: "Lato"),
                            ),
                          ),
                        ),
                ),
              ),
          ],
        ),
        actionWidget(
            onTap: () async {
              fAliplayer?.setMuted(true);
              fAliplayer?.pause();
              await context.handleActionIsGuest(() async {
                if (data.email != email) {
                  context.read<PreviewPicNotifier>().reportContent(context, data, fAliplayer: fAliplayer, onCompleted: () async {
                    imageCache.clear();
                    imageCache.clearLiveImages();
                    await (Routing.navigatorKey.currentContext ?? context).read<HomeNotifier>().initNewHome(context, mounted, isreload: true, forceIndex: 0);
                  });
                } else {
                  ShowBottomSheet().onShowOptionContent(
                    context,
                    contentData: data,
                    captionTitle: hyppePic,
                    onDetail: false,
                    isShare: data.isShared,
                    onUpdate: () {
                      (Routing.navigatorKey.currentContext ?? context).read<HomeNotifier>().initNewHome(context, mounted, isreload: true, forceIndex: 0);
                    },
                    fAliplayer: fAliplayer,
                  );
                }
              });
            },
            data: data),
      ],
    );
  }

  Widget actionWidget({Function()? onTap, ContentData? data}) {
    return Padding(
      padding: const EdgeInsets.only(right: 18.0, top: 12.0, bottom: 12.0),
      child: Row(
        children: [
          if ((data!.saleAmount ?? 0) > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 13),
              child: const CustomIconWidget(
                iconData: "${AssetPath.vectorPath}sale.svg",
                defaultColor: false,
                height: 28,
              ),
            ),
          if ((data.certified ?? false) && (data.saleAmount ?? 0) == 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 13),
              child: const CustomIconWidget(
                iconData: '${AssetPath.vectorPath}ownership.svg',
                defaultColor: false,
                height: 28,
              ),
            ),
          GestureDetector(
            onTap: onTap,
            child: const Icon(
              Icons.more_vert,
              color: kHyppeLightBackground,
              shadows: <Shadow>[Shadow(color: Colors.black54, blurRadius: 8.0)],
            ),
          ),
        ],
      ),
    );
  }

  Size _textSize(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(text: TextSpan(text: text, style: style), maxLines: 1, textDirection: TextDirection.ltr)..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size;
  }
}
