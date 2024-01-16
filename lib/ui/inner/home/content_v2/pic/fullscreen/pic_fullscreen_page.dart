import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_aliplayer/flutter_aliplayer.dart';
import 'package:flutter_aliplayer/flutter_aliplayer_factory.dart';
import 'package:hyppe/core/arguments/pic_fullscreen_argument.dart';
import 'package:hyppe/core/bloc/posts_v2/bloc.dart';
import 'package:hyppe/core/bloc/posts_v2/state.dart';
import 'package:hyppe/core/config/ali_config.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/constants/utils.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/models/collection/utils/zoom_pic/zoom_pic.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/entities/like/notifier.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
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
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'dart:math' as math;

import '../screen.dart';

class PicFullscreenPage extends StatefulWidget {
  final PicFullscreenArgument? argument;
  const PicFullscreenPage({super.key, this.argument});

  @override
  State<PicFullscreenPage> createState() => _PicFullscreenPageState();
}

class _PicFullscreenPageState extends State<PicFullscreenPage>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  PageController controller = PageController();
  late final AnimationController animatedController =
      AnimationController(vsync: this, duration: const Duration(seconds: 2))
        ..repeat();

  FlutterAliplayer? fAliplayer;
  bool isPrepare = false;
  bool isPlay = false;
  bool isPause = false;
  bool isloading = false;
  bool isMute = false;
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
    super.didChangeDependencies();
  }

  Future<void> initialPage() async {
    //Ads
    final notifier = Provider.of<PreviewPicNotifier>(context, listen: false);
    notifier.initialPicConnection(context);
    notifier.initAdsCounter();
    lang = context.read<TranslateNotifierV2>().translate;
    email = SharedPreference().readStorage(SpKeys.email);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      fAliplayer =
          FlutterAliPlayerFactory.createAliPlayer(playerId: 'aliPicFullScreen');
      WidgetsBinding.instance.addObserver(this);
      fAliplayer?.setAutoPlay(true);
      fAliplayer?.setLoop(true);

      //Turn on mix mode
      if (Platform.isIOS) {
        FlutterAliplayer.enableMix(true);
      }

      //set player
      fAliplayer?.setPreferPlayerName(GlobalSettings.mPlayerName);
      fAliplayer
          ?.setEnableHardwareDecoder(GlobalSettings.mEnableHardwareDecoder);
    });
    controller = PageController(initialPage: widget.argument?.index ?? 0);
  }

  @override
  void dispose() {
    fAliplayer?.stop();
    fAliplayer!.destroy();
    animatedController.dispose();
    super.dispose();
  }

  //Start Music
  void startMusic(BuildContext context, ContentData data) async {
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
    if (isMute) {
      fAliplayer?.setMuted(true);
    }
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarBrightness: Brightness.light,
            statusBarIconBrightness: Brightness.light),
        child: Consumer2<PreviewPicNotifier, HomeNotifier>(
            builder: (_, notifier, home, __) {
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
              scrollDirection: Axis.vertical,
              itemCount: notifier.pic?.length ?? 0,
              onPageChanged: (value) {
                indexPic = value;
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

                return imagePic(
                    picData: notifier.pic![index],
                    index: index,
                    notifier: notifier,
                    homeNotifier: home);
              });
        }),
      ),
    );
  }

  Widget imagePic(
      {ContentData? picData,
      int index = 0,
      PreviewPicNotifier? notifier,
      HomeNotifier? homeNotifier}) {
    final isAds = picData!.inBetweenAds != null && picData.postID == null;
    // notifier!.initialPicConnection(context);
    return picData.isContentLoading ?? false
        ? Builder(builder: (context) {
            Future.delayed(const Duration(seconds: 1), () {
              setState(() {
                picData.isContentLoading = false;
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
                    _curPostId =
                        picData.inBetweenAds?.adsId ?? index.toString();

                    if (_lastCurPostId != _curPostId) {
                      final indexList = widget.argument!.picData.indexWhere(
                          (element) =>
                              element.inBetweenAds?.adsId == _curPostId);

                      if (indexList == (widget.argument!.picData.length) - 1) {
                        context
                            .read<HomeNotifier>()
                            .initNewHome(context, mounted,
                                isreload: false, isgetMore: true)
                            .then((value) {});
                      }
                      fAliplayer?.stop();

                      Future.delayed(const Duration(milliseconds: 500), () {
                        System()
                            .increaseViewCount2(context, picData, check: false);
                      });

                      if (picData.certified ?? false) {
                        System().block(context);
                      } else {
                        System().disposeBlock();
                      }
                      setState(() {
                        Future.delayed(const Duration(milliseconds: 400), () {
                          itemHeight =
                              widget.argument!.picData[indexList].height ?? 0;
                        });
                      });
                    }
                    _lastCurIndex = _curIdx;
                    _lastCurPostId = _curPostId;
                  }
                },
                child: context.getAdsInBetween(picData.inBetweenAds, (info) {},
                    () {
                  context.read<PreviewPicNotifier>().setAdsData(index, null);
                }, (player, id) {}),
              )
            : Stack(
                children: [
                  Positioned.fill(
                    child: VisibilityDetector(
                      key: Key(index.toString()),
                      onVisibilityChanged: (info) {
                        if (info.visibleFraction == 1 ||
                            info.visibleFraction >= 0.6) {
                          _curIdx = index;
                          _curPostId = picData.postID ?? index.toString();
                          // if (_lastCurIndex != _curIdx) {
                          if (_lastCurPostId != _curPostId) {
                            final indexList = notifier!.pic!.indexWhere(
                                (element) => element.postID == _curPostId);

                            if (indexList == (notifier.pic?.length ?? 0) - 1) {
                              context
                                  .read<HomeNotifier>()
                                  .initNewHome(context, mounted,
                                      isreload: false, isgetMore: true)
                                  .then((value) {});
                            }
                            if (picData.music != null) {
                              debugPrint("ada musiknya ${picData.music}");
                              Future.delayed(const Duration(milliseconds: 100),
                                  () {
                                startMusic(context, picData);
                              });
                            } else {
                              fAliplayer?.stop();
                            }

                            Future.delayed(const Duration(milliseconds: 500),
                                () {
                              System().increaseViewCount2(context, picData,
                                  check: false);
                            });

                            if (picData.certified ?? false) {
                              System().block(context);
                            } else {
                              System().disposeBlock();
                            }
                            setState(() {
                              Future.delayed(const Duration(milliseconds: 400),
                                  () {
                                itemHeight =
                                    notifier.pic?[indexList ?? 0].height ?? 0;
                              });
                            });

                            ///ADS IN BETWEEN === Hariyanto Lukman ===
                            if (!notifier.loadAds) {
                              if ((notifier.pic?.length ?? 0) >
                                  notifier.nextAdsShowed) {
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
                      child: Center(
                          child: !notifier!.isConnect
                              ? OfflineMode(
                                  function: () async {
                                    var connect =
                                        await System().checkConnections();
                                    if (connect) {
                                      notifier.initialPic(context);
                                    }
                                  },
                                )
                              : ZoomableImage(
                                  enable: true,
                                  onScaleStart: () {
                                    print(
                                        "================masuk zoom============");
                                    // widget.onScaleStart?.call();
                                  }, // optional
                                  onScaleStop: () {
                                    // widget.onScaleStop?.call();
                                  },
                                  child: CustomBaseCacheImage(
                                    memCacheWidth: 100,
                                    memCacheHeight: 100,
                                    widthPlaceHolder: 80,
                                    heightPlaceHolder: 80,
                                    imageUrl: (picData.isApsara ?? false)
                                        ? ("${picData.mediaEndpoint}?key=${picData.valueCache}")
                                        : ("${picData.fullThumbPath}&key=${picData.valueCache}"),
                                    imageBuilder: (context, imageProvider) {
                                      return GestureDetector(
                                        behavior: HitTestBehavior.translucent,
                                        onTapDown: (details) {
                                          var position = details.globalPosition;
                                          notifier.positionDxDy = position;
                                        },
                                        onDoubleTap: () {
                                          context.read<LikeNotifier>().likePost(
                                              context, notifier!.pic![index]);
                                        },
                                        onTap: () {
                                          setState(() {
                                            isMute = !isMute;
                                            opacityLevel = 1.0;
                                          });
                                          fAliplayer?.setMuted(isMute);
                                          if (isMute) {
                                            animatedController.stop();
                                          } else {
                                            animatedController.repeat();
                                          }
                                          Future.delayed(
                                              const Duration(seconds: 1), () {
                                            opacityLevel = 0.0;
                                            setState(() {});
                                          });
                                        },
                                        child: ImageSize(
                                          onChange: (Size size) {
                                            if ((picData.imageHeightTemp ??
                                                    0) ==
                                                0) {
                                              setState(() {
                                                picData.imageHeightTemp =
                                                    size.height;
                                              });
                                            }
                                          },
                                          child: picData.reportedStatus ==
                                                  'BLURRED'
                                              ? ImageFiltered(
                                                  imageFilter: ImageFilter.blur(
                                                      sigmaX: 30, sigmaY: 30),
                                                  child: Image(
                                                    image: imageProvider,
                                                    fit: BoxFit.cover,
                                                    width:
                                                        SizeConfig.screenWidth,
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
                                        decoration: BoxDecoration(
                                            color: kHyppeNotConnect,
                                            borderRadius:
                                                BorderRadius.circular(16)),
                                        width: SizeConfig.screenWidth,
                                        height: 250,
                                        padding: const EdgeInsets.all(20),
                                        alignment: Alignment.center,
                                        child: CustomTextWidget(
                                          textToDisplay:
                                              lang?.couldntLoadImage ?? 'Error',
                                          maxLines: 3,
                                        )),
                                    errorWidget: (context, url, error) {
                                      return Container(
                                          decoration: BoxDecoration(
                                              color: kHyppeNotConnect,
                                              borderRadius:
                                                  BorderRadius.circular(16)),
                                          width: SizeConfig.screenWidth,
                                          height: 250,
                                          padding: const EdgeInsets.all(20),
                                          alignment: Alignment.center,
                                          child: CustomTextWidget(
                                            textToDisplay:
                                                lang?.couldntLoadImage ??
                                                    'Error',
                                            maxLines: 3,
                                          ));
                                    },
                                  ),
                                )),
                    ),
                  ),
                  _buildBody(context, SizeConfig.screenWidth, picData),
                  _buttomBodyRight(
                      picData: picData, notifier: notifier, index: index),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                        margin: const EdgeInsets.only(
                            top: kTextTabBarHeight - 12, left: 12.0),
                        padding: const EdgeInsets.symmetric(vertical: 18.0),
                        width: double.infinity,
                        height: kToolbarHeight * 2,
                        child: appBar(picData)),
                  ),
                  if (picData.music != null)
                    Positioned(
                      top: notifier!.positionDxDy.dy - 36,
                      left: notifier.positionDxDy.dx - 36,
                      child: AnimatedOpacity(
                        opacity: opacityLevel,
                        duration: const Duration(milliseconds: 500),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: CustomIconWidget(
                            iconData: isMute
                                ? '${AssetPath.vectorPath}sound-off.svg'
                                : '${AssetPath.vectorPath}sound-on.svg',
                            defaultColor: false,
                            height: 32,
                          ),
                        ),
                      ),
                    ),
                ],
              );
  }

  Widget _buildBody(BuildContext context, width, ContentData data) {
    return Positioned(
      bottom: kToolbarHeight - 12,
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
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    children: [
                      if (data.tagPeople?.isNotEmpty ?? false)
                        GestureDetector(
                          onTap: () {
                            fAliplayer?.pause();
                            context.read<PicDetailNotifier>().showUserTag(
                                context, data.tagPeople, data.postID,
                                title: lang!.inthisphoto,
                                fAliplayer: fAliplayer);
                          },
                          child: Row(
                            children: [
                              const CustomIconWidget(
                                iconData:
                                    '${AssetPath.vectorPath}tag_people.svg',
                                defaultColor: false,
                                height: 24,
                              ),
                              Text(
                                '${data.tagPeople!.length} ${lang!.people}',
                                style:
                                    const TextStyle(color: kHyppeTextPrimary),
                              )
                            ],
                          ),
                        ),
                      if (data.location != '')
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: (data.tagPeople?.isNotEmpty ?? false)
                                  ? 12.0
                                  : 0.0,
                              vertical: 16.0),
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: Row(
                              children: [
                                const Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 8.0),
                                  child: CustomIconWidget(
                                    iconData:
                                        '${AssetPath.vectorPath}map-light.svg',
                                    defaultColor: false,
                                    height: 16,
                                  ),
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width * .5,
                                  child: Text(
                                    '${data.location}',
                                    maxLines: 1,
                                    style: const TextStyle(
                                        color: kHyppeLightBackground,
                                        fontSize: 10),
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
                  width: SizeConfig.screenWidth! * .7,
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: CustomDescContent(
                    desc: "${data.description}",
                    trimLines: 2,
                    textAlign: TextAlign.start,
                    seeLess:
                        ' ${lang?.seeLess}', // ${notifier2.translate.seeLess}',
                    seeMore:
                        '  ${lang?.seeMoreContent}', //${notifier2.translate.seeMoreContent}',
                    normStyle:
                        const TextStyle(fontSize: 12, color: kHyppeTextPrimary),
                    hrefStyle: Theme.of(context)
                        .textTheme
                        .subtitle2
                        ?.copyWith(color: kHyppePrimary),
                    expandStyle: Theme.of(context)
                        .textTheme
                        .subtitle2
                        ?.copyWith(color: kHyppeTextPrimary),
                  ),
                ),
                if (data.music != null)
                  Container(
                    width: SizeConfig.screenWidth! * .7,
                    margin: const EdgeInsets.only(left: 16.0, top: 12.0),
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
                                angle: animatedController.value * 2 * math.pi,
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
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(24)),
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: imageProvider,
                                    ),
                                  ),
                                );
                              },
                              errorWidget: (_, __, ___) {
                                return const CustomIconWidget(
                                  iconData:
                                      "${AssetPath.vectorPath}music_stroke_black.svg",
                                  defaultColor: false,
                                  color: kHyppeLightIcon,
                                  height: 18,
                                );
                              },
                              emptyWidget: const CustomIconWidget(
                                iconData:
                                    "${AssetPath.vectorPath}music_stroke_black.svg",
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
                          width: SizeConfig.screenWidth! * .55,
                          child: CustomTextWidget(
                            textToDisplay: " ${data.music?.musicTitle ?? ''}",
                            maxLines: 1,
                            textStyle: const TextStyle(
                                color: kHyppeTextPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.w700),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ],
                    ),
                  )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buttomBodyRight(
      {ContentData? picData, PreviewPicNotifier? notifier, int index = -1}) {
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
                  iconData:
                      '${AssetPath.vectorPath}${(picData?.insight?.isPostLiked ?? false) ? 'liked.svg' : 'love-shadow.svg'}',
                  value: '${picData?.insight?.likes}',
                  liked: picData?.insight?.isPostLiked ?? false),
            ),
            if (picData!.allowComments ?? false)
              buttonRight(
                onFunctionTap: () {
                  Routing().move(Routes.commentsDetail,
                      argument: CommentsArgument(
                          postID: picData.postID ?? '',
                          fromFront: true,
                          data: picData));
                },
                iconData: '${AssetPath.vectorPath}comment-shadow.svg',
                value: picData.comments! > 0
                    ? picData.comments.toString()
                    : lang?.comments ?? '',
              ),
            if ((picData.isShared ?? false))
              buttonRight(
                  onFunctionTap: () {
                    context
                        .read<PicDetailNotifier>()
                        .createdDynamicLink(context, data: picData);
                  },
                  iconData: '${AssetPath.vectorPath}share-shadow.svg',
                  value: lang!.share ?? 'Share'),
            if ((picData.saleAmount ?? 0) > 0 && email != picData.email)
              buttonRight(
                  onFunctionTap: () async {
                    fAliplayer?.pause();
                    await ShowBottomSheet.onBuyContent(context,
                        data: picData, fAliplayer: fAliplayer);
                  },
                  iconData: '${AssetPath.vectorPath}cart-shadow.svg',
                  value: lang!.buy ?? 'Buy'),
          ],
        ),
      ),
    );
  }

  Widget buttonRight(
      {Function()? onFunctionTap,
      required String iconData,
      required String value,
      bool liked = false}) {
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
            Text(
              value,
              style: const TextStyle(
                  shadows: [
                    Shadow(
                        offset: Offset(0.0, 1.0),
                        blurRadius: 2.0,
                        color: Colors.black54),
                    Shadow(
                        offset: Offset(0.0, 1.0),
                        blurRadius: 2.0,
                        color: Colors.black54),
                  ],
                  color: kHyppePrimaryTransparent,
                  fontWeight: FontWeight.w500,
                  fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget appBar(ContentData data) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              onPressed: () {
                fAliplayer?.pause();

                Routing().moveBack();
              },
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
                shadows: <Shadow>[
                  Shadow(color: Colors.black54, blurRadius: 8.0)
                ],
              ),
            ),
            ProfileComponent(
              show: true,
              following: true,
              onFollow: () {},
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
                  isMute = true;
                });
              },
              featureType: FeatureType.pic,
              imageUrl:
                  '${System().showUserPicture(data.avatar?.mediaEndpoint)}',
              badge: data.urluserBadge,
              createdAt: '${System().readTimestamp(
                DateTime.parse(System().dateTimeRemoveT(data.createdAt ?? ''))
                    .millisecondsSinceEpoch,
                context,
                fullCaption: true,
              )}',
            ),
          ],
        ),
        actionWidget(
            onTap: () {
              if (data.email != email) {
                context.read<PreviewPicNotifier>().reportContent(context, data,
                    fAliplayer: fAliplayer, onCompleted: () async {
                  imageCache.clear();
                  imageCache.clearLiveImages();
                  await (Routing.navigatorKey.currentContext ?? context)
                      .read<HomeNotifier>()
                      .initNewHome(context, mounted,
                          isreload: true, forceIndex: 0);
                });
              } else {
                fAliplayer?.setMuted(true);
                fAliplayer?.pause();
                ShowBottomSheet().onShowOptionContent(
                  context,
                  contentData: data,
                  captionTitle: hyppePic,
                  onDetail: false,
                  isShare: data.isShared,
                  onUpdate: () {
                    (Routing.navigatorKey.currentContext ?? context)
                        .read<HomeNotifier>()
                        .initNewHome(context, mounted,
                            isreload: true, forceIndex: 0);
                  },
                  fAliplayer: fAliplayer,
                );
              }
            },
            data: data),
      ],
    );
  }

  Widget actionWidget({Function()? onTap, ContentData? data}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
      child: Row(
        children: [
          Visibility(
            visible: (data!.saleAmount ?? 0) > 0,
            child: Container(
              padding: EdgeInsets.all(
                  data.email == SharedPreference().readStorage(SpKeys.email)
                      ? 2.0
                      : 13),
              child: const CustomIconWidget(
                iconData: "${AssetPath.vectorPath}sale.svg",
                defaultColor: false,
                height: 22,
              ),
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
}
