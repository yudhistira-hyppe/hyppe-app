import 'dart:ui';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_aliplayer/flutter_alilistplayer.dart';
import 'package:hyppe/core/constants/kyc_status.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/utils.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/widget/button_boost.dart';
import 'package:hyppe/ui/constant/widget/custom_newdesc_content_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/no_result_found.dart';
import 'package:hyppe/ui/constant/widget/profile_landingpage.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/playlist/comments_detail/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/playlist/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/widget/fullscreen/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/widget/vid_player_page.dart';
import 'package:hyppe/ui/inner/home/notifier_v2.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_shimmer.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/notifier.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../../../app.dart';
import '../../../../../core/config/ali_config.dart';
import '../../../../../core/services/route_observer_service.dart';
import '../../../../../ux/path.dart';
import '../../../../../ux/routing.dart';
import '../../../../constant/entities/like/notifier.dart';

class HyppePreviewVid extends StatefulWidget {
  const HyppePreviewVid({Key? key}) : super(key: key);

  @override
  _HyppePreviewVidState createState() => _HyppePreviewVidState();
}

class _HyppePreviewVidState extends State<HyppePreviewVid>
    with WidgetsBindingObserver, TickerProviderStateMixin, RouteAware {
  bool isPrepare = false;
  bool isPlay = false;
  bool isPause = false;
  bool isloading = false;
  int _curIdx = -1;
  int _lastCurIndex = -1;

  String auth = '';
  String email = '';
  LocalizationModelV2? lang;
  ContentData? dataSelected;
  ModeTypeAliPLayer? _playMode = ModeTypeAliPLayer.auth;

  Map<int, FlutterAliplayer> dataAli = {};

  @override
  void initState() {
    isStopVideo = true;
    FirebaseCrashlytics.instance.setCustomKey('layout', 'HyppePreviewVid');
    email = SharedPreference().readStorage(SpKeys.email);
    final notifier = Provider.of<PreviewVidNotifier>(context, listen: false);
    // notifier.initialVid(context, reload: true);
    notifier.pageController.addListener(() => notifier.scrollListener(context));
    lang = context.read<TranslateNotifierV2>().translate;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {});

    super.initState();
  }

  @override
  void didChangeDependencies() {
    CustomRouteObserver.routeObserver
        .subscribe(this, ModalRoute.of(context) as PageRoute);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    isStopVideo = false;
    try {
      final notifier = context.read<PreviewVidNotifier>();
      notifier.pageController.dispose();
    } catch (e) {
      e.logger();
    }
    CustomRouteObserver.routeObserver.unsubscribe(this);

    super.dispose();
  }

  @override
  void deactivate() {
    print("====== deactivate dari diary");
    isStopVideo = false;
    super.deactivate();
  }

  @override
  void didPop() {
    print("====== didpop dari diary");
    super.didPop();
  }

  @override
  void didPopNext() {
    print("======= didPopNext dari diary");
    final notifier = context.read<PreviewVidNotifier>();
    if (_curIdx != -1) {
      notifier.vidData?[_curIdx].fAliplayer?.play();
    }

    // System().disposeBlock();

    super.didPopNext();
  }

  @override
  void didPushNext() {
    print("========= didPushNext dari diary");
    final notifier = context.read<PreviewVidNotifier>();
    if (_curIdx != -1) {
      notifier.vidData?[_curIdx].fAliplayer?.pause();
    }

    super.didPushNext();
  }

  PreviewVidNotifier getNotifier(BuildContext context) {
    return context.read<PreviewVidNotifier>();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    // final vidNotifier = context.watch<PreviewVidNotifier>();
    // final error = context.select((ErrorService value) => value.getError(ErrorType.vid));
    // final likeNotifier = Provider.of<LikeNotifier>(context, listen: false);

    return Consumer3<PreviewVidNotifier, TranslateNotifierV2, HomeNotifier>(
      builder:
          (context, vidNotifier, translateNotifier, homeNotifier, widget) =>
              SizedBox(
        child: Column(
          children: [
            (vidNotifier.vidData != null)
                ? (vidNotifier.vidData?.isEmpty ?? true)
                    ? const NoResultFound()
                    : Expanded(
                        child: NotificationListener<
                            OverscrollIndicatorNotification>(
                          onNotification: (overscroll) {
                            overscroll.disallowIndicator();
                            return false;
                          },
                          child: ListView.builder(
                            // controller: vidNotifier.pageController,
                            // onPageChanged: (index) async {
                            //   print('HyppePreviewVid index : $index');
                            //   if (index == (vidNotifier.itemCount - 1)) {
                            //     final values = await vidNotifier.contentsQuery.loadNext(context, isLandingPage: true);
                            //     if (values.isNotEmpty) {
                            //       vidNotifier.vidData = [...(vidNotifier.vidData ?? [] as List<ContentData>)] + values;
                            //     }
                            //   }
                            //   // context.read<PreviewVidNotifier>().nextVideo = false;
                            //   // context.read<PreviewVidNotifier>().initializeVideo = false;
                            // },
                            shrinkWrap: true,
                            itemCount: vidNotifier.itemCount,
                            itemBuilder: (BuildContext context, int index) {
                              if (vidNotifier.vidData == null ||
                                  homeNotifier.isLoadingVid) {
                                vidNotifier.vidData?[index].fAliplayer?.pause();
                                _lastCurIndex = -1;
                                return CustomShimmer(
                                  margin: const EdgeInsets.only(
                                      bottom: 100, right: 16, left: 16),
                                  height: context.getHeight() / 8,
                                  width: double.infinity,
                                );
                              } else if (index == vidNotifier.vidData?.length &&
                                  vidNotifier.hasNext) {
                                return const CustomLoading(size: 5);
                              }
                              // if (_curIdx == 0 && vidNotifier.vidData?[0].reportedStatus == 'BLURRED') {
                              //   isPlay = false;
                              //   vidNotifier.vidData?[index].fAliplayer?.stop();
                              // }
                              final vidData = vidNotifier.vidData?[index];

                              return itemVid(context,
                                  vidData ?? ContentData(), vidNotifier, index);
                            },
                          ),
                        ),
                      )
                : const AspectRatio(
                    aspectRatio: 16 / 9,
                    child: CustomShimmer(
                      height: double.infinity,
                      width: double.infinity,
                    ),
                  ),
            homeNotifier.isLoadingLoadmore
                ? const SizedBox(
                    height: 50,
                    child: CustomLoading(),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  Widget itemVid(BuildContext context, ContentData vidData, PreviewVidNotifier notifier, int index) {
    var map = {
      DataSourceRelated.vidKey: vidData.apsaraId,
      DataSourceRelated.regionKey: DataSourceRelated.defaultRegion,
    };
    final ads = context.read<VideoNotifier>();
    return Column(
      children: [
        Container(
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
                      username: vidData.username,
                      featureType: FeatureType.other,
                      // isCelebrity: vidnotifier.diaryData?[index].privacy?.isCelebrity,
                      isCelebrity: false,
                      imageUrl:
                          '${System().showUserPicture(vidData.avatar?.mediaEndpoint)}',
                      onTapOnProfileImage: () =>
                          System().navigateToProfile(context, vidData.email ?? ''),
                      createdAt: '2022-02-02',
                      musicName: vidData.music?.musicTitle ?? '',
                      location: vidData.location ?? '',
                      isIdVerified: vidData.privacy?.isIdVerified,
                    ),
                  ),
                  if (vidData.email != email && (vidData.isNewFollowing ?? false))
                    Consumer<PreviewPicNotifier>(
                      builder: (context, picNot, child) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            if (vidData.insight?.isloadingFollow != true) {
                              picNot.followUser(context, vidData,
                                  isUnFollow: vidData.following,
                                  isloading:
                                      vidData.insight!.isloadingFollow ?? false);
                            }
                          },
                          child: vidData.insight?.isloadingFollow ?? false
                              ? Container(
                                  height: 40,
                                  width: 30,
                                  child: const Align(
                                    alignment: Alignment.bottomRight,
                                    child: CustomLoading(),
                                  ),
                                )
                              : Text(
                                  (vidData.following ?? false)
                                      ? (lang?.following ?? '')
                                      : (lang?.follow ?? ''),
                                  style: const TextStyle(
                                      color: kHyppePrimary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: "Lato"),
                                ),
                        ),
                      ),
                    ),
                  GestureDetector(
                    onTap: () {
                      if (vidData.email != email) {
                        // FlutterAliplayer? fAliplayer
                        context.read<PreviewPicNotifier>().reportContent(
                            context, vidData,
                            fAliplayer: vidData.fAliplayer);
                      } else {
                        if (_curIdx != -1) {
                          print('Vid Landing Page: pause $_curIdx');
                          notifier.vidData?[_curIdx].fAliplayer?.pause();
                        }

                        ShowBottomSheet().onShowOptionContent(
                          context,
                          contentData: vidData,
                          captionTitle: hyppeVid,
                          onDetail: false,
                          isShare: vidData.isShared,
                          onUpdate: () => context.read<HomeNotifier>().onUpdate(),
                          fAliplayer: vidData.fAliplayer,
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
                  if (info.visibleFraction >= 0.6) {
                    if (_curIdx != index) {
                      Future.delayed(const Duration(milliseconds: 400), () {
                        try {
                          if (_curIdx != -1) {
                            if (notifier.vidData?[_curIdx].fAliplayer != null) {
                              notifier.vidData?[_curIdx].fAliplayer?.pause();
                            } else {
                              dataAli[_curIdx]?.pause();
                            }
                            ads.adsAliplayer?.pause();
                            // notifier.vidData?[_curIdx].fAliplayerAds?.pause();
                            // setState(() {
                            //   _curIdx = -1;
                            // });
                          }
                        } catch (e) {
                          e.logger();
                        }
                        // System().increaseViewCount2(context, vidData);
                      });
                      if (vidData.certified ?? false) {
                        System().block(context);
                      } else {
                        System().disposeBlock();
                      }
                    }
                  }
                },
                child: globalInternetConnection
                    ? Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        child: Builder(builder: (context) {
                          return VidPlayerPage(
                            orientation: Orientation.portrait,
                            onShowAds: (ads){
                              setState(() {
                                vidData.adsShowing = ads != null;
                              });
                            },
                            betweenAds: (ads){
                              if(ads != null){
                                notifier.setAdsData(index, ads);
                              }
                            },
                            playMode: (vidData.isApsara ?? false)
                                ? ModeTypeAliPLayer.auth
                                : ModeTypeAliPLayer.url,
                            dataSourceMap: map,
                            data: vidData,
                            height: MediaQuery.of(context).size.width * 9.0 / 16.0,
                            width: MediaQuery.of(context).size.width,
                            inLanding: true,
                            fromDeeplink: false,
                            functionFullTriger: (value) {
                              print('===========hahhahahahaa===========');
                              // fullscreen();
                              // notifier.vidData?[_curIdx].fAliplayer?.pause();
                              // showDialog(context: context, builder: (context){
                              //     return VideoFullscreenPage(data: notifier.vidData?[_curIdx] ?? ContentData(), onClose: (){
                              //       // Routing().moveBack();
                              //     }, seekValue: value ?? 0);
                              //   });
                            },
                            onPlay: (exec) {
                              try {
                                if (_curIdx != -1) {
                                  if (_curIdx != index) {
                                    print(
                                        'Vid Landing Page: stop $_curIdx ${notifier.vidData?[_curIdx].fAliplayer} ${dataAli[_curIdx]}');
                                    if (notifier.vidData?[_curIdx].fAliplayer !=
                                        null) {
                                      notifier.vidData?[_curIdx].fAliplayer?.stop();
                                    } else {
                                      final player = dataAli[_curIdx];
                                      if (player != null) {
                                        // notifier.vidData?[_curIdx].fAliplayer = player;
                                        player.stop();
                                      }
                                    }
                                    ads.adsAliplayer?.stop();
                                    // notifier.vidData?[_curIdx].fAliplayerAds?.stop();
                                  }
                                }
                              } catch (e) {
                                e.logger();
                              } finally {
                                setState(() {
                                  _curIdx = index;
                                });
                              }
                              // _lastCurIndex = _curIdx;
                            },
                            getPlayer: (main) {
                              print('Vid Player1: screen ${main}');
                              notifier.setAliPlayer(index, main);
                              setState(() {
                                dataAli[index] = main;
                              });
                              print(
                                  'Vid Player1: after $index ${globalAliPlayer} : ${notifier.vidData?[index].fAliplayer}');
                            },
                            getAdsPlayer: (ads) {
                              // notifier.vidData?[index].fAliplayerAds = ads;
                            },
                            // fAliplayer: notifier.vidData?[index].fAliplayer,
                            // fAliplayerAds: notifier.vidData?[index].fAliplayerAds,
                          );
                        }),
                      )
                    : GestureDetector(
                        onTap: () async {
                          globalInternetConnection =
                              await System().checkConnections();
                          // _networklHasErrorNotifier.value++;
                          // reloadImage(index);
                        },
                        child: Container(
                            decoration: BoxDecoration(
                                color: kHyppeNotConnect,
                                borderRadius: BorderRadius.circular(16)),
                            width: SizeConfig.screenWidth,
                            height: 250,
                            margin: EdgeInsets.only(bottom: 16),
                            alignment: Alignment.center,
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: CustomTextWidget(
                                textToDisplay: lang?.couldntLoadVideo ?? 'Error',
                                maxLines: 4,
                              ),
                            )),
                      ),
              ),
              if(vidData.adsShowing ?? true)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: const BoxDecoration(color: kHyppeLightSurface),
                child: Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 12),
                      height: 36,
                      width: 36,
                      decoration: BoxDecoration(
                        image: const DecorationImage(
                          image:
                              AssetImage('${AssetPath.pngPath}image_ads_exp.png'),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTextWidget(
                            textToDisplay: 'nike.official',
                            textStyle: context
                                .getTextTheme()
                                .caption
                                ?.copyWith(fontWeight: FontWeight.w700, color: Colors.black),
                          ),
                          fourPx,
                          SizedBox(
                            child: RichText(
                              text: TextSpan(children: [
                                TextSpan(
                                    text: 'Ad ·',
                                    style: context
                                        .getTextTheme()
                                        .caption
                                        ?.copyWith(fontWeight: FontWeight.w700, color: Colors.black)),
                                TextSpan(
                                    text: ' www.example.com',
                                    style: context.getTextTheme().caption)
                              ]),
                            ),
                          )
                        ],
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: Ink(
                        width: 120,
                        decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            color: KHyppeButtonAds),
                        child: InkWell(
                          splashColor: context.getColorScheme().secondary,
                          onTap: () async {},
                          child: Builder(
                            builder: (context) {
                              final notifier = context.read<TranslateNotifierV2>();
                              return Container(
                                padding: const EdgeInsets.all(10),
                                alignment: Alignment.center,
                                child: Text(
                                  notifier.translate.learnMore ?? 'Learn More',
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
              ),
              twelvePx,
              SharedPreference().readStorage(SpKeys.statusVerificationId) ==
                          VERIFIED &&
                      (vidData.boosted.isEmpty) &&
                      (vidData.reportedStatus != 'OWNED' &&
                          vidData.reportedStatus != 'BLURRED' &&
                          vidData.reportedStatus2 != 'BLURRED') &&
                      vidData.email == email
                  ? Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ButtonBoost(
                        onDetail: false,
                        marginBool: true,
                        contentData: vidData,
                        startState: () {
                          SharedPreference()
                              .writeStorage(SpKeys.isShowPopAds, true);
                        },
                        afterState: () {
                          SharedPreference()
                              .writeStorage(SpKeys.isShowPopAds, false);
                        },
                      ),
                    )
                  : Container(),
              if (vidData.email == email &&
                  (vidData.boostCount ?? 0) >= 0 &&
                  (vidData.boosted.isNotEmpty))
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: kHyppeGreyLight,
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
                        child: Text(
                          "${vidData.boostJangkauan ?? '0'} ${lang?.reach}",
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: kHyppeTextLightPrimary),
                        ),
                      )
                    ],
                  ),
                ),
              Consumer<LikeNotifier>(
                builder: (context, likeNotifier, child) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Consumer<LikeNotifier>(
                          builder: (context, likeNotifier, child) => Align(
                            alignment: Alignment.bottomRight,
                            child: vidData.insight?.isloading ?? false
                                ? const SizedBox(
                                    height: 28,
                                    width: 28,
                                    child: CircularProgressIndicator(
                                      color: kHyppePrimary,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : InkWell(
                                    child: CustomIconWidget(
                                      defaultColor: false,
                                      color: (vidData.insight?.isPostLiked ?? false)
                                          ? kHyppeRed
                                          : kHyppeTextLightPrimary,
                                      iconData:
                                          '${AssetPath.vectorPath}${(vidData.insight?.isPostLiked ?? false) ? 'liked.svg' : 'none-like.svg'}',
                                      height: 28,
                                    ),
                                    onTap: () {
                                      if (vidData != null) {
                                        likeNotifier.likePost(context, vidData);
                                      }
                                    },
                                  ),
                          ),
                        ),
                        if (vidData.allowComments ?? false)
                          Padding(
                            padding: const EdgeInsets.only(left: 21.0),
                            child: GestureDetector(
                              onTap: () {
                                Routing().move(Routes.commentsDetail,
                                    argument: CommentsArgument(
                                        postID: vidData.postID ?? '',
                                        fromFront: true,
                                        data: vidData));
                              },
                              child: const CustomIconWidget(
                                defaultColor: false,
                                color: kHyppeTextLightPrimary,
                                iconData: '${AssetPath.vectorPath}comment2.svg',
                                height: 24,
                              ),
                            ),
                          ),
                        if ((vidData.isShared ?? false))
                          Padding(
                            padding: EdgeInsets.only(left: 21.0),
                            child: GestureDetector(
                              onTap: () {
                                context
                                    .read<VidDetailNotifier>()
                                    .createdDynamicLink(context, data: vidData);
                              },
                              child: CustomIconWidget(
                                defaultColor: false,
                                color: kHyppeTextLightPrimary,
                                iconData: '${AssetPath.vectorPath}share2.svg',
                                height: 24,
                              ),
                            ),
                          ),
                        if ((vidData.saleAmount ?? 0) > 0 && email != vidData.email)
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                vidData.fAliplayer?.pause();
                                await ShowBottomSheet.onBuyContent(context,
                                    data: vidData, fAliplayer: vidData.fAliplayer);
                                // fAliplayer?.play();
                              },
                              child: const Align(
                                alignment: Alignment.centerRight,
                                child: CustomIconWidget(
                                  defaultColor: false,
                                  color: kHyppeTextLightPrimary,
                                  iconData: '${AssetPath.vectorPath}cart.svg',
                                  height: 24,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    twelvePx,
                    Text(
                      "${vidData.insight?.likes}  ${lang?.like}",
                      style: const TextStyle(
                          color: kHyppeTextLightPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14),
                    ),
                  ],
                ),
              ),
              twelvePx,
              CustomNewDescContent(
                // desc: "${data?.description}",
                username: vidData.username ?? '',
                desc: "${vidData.description}",
                trimLines: 3,
                textAlign: TextAlign.start,
                seeLess: ' ${lang?.seeLess}', // ${notifier2.translate.seeLess}',
                seeMore:
                    '  ${lang?.seeMoreContent}', //${notifier2.translate.seeMoreContent}',
                normStyle:
                    const TextStyle(fontSize: 12, color: kHyppeTextLightPrimary),
                hrefStyle: Theme.of(context)
                    .textTheme
                    .subtitle2
                    ?.copyWith(color: kHyppePrimary),
                expandStyle: Theme.of(context)
                    .textTheme
                    .subtitle2
                    ?.copyWith(color: Theme.of(context).colorScheme.primary),
              ),
              GestureDetector(
                onTap: () {
                  Routing().move(Routes.commentsDetail,
                      argument: CommentsArgument(
                          postID: vidData.postID ?? '',
                          fromFront: true,
                          data: vidData));
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    "${lang?.seeAll} ${vidData.comments} ${lang?.comment}",
                    style: const TextStyle(fontSize: 12, color: kHyppeBurem),
                  ),
                ),
              ),
              (vidData.comment?.length ?? 0) > 0
                  ? Padding(
                      padding: const EdgeInsets.only(top: 0.0),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: (vidData.comment?.length ?? 0) >= 2 ? 2 : 1,
                        itemBuilder: (context, indexComment) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6.0),
                            child: CustomNewDescContent(
                              // desc: "${vidData?.description}",
                              username: vidData.comment?[indexComment].userComment
                                      ?.username ??
                                  '',
                              desc:
                                  vidData.comment?[indexComment].txtMessages ?? '',
                              trimLines: 3,
                              textAlign: TextAlign.start,
                              seeLess:
                                  ' ${lang?.seeLess}', // ${notifier2.translate.seeLess}',
                              seeMore:
                                  ' ${lang?.seeMoreContent}', //${notifier2.translate.seeMoreContent}',
                              normStyle: const TextStyle(
                                  fontSize: 12, color: kHyppeTextLightPrimary),
                              hrefStyle: Theme.of(context)
                                  .textTheme
                                  .subtitle2
                                  ?.copyWith(color: kHyppePrimary),
                              expandStyle: Theme.of(context)
                                  .textTheme
                                  .subtitle2
                                  ?.copyWith(
                                      color: Theme.of(context).colorScheme.primary),
                            ),
                          );
                        },
                      ),
                    )
                  : Container(),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  "${System().readTimestamp(
                    DateTime.parse(System().dateTimeRemoveT(
                            vidData.createdAt ?? DateTime.now().toString()))
                        .millisecondsSinceEpoch,
                    context,
                    fullCaption: true,
                  )}",
                  style: TextStyle(fontSize: 12, color: kHyppeBurem),
                ),
              ),
            ],
          ),
        ),
        context.getAdsInBetween(vidData.adsData, vidData.postID ?? '', (info){
          if (notifier.vidData?[_curIdx].fAliplayer != null) {
            notifier.vidData?[_curIdx].fAliplayer?.pause();
          } else {
            dataAli[_curIdx]?.pause();
          }
          ads.adsAliplayer?.pause();
        })
      ],
    );
  }
}
