import 'dart:convert';
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
import 'package:hyppe/ui/constant/widget/no_result_found.dart';
import 'package:hyppe/ui/constant/widget/profile_landingpage.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/playlist/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/widget/pic_top_item.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/playlist/comments_detail/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/playlist/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/widget/vid_player_page.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/widget/video_thumbnail_report.dart';
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
import '../../../../../core/bloc/posts_v2/bloc.dart';
import '../../../../../core/bloc/posts_v2/state.dart';
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

class _HyppePreviewVidState extends State<HyppePreviewVid> with WidgetsBindingObserver, TickerProviderStateMixin, RouteAware {
  // FlutterAliplayer? fAliplayer;
  // FlutterAliplayer? fAliplayerAds;
  bool isPrepare = false;
  bool isPlay = false;
  bool isPause = false;
  // bool _showLoading = false;
  // bool _inSeek = false;
  bool isloading = false;
  // bool isMute = false;

  // int _loadingPercent = 0;
  // int _currentPlayerState = 0;
  // int _videoDuration = 1;
  // int _currentPosition = 0;
  // int _bufferPosition = 0;
  // int _currentPositionText = 0;
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
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //   fAliplayer = FlutterAliPlayerFactory.createAliPlayer();
    //   WidgetsBinding.instance.addObserver(this);
    //   fAliplayer?.pause();
    //   fAliplayer?.setAutoPlay(true);
    //   fAliplayer?.setLoop(true);
    //
    //   //Turn on mix mode
    //   if (Platform.isIOS) {
    //     FlutterAliplayer.enableMix(true);
    //   }
    //
    //   //set player
    //   fAliplayer?.setPreferPlayerName(GlobalSettings.mPlayerName);
    //   fAliplayer?.setEnableHardwareDecoder(GlobalSettings.mEnableHardwareDecoder);
    //   _initListener();
    // });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    CustomRouteObserver.routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
    super.didChangeDependencies();
  }

  // _initListener() {
  //   fAliplayer?.setOnEventReportParams((params, playerId) {
  //     print("EventReportParams=${params}");
  //   });
  //   fAliplayer?.setOnPrepared((playerId) {
  //     // Fluttertoast.showToast(msg: "OnPrepared ");
  //     fAliplayer?.getPlayerName().then((value) => print("getPlayerName==${value}"));
  //     fAliplayer?.getMediaInfo().then((value) {
  //       setState(() {
  //         isPrepare = true;
  //         getNotifier(context).vidData?[_lastCurIndex].isLoading = false;
  //       });
  //     });
  //     isPlay = true;
  //     dataSelected?.isDiaryPlay = true;
  //     _initAds(context);
  //   });
  //   fAliplayer?.setOnRenderingStart((playerId) {
  //     // Fluttertoast.showToast(msg: " OnFirstFrameShow ");
  //   });
  //   fAliplayer?.setOnVideoSizeChanged((width, height, rotation, playerId) {});
  //   fAliplayer?.setOnStateChanged((newState, playerId) {
  //     _currentPlayerState = newState;
  //     print("aliyun : onStateChanged $newState");
  //     switch (newState) {
  //       case FlutterAvpdef.AVPStatus_AVPStatusStarted:
  //         setState(() {
  //           getNotifier(context).vidData?[_lastCurIndex].isLoading = false;
  //           isPause = false;
  //         });
  //         break;
  //       case FlutterAvpdef.AVPStatus_AVPStatusPaused:
  //         isPause = true;
  //         setState(() {});
  //         break;
  //       default:
  //     }
  //   });
  //   fAliplayer?.setOnLoadingStatusListener(loadingBegin: (playerId) {
  //     setState(() {
  //       _loadingPercent = 0;
  //       getNotifier(context).vidData?[_lastCurIndex].isLoading = true;
  //     });
  //   }, loadingProgress: (percent, netSpeed, playerId) {
  //     _loadingPercent = percent;
  //     if (percent == 100) {
  //       getNotifier(context).vidData?[_lastCurIndex].isLoading = false;
  //     }
  //     setState(() {});
  //   }, loadingEnd: (playerId) {
  //     setState(() {
  //       getNotifier(context).vidData?[_lastCurIndex].isLoading = false;
  //     });
  //   });
  //   fAliplayer?.setOnSeekComplete((playerId) {
  //     _inSeek = false;
  //   });
  //   fAliplayer?.setOnInfo((infoCode, extraValue, extraMsg, playerId) {
  //     if (infoCode == FlutterAvpdef.CURRENTPOSITION) {
  //       if (_videoDuration != 0 && (extraValue ?? 0) <= _videoDuration) {
  //         _currentPosition = extraValue ?? 0;
  //       }
  //       // if (!_inSeek) {
  //       //   setState(() {
  //       //     _currentPositionText = extraValue ?? 0;
  //       //   });
  //       // }
  //     } else if (infoCode == FlutterAvpdef.BUFFEREDPOSITION) {
  //       _bufferPosition = extraValue ?? 0;
  //       // if (mounted) {
  //       //   setState(() {});
  //       // }
  //     } else if (infoCode == FlutterAvpdef.AUTOPLAYSTART) {
  //       // Fluttertoast.showToast(msg: "AutoPlay");
  //     } else if (infoCode == FlutterAvpdef.CACHESUCCESS) {
  //     } else if (infoCode == FlutterAvpdef.CACHEERROR) {
  //     } else if (infoCode == FlutterAvpdef.LOOPINGSTART) {
  //       // Fluttertoast.showToast(msg: "Looping Start");
  //     } else if (infoCode == FlutterAvpdef.SWITCHTOSOFTWAREVIDEODECODER) {
  //       // Fluttertoast.showToast(msg: "change to soft ware decoder");
  //       // mOptionsFragment.switchHardwareDecoder();
  //     }
  //   });
  //   fAliplayer?.setOnCompletion((playerId) {
  //     getNotifier(context).vidData?[_lastCurIndex].isLoading = false;
  //
  //     isPause = true;
  //
  //     setState(() {
  //       _currentPosition = _videoDuration;
  //     });
  //   });
  //
  //   fAliplayer?.setOnSnapShot((path, playerId) {
  //     print("aliyun : snapShotPath = $path");
  //     // Fluttertoast.showToast(msg: "SnapShot Save : $path");
  //   });
  //   fAliplayer?.setOnError((errorCode, errorExtra, errorMsg, playerId) {
  //     getNotifier(context).vidData?[_lastCurIndex].isLoading = false;
  //
  //     setState(() {});
  //   });
  //
  //   fAliplayer?.setOnTrackChanged((value, playerId) {
  //     AVPTrackInfo info = AVPTrackInfo.fromJson(value);
  //     if (info != null && (info.trackDefinition?.length ?? 0) > 0) {
  //       // trackFragmentKey.currentState.onTrackChanged(info);
  //       // Fluttertoast.showToast(msg: "${info.trackDefinition}切换成功");
  //     }
  //   });
  //   fAliplayer?.setOnThumbnailPreparedListener(preparedSuccess: (playerId) {}, preparedFail: (playerId) {});
  //
  //   fAliplayer?.setOnThumbnailGetListener(
  //       onThumbnailGetSuccess: (bitmap, range, playerId) {
  //         // _thumbnailBitmap = bitmap;
  //         var provider = MemoryImage(bitmap);
  //         precacheImage(provider, context).then((_) {
  //           setState(() {});
  //         });
  //       },
  //       onThumbnailGetFail: (playerId) {});
  //
  //   fAliplayer?.setOnSubtitleHide((trackIndex, subtitleID, playerId) {
  //     if (mounted) {
  //       setState(() {});
  //     }
  //   });
  //
  //   fAliplayer?.setOnSubtitleShow((trackIndex, subtitleID, subtitle, playerId) {
  //     if (mounted) {
  //       setState(() {});
  //     }
  //   });
  // }
  //
  // void onViewPlayerCreated(viewId) async {
  //   fAliplayer?.setPlayerView(viewId);
  // }

  // _initAds(BuildContext context) async {
  //   //for ads
  //   // getCountVid();
  //   // await _newInitAds(true);
  //   context.incrementAdsCount();
  //   if (context.getAdsCount() == null) {
  //     context.setAdsCount(0);
  //   } else {
  //     final adsNotifier = context.read<PreviewVidNotifier>();
  //     if (context.getAdsCount() == 2) {
  //       try {
  //         context.read<PreviewVidNotifier>().getAdsVideo(context, false);
  //       } catch (e) {
  //         'Failed to fetch ads data 0 : $e'.logger();
  //       }
  //     }
  //     if (context.getAdsCount() == 3 && adsNotifier.adsData != null) {
  //       fAliplayer?.pause();
  //       System().adsPopUp(context, adsNotifier.adsData?.data ?? AdsData(), adsNotifier.adsData?.data?.apsaraAuth ?? '', isInAppAds: false).whenComplete(() {
  //         fAliplayer?.play();
  //       });
  //     }
  //   }
  // }

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
      builder: (context, vidNotifier, translateNotifier, homeNotifier, widget) => SizedBox(
        child: Column(
          children: [
            (vidNotifier.vidData != null)
                ? (vidNotifier.vidData?.isEmpty ?? true)
                    ? const NoResultFound()
                    : Expanded(
                        child: NotificationListener<OverscrollIndicatorNotification>(
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
                              if (vidNotifier.vidData == null || homeNotifier.isLoadingVid) {
                                vidNotifier.vidData?[index].fAliplayer?.pause();
                                _lastCurIndex = -1;
                                return CustomShimmer(
                                  margin: const EdgeInsets.only(bottom: 100, right: 16, left: 16),
                                  height: context.getHeight() / 8,
                                  width: double.infinity,
                                );
                              } else if (index == vidNotifier.vidData?.length && vidNotifier.hasNext) {
                                return const CustomLoading(size: 5);
                              }
                              // if (_curIdx == 0 && vidNotifier.vidData?[0].reportedStatus == 'BLURRED') {
                              //   isPlay = false;
                              //   vidNotifier.vidData?[index].fAliplayer?.stop();
                              // }
                              final vidData = vidNotifier.vidData?[index];

                              return itemVid(vidData ?? ContentData(), vidNotifier, index);
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

  Widget itemVid(ContentData vidData, PreviewVidNotifier notifier, int index) {
    var map = {
      DataSourceRelated.vidKey: vidData.apsaraId,
      DataSourceRelated.regionKey: DataSourceRelated.defaultRegion,
    };
    return Container(
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
                  imageUrl: '${System().showUserPicture(vidData.avatar?.mediaEndpoint)}',
                  onTapOnProfileImage: () => System().navigateToProfile(context, vidData.email ?? ''),
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
                          picNot.followUser(context, vidData, isUnFollow: vidData.following, isloading: vidData.insight!.isloadingFollow ?? false);
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
                              (vidData.following ?? false) ? (lang?.following ?? '') : (lang?.follow ?? ''),
                              style: TextStyle(color: kHyppePrimary, fontSize: 12, fontWeight: FontWeight.w700, fontFamily: "Lato"),
                            ),
                    ),
                  ),
                ),
              GestureDetector(
                onTap: () {
                  if (vidData.email != email) {
                    // FlutterAliplayer? fAliplayer
                    context.read<PreviewPicNotifier>().reportContent(context, vidData, fAliplayer: vidData.fAliplayer);
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
              print("visibleFraction: ${info.visibleFraction}");
              if (info.visibleFraction >= 0.6) {
                if (_curIdx != index) {
                  Future.delayed(const Duration(milliseconds: 400), () {
                    try {
                      if (_curIdx != -1) {
                        print('Vid Landing Page: pause $_curIdx ${notifier.vidData?[_curIdx].fAliplayer} ${dataAli[_curIdx]}');
                        if (notifier.vidData?[_curIdx].fAliplayer != null) {
                          notifier.vidData?[_curIdx].fAliplayer?.pause();
                        } else {
                          dataAli[_curIdx]?.pause();
                        }

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
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              child: Builder(builder: (context) {
                return VidPlayerPage(
                  orientation: Orientation.portrait,
                  playMode: (vidData.isApsara ?? false) ? ModeTypeAliPLayer.auth : ModeTypeAliPLayer.url,
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
                          print('Vid Landing Page: stop $_curIdx ${notifier.vidData?[_curIdx].fAliplayer} ${dataAli[_curIdx]}');
                          if (notifier.vidData?[_curIdx].fAliplayer != null) {
                            notifier.vidData?[_curIdx].fAliplayer?.stop();
                          } else {
                            final player = dataAli[_curIdx];
                            if (player != null) {
                              // notifier.vidData?[_curIdx].fAliplayer = player;
                              player.stop();
                            }
                          }
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
                    print('Vid Player1: after $index ${globalAliPlayer} : ${notifier.vidData?[index].fAliplayer}');
                  },
                  getAdsPlayer: (ads) {
                    // notifier.vidData?[index].fAliplayerAds = ads;
                  },
                  // fAliplayer: notifier.vidData?[index].fAliplayer,
                  // fAliplayerAds: notifier.vidData?[index].fAliplayerAds,
                );
              }),
            ),
          ),
          SharedPreference().readStorage(SpKeys.statusVerificationId) == VERIFIED &&
                  (vidData.boosted.isEmpty) &&
                  (vidData.reportedStatus != 'OWNED' && vidData.reportedStatus != 'BLURRED' && vidData.reportedStatus2 != 'BLURRED') &&
                  vidData.email == email
              ? Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ButtonBoost(
                    onDetail: false,
                    marginBool: true,
                    contentData: vidData,
                    startState: () {
                      SharedPreference().writeStorage(SpKeys.isShowPopAds, true);
                    },
                    afterState: () {
                      SharedPreference().writeStorage(SpKeys.isShowPopAds, false);
                    },
                  ),
                )
              : Container(),
          if (vidData.email == email && (vidData.boostCount ?? 0) >= 0 && (vidData.boosted.isNotEmpty))
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
                                  color: (vidData.insight?.isPostLiked ?? false) ? kHyppeRed : kHyppeTextLightPrimary,
                                  iconData: '${AssetPath.vectorPath}${(vidData.insight?.isPostLiked ?? false) ? 'liked.svg' : 'none-like.svg'}',
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
                    if (vidData.allowComments ?? true)
                      Padding(
                        padding: const EdgeInsets.only(left: 21.0),
                        child: GestureDetector(
                          onTap: () {
                            Routing().move(Routes.commentsDetail, argument: CommentsArgument(postID: vidData.postID ?? '', fromFront: true, data: vidData));
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
                            context.read<VidDetailNotifier>().createdDynamicLink(context, data: vidData);
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
                            await ShowBottomSheet.onBuyContent(context, data: vidData, fAliplayer: vidData.fAliplayer);
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
                  style: const TextStyle(color: kHyppeTextLightPrimary, fontWeight: FontWeight.w700, fontSize: 14),
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
            seeMore: '  ${lang?.seeMoreContent}', //${notifier2.translate.seeMoreContent}',
            normStyle: const TextStyle(fontSize: 12, color: kHyppeTextLightPrimary),
            hrefStyle: Theme.of(context).textTheme.subtitle2?.copyWith(color: kHyppePrimary),
            expandStyle: Theme.of(context).textTheme.subtitle2?.copyWith(color: Theme.of(context).colorScheme.primary),
          ),
          GestureDetector(
            onTap: () {
              Routing().move(Routes.commentsDetail, argument: CommentsArgument(postID: vidData.postID ?? '', fromFront: true, data: vidData));
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
                          username: vidData.comment?[indexComment].userComment?.username ?? '',
                          desc: vidData.comment?[indexComment].txtMessages ?? '',
                          trimLines: 3,
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
                DateTime.parse(System().dateTimeRemoveT(vidData.createdAt ?? DateTime.now().toString())).millisecondsSinceEpoch,
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
                context.read<PicDetailNotifier>().showUserTag(context, data?.tagPeople, data?.postID);
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
                      Text(transnot.translate.sensitiveContent ?? 'Sensitive Content', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                      Text("HyppeVid ${transnot.translate.contentContainsSensitiveMaterial}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          )),
                      // data.email == SharedPreference().readStorage(SpKeys.email)
                      //     ? GestureDetector(
                      //         onTap: () => Routing().move(Routes.appeal, argument: data),
                      //         child: Container(
                      //             padding: const EdgeInsets.all(8),
                      //             margin: const EdgeInsets.all(18),
                      //             decoration: BoxDecoration(border: Border.all(color: Colors.white), borderRadius: BorderRadius.circular(10)),
                      //             child: Text(transnot.translate.appealThisWarning ?? 'Appeal This Warning', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600))),
                      //       )
                      //     : const SizedBox(),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          data.reportedStatus = '';
                          // start(data);
                          // context.read<ReportNotifier>().seeContent(context, data, hyppeVid);
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
                            "${transnot.translate.see} HyppeVid",
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
