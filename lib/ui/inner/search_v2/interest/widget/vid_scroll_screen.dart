import 'dart:convert';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_aliplayer/flutter_aliplayer.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/ui/inner/search_v2/notifier.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../../../app.dart';
import '../../../../../core/bloc/posts_v2/bloc.dart';
import '../../../../../core/bloc/posts_v2/state.dart';
import '../../../../../core/config/ali_config.dart';
import '../../../../../core/constants/asset_path.dart';
import '../../../../../core/constants/enum.dart';
import '../../../../../core/constants/kyc_status.dart';
import '../../../../../core/constants/shared_preference_keys.dart';
import '../../../../../core/constants/size_config.dart';
import '../../../../../core/constants/themes/hyppe_colors.dart';
import '../../../../../core/constants/utils.dart';
import '../../../../../core/models/collection/posts/content_v2/content_data.dart';
import '../../../../../core/services/route_observer_service.dart';
import '../../../../../core/services/shared_preference.dart';
import '../../../../../core/services/system.dart';
import '../../../../../ux/path.dart';
import '../../../../../ux/routing.dart';
import '../../../../constant/entities/like/notifier.dart';
import '../../../../constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import '../../../../constant/overlay/general_dialog/show_general_dialog.dart';
import '../../../../constant/widget/button_boost.dart';
import '../../../../constant/widget/custom_icon_widget.dart';
import '../../../../constant/widget/custom_loading.dart';
import '../../../../constant/widget/custom_newdesc_content_widget.dart';
import '../../../../constant/widget/custom_shimmer.dart';
import '../../../../constant/widget/custom_spacer.dart';
import '../../../../constant/widget/custom_text_widget.dart';
import '../../../../constant/widget/profile_landingpage.dart';
import '../../../home/content_v2/diary/playlist/widget/content_violation.dart';
import '../../../home/content_v2/pic/notifier.dart';
import '../../../home/content_v2/vid/playlist/comments_detail/screen.dart';
import '../../../home/content_v2/vid/playlist/notifier.dart';
import '../../../home/content_v2/vid/widget/vid_player_page.dart';
import '../../../home/notifier_v2.dart';

class VidScrollScreen extends StatefulWidget {
  final String interestKey;
  const VidScrollScreen({Key? key, required this.interestKey}) : super(key: key);

  @override
  State<VidScrollScreen> createState() => _VidScrollScreenState();
}

class _VidScrollScreenState extends State<VidScrollScreen> with WidgetsBindingObserver, TickerProviderStateMixin, RouteAware  {
  bool isPrepare = false;
  bool isPlay = false;
  bool isPause = false;
  bool isloading = false;
  int _curIdx = -1;

  bool toComment = false;

  String auth = '';
  String email = '';

  Map<int, FlutterAliplayer> dataAli = {};

  // final ItemScrollController itemScrollController = ItemScrollController();
  // final ScrollOffsetController scrollOffsetController = ScrollOffsetController();
  //
  // /// Listener that reports the position of items when the list is scrolled.
  // final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();

  @override
  void initState() {
    isStopVideo = true;
    FirebaseCrashlytics.instance.setCustomKey('layout', 'ScrollVid');
    email = SharedPreference().readStorage(SpKeys.email);
    final notifier = Provider.of<SearchNotifier>(context, listen: false);
    checkInet(notifier);

    super.initState();
  }

  void checkInet(SearchNotifier notifier) async {
    var inet = await System().checkConnections();
    if (!inet) {
      ShowGeneralDialog.showToastAlert(
        Routing.navigatorKey.currentContext ?? context,
        notifier.language.internetConnectionLost ?? ' Error',
            () async {
          Routing().moveBack();
        },
      );
    }
  }

