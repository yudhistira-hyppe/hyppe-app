import 'dart:convert';
import 'dart:ui';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_aliplayer/flutter_alilistplayer.dart';
import 'package:hyppe/app.dart';
import 'package:hyppe/core/arguments/contents/slided_vid_detail_screen_argument.dart';
import 'package:hyppe/core/bloc/posts_v2/bloc.dart';
import 'package:hyppe/core/bloc/posts_v2/state.dart';
import 'package:hyppe/core/config/ali_config.dart';
import 'package:hyppe/core/constants/kyc_status.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/utils.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/services/route_observer_service.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/entities/like/notifier.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/show_general_dialog.dart';
import 'package:hyppe/ui/constant/widget/button_boost.dart';
import 'package:hyppe/ui/constant/widget/custom_background_layer.dart';
import 'package:hyppe/ui/constant/widget/custom_newdesc_content_widget.dart';
import 'package:hyppe/ui/constant/widget/no_result_found.dart';
import 'package:hyppe/ui/constant/widget/profile_landingpage.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/playlist/widget/content_violation.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/playlist/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/widget/pic_top_item.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/playlist/comments_detail/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/playlist/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/scroll/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/widget/vid_player_page.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/widget/video_thumbnail_report.dart';
import 'package:hyppe/ui/inner/home/notifier_v2.dart';
import 'package:hyppe/ui/inner/home/widget/view_like.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_shimmer.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../../../constant/widget/custom_text_widget.dart';

class ScrollVid extends StatefulWidget {
  final SlidedVidDetailScreenArgument? arguments;
  const ScrollVid({
    Key? key,
    this.arguments,
  }) : super(key: key);

  @override
  State<ScrollVid> createState() => _ScrollVidState();
}

class _ScrollVidState extends State<ScrollVid> with WidgetsBindingObserver, TickerProviderStateMixin, RouteAware {
  List<ContentData>? vidData = [];
  int indexVid = 0;
  bool isPrepare = false;
  bool isPlay = false;
  bool isPause = false;
  bool isloading = false;
  int _curIdx = -1;
  // int _lastCurIndex = -1;
  int _cardIndex = 0;

  bool toComment = false;

  String auth = '';
  String email = '';
  LocalizationModelV2? lang;
  ContentData? dataSelected;
  // ModeTypeAliPLayer? _playMode = ModeTypeAliPLayer.auth;

  Map<int, FlutterAliplayer> dataAli = {};

  
  final ScrollOffsetController scrollOffsetController = ScrollOffsetController();

