import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_aliplayer/flutter_aliplayer.dart';
import 'package:flutter_aliplayer/flutter_aliplayer_factory.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/ui/inner/search_v2/notifier.dart';
import 'package:hyppe/ui/inner/search_v2/shimmer/search_shimmer.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:visibility_detector/visibility_detector.dart';

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
import '../../../../../core/models/collection/utils/zoom_pic/zoom_pic.dart';
import '../../../../../core/services/route_observer_service.dart';
import '../../../../../core/services/shared_preference.dart';
import '../../../../../core/services/system.dart';
import '../../../../../ux/path.dart';
import '../../../../../ux/routing.dart';
import '../../../../constant/entities/like/notifier.dart';
import '../../../../constant/entities/report/notifier.dart';
import '../../../../constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import '../../../../constant/overlay/general_dialog/show_general_dialog.dart';
import '../../../../constant/widget/button_boost.dart';
import '../../../../constant/widget/custom_base_cache_image.dart';
import '../../../../constant/widget/custom_icon_widget.dart';
import '../../../../constant/widget/custom_loading.dart';
import '../../../../constant/widget/custom_newdesc_content_widget.dart';
import '../../../../constant/widget/custom_shimmer.dart';
import '../../../../constant/widget/custom_spacer.dart';
import '../../../../constant/widget/custom_text_widget.dart';
import '../../../../constant/widget/profile_landingpage.dart';
import '../../../home/content_v2/diary/playlist/widget/content_violation.dart';
import '../../../home/content_v2/pic/notifier.dart';
import '../../../home/content_v2/pic/playlist/notifier.dart';
import '../../../home/content_v2/pic/widget/pic_top_item.dart';
import '../../../home/content_v2/vid/notifier.dart';
import '../../../home/content_v2/vid/playlist/comments_detail/screen.dart';
import '../../../home/notifier_v2.dart';

class PicScrollScreen extends StatefulWidget {
  final String interestKey;
  const PicScrollScreen({Key? key, required this.interestKey}) : super(key: key);

  @override
  State<PicScrollScreen> createState() => _PicScrollScreenState();
}

class _PicScrollScreenState extends State<PicScrollScreen> with WidgetsBindingObserver, TickerProviderStateMixin, RouteAware  {
  FlutterAliplayer? fAliplayer;

  // bool isZoom = false;
  bool isPrepare = false;
  bool isPlay = false;
  bool isPause = false;
  // bool _showLoading = false;
  // bool _inSeek = false;
  bool isloading = false;

  // int _loadingPercent = 0;
  // int _currentPlayerState = 0;
  int _videoDuration = 1;
  // int _currentPosition = 0;
  // int _bufferPosition = 0;
  // int _currentPositionText = 0;
  int _curIdx = 0;
  int _lastCurIndex = -1;

  String auth = '';
  String url = '';
  // final Map _dataSourceMap = {};
  // ModeTypeAliPLayer? _playMode = ModeTypeAliPLayer.auth;
  bool isMute = false;
  String email = '';
  // String statusKyc = '';
  bool isInPage = true;
  // bool _scroolEnabled = true;
  bool toComment = false;

  final ItemScrollController itemScrollController = ItemScrollController();
  final ScrollOffsetController scrollOffsetController = ScrollOffsetController();

  /// Listener that reports the position of items when the list is scrolled.
  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();
  // final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'HyppePreviewPic');
    final notifier = Provider.of<SearchNotifier>(context, listen: false);

    email = SharedPreference().readStorage(SpKeys.email);
    // statusKyc = SharedPreference().readStorage(SpKeys.statusVerificationId);
    // stopwatch = new Stopwatch()..start();
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      fAliplayer = FlutterAliPlayerFactory.createAliPlayer(playerId: 'aliPic-${notifier.interestContents[widget.interestKey]?.pict?.first.postID}');
      WidgetsBinding.instance.addObserver(this);

      fAliplayer?.setAutoPlay(true);
      fAliplayer?.setLoop(true);

      //Turn on mix mode
      if (Platform.isIOS) {
        FlutterAliplayer.enableMix(true);
      }