  @override
  void didChangeDependencies() {
    CustomRouteObserver.routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    isStopVideo = false;
    try {
      // final notifier = context.read<ScrollVidNotifier>();
      // notifier.pageController.dispose();
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
    final notifier = context.read<SearchNotifier>();
    final vidData = notifier.interestContents[widget.interestKey]?.vid;
    if (_curIdx != -1) {
      vidData?[_curIdx].fAliplayer?.play();
    }

    // System().disposeBlock();
    if (toComment) {
      setState(() {
        toComment = false;
      });
    }

    super.didPopNext();
  }

  @override
  void didPushNext() {
    print("========= didPushNext dari diary");
    final notifier = context.read<SearchNotifier>();
    final vidData = notifier.interestContents[widget.interestKey]?.vid;
    if (_curIdx != -1) {
      vidData?[_curIdx].fAliplayer?.pause();
    }

    super.didPushNext();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Consumer<SearchNotifier>(
      builder: (_, vidNotifier, __){
        final vidData = vidNotifier.interestContents[widget.interestKey]?.vid;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            (vidData != null)
                ? Flexible(
              child: NotificationListener<OverscrollIndicatorNotification>(
                onNotification: (overscroll) {
                  overscroll.disallowIndicator();
                  return false;
                },
                child: Column(
                  children: List.generate(vidData.length, (index) => itemVid(vidNotifier, index, vidData)),
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
          ],
        );
      },
    );
  }

  Widget itemVid(SearchNotifier notifier, int index, List<ContentData> vidData) {
    var map = {
      DataSourceRelated.vidKey: vidData[index].apsaraId,
      DataSourceRelated.regionKey: DataSourceRelated.defaultRegion,
    };
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
      ),
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 16),
      margin: const EdgeInsets.only(
        top: 10,
        left: 6,
        right: 6,
      ),
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
                  username: vidData[index].username,
                  featureType: FeatureType.other,
                  // isCelebrity: vidnotifier.diaryData?[index].privacy?.isCelebrity,
                  isCelebrity: false,
                  imageUrl: '${System().showUserPicture(vidData[index].avatar?.mediaEndpoint)}',
                  onTapOnProfileImage: () => System().navigateToProfile(context, vidData[index].email ?? ''),
                  createdAt: '2022-02-02',
                  musicName: vidData[index].music?.musicTitle ?? '',
                  location: vidData[index].location ?? '',
                  isIdVerified: vidData[index].privacy?.isIdVerified,
                  badge: vidData[index].urluserBadge,
                ),
              ),
              if (vidData[index].email != email && (vidData[index].isNewFollowing ?? false))
                Consumer<PreviewPicNotifier>(
                  builder: (context, picNot, child) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        if (vidData[index].insight?.isloadingFollow != true) {
                          picNot.followUser(context, vidData[index], isUnFollow: vidData[index].following, isloading: vidData[index].insight!.isloadingFollow ?? false);
                        }
                      },
                      child: vidData[index].insight?.isloadingFollow ?? false
                          ? Container(
                        height: 40,
                        width: 30,
                        child: const Align(
                          alignment: Alignment.bottomRight,
                          child: CustomLoading(),
                        ),
                      )
                          : Text(
                        (vidData[index].following ?? false) ? (notifier.language.following ?? '') : (notifier.language.follow ?? ''),
                        style: const TextStyle(color: kHyppePrimary, fontSize: 12, fontWeight: FontWeight.w700, fontFamily: "Lato"),
                      ),
                    ),
                  ),
                ),
              GestureDetector(
                onTap: () {
                  if (vidData[index].email != email) {
                    // FlutterAliplayer? fAliplayer
                    context.read<PreviewPicNotifier>()
                        .reportContent(
                        context,
                        vidData[index] ,
                        fAliplayer: vidData[index].fAliplayer,
                        onCompleted: (){},
                        key: widget.interestKey);
                  } else {
                    if (_curIdx != -1) {
                      print('Vid Landing Page: pause $_curIdx');
                      vidData[_curIdx].fAliplayer?.pause();
                    }

                    ShowBottomSheet().onShowOptionContent(
                      context,
                      contentData: vidData[index] ,
                      captionTitle: hyppeVid,
                      onDetail: false,
                      isShare: vidData[index].isShared,
                      onUpdate: () => context.read<HomeNotifier>().onUpdate(),
                      fAliplayer: vidData[index].fAliplayer,
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
              print("visibleFraction: ${info.visibleFraction}");
              if (info.visibleFraction >= 0.6) {
                if (_curIdx != index) {
                  Future.delayed(const Duration(milliseconds: 400), () {
                    try {
                      if (_curIdx != -1) {
                        print('Vid Landing Page: pause $_curIdx ${vidData[_curIdx].fAliplayer} ${dataAli[_curIdx]}');
                        if (vidData[_curIdx].fAliplayer != null) {
                          vidData[_curIdx].fAliplayer?.pause();
                        } else {
                          dataAli[_curIdx]?.pause();
                        }
                      }
                    } catch (e) {
                      e.logger();
                    }
                    // System().increaseViewCount2(context, vidData);
                  });
                  if (vidData[index].certified ?? false) {
                    System().block(context);
                  } else {
                    System().disposeBlock();
                  }
                }
              }
            },
            child: !notifier.connectionError
                ? Container(
              margin: const EdgeInsets.only(bottom: 20),
              child: Builder(builder: (context) {
                return VidPlayerPage(
                  orientation: Orientation.portrait,
                  playMode: (vidData[index].isApsara ?? false) ? ModeTypeAliPLayer.auth : ModeTypeAliPLayer.url,
                  dataSourceMap: map,
                  data: vidData[index] ,
                  height: MediaQuery.of(context).size.width * 9.0 / 16.0,
                  width: MediaQuery.of(context).size.width,
                  inLanding: true,
                  fromDeeplink: false,
                  functionFullTriger: (value) {
                  },
                  onPlay: (exec) async {
                    await notifier.checkConnection();
                    try {
                      if (_curIdx != -1) {
                        if (_curIdx != index) {
                          print('Vid Landing Page: stop $_curIdx ${vidData[_curIdx].fAliplayer} ${dataAli[_curIdx]}');
                          if (vidData[_curIdx].fAliplayer != null) {
                            vidData[_curIdx].fAliplayer?.stop();
                          } else {
                            final player = dataAli[_curIdx];
                            if (player != null) {
                              // vidData?[_curIdx].fAliplayer = player;
                              player.stop();
                            }
                          }
                          // vidData?[_curIdx].fAliplayerAds?.stop();
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
                  getPlayer: (main, id) {
                    print('Vid Player1: screen ${main}');
                    // notifier.setAliPlayer(index, main);
                    setState(() {
                      vidData[index].fAliplayer = main;
                      dataAli[index] = main;
                    });
                    print('Vid Player1: after $index ${globalAliPlayer} : ${vidData[index].fAliplayer}');
                  },
                  getAdsPlayer: (ads) {
                    // vidData?[index].fAliplayerAds = ads;
                  },
                  // fAliplayer: vidData?[index].fAliplayer,
                  // fAliplayerAds: vidData?[index].fAliplayerAds,
                );
              }),
            )
                : GestureDetector(
              onTap: () {
                notifier.checkConnection();
              },
              child: Container(
                  decoration: BoxDecoration(color: kHyppeNotConnect, borderRadius: BorderRadius.circular(16)),
                  width: SizeConfig.screenWidth,
                  height: 250,
                  alignment: Alignment.center,
                  child: CustomTextWidget(textToDisplay: notifier.language.couldntLoadVideo ?? 'Error')),
            ),
          ),
          SharedPreference().readStorage(SpKeys.statusVerificationId) == VERIFIED &&
              (vidData[index].boosted.isEmpty) &&
              (vidData[index].reportedStatus != 'OWNED' && vidData[index].reportedStatus != 'BLURRED' && vidData[index].reportedStatus2 != 'BLURRED') &&
              vidData[index].email == email
              ? Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 16),
            child: ButtonBoost(
              onDetail: false,
              marginBool: true,
              contentData: vidData[index] ,
              startState: () {
                SharedPreference().writeStorage(SpKeys.isShowPopAds, true);
              },
              afterState: () {
                SharedPreference().writeStorage(SpKeys.isShowPopAds, false);
              },
            ),
          )
              : Container(),
          vidData[index].email == SharedPreference().readStorage(SpKeys.email) && (vidData[index].reportedStatus == 'OWNED')
              ? Padding(
            padding: const EdgeInsets.only(bottom: 11.0),
            child: ContentViolationWidget(
              data: vidData[index] ,
              text: notifier.language.thisHyppeVidisSubjectToModeration ?? '',
            ),
          )
              : Container(),
          if (vidData[index].email == email && (vidData[index].boostCount ?? 0) >= 0 && (vidData[index].boosted.isNotEmpty))
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
                      "${vidData[index].boostJangkauan ?? '0'} ${notifier.language.reach}",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kHyppeTextLightPrimary),
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
                        child: vidData[index].insight?.isloading ?? false
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
                            color: (vidData[index].insight?.isPostLiked ?? false) ? kHyppeRed : kHyppeTextLightPrimary,
                            iconData: '${AssetPath.vectorPath}${(vidData[index].insight?.isPostLiked ?? false) ? 'liked.svg' : 'none-like.svg'}',
                            height: 28,
                          ),
                          onTap: () {
                            likeNotifier.likePost(context, vidData[index]);
                          },
                        ),
                      ),
                    ),
                    if (vidData[index].allowComments ?? false)
                      Padding(
                        padding: const EdgeInsets.only(left: 21.0),
                        child: GestureDetector(
                          onTap: () {
                            toComment = true;
                            Routing().move(Routes.commentsDetail,
                                argument: CommentsArgument(
                                  postID: vidData[index].postID ?? '',
                                  fromFront: true,
                                  data: vidData[index],
                                  pageDetail: true,
                                ));
                          },
                          child: const CustomIconWidget(
                            defaultColor: false,
                            color: kHyppeTextLightPrimary,
                            iconData: '${AssetPath.vectorPath}comment2.svg',
                            height: 24,
                          ),
                        ),
                      ),
                    if ((vidData[index].isShared ?? false))
                      Padding(
                        padding: const EdgeInsets.only(left: 21.0),
                        child: GestureDetector(
                          onTap: () {
                            context.read<VidDetailNotifier>().createdDynamicLink(context, data: vidData[index]);
                          },
                          child: const CustomIconWidget(
                            defaultColor: false,
                            color: kHyppeTextLightPrimary,
                            iconData: '${AssetPath.vectorPath}share2.svg',
                            height: 24,
                          ),
                        ),
                      ),
                    if ((vidData[index].saleAmount ?? 0) > 0 && email != vidData[index].email)
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            vidData[index].fAliplayer?.pause();
                            await ShowBottomSheet.onBuyContent(context, data: vidData[index], fAliplayer: vidData[index].fAliplayer);

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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "${vidData[index].insight?.likes}  ${notifier.language.like}",
                      style: const TextStyle(color: kHyppeTextLightPrimary, fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                    const Text(
                      " . ",
                      style: TextStyle(color: kHyppeTextLightPrimary, fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    Text(
                      " ${System().formatterNumber(vidData[index].insight?.views)}  ${notifier.language.views}",
                      style: const TextStyle(color: kHyppeTextLightPrimary, fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
          twelvePx,
          CustomNewDescContent(
            email: vidData[index].email??'',
            username: vidData[index].username ?? '',
            desc: "${vidData[index].description}",
            trimLines: 2,
            textAlign: TextAlign.start,
            seeLess: ' ${notifier.language.seeLess}', // ${notifier2.translate.seeLess}',
            seeMore: '  ${notifier.language.seeMoreContent}', //${notifier2.translate.seeMoreContent}',
            normStyle: const TextStyle(fontSize: 12, color: kHyppeTextLightPrimary),
            hrefStyle: Theme.of(context).textTheme.subtitle2?.copyWith(color: kHyppePrimary),
            expandStyle: Theme.of(context).textTheme.subtitle2?.copyWith(color: Theme.of(context).colorScheme.primary),
          ),
          if (vidData[index].allowComments ?? true)
            GestureDetector(
              onTap: () {
                toComment = true;
                Routing().move(Routes.commentsDetail,
                    argument: CommentsArgument(
                      postID: vidData[index].postID ?? '',
                      fromFront: true,
                      data: vidData[index] ,
                      pageDetail: true,
                    ));
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  "${notifier.language.seeAll} ${vidData[index].comments} ${notifier.language.comment}",
                  style: const TextStyle(fontSize: 12, color: kHyppeBurem),
                ),
              ),
            ),
          (vidData[index].comment?.length ?? 0) > 0
              ? Padding(
            padding: const EdgeInsets.only(top: 0.0),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: (vidData[index].comment?.length ?? 0) >= 2 ? 2 : 1,
              itemBuilder: (context, indexComment) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: CustomNewDescContent(
                    // desc: "${vidData?.description}",
                    username: vidData[index].comment?[indexComment].userComment?.username ?? '',
                    desc: vidData[index].comment?[indexComment].txtMessages ?? '',
                    trimLines: 2,
                    textAlign: TextAlign.start,
                    seeLess: ' ${notifier.language.seeLess}', // ${notifier2.translate.seeLess}',
                    seeMore: ' ${notifier.language.seeMoreContent}', //${notifier2.translate.seeMoreContent}',
                    normStyle: const TextStyle(fontSize: 12, color: kHyppeTextLightPrimary),
                    hrefStyle: Theme.of(context).textTheme.subtitle2?.copyWith(color: kHyppePrimary),
                    expandStyle: Theme.of(context).textTheme.subtitle2?.copyWith(color: Theme.of(context).colorScheme.primary),
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
                DateTime.parse(System().dateTimeRemoveT(vidData[index].createdAt ?? DateTime.now().toString())).millisecondsSinceEpoch,
                context,
                fullCaption: true,
              )}",
              style: TextStyle(fontSize: 12, color: kHyppeBurem),
            ),
          ),
        ],
      ),
    );
  }


  Widget blurContentWidget(BuildContext context, LocalizationModelV2 lang, ContentData data) {
    return data.reportedStatus == 'BLURRED'
        ? Positioned.fill(
      child: Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Spacer(),
                const CustomIconWidget(
                  iconData: "${AssetPath.vectorPath}eye-off.svg",
                  defaultColor: false,
                  height: 30,
                ),
                Text(lang.sensitiveContent ?? 'Sensitive Content', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                Text("HyppeVid ${lang.contentContainsSensitiveMaterial}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                    )),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    data.reportedStatus = '';
                    data.fAliplayer?.prepare();
                    data.fAliplayer?.play();
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
                      "${lang.see} HyppeVid",
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          )),
    )
        : Container();
  }

  Future getOldVideoUrl(ContentData data) async {
    setState(() {
      isloading = true;
    });
    try {
      final notifier = PostsBloc();
      await notifier.getOldVideo(context, apsaraId: data.postID ?? '');
      final fetch = notifier.postsFetch;
      if (fetch.postsState == PostsState.videoApsaraSuccess) {
        Map jsonMap = json.decode(fetch.data.toString());

        data.fAliplayer?.setUrl(jsonMap['data']['url']);
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

  Future getAuth(ContentData data) async {
    setState(() {
      isloading = true;
    });
    data.isLoading = true;
    try {
      final notifier = PostsBloc();
      await notifier.getAuthApsara(context, apsaraId: data.apsaraId ?? '');
      final fetch = notifier.postsFetch;
      if (fetch.postsState == PostsState.videoApsaraSuccess) {
        Map jsonMap = json.decode(fetch.data.toString());
        auth = jsonMap['PlayAuth'];

        data.fAliplayer?.setVidAuth(
          vid: data.apsaraId,
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
}