  /// Listener that reports the position of items when the list is scrolled.
  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    isStopVideo = true;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    FirebaseCrashlytics.instance.setCustomKey('layout', 'ScrollVid');
    email = SharedPreference().readStorage(SpKeys.email);
    final notifier = Provider.of<ScrollVidNotifier>(context, listen: false);
    // notifier.initialVid(context, reload: true);
    lang = context.read<TranslateNotifierV2>().translate;
    vidData = widget.arguments?.vidData;
    indexVid = widget.arguments!.page ?? 0;
    notifier.vidData = widget.arguments?.vidData;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      print("============== widget argument ${widget.arguments!.vidData}");
      notifier.itemScrollController.jumpTo(index: widget.arguments!.page!);
      // notifier.checkConnection();
    });
    var index = 0;
    var lastIndex = 0;
    itemPositionsListener.itemPositions.addListener(() async {
      index = itemPositionsListener.itemPositions.value.first.index;
      if (lastIndex != index) {
        if (index == vidData!.length - 2) {
          bool connect = await System().checkConnections();
          if (connect) {
            print("ini reload harusnya");
            if (!notifier.isLoadingLoadmore) {
              await notifier.loadMore(context, _scrollController, widget.arguments!.pageSrc!, widget.arguments?.key ?? '');
              if (mounted) {
                setState(() {
                  vidData = notifier.vidData;
                });
              } else {
                vidData = notifier.vidData;
              }
            }
          } else {
            if (mounted) {
              ShowGeneralDialog.showToastAlert(
                context,
                lang?.internetConnectionLost ?? ' Error',
                () async {},
              );
            }
          }
        }
        lastIndex = index;
      }
    });
    checkInet();

    super.initState();
  }

  void checkInet() async {
    var inet = await System().checkConnections();
    if (!inet) {
      TranslateNotifierV2 tn = context.read<TranslateNotifierV2>();
      ShowGeneralDialog.showToastAlert(
        context,
        tn.translate.internetConnectionLost ?? ' Error',
        () async {
          Routing().moveBack();
        },
      );
    }
  }

  @override
  void didChangeDependencies() {
    CustomRouteObserver.routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
    // await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
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
    ScrollVidNotifier notifier = context.read<ScrollVidNotifier>();
    if (indexVid == (notifier.vidData?.length ?? 0)) {
      setState(() {
        indexVid = _curIdx - 1;
        print("=-=-=-=-=-  $indexVid =-==-=-=-=-=-=");
      });
    }
    // final notifier = context.read<ScrollVidNotifier>();
    if (_curIdx != -1) {
      vidData?[_curIdx].fAliplayer?.play();
    }

    // System().disposeBlock();
    if (toComment) {
      ScrollVidNotifier notifier = context.read<ScrollVidNotifier>();
      setState(() {
        vidData = notifier.vidData;
        toComment = false;
      });
    }

    super.didPopNext();
  }

  @override
  void didPushNext() {
    print("========= didPushNext dari diary");
    // final notifier = context.read<ScrollVidNotifier>();
    if (_curIdx != -1) {
      vidData?[_curIdx].fAliplayer?.pause();
    }

    super.didPushNext();
  }

  ScrollVidNotifier getNotifier(BuildContext context) {
    return context.read<ScrollVidNotifier>();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    // final vidNotifier = context.watch<ScrollVidNotifier>();
    // final error = context.select((ErrorService value) => value.getError(ErrorType.vid));
    // final likeNotifier = Provider.of<LikeNotifier>(context, listen: false);

    return Scaffold(
      backgroundColor: kHyppeLightSurface,
      body: WillPopScope(
        onWillPop: () async {
          Navigator.pop(context, '$_cardIndex');
          return false;
        },
        child: Consumer3<ScrollVidNotifier, TranslateNotifierV2, HomeNotifier>(
          builder: (_, vidNotifier, translateNotifier, homeNotifier, __) => SafeArea(
            child: SizedBox(
              child: Column(
                children: [
                    ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(transform: Matrix4.translationValues(-18.0, 0.0, 0.0), margin: const EdgeInsets.symmetric(horizontal: 10), child: widget.arguments?.titleAppbar ?? Container()),
                          if (vidData?.isNotEmpty ?? false)
                          if (vidData?[indexVid].email != email && (vidData?[indexVid].isNewFollowing ?? false) && (widget.arguments?.isProfile ?? false))
                            Consumer<PreviewPicNotifier>(
                              builder: (context, picNot, child) => Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: GestureDetector(
                                  onTap: () {
                                    context.handleActionIsGuest(() {
                                      if (vidData?[indexVid].insight?.isloadingFollow != true) {
                                        picNot.followUser(context, vidData![indexVid], isUnFollow: vidData?[indexVid].following, isloading: vidData?[indexVid].insight!.isloadingFollow ?? false);
                                      }
                                    });
                                  },
                                  child: vidData?[indexVid].insight?.isloadingFollow ?? false
                                      ? const SizedBox(
                                          height: 30,
                                          width: 30,
                                          child: Center(
                                            child: CustomLoading(),
                                          ),
                                        )
                                      : SizedBox(
                                          height: 40,
                                          child: Center(
                                            child: Text(
                                              (vidData?[indexVid].following ?? false) ? (lang?.following ?? '') : (lang?.follow ?? ''),
                                              style: const TextStyle(color: kHyppePrimary, fontWeight: FontWeight.w700, fontFamily: "Lato"),
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      leading: IconButton(
                          icon: const Icon(
                            Icons.chevron_left,
                            color: kHyppeTextLightPrimary,
                          ),
                          onPressed: () {
                            Navigator.pop(context, '$_cardIndex');
                          }),
                    ),
                  Expanded(
                    child: (vidData?.isEmpty ?? true)
                        ? const NoResultFound()
                        : RefreshIndicator(
                            onRefresh: () async {
                              bool connect = await System().checkConnections();
                              if (connect) {
                                setState(() {
                                  isloading = true;
                                });
                                await vidNotifier.reload(context, widget.arguments!.pageSrc!, key: widget.arguments?.key ?? '');
                                setState(() {
                                  vidData = vidNotifier.vidData;
                                });
                              } else {
                                if (mounted) {
                                  ShowGeneralDialog.showToastAlert(
                                    context,
                                    lang?.internetConnectionLost ?? ' Error',
                                    () async {},
                                  );
                                }
                              }
                            },
                            child: NotificationListener<OverscrollIndicatorNotification>(
                              onNotification: (overscroll) {
                                overscroll.disallowIndicator();
                                return false;
                              },
                              child: ScrollablePositionedList.builder(
                                itemScrollController: vidNotifier.itemScrollController,
                                itemPositionsListener: itemPositionsListener,
                                scrollOffsetController: scrollOffsetController,
                                physics: const AlwaysScrollableScrollPhysics(),
                                shrinkWrap: false,
                                padding: const EdgeInsets.symmetric(horizontal: 11.5),
                                itemCount: vidData?.length ?? 0,
                                itemBuilder: (BuildContext context, int index) {
                                  if (vidData == null || homeNotifier.isLoadingVid) {
                                    vidData?[index].fAliplayer?.pause();
                                    // _lastCurIndex = -1;
                                    return CustomShimmer(
                                      margin: const EdgeInsets.only(bottom: 100, right: 16, left: 16),
                                      height: context.getHeight() / 8,
                                      width: double.infinity,
                                    );
                                  } else if (index == vidData?.length) {
                                    return const CustomLoading(size: 5);
                                  }
                                  // if (_curIdx == 0 && vidData?[0].reportedStatus == 'BLURRED') {
                                  //   isPlay = false;
                                  //   vidData?[index].fAliplayer?.stop();
                                  // }
                                  // final vidData = vidData?[index];

                                  return itemVid(vidNotifier, index);
                                },
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget itemVid(ScrollVidNotifier notifier, int index) {
    var map = {
      DataSourceRelated.vidKey: vidData?[index].apsaraId,
      DataSourceRelated.regionKey: DataSourceRelated.defaultRegion,
    };
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
          ),
          padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 16),
          margin: const EdgeInsets.only(
            top: 18,
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
                      username: '${vidData?[index].username}',
                      featureType: FeatureType.other,
                      // isCelebrity: vidnotifier.diaryData?[index].privacy?.isCelebrity,
                      isCelebrity: false,
                      imageUrl: '${System().showUserPicture(vidData?[index].avatar?.mediaEndpoint)}',
                      onTapOnProfileImage: () => System().navigateToProfile(context, vidData?[index].email ?? ''),
                      createdAt: '2022-02-02',
                      musicName: vidData?[index].music?.musicTitle ?? '',
                      location: vidData?[index].location ?? '',
                      isIdVerified: vidData?[index].privacy?.isIdVerified,
                      badge: vidData?[index].urluserBadge,
                    ),
                  ),
                  if (vidData?[index].email != email && (vidData?[index].isNewFollowing ?? false) && !(widget.arguments?.isProfile ?? false))
                    Consumer<PreviewPicNotifier>(
                      builder: (context, picNot, child) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            context.handleActionIsGuest(() {
                              if (vidData?[index].insight?.isloadingFollow != true) {
                                picNot.followUser(context, vidData![index], isUnFollow: vidData?[index].following, isloading: vidData?[index].insight!.isloadingFollow ?? false);
                              }
                            });
                          },
                          child: vidData?[index].insight?.isloadingFollow ?? false
                              ? Container(
                                  height: 40,
                                  width: 30,
                                  child: const Align(
                                    alignment: Alignment.bottomRight,
                                    child: CustomLoading(),
                                  ),
                                )
                              : Text(
                                  (vidData?[index].following ?? false) ? (lang?.following ?? '') : (lang?.follow ?? ''),
                                  style: TextStyle(color: kHyppePrimary, fontSize: 12, fontWeight: FontWeight.w700, fontFamily: "Lato"),
                                ),
                        ),
                      ),
                    ),
                  GestureDetector(
                    onTap: () {
                      context.handleActionIsGuest(() async {
                        if (vidData?[index].email != email) {
                          // FlutterAliplayer? fAliplayer
                          context.read<PreviewPicNotifier>().reportContent(context, vidData?[index] ?? ContentData(), fAliplayer: vidData?[index].fAliplayer, onCompleted: () async {
                            bool connect = await System().checkConnections();
                            if (connect) {
                              setState(() {
                                isloading = true;
                              });
                              await notifier.reload(Routing.navigatorKey.currentContext ?? context, widget.arguments!.pageSrc!, key: widget.arguments?.key ?? '');
                              setState(() {
                                vidData = notifier.vidData;
                              });
                            } else {
                              if (mounted) {
                                ShowGeneralDialog.showToastAlert(
                                  context,
                                  lang?.internetConnectionLost ?? ' Error',
                                  () async {},
                                );
                              }
                            }
                          });
                        } else {
                          if (_curIdx != -1) {
                            print('Vid Landing Page: pause $_curIdx');
                            vidData?[_curIdx].fAliplayer?.pause();
                          }

                          ShowBottomSheet().onShowOptionContent(
                            context,
                            contentData: vidData?[index] ?? ContentData(),
                            captionTitle: hyppeVid,
                            onDetail: false,
                            isShare: vidData?[index].isShared,
                            onUpdate: () {
                              if  (index == (vidData?.length ?? 0 - 1)) {
                                setState(() {
                                  indexVid = index - 1;
                                });
                              }
                              setState(() {});
                              context.read<HomeNotifier>().onUpdate();
                            },
                            fAliplayer: vidData?[index].fAliplayer,
                          );
                          vidData?[index].fAliplayer?.pause();
                        }
                      });
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
                    _cardIndex = index;
                    if (_curIdx != index) {
                      Future.delayed(const Duration(milliseconds: 400), () {
                        try {
                          widget.arguments?.scrollController?.jumpTo(System().scrollAuto(_cardIndex, widget.arguments?.heightTopProfile ?? 0, widget.arguments?.heightBox?.toInt() ?? 100));
                        } catch (e) {
                          print("ini error $e");
                        }
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
                child: (vidData?[index].reportedStatus == 'BLURRED')
                    ? blurContentWidget(context, vidData![index])
                    : !notifier.connectionError
                        ? Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            child: Builder(builder: (context) {
                              return VidPlayerPage(
                                isVidFormProfile: widget.arguments!.isProfile ?? false,
                                enableWakelock: false,
                                orientation: Orientation.portrait,
                                playMode: (vidData?[index].isApsara ?? false) ? ModeTypeAliPLayer.auth : ModeTypeAliPLayer.url,
                                dataSourceMap: map,
                                data: vidData?[index] ?? ContentData(),
                                vidData: vidData,
                                index: index,
                                height: MediaQuery.of(context).size.width * 9.0 / 16.0,
                                width: MediaQuery.of(context).size.width,
                                inLanding: true,
                                fromDeeplink: false,
                                isAutoPlay: false,
                                functionFullTriger: (value) {},
                                onPlay: (exec) async {
                                  await notifier.checkConnection();
                                  try {
                                    if (_curIdx != -1) {
                                      if (_curIdx != index) {
                                        if (vidData?[_curIdx].fAliplayer != null) {
                                          vidData?[_curIdx].fAliplayer?.stop();
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
                                  globalAliPlayer = main;
                                  setState(() {
                                    vidData?[index].fAliplayer = main;
                                    dataAli[index] = main;
                                  });
                                  print('Vid Player1: after $index ${globalAliPlayer} : ${vidData?[index].fAliplayer}');
                                },
                                getAdsPlayer: (ads) {
                                  // vidData?[index].fAliplayerAds = ads;
                                },
                                loadMoreFunction: () {},
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
                                child: CustomTextWidget(textToDisplay: lang?.couldntLoadVideo ?? 'Error')),
                          ),
              ),
              SharedPreference().readStorage(SpKeys.statusVerificationId) == VERIFIED &&
                      (vidData![index].boosted.isEmpty) &&
                      (vidData?[index].reportedStatus != 'OWNED' && vidData?[index].reportedStatus != 'BLURRED' && vidData?[index].reportedStatus2 != 'BLURRED') &&
                      vidData?[index].email == email
                  ? Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ButtonBoost(
                        onDetail: false,
                        marginBool: true,
                        contentData: vidData?[index] ?? ContentData(),
                        startState: () {
                          SharedPreference().writeStorage(SpKeys.isShowPopAds, true);
                        },
                        afterState: () {
                          SharedPreference().writeStorage(SpKeys.isShowPopAds, false);
                        },
                      ),
                    )
                  : Container(),
              vidData?[index].email == SharedPreference().readStorage(SpKeys.email) && (vidData?[index].reportedStatus == 'OWNED' || vidData?[index].reportedStatus == 'OWNED')
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 11.0),
                      child: ContentViolationWidget(
                        data: vidData?[index] ?? ContentData(),
                        text: lang?.thisHyppeVidisSubjectToModeration ?? '',
                      ),
                    )
                  : Container(),
              if (vidData?[index].email == email && (vidData?[index].boostCount ?? 0) >= 0 && (vidData?[index].boosted.isNotEmpty ?? [].isEmpty))
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(bottom: 10),
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
                          "${vidData?[index].boostJangkauan ?? '0'} ${lang?.reach}",
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kHyppeTextLightPrimary),
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
                            child: vidData?[index].insight?.isloading ?? false
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
                                      color: (vidData?[index].insight?.isPostLiked ?? false) ? kHyppeRed : kHyppeTextLightPrimary,
                                      iconData: '${AssetPath.vectorPath}${(vidData?[index].insight?.isPostLiked ?? false) ? 'liked.svg' : 'none-like.svg'}',
                                      height: 28,
                                    ),
                                    onTap: () {
                                      if (vidData != null) {
                                        likeNotifier.likePost(context, vidData?[index] ?? ContentData()).then((value) {
                                          List<ContentData>? vidData = context.read<PreviewVidNotifier>().vidData;
                                          int idx = vidData!.indexWhere((e) => e.postID == value['_id']);
                                          vidData[idx].insight?.isPostLiked = value['isPostLiked'];
                                          vidData[idx].insight?.likes = value['likes'];
                                          vidData[idx].isLiked = value['isLiked'];
                                        });
                                      }
                                    },
                                  ),
                          ),
                        ),
                        if (vidData?[index].allowComments ?? false)
                          Padding(
                            padding: const EdgeInsets.only(left: 21.0),
                            child: GestureDetector(
                              onTap: () {
                                toComment = true;
                                Routing().move(Routes.commentsDetail,
                                    argument: CommentsArgument(
                                      postID: vidData?[index].postID ?? '',
                                      fromFront: true,
                                      data: vidData?[index] ?? ContentData(),
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
                        if ((vidData?[index].isShared ?? false))
                          Padding(
                            padding: EdgeInsets.only(left: 21.0),
                            child: GestureDetector(
                              onTap: () {
                                context.read<VidDetailNotifier>().createdDynamicLink(context, data: vidData?[index] ?? ContentData());
                              },
                              child: CustomIconWidget(
                                defaultColor: false,
                                color: kHyppeTextLightPrimary,
                                iconData: '${AssetPath.vectorPath}share2.svg',
                                height: 24,
                              ),
                            ),
                          ),
                        if ((vidData?[index].saleAmount ?? 0) > 0 && email != vidData?[index].email)
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                await context.handleActionIsGuest(() async {
                                  vidData?[index].fAliplayer?.pause();
                                  await ShowBottomSheet.onBuyContent(context, data: vidData?[index] ?? ContentData(), fAliplayer: vidData?[index].fAliplayer);
                                });
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
                    RichText(
                      text: TextSpan(children: [
                        TextSpan(
                          text: "${vidData?[index].insight?.likes} ${lang!.like}",
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => Navigator.push(
                                context,
                                CupertinoPageRoute(
                                    builder: (context) => ViewLiked(
                                          postId: vidData?[index].postID ?? '',
                                          eventType: 'LIKE',
                                        ))),
                          style: const TextStyle(color: kHyppeTextLightPrimary, fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                        const TextSpan(
                          text: " . ",
                          style: TextStyle(color: kHyppeTextLightPrimary, fontWeight: FontWeight.w700, fontSize: 22),
                        ),
                        TextSpan(
                          text: "${vidData?[index].insight!.views?.getCountShort()} ${lang!.views}",
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => Navigator.push(
                                context,
                                CupertinoPageRoute(
                                    builder: (context) => ViewLiked(
                                          postId: vidData?[index].postID ?? '',
                                          eventType: 'VIEW',
                                        ))),
                          style: const TextStyle(color: kHyppeTextLightPrimary, fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                      ]),
                    ),
                  ],
                ),
              ),
              twelvePx,
              CustomNewDescContent(
                email: vidData?[index].email ?? '',
                username: vidData?[index].username ?? '',
                desc: "${vidData?[index].description}",
                trimLines: 2,
                textAlign: TextAlign.start,
                seeLess: ' ${lang?.less}',
                seeMore: ' ${lang?.more}',
                normStyle: const TextStyle(fontSize: 12, color: kHyppeTextLightPrimary),
                hrefStyle: Theme.of(context).textTheme.titleSmall?.copyWith(color: kHyppePrimary),
                expandStyle: const TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.bold),
              ),
              if (vidData?[index].allowComments ?? true)
                GestureDetector(
                  onTap: () {
                    toComment = true;
                    Routing().move(Routes.commentsDetail,
                        argument: CommentsArgument(
                          postID: vidData?[index].postID ?? '',
                          fromFront: true,
                          data: vidData?[index] ?? ContentData(),
                          pageDetail: true,
                        ));
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      "${lang?.seeAll} ${vidData?[index].comments} ${lang?.comment}",
                      style: const TextStyle(fontSize: 12, color: kHyppeBurem),
                    ),
                  ),
                ),
              (vidData?[index].comment?.length ?? 0) > 0
                  ? Padding(
                      padding: const EdgeInsets.only(top: 0.0),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: (vidData?[index].comment?.length ?? 0) >= 2 ? 2 : 1,
                        itemBuilder: (context, indexComment) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6.0),
                            child: CustomNewDescContent(
                              // desc: "${vidData?.description}",
                              email: vidData?[index].email??'',
                              username: vidData?[index].comment?[indexComment].userComment?.username ?? '',
                              desc: vidData?[index].comment?[indexComment].txtMessages ?? '',
                              trimLines: 2,
                              textAlign: TextAlign.start,
                              seeLess: ' ${lang?.seeLess}', // ${notifier2.translate.seeLess}',
                              seeMore: ' ${lang?.seeMoreContent}', //${notifier2.translate.seeMoreContent}',
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
                    DateTime.parse(System().dateTimeRemoveT(vidData?[index].createdAt ?? DateTime.now().toString())).millisecondsSinceEpoch,
                    context,
                    fullCaption: true,
                  )}",
                  style: TextStyle(fontSize: 12, color: kHyppeBurem),
                ),
              ),
            ],
          ),
        ),
        vidData?.length == index && notifier.isLoadingLoadmore
            ? const SizedBox(
                height: 50,
                child: CustomLoading(),
              )
            : Container(),
      ],
    );
  }

  // Widget itemVid(ContentData vidData, ScrollVidNotifier vidNotifier) {
  //   return GestureDetector(
  //     onTap: () {
  //       vidNotifier.navigateToHyppeVidDetail(context, vidData, fromLAnding: true);
  //     },
  //     child: Container(
  //       decoration: BoxDecoration(
  //         borderRadius: BorderRadius.circular(16),
  //         color: Colors.white,
  //       ),
  //       padding: const EdgeInsets.only(top: 20, left: 16, right: 16, bottom: 16),
  //       margin: const EdgeInsets.only(bottom: 16),
  //       child: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             crossAxisAlignment: CrossAxisAlignment.center,
  //             children: [
  //               Expanded(
  //                 child: ProfileLandingPage(
  //                   show: true,
  //                   // cacheKey: vidData?.email == email ? homeNotifier.profileImageKey : null,
  //                   onFollow: () {},
  //                   following: true,
  //                   haveStory: false,
  //                   textColor: kHyppeTextLightPrimary,
  //                   username: vidData?[index].username,
  //                   featureType: FeatureType.other,
  //                   // isCelebrity: vidvidData?.privacy?.isCelebrity,
  //                   isCelebrity: false,
  //                   imageUrl: '${System().showUserPicture(vidData?[index].avatar?.mediaEndpoint)}',
  //                   onTapOnProfileImage: () => System().navigateToProfile(context, vidData?[index].email ?? ''),
  //                   createdAt: '2022-02-02',
  //                   musicName: vidData?[index].music?.musicTitle ?? '',
  //                   location: vidData?[index].location ?? '',
  //                   isIdVerified: vidData?[index].privacy?.isIdVerified,
  //                 ),
  //               ),
  //               if (vidData?[index].email != email && (vidData?[index].isNewFollowing ?? false))
  //                 Consumer<PreviewPicNotifier>(
  //                   builder: (context, picNot, child) => Padding(
  //                     padding: const EdgeInsets.symmetric(horizontal: 8.0),
  //                     child: GestureDetector(
  //                       onTap: () {
  //                         if (vidData?[index].insight?.isloadingFollow != true) {
  //                           picNot.followUser(context, vidData, isUnFollow: vidData?[index].following, isloading: vidData?[index].insight!.isloadingFollow ?? false);
  //                         }
  //                       },
  //                       child: vidData?[index].insight?.isloadingFollow ?? false
  //                           ? Container(
  //                               height: 40,
  //                               width: 30,
  //                               child: Align(
  //                                 alignment: Alignment.bottomRight,
  //                                 child: CustomLoading(),
  //                               ),
  //                             )
  //                           : Text(
  //                               (vidData?[index].following ?? false) ? (lang?.following ?? '') : (lang?.follow ?? ''),
  //                               style: TextStyle(color: kHyppePrimary, fontSize: 12, fontWeight: FontWeight.w700, fontFamily: "Lato"),
  //                             ),
  //                     ),
  //                   ),
  //                 ),
  //               GestureDetector(
  //                 onTap: () {
  //                   if (vidData?[index].email != SharedPreference().readStorage(SpKeys.email)) {
  //                     vidNotifier.reportContent(context, vidData);
  //                   } else {
  //                     ShowBottomSheet().onShowOptionContent(
  //                       context,
  //                       contentData: vidData,
  //                       captionTitle: hyppeVid,
  //                       onDetail: false,
  //                       isShare: vidData?[index].isShared,
  //                       onUpdate: () => context.read<HomeNotifier>().onUpdate(),
  //                     );
  //                   }
  //                 },
  //                 child: const Icon(
  //                   Icons.more_vert,
  //                   color: kHyppeTextLightPrimary,
  //                 ),
  //               ),
  //             ],
  //           ),
  //           twelvePx,
  //           Stack(
  //             children: [
  //               AspectRatio(
  //                 aspectRatio: 16 / 9,
  //                 child: Container(
  //                   decoration: BoxDecoration(
  //                     borderRadius: BorderRadius.circular(16),
  //                     color: Colors.black,
  //                   ),
  //                   child: CustomBaseCacheImage(
  //                     memCacheWidth: 100,
  //                     memCacheHeight: 100,
  //                     widthPlaceHolder: 80,
  //                     heightPlaceHolder: 80,
  //                     imageUrl: (vidData?[index].isApsara ?? false) ? (vidData?[index].mediaThumbEndPoint ?? "") : "${vidData?[index].fullThumbPath}",
  //                     imageBuilder: (context, imageProvider) => Container(
  //                       // const EdgeInsets.symmetric(horizontal: 4.5),
  //                       width: SizeConfig.screenWidth,
  //                       height: SizeConfig.screenWidth! / 1.5,
  //                       decoration: BoxDecoration(
  //                         image: DecorationImage(
  //                           image: imageProvider,
  //                           fit: BoxFit.contain,
  //                         ),
  //                         borderRadius: BorderRadius.circular(16.0),
  //                       ),
  //                     ),
  //                     errorWidget: (context, url, error) {
  //                       return Container(
  //                         // const EdgeInsets.symmetric(horizontal: 4.5),
  //
  //                         height: 186,
  //                         decoration: BoxDecoration(
  //                           image: const DecorationImage(
  //                             image: AssetImage('${AssetPath.pngPath}content-error.png'),
  //                             fit: BoxFit.contain,
  //                           ),
  //                           borderRadius: BorderRadius.circular(8.0),
  //                         ),
  //                       );
  //                     },
  //                     emptyWidget: Container(
  //                       // const EdgeInsets.symmetric(horizontal: 4.5),
  //
  //                       height: 186,
  //                       decoration: BoxDecoration(
  //                         image: const DecorationImage(
  //                           image: AssetImage('${AssetPath.pngPath}content-error.png'),
  //                           fit: BoxFit.contain,
  //                         ),
  //                         borderRadius: BorderRadius.circular(8.0),
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //               AspectRatio(aspectRatio: 16 / 9, child: _buildBody(context, vidData, SizeConfig.screenWidth)),
  //             ],
  //           ),
  //           // (vidData?.tagPeople?.isNotEmpty ?? false) || vidData?.location != ''
  //           //     ? Padding(
  //           //         padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(top: 10.0),
  //           //         child: Row(
  //           //           children: [
  //           //             vidData?.tagPeople?.isNotEmpty ?? false
  //           //                 ? TagLabel(
  //           //                     icon: 'tag_people',
  //           //                     label: '${vidData?.tagPeople?.length} people',
  //           //                     function: () {
  //           //                       vidNotifier.showUserTag(context, index, vidData?.postID);
  //           //                     },
  //           //                   )
  //           //                 : const SizedBox(),
  //           //             vidData?.location == '' || vidData?.location == null
  //           //                 ? const SizedBox()
  //           //                 : TagLabel(
  //           //                     icon: 'maptag',
  //           //                     label: "${vidData?.location}",
  //           //                     function: () {},
  //           //                   ),
  //           //           ],
  //           //         ),
  //           //       )
  //           //     : const SizedBox(),
  //           SharedPreference().readStorage(SpKeys.statusVerificationId) == VERIFIED &&
  //                   (vidData?[index].boosted.isEmpty) &&
  //                   (vidData?[index].reportedStatus != 'OWNED' && vidData?[index].reportedStatus != 'BLURRED' && vidData?[index].reportedStatus2 != 'BLURRED') &&
  //                   vidData?[index].email == email
  //               ? Container(
  //                   width: MediaQuery.of(context).size.width * 0.8,
  //                   margin: const EdgeInsets.only(top: 10),
  //                   child: ButtonBoost(
  //                     onDetail: false,
  //                     marginBool: true,
  //                     contentData: vidData,
  //                     startState: () {
  //                       SharedPreference().writeStorage(SpKeys.isShowPopAds, true);
  //                     },
  //                     afterState: () {
  //                       SharedPreference().writeStorage(SpKeys.isShowPopAds, false);
  //                     },
  //                   ),
  //                 )
  //               : Container(),
  //           if (vidData?[index].email == email && (vidData?[index].boostCount ?? 0) >= 0 && (vidData?[index].boosted.isNotEmpty))
  //             Container(
  //               padding: const EdgeInsets.all(10),
  //               margin: const EdgeInsets.only(top: 10),
  //               decoration: BoxDecoration(
  //                 borderRadius: BorderRadius.circular(6),
  //                 color: kHyppeGreyLight,
  //               ),
  //               child: Row(
  //                 mainAxisAlignment: MainAxisAlignment.start,
  //                 children: [
  //                   const CustomIconWidget(
  //                     iconData: "${AssetPath.vectorPath}reach.svg",
  //                     defaultColor: false,
  //                     height: 24,
  //                     color: kHyppeTextLightPrimary,
  //                   ),
  //                   Padding(
  //                     padding: const EdgeInsets.only(left: 13),
  //                     child: Text(
  //                       "${vidData?[index].boostJangkauan ?? '0'} ${lang?.reach}",
  //                       style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kHyppeTextLightPrimary),
  //                     ),
  //                   )
  //                 ],
  //               ),
  //             ),
  //           twelvePx,
  //           CustomNewDescContent(
  //             // desc: "${data?.description}",
  //             username: '',
  //             desc: "${vidData?[index].description}",
  //             trimLines: 2,
  //             textAlign: TextAlign.start,
  //             seeLess: ' ${lang?.seeLess}', // ${notifier2.translate.seeLess}',
  //             seeMore: '  ${lang?.seeMoreContent}', //${notifier2.translate.seeMoreContent}',
  //             normStyle: const TextStyle(fontSize: 12, color: kHyppeTextLightPrimary),
  //             hrefStyle: Theme.of(context).textTheme.subtitle2?.copyWith(color: kHyppePrimary),
  //             expandStyle: Theme.of(context).textTheme.subtitle2?.copyWith(color: Theme.of(context).colorScheme.primary),
  //           ),
  //           eightPx,
  //           Padding(
  //             padding: const EdgeInsets.symmetric(vertical: 4.0),
  //             child: Text(
  //               "${System().readTimestamp(
  //                 DateTime.parse(System().dateTimeRemoveT(vidData?[index].createdAt ?? DateTime.now().toString())).millisecondsSinceEpoch,
  //                 context,
  //                 fullCaption: true,
  //               )}",
  //               style: const TextStyle(fontSize: 12, color: kHyppeBurem),
  //             ),
  //           ),
  //           // vidData?.email == SharedPreference().readStorage(SpKeys.email) ? ButtonBoost(contentData: vidData) : Container(),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildBody(context, data, width) {
    // final translate = Provider.of<TranslateNotifierV2>(context, listen: false);
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: PicTopItem(data: data),
        ),
        if (data?.tagPeople?.isNotEmpty ?? false)
          Positioned(
            bottom: 18,
            left: 12,
            child: GestureDetector(
              onTap: () {
                context.read<PicDetailNotifier>().showUserTag(context, data?.tagPeople, data?.postID, title: lang!.inThisVideo);
              },
              child: const CustomIconWidget(
                iconData: '${AssetPath.vectorPath}tag_people.svg',
                defaultColor: false,
                height: 20,
              ),
            ),
          ),

        Positioned(
            bottom: 18,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                System().formatDuration(Duration(seconds: data?.metadata?.duration ?? 0).inMilliseconds),
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            )),
        // Positioned(bottom: 0, left: 0, child: PicBottomItem(data: data, width: width)),
        (data?.reportedStatus == "BLURRED")
            ? Positioned.fill(
                child: VideoThumbnailReport(
                  videoData: data,
                  seeContent: false,
                ),
              )
            : Container(),
        // data?.reportedStatus == 'BLURRED'
        //     ? ClipRect(
        //         child: BackdropFilter(
        //           filter: ImageFilter.blur(
        //             sigmaX: 30.0,
        //             sigmaY: 30.0,
        //           ),
        //           child: Container(
        //             alignment: Alignment.center,
        //             width: SizeConfig.screenWidth,
        //             height: 200.0,
        //             child: Column(
        //               mainAxisAlignment: MainAxisAlignment.center,
        //               children: const [
        //                 CustomIconWidget(
        //                   iconData: "${AssetPath.vectorPath}eye-off.svg",
        //                   defaultColor: false,
        //                   height: 50,
        //                   color: Colors.white,
        //                 ),
        //               ],
        //             ),
        //           ),
        //         ),
        //       )
        //     : Container(),
      ],
    );
  }

  Widget blurContentWidget(BuildContext context, ContentData data) {
    final transnot = Provider.of<TranslateNotifierV2>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: 19 / 13,
          child: Stack(
            children: [
              Center(
                child: ClipRRect(
                  // borderRadius: BorderRadius.circular(8.0),
                  child: CustomBackgroundLayer(
                    sigmaX: 10,
                    sigmaY: 10,
                    thumbnail: (data.isApsara ?? false) ? (data.mediaThumbEndPoint ?? '') : '${data.fullThumbPath}',
                  ),
                ),
              ),
              Positioned.fill(
                child: Center(
                    child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      twelvePx,
                      const CustomIconWidget(
                        iconData: "${AssetPath.vectorPath}eye-off.svg",
                        defaultColor: false,
                        height: 24,
                        color: Colors.white,
                      ),
                      fourPx,
                      Text(transnot.translate.sensitiveContent ?? 'Sensitive Content', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                      fourPx,
                      Text("${transnot.translate.contentContainsSensitiveMaterial}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          )),
                      data.email == SharedPreference().readStorage(SpKeys.email)
                          ? GestureDetector(
                              onTap: () async {
                                System().checkConnections().then((value) {
                                  if (value) {
                                    Routing().move(Routes.appeal, argument: data);
                                  }
                                });
                              },
                              child: Container(
                                  padding: const EdgeInsets.all(8),
                                  margin: const EdgeInsets.only(top: 6),
                                  decoration: BoxDecoration(border: Border.all(color: Colors.white), borderRadius: BorderRadius.circular(10)),
                                  child: Text(transnot.translate.appealThisWarning ?? 'Appeal This Warning', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600))),
                            )
                          : const SizedBox(),
                      thirtyTwoPx,
                    ],
                  ),
                )),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        data.reportedStatus = '';
                      });

                      // start(data);
                      // context.read<ReportNotifier>().seeContent(context, data, hyppeVid);
                      data.fAliplayer?.prepare();
                      data.fAliplayer?.play();
                      // context.read<ReportNotifier>().seeContent(context, videoData!, hyppeVid);
                    },
                    child: Container(
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      margin: const EdgeInsets.all(8),
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
                        "${transnot.translate.see} Vid",
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // void finish(ContentData data) async {
  //
  //   data.fAliplayer?.stop();
  //   setState(() {
  //     dataSelected?.isDiaryPlay = false;
  //     isPlay = false;
  //   });
  //   dataSelected = data;
  // }
  //
  // void start(ContentData data) async{
  //   finish(data);
  //   _lastCurIndex = _curIdx;
  //
  //   if (data.reportedStatus != 'BLURRED') {
  //     if (data.isApsara ?? false) {
  //       _playMode = ModeTypeAliPLayer.auth;
  //       await getAuth(data);
  //     } else {
  //       _playMode = ModeTypeAliPLayer.url;
  //       await getOldVideoUrl(data);
  //     }
  //   }
  //
  //   setState(() {
  //     isPause = false;
  //   });
  //   if (data.reportedStatus == 'BLURRED') {
  //   } else {
  //     data.fAliplayer?.prepare();
  //   }
  // }

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