      notifier.checkConnection();

      //set player
      fAliplayer?.setPreferPlayerName(GlobalSettings.mPlayerName);
      fAliplayer?.setEnableHardwareDecoder(GlobalSettings.mEnableHardwareDecoder);
      _initListener();
    });
    var index = 0;
    var lastIndex = 0;

    itemPositionsListener.itemPositions.addListener(() async {
      index = itemPositionsListener.itemPositions.value.first.index;
      if (lastIndex != index) {
        if (index == (notifier.interestContents[widget.interestKey]?.pict?.length ?? 2) - 2) {
          if (!notifier.intHasNextPic) {
            notifier.getDetailInterest(Routing.navigatorKey.currentContext ?? context, widget.interestKey, reload: false, hyppe: HyppeType.HyppePic);
          }
        }
      }
      lastIndex = index;
    });

    checkInet(notifier);

    super.initState();
  }

  void checkInet(SearchNotifier notifier) async {
    var inet = await System().checkConnections();
    if (!inet) {
      ShowGeneralDialog.showToastAlert(
        context,
        notifier.language.internetConnectionLost ?? ' Error',
            () async {
          Routing().moveBack();
        },
      );
    }
  }

  _initListener() {
    fAliplayer?.setOnEventReportParams((params, playerId) {
      print("EventReportParams=${params}");
    });
    fAliplayer?.setOnPrepared((playerId) {
      // Fluttertoast.showToast(msg: "OnPrepared ");
      if (SharedPreference().readStorage(SpKeys.isShowPopAds)) {
        isMute = true;
        fAliplayer?.pause();
      }

      fAliplayer?.getPlayerName().then((value) => print("getPlayerName==${value}"));
      fAliplayer?.getMediaInfo().then((value) {
        setState(() {
          isPrepare = true;
        });
      });
      isPlay = true;
    });
    fAliplayer?.setOnRenderingStart((playerId) {
      // Fluttertoast.showToast(msg: " OnFirstFrameShow ");
    });
    fAliplayer?.setOnVideoSizeChanged((width, height, rotation, playerId) {});
    fAliplayer?.setOnStateChanged((newState, playerId) {
      // _currentPlayerState = newState;
      print("aliyun : onStateChanged $newState");
      switch (newState) {
        case FlutterAvpdef.AVPStatus_AVPStatusStarted:
          setState(() {
            // _showLoading = false;
            isPause = false;
          });
          break;
        case FlutterAvpdef.AVPStatus_AVPStatusPaused:
          isPause = true;
          setState(() {});
          break;
        default:
      }
    });
    fAliplayer?.setOnLoadingStatusListener(loadingBegin: (playerId) {
      setState(() {
        // _loadingPercent = 0;
        // _showLoading = true;
      });
    }, loadingProgress: (percent, netSpeed, playerId) {
      // _loadingPercent = percent;
      if (percent == 100) {
        // _showLoading = false;
      }
      setState(() {});
    }, loadingEnd: (playerId) {
      setState(() {
        // _showLoading = false;
      });
    });
    fAliplayer?.setOnSeekComplete((playerId) {
      // _inSeek = false;
    });
    fAliplayer?.setOnInfo((infoCode, extraValue, extraMsg, playerId) {
      if (infoCode == FlutterAvpdef.CURRENTPOSITION) {
        if (_videoDuration != 0 && (extraValue ?? 0) <= _videoDuration) {
          // _currentPosition = extraValue ?? 0;
        }
        // if (!_inSeek) {
        //   setState(() {
        //     _currentPositionText = extraValue ?? 0;
        //   });
        // }
      } else if (infoCode == FlutterAvpdef.BUFFEREDPOSITION) {
        // _bufferPosition = extraValue ?? 0;
        if (mounted) {
          setState(() {});
        }
      } else if (infoCode == FlutterAvpdef.AUTOPLAYSTART) {
        // Fluttertoast.showToast(msg: "AutoPlay");
      } else if (infoCode == FlutterAvpdef.CACHESUCCESS) {
      } else if (infoCode == FlutterAvpdef.CACHEERROR) {
      } else if (infoCode == FlutterAvpdef.LOOPINGSTART) {
        // Fluttertoast.showToast(msg: "Looping Start");
      } else if (infoCode == FlutterAvpdef.SWITCHTOSOFTWAREVIDEODECODER) {
        // Fluttertoast.showToast(msg: "change to soft ware decoder");
        // mOptionsFragment.switchHardwareDecoder();
      }
    });
    fAliplayer?.setOnCompletion((playerId) {
      // _showLoading = false;

      isPause = true;

      setState(() {
        // _currentPosition = _videoDuration;
      });
    });

    fAliplayer?.setOnSnapShot((path, playerId) {
      print("aliyun : snapShotPath = $path");
      // Fluttertoast.showToast(msg: "SnapShot Save : $path");
    });
    fAliplayer?.setOnError((errorCode, errorExtra, errorMsg, playerId) {
      // _showLoading = false;

      setState(() {});
    });

    fAliplayer?.setOnTrackChanged((value, playerId) {
      AVPTrackInfo info = AVPTrackInfo.fromJson(value);
      if ((info.trackDefinition?.length ?? 0) > 0) {
        // trackFragmentKey.currentState.onTrackChanged(info);
        // Fluttertoast.showToast(msg: "${info.trackDefinition}切换成功");
      }
    });
    fAliplayer?.setOnThumbnailPreparedListener(preparedSuccess: (playerId) {}, preparedFail: (playerId) {});

    fAliplayer?.setOnThumbnailGetListener(
        onThumbnailGetSuccess: (bitmap, range, playerId) {
          // _thumbnailBitmap = bitmap;
          var provider = MemoryImage(bitmap);
          precacheImage(provider, context).then((_) {
            setState(() {});
          });
        },
        onThumbnailGetFail: (playerId) {});

    fAliplayer?.setOnSubtitleHide((trackIndex, subtitleID, playerId) {
      if (mounted) {
        setState(() {});
      }
    });

    fAliplayer?.setOnSubtitleShow((trackIndex, subtitleID, subtitle, playerId) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void start(ContentData data) async {

    fAliplayer?.stop();

    isPlay = false;

    // _playMode = ModeTypeAliPLayer.auth;
    // await getAuth(data.music?.apsaraMusic ?? '');
    if (data.reportedStatus != 'BLURRED') {
      // _playMode = ModeTypeAliPLayer.auth;
      await getAuth(data.music?.apsaraMusic ?? '');
    }

    setState(() {
      isPause = false;
      // _isFirstRenderShow = false;
    });

    print("sedang prepare");
    print("sedang prepare $isMute");
    fAliplayer?.prepare();
    if (isMute) {
      fAliplayer?.setMuted(true);
    }
    // fAliplayer?.play();
  }

  Future getAuth(String apsaraId) async {
    setState(() {
      isloading = true;
    });
    try {
      final notifier = PostsBloc();
      await notifier.getAuthApsara(context, apsaraId: apsaraId, check: false);
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
        // widget.videoData?.fullContentPath = jsonMap['PlayUrl'];
      }
    } catch (e) {
      setState(() {
        isloading = false;
      });
      // 'Failed to fetch ads data $e'.logger();
    }
  }

  Future getOldVideoUrl(String postId) async {
    setState(() {
      isloading = true;
    });
    try {
      final notifier = PostsBloc();
      await notifier.getOldVideo(context, apsaraId: postId, check: false);
      final fetch = notifier.postsFetch;
      if (fetch.postsState == PostsState.videoApsaraSuccess) {
        Map jsonMap = json.decode(fetch.data.toString());

        fAliplayer?.setUrl(jsonMap['data']['url']);
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

  void onViewPlayerCreated(viewId) async {
    fAliplayer?.setPlayerView(viewId);
  }

  @override
  void didChangeDependencies() {
    CustomRouteObserver.routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    print("---=-=-=-=--===-=-=-=-DiSPOSE--=-=-=-=-=-=-=-=-=-=-=----==-=");

    super.dispose();
    // WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void deactivate() {
    print("====== deactivate ");
    fAliplayer?.stop();
    System().disposeBlock();
    if ((Routing.navigatorKey.currentContext ?? context).read<PreviewVidNotifier>().canPlayOpenApps) {
      fAliplayer?.destroy();
    }
    if (Platform.isIOS) {
      FlutterAliplayer.enableMix(false);
    }
    super.deactivate();
  }

  @override
  void didPop() {
    print("====== didpop ");
    super.didPop();
  }

  @override
  void didPopNext() {
    print("======= didPopNext");
    isInPage = true;
    fAliplayer?.play();
    // System().disposeBlock();
    if (toComment) {

      setState(() {

        toComment = false;
      });
    }
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
    isInPage = false;
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
        if ((Routing.navigatorKey.currentContext ?? context).read<PreviewVidNotifier>().canPlayOpenApps && !SharedPreference().readStorage(SpKeys.isShowPopAds)) {
          fAliplayer?.play();
        }
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

  ValueNotifier<int> _networklHasErrorNotifier = ValueNotifier(0);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Consumer<SearchNotifier>(
      builder: (_, notifier, __){
        final pics = notifier.interestContents[widget.interestKey]?.pict;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            pics?.isEmpty ?? true
                ?  const Flexible(child: SearchShimmer())
                : Column(
                children: List.generate(pics?.length ?? 0, (index){
                  if (pics == null) {
                    fAliplayer?.pause();
                    _lastCurIndex = -1;
                    return CustomShimmer(
                      width: (MediaQuery.of(context).size.width - 11.5 - 11.5 - 9) / 2,
                      height: 168,
                      radius: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 10),
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
                    );
                  } else if (index == pics.length) {
                    return UnconstrainedBox(
                      child: Container(
                        alignment: Alignment.center,
                        width: 80 * SizeConfig.scaleDiagonal,
                        height: 80 * SizeConfig.scaleDiagonal,
                        child: const CustomLoading(),
                      ),
                    );
                  }

                  return itemPict(notifier, index, pics);
                })
            ),
          ],
        );
      },
    );
  }

  var initialControllerValue;

  Widget itemPict(SearchNotifier notifier, int index, List<ContentData>  pics) {
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
                  username: pics[index].username,
                  featureType: FeatureType.other,
                  // isCelebrity: vidpics?[index].privacy?.isCelebrity,
                  isCelebrity: false,
                  imageUrl: '${System().showUserPicture(pics[index].avatar?.mediaEndpoint)}',
                  onTapOnProfileImage: () => System().navigateToProfile(context, pics[index].email ?? ''),
                  createdAt: '2022-02-02',
                  musicName: pics[index].music?.musicTitle ?? '',
                  location: pics[index].location ?? '',
                  isIdVerified: pics[index].privacy?.isIdVerified,
                  badge: pics[index].urluserBadge,
                ),
              ),
              if (pics[index].email != email && (pics[index].isNewFollowing ?? false))
                Consumer<PreviewPicNotifier>(
                  builder: (context, picNot, child) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: GestureDetector(
                      onTap: () async {
                        await context.handleActionIsGuest(() async  {
                          if (pics[index].insight?.isloadingFollow != true) {
                            picNot.followUser(context, pics[index] , isUnFollow: pics[index].following, isloading: pics[index].insight!.isloadingFollow ?? false);
                          }
                        });

                      },
                      child: pics[index].insight?.isloadingFollow ?? false
                          ? Container(
                        height: 40,
                        width: 30,
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: CustomLoading(),
                        ),
                      )
                          : Text(
                        (pics[index].following ?? false) ? (notifier.language.following ?? '') : (notifier.language.follow ?? ''),
                        style: TextStyle(color: kHyppePrimary, fontSize: 12, fontWeight: FontWeight.w700, fontFamily: "Lato"),
                      ),
                    ),
                  ),
                ),
              GestureDetector(
                onTap: () {
                  // fAliplayer?.pause();
                  context.handleActionIsGuest(() async  {
                    if (pics[index].email != email) {
                      context.read<PreviewPicNotifier>()
                          .reportContent(
                          context,
                          pics[index] ,
                          fAliplayer: fAliplayer,
                          onCompleted: (){},
                          key: widget.interestKey);
                    } else {
                      fAliplayer?.setMuted(true);
                      fAliplayer?.pause();
                      ShowBottomSheet().onShowOptionContent(
                        context,
                        contentData: pics[index] ,
                        captionTitle: hyppePic,
                        onDetail: false,
                        isShare: pics[index].isShared,
                        onUpdate: () => context.read<HomeNotifier>().onUpdate(),
                        fAliplayer: fAliplayer,
                      );
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
              // print("ada musiknya ${info.visibleFraction}");
              // a.scrollAuto();
              if (info.visibleFraction >= 0.6) {
                _curIdx = index;
                //=============

                //=============
                if (_lastCurIndex != _curIdx) {

                  if (pics[index].music?.musicTitle != null) {
                    // print("ada musiknya ${pics?[index].music}");
                    Future.delayed(const Duration(milliseconds: 100), () {
                      start(pics[index] );
                    });
                  } else {
                    fAliplayer?.stop();
                  }
                  Future.delayed(const Duration(milliseconds: 100), () {
                    System().increaseViewCount2(context, pics[index] , check: false);
                  });
                  if (pics[index].certified ?? false) {
                    System().block(context);
                  } else {
                    System().disposeBlock();
                  }
                }
                _lastCurIndex = _curIdx;
              }
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              width: SizeConfig.screenWidth,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.white,
                ),
                child: Stack(
                  children: [

                    !notifier.connectionError
                        ? GestureDetector(
                      onTap: () {
                        if (pics[index].reportedStatus != 'BLURRED') {
                          fAliplayer?.play();
                          setState(() {
                            isMute = !isMute;
                          });
                          fAliplayer?.setMuted(isMute);
                        }
                      },
                      onDoubleTap: () {
                        final _likeNotifier = context.read<LikeNotifier>();
                        _likeNotifier.likePost(context, pics[index]);
                      },
                      child: Center(
                        child: Container(
                          color: Colors.transparent,
                          // width: SizeConfig.screenWidth,
                          // height: SizeConfig.screenHeight,
                          child: ZoomableImage(
                            onScaleStart: () {
                              // zoom(true);
                              notifier.isZoom = true;
                            },
                            onScaleStop: () {
                              // zoom(false);
                              notifier.isZoom = false;
                            },
                            child: pics[index].isLoading
                                ? Container()
                                : ValueListenableBuilder(
                                valueListenable: _networklHasErrorNotifier,
                                builder: (BuildContext context, int count, _) {
                                  return CustomBaseCacheImage(
                                    memCacheWidth: 100,
                                    memCacheHeight: 100,
                                    widthPlaceHolder: 80,
                                    heightPlaceHolder: 80,
                                    imageUrl: (pics[index].isApsara ?? false) ? (pics[index].mediaEndpoint ?? "") : "${pics[index].fullContent ?? ''}" + '&2',
                                    imageBuilder: (context, imageProvider) => ClipRRect(
                                      borderRadius: BorderRadius.circular(20), // Image borderr
                                      child: pics[index].reportedStatus == 'BLURRED'
                                          ? ImageFiltered(
                                        imageFilter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                                        child: Image(
                                          image: imageProvider,
                                          fit: BoxFit.fitHeight,
                                          width: SizeConfig.screenWidth,
                                        ),
                                      )
                                          : Image(
                                        image: imageProvider,
                                        fit: BoxFit.fitHeight,
                                        width: SizeConfig.screenWidth,
                                      ),
                                    ),
                                    emptyWidget: GestureDetector(
                                      onTap: () {
                                        _networklHasErrorNotifier.value++;
                                      },
                                      child: Container(
                                          decoration: BoxDecoration(color: kHyppeNotConnect, borderRadius: BorderRadius.circular(16)),
                                          width: SizeConfig.screenWidth,
                                          height: 250,
                                          alignment: Alignment.center,
                                          child: CustomTextWidget(textToDisplay: notifier.language.couldntLoadImage ?? 'Error')),
                                    ),
                                    errorWidget: (context, url, error) {
                                      return GestureDetector(
                                        onTap: () {
                                          _networklHasErrorNotifier.value++;
                                        },
                                        child: Container(
                                            decoration: BoxDecoration(color: kHyppeNotConnect, borderRadius: BorderRadius.circular(16)),
                                            width: SizeConfig.screenWidth,
                                            height: 250,
                                            alignment: Alignment.center,
                                            child: CustomTextWidget(textToDisplay: notifier.language.couldntLoadImage ?? 'Error')),
                                      );
                                    },
                                  );
                                }),
                          ),
                        ),
                      ),
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
                          child: CustomTextWidget(textToDisplay: notifier.language.couldntLoadImage ?? 'Error')),
                    ),
                    _buildBody(context, SizeConfig.screenWidth, pics[index]),
                    blurContentWidget(context, notifier.language, pics[index]),
                  ],
                ),
              ),
            ),
          ),
          SharedPreference().readStorage(SpKeys.statusVerificationId) == VERIFIED &&
              (pics[index].boosted.isEmpty) &&
              (pics[index].reportedStatus != 'OWNED' && pics[index].reportedStatus != 'BLURRED' && pics[index].reportedStatus2 != 'BLURRED') &&
              pics[index].email == email
              ? Container(
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.only(bottom: 16),
            child: ButtonBoost(
              onDetail: false,
              marginBool: true,
              contentData: pics[index],
              startState: () {
                SharedPreference().writeStorage(SpKeys.isShowPopAds, true);
              },
              afterState: () {
                SharedPreference().writeStorage(SpKeys.isShowPopAds, false);
              },
            ),
          )
              : Container(),
          pics[index].email == SharedPreference().readStorage(SpKeys.email) && (pics[index].reportedStatus == 'OWNED')
              ? Padding(
            padding: const EdgeInsets.only(bottom: 11.0),
            child: ContentViolationWidget(
              data: pics[index],
              text: notifier.language.thisHyppeVidisSubjectToModeration ?? '',
            ),
          )
              : Container(),
          if (pics[index].email == email && (pics[index].boostCount ?? 0) >= 0 && (pics[index].boosted.isNotEmpty))
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
                    child: CustomTextWidget(
                      textToDisplay: "${pics[index].boostJangkauan ?? '0'} ${notifier.language.reach}",
                      textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kHyppeTextLightPrimary),
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
                    SizedBox(
                      width: 30,
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: pics[index].insight?.isloading ?? false
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
                            color: (pics[index].insight?.isPostLiked ?? false) ? kHyppeRed : kHyppeTextLightPrimary,
                            iconData: '${AssetPath.vectorPath}${(pics[index].insight?.isPostLiked ?? false) ? 'liked.svg' : 'none-like.svg'}',
                            height: 28,
                          ),
                          onTap: () {
                            likeNotifier.likePost(context, pics[index]);
                          },
                        ),
                      ),
                    ),
                    if (pics[index].allowComments ?? false)
                      Padding(
                        padding: EdgeInsets.only(left: 21.0),
                        child: GestureDetector(
                          onTap: () {
                            toComment = true;
                            Routing().move(Routes.commentsDetail,
                                argument: CommentsArgument(
                                  postID: pics[index].postID ?? '',
                                  fromFront: true,
                                  data: pics[index] ,
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
                    if ((pics[index].isShared ?? false))
                      GestureDetector(
                        onTap: () {
                          context.read<PicDetailNotifier>().createdDynamicLink(context, data: pics[index]);
                        },
                        child: const Padding(
                          padding: EdgeInsets.only(left: 21.0),
                          child: CustomIconWidget(
                            defaultColor: false,
                            color: kHyppeTextLightPrimary,
                            iconData: '${AssetPath.vectorPath}share2.svg',
                            height: 24,
                          ),
                        ),
                      ),
                    if ((pics[index].saleAmount ?? 0) > 0 && email != pics[index].email)
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            await context.handleActionIsGuest(() async  {
                              fAliplayer?.pause();
                              await ShowBottomSheet.onBuyContent(context, data: pics[index], fAliplayer: fAliplayer);
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
                Text(
                  "${pics[index].insight?.likes}  ${notifier.language.like}",
                  style: const TextStyle(color: kHyppeTextLightPrimary, fontWeight: FontWeight.w700, fontSize: 14),
                ),
              ],
            ),
          ),
          fourPx,
          CustomNewDescContent(
            email: pics[index].email??'',
            username: pics[index].username ?? '',
            desc: "${pics[index].description}",
            trimLines: 2,
            textAlign: TextAlign.start,
            seeLess: ' ${notifier.language.seeLess}', // ${notifier2.translate.seeLess}',
            seeMore: '  ${notifier.language.seeMoreContent}', //${notifier2.translate.seeMoreContent}',
            normStyle: const TextStyle(fontSize: 12, color: kHyppeTextLightPrimary),
            hrefStyle: Theme.of(context).textTheme.subtitle2?.copyWith(color: kHyppePrimary, fontSize: 12),
            expandStyle: Theme.of(context).textTheme.subtitle2?.copyWith(color: Theme.of(context).colorScheme.primary),
          ),
          if (pics[index].allowComments ?? true)
            GestureDetector(
              onTap: () {
                toComment = true;
                Routing().move(Routes.commentsDetail,
                    argument: CommentsArgument(
                      postID: pics[index].postID ?? '',
                      fromFront: true,
                      data: pics[index] ,
                      pageDetail: true,
                    ));
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  "${notifier.language.seeAll} ${pics[index].comments} ${notifier.language.comment}",
                  style: const TextStyle(fontSize: 12, color: kHyppeBurem),
                ),
              ),
            ),
          (pics[index].comment?.length ?? 0) > 0
              ? Padding(
            padding: const EdgeInsets.only(top: 0.0),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: (pics[index].comment?.length ?? 0) >= 2 ? 2 : 1,
              itemBuilder: (context, indexComment) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: CustomNewDescContent(
                    email: pics[index].comment?[indexComment].sender ?? '',
                    username: pics[index].comment?[indexComment].userComment?.username ?? '',
                    desc: pics[index].comment?[indexComment].txtMessages ?? '',
                    trimLines: 2,
                    textAlign: TextAlign.start,
                    seeLess: ' seeLess', // ${notifier2.translate.seeLess}',
                    seeMore: '  Selengkapnya ', //${notifier2.translate.seeMoreContent}',
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
                DateTime.parse(System().dateTimeRemoveT(pics[index].createdAt ?? DateTime.now().toString())).millisecondsSinceEpoch,
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

  Widget _buildBody(BuildContext context, width, ContentData data) {
    return Positioned.fill(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: PicTopItem(data: data),
          ),
          if (data.tagPeople?.isNotEmpty ?? false)
            Positioned(
              bottom: 18,
              left: 12,
              child: GestureDetector(
                onTap: () {
                  fAliplayer?.pause();

                  context.read<PicDetailNotifier>().showUserTag(context, data.tagPeople, data.postID, fAliplayer: fAliplayer);
                },
                child: const CustomIconWidget(
                  iconData: '${AssetPath.vectorPath}tag_people.svg',
                  defaultColor: false,
                  height: 24,
                ),
              ),
            ),
          if (data.music?.musicTitle != null)
            Align(
              alignment: Alignment.bottomRight,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    isMute = !isMute;
                  });
                  fAliplayer?.setMuted(isMute);
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CustomIconWidget(
                    iconData: isMute ? '${AssetPath.vectorPath}sound-off.svg' : '${AssetPath.vectorPath}sound-on.svg',
                    defaultColor: false,
                    height: 24,
                  ),
                ),
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
                Text("HyppePic ${lang.contentContainsSensitiveMaterial}",
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
                    System().increaseViewCount2(context, data);
                    setState(() {
                      data.reportedStatus = '';
                    });
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
                      "${lang.see} HyppePic",
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

  void reloadImage(index, List<ContentData> pics) {
    setState(() {
      pics[index].isLoading = true;
    });
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        pics[index].isLoading = false;
      });
    });
  }
}

class AllowMultipleScaleRecognizer extends ScaleGestureRecognizer {
  @override
  void rejectGesture(int pointer) {
    acceptGesture(pointer);
  }
}