import 'dart:async';
import 'dart:io';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_aliplayer/flutter_aliplayer_factory.dart';
import 'package:hyppe/app.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/entities/follow/notifier.dart';
import 'package:hyppe/ui/constant/entities/report/notifier.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/preview/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/tutor_landing/widget/diary.dart';
import 'package:hyppe/ui/inner/home/content_v2/tutor_landing/widget/pic.dart';
import 'package:hyppe/ui/inner/home/content_v2/tutor_landing/widget/story.dart';
import 'package:hyppe/ui/inner/home/content_v2/tutor_landing/widget/vid.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/notifier.dart';
import 'package:hyppe/ui/inner/home/widget/home_app_bar.dart';
import 'package:hyppe/ui/inner/main/notifier.dart';
import 'package:hyppe/ui/inner/upload/pre_upload_content/notifier.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/ui/inner/home/notifier_v2.dart';
// v2 view
import 'package:showcaseview/showcaseview.dart';
import '../../../../../core/services/route_observer_service.dart';
import '../../../../constant/widget/after_first_layout_mixin.dart';
import 'package:move_to_background/move_to_background.dart';
import 'package:flutter/services.dart';

class TutorLandingScreen extends StatefulWidget {
  final bool canShowAds;
  final GlobalKey keyButton;
  const TutorLandingScreen({Key? key, required this.keyButton, required this.canShowAds}) : super(key: key);

  @override
  State<TutorLandingScreen> createState() => _TutorLandingScreenState();
}

class _TutorLandingScreenState extends State<TutorLandingScreen> with RouteAware, AfterFirstLayoutMixin, SingleTickerProviderStateMixin {
  // final GlobalKey<RefreshIndicatorState> _globalKey = GlobalKey<RefreshIndicatorState>();
  // final GlobalKey<NestedScrollViewState> globalKey = GlobalKey();
  bool appbarSeen = true;
  late TabController _tabController;
  double offset = 0.0;
  List filterList = [
    {"id": '1', 'name': "Pic"},
    {"id": '2', 'name': "Diary"},
    {"id": '3', 'name': "Vid"},
  ];

  GlobalKey keyButton = GlobalKey();
  GlobalKey keyButton1 = GlobalKey();
  GlobalKey keyButton2 = GlobalKey();
  LocalizationModelV2? _language;

  @override
  void didChangeDependencies() {
    // CustomRouteObserver.routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
    super.didChangeDependencies();
  }

  @override
  void didPop() {
    isHomeScreen = false;
    'didPop isOnHomeScreen $isHomeScreen'.logger();
    super.didPop();
  }

  @override
  void didPopNext() {
    Future.delayed(const Duration(milliseconds: 500), () async {
      final fixContext = Routing.navigatorKey.currentContext;
      isHomeScreen = true;
      'didPopNext isOnHomeScreen $isHomeScreen'.logger();
      (fixContext ?? context).read<ReportNotifier>().inPosition = contentPosition.home;
      if (isHomeScreen) {
        print("isOnHomeScreen hit ads");
        var homneNotifier = (fixContext ?? context).read<HomeNotifier>();
        await homneNotifier.getAdsApsara((fixContext ?? context), true);
      }
    });
    "+++++++++++++ didPopNext".logger();
    // System().disposeBlock();

    super.didPopNext();
  }

  @override
  void didPushNext() {
    isHomeScreen = widget.canShowAds;
    'didPushNext isOnHomeScreen $isHomeScreen'.logger();
    super.didPushNext();
  }

  @override
  void dispose() {
    CustomRouteObserver.routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void deactivate() {
    isHomeScreen = false;
    // globalScroller = null;
    'deactivate isOnHomeScreen $isHomeScreen'.logger();
    super.deactivate();
  }

  @override
  void didPush() {
    'didPush isOnHomeScreen $isHomeScreen'.logger();
  }

  void show() {
    ShowCaseWidget.of(context).startShowCase([keyButton, keyButton1, keyButton2, keyButton1, widget.keyButton]);
  }

  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'HomeScreen');
    isHomeScreen = widget.canShowAds;
    'initState isOnHomeScreen $isHomeScreen'.logger();
    _tabController = TabController(length: 3, vsync: this);

    offset = 0;
    WidgetsBinding.instance.addPostFrameCallback((_) => show());

    Future.delayed(Duration.zero, () {
      final notifier = context.read<HomeNotifier>();
      notifier.setSessionID();
      _language = context.read<TranslateNotifierV2>().translate;
      final notifierFollow = context.read<FollowRequestUnfollowNotifier>();
      final notifierMain = context.read<MainNotifier>();

      if (notifier.preventReloadAfterUploadPost) {
        notifier.preventReloadAfterUploadPost = false;
      } else {
        var pic = context.read<PreviewPicNotifier>();
        var diary = context.read<PreviewDiaryNotifier>();
        var vid = context.read<PreviewVidNotifier>();
        if (pic.pic == null && diary.diaryData == null && vid.vidData == null) {
          notifier.initNewHome(context, mounted, isreload: false, isNew: true);
        }
      }
      if (notifierFollow.listFollow.isEmpty) {
        notifierFollow.listFollow = [
          {'name': "${_language?.follow}", 'code': 'TOFOLLOW'},
          {'name': "${_language?.following}", 'code': 'FOLLOWING'},
        ];
      }

      notifierMain.globalKey.currentState?.innerController.addListener(() {
        try {
          setState(() {
            offset = notifierMain.globalKey.currentState?.innerController.position.pixels ?? 0;
            // print(offset);
          });
          if ((notifierMain.globalKey.currentState?.innerController.position.pixels ?? 0) >= (notifierMain.globalKey.currentState?.innerController.position.maxScrollExtent ?? 0) &&
              !(notifierMain.globalKey.currentState?.innerController.position.outOfRange ?? true)) {
            notifier.initNewHome(context, mounted, isreload: false, isgetMore: true);
          }
        } catch (e) {
          e.logger();
        }
      });
      Routing.navigatorKey.currentState?.overlay?.context.read<MainNotifier>().scrollController.addListener(() {
        // print(context.read<MainNotifier>().scrollController.offset);
        try {
          if (mounted) {
            if ((Routing.navigatorKey.currentState?.overlay?.context.read<MainNotifier>().scrollController.offset ?? 0) >= 160) {
              setState(() {
                appbarSeen = false;
              });
            } else {
              setState(() {
                appbarSeen = true;
              });
            }
          } else {
            if ((Routing.navigatorKey.currentState?.overlay?.context.read<MainNotifier>().scrollController.offset ?? 0) >= 160) {
              appbarSeen = false;
            } else {
              appbarSeen = true;
            }
          }
        } catch (e) {
          e.logger();
        }
      });
      // });
      context.read<ReportNotifier>().inPosition = contentPosition.home;
      _initLicense();
      // FlutterAliPlayerFactory.loadRtsLibrary();
      // _loadEncrypted();
    });

    context.read<PreUploadContentNotifier>().onGetInterest(context);

    if (mounted) {
      setState(() => {});
    }
    super.initState();
    '++++++++++++++++ iniststate'.logger();
  }

  _initLicense() {
    if (Platform.isIOS) {
      FlutterAliPlayerFactory.initLicenseServiceForIOS();
    } else {
      // 不需要
    }
  }

  _loadEncrypted() async {
    if (Platform.isAndroid) {
      var bytes = await rootBundle.load("assets/encryptedApp.dat");
      // getExternalStorageDirectories
      FlutterAliPlayerFactory.initService(bytes.buffer.asUint8List());
    } else if (Platform.isIOS) {
      var bytes = await rootBundle.load("assets/encryptedApp_ios.dat");
      FlutterAliPlayerFactory.initService(bytes.buffer.asUint8List());
    }
  }

  bool isZoom = false;

  void zoom(val) {
    setState(() {
      isZoom = val;
    });
  }

  @override
  Widget build(BuildContext context) {
    // print("iszoom $isZoom");
    isFromSplash = false;
    return Consumer2<HomeNotifier, SelfProfileNotifier>(
      builder: (_, notifier, selfnotifier, __) => WillPopScope(
        onWillPop: () async {
          MoveToBackground.moveTaskToBack();
          return false;
        },
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(SizeWidget.appBarHome),
            child: HomeAppBar(name: selfnotifier.user.profile?.fullName, offset: offset),
          ),
          body: Builder(
            builder: (context) => DefaultTabController(
              length: 3,
              child: RefreshIndicator(
                color: kHyppePrimary,
                notificationPredicate: (notification) {
                  if (notifier.isLoadingPict || notifier.isLoadingDiary || notifier.isLoadingVid) {
                    return false;
                  } else {
                    // with NestedScrollView local(depth == 2) OverscrollNotification are not sent
                    if (notification is OverscrollNotification || Platform.isIOS) {
                      return notification.depth == 2;
                    }
                    return notification.depth == 0;
                    // if (_tabController.index != 0) {}
                    // return notification.depth == 0;
                  }
                },
                onRefresh: () async {
                  print(isZoom);
                  if (!isZoom) {
                    Future.delayed(Duration(milliseconds: 400), () async {
                      imageCache.clear();
                      imageCache.clearLiveImages();
                      await notifier.initNewHome(context, mounted, isreload: true);
                    });
                  }
                },
                child: AbsorbPointer(
                  absorbing: isZoom,
                  child: NestedScrollView(
                    key: context.read<MainNotifier>().globalKey,
                    controller: context.read<MainNotifier>().scrollController,
                    // physics: const NeverScrollableScrollPhysics(),
                    // dragStartBehavior: DragStartBehavior.start,
                    headerSliverBuilder: (context, bool innerBoxIsScrolled) {
                      return [
                        SliverOverlapAbsorber(
                          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                              sixPx,
                              const StoryTutor(),
                              sixPx,
                              // GestureDetector(
                              //     onTap: () {
                              //       _showMessage("hahaha");
                              //     },
                              //     child: Text("hahahahaha")),
                              Container(
                                padding: const EdgeInsets.all(16),
                                color: kHyppeLightSurface,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                    color: kHyppeLightButtonText,
                                  ),
                                  child: TabBar(
                                    controller: _tabController,
                                    indicator: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                        25.0,
                                      ),
                                      color: kHyppePrimary,
                                    ),
                                    labelPadding: const EdgeInsets.symmetric(vertical: 0),
                                    labelColor: kHyppeLightButtonText,
                                    unselectedLabelColor: Theme.of(context).tabBarTheme.unselectedLabelColor,
                                    labelStyle: TextStyle(fontFamily: "Gotham", fontWeight: FontWeight.w400, fontSize: 14 * SizeConfig.scaleDiagonal),
                                    // indicator: UnderlineTabIndicator(borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.0)),
                                    unselectedLabelStyle: TextStyle(fontFamily: "Roboto", fontWeight: FontWeight.w400, fontSize: 14 * SizeConfig.scaleDiagonal),
                                    tabs: [
                                      ...List.generate(filterList.length, (index) {
                                        String titleCase = "";
                                        String descCase = "";
                                        String stepTitle = '';
                                        switch (index) {
                                          case 0:
                                            titleCase = 'Pic! 📸';
                                            descCase = _language?.tutorLanding1 ?? '';
                                            stepTitle = "1/6";
                                            break;
                                          case 1:
                                            if (_tabController.index == 1) {
                                              titleCase = 'Diary! 🎥';
                                              descCase = _language?.tutorLanding2 ?? '';
                                              stepTitle = "2/6";
                                            } else {
                                              titleCase = 'Geser 👆';
                                              descCase = _language?.tutorLanding4 ?? '';
                                              stepTitle = "4/6";
                                            }
                                            break;
                                          case 2:
                                            titleCase = 'Video! 🎥';
                                            descCase = _language?.tutorLanding3 ?? '';
                                            stepTitle = "3/6";
                                            break;
                                        }
                                        return Padding(
                                          padding: EdgeInsets.all(9),
                                          child: Showcase(
                                            key: index == 0
                                                ? keyButton
                                                : index == 1
                                                    ? keyButton1
                                                    : keyButton2,
                                            tooltipBackgroundColor: kHyppeTextLightPrimary,
                                            overlayOpacity: 0,
                                            targetPadding: const EdgeInsets.all(0),
                                            tooltipPosition: TooltipPosition.bottom,
                                            title: titleCase,
                                            titleTextStyle: TextStyle(fontSize: 12, color: kHyppeNotConnect),
                                            titlePadding: EdgeInsets.all(6),
                                            description: descCase,
                                            descTextStyle: TextStyle(fontSize: 10, color: kHyppeNotConnect),
                                            descriptionPadding: EdgeInsets.all(6),
                                            textColor: Colors.white,
                                            targetShapeBorder: const CircleBorder(),
                                            disableDefaultTargetGestures: true,
                                            onBarrierClick: () {},
                                            descWidget: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    stepTitle,
                                                    style: TextStyle(color: kHyppeBurem, fontSize: 10),
                                                  ),
                                                  GestureDetector(
                                                      onTap: () {
                                                        ShowCaseWidget.of(context).next();
                                                        switch (index) {
                                                          case 0:
                                                            _tabController.index = 1;
                                                            break;
                                                          case 1:
                                                            if (_tabController.index == 1) {
                                                              _tabController.index = 2;
                                                            } else {}
                                                            break;
                                                          case 2:
                                                            // _tabController.index = 0;
                                                            break;
                                                        }
                                                      },
                                                      child: Text(
                                                        "Selanjutnya",
                                                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                                      ))
                                                ],
                                              ),
                                            ),
                                            child: Text(
                                              filterList[index]['name'],
                                              style: TextStyle(fontFamily: 'Lato', fontSize: 14),
                                            ),
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                              ),
                            ]),
                          ),
                        ),

                        // FilterLanding(),
                        // HyppePreviewVid(),
                        // HyppePreviewDiary(),
                      ];
                    },
                    body: TabBarView(
                      controller: _tabController,
                      physics: isZoom ? const NeverScrollableScrollPhysics() : const AlwaysScrollableScrollPhysics(),
                      children: [
                        // Pict
                        Container(
                          height: 40,
                          padding: const EdgeInsets.only(left: 6.0, right: 6),
                          color: kHyppeLightSurface,
                          child: PicTutor(
                            appbarSeen: appbarSeen,
                            scrollController: context.read<MainNotifier>().globalKey.currentState?.innerController,
                            // offset: offset,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(left: 6.0, right: 6),
                          color: kHyppeLightSurface,
                          child: DiaryTutor(
                            scrollController: context.read<MainNotifier>().globalKey.currentState?.innerController,
                          ),
                        ),
                        // second tab bar viiew widget
                        Container(
                          padding: const EdgeInsets.only(left: 6.0, right: 6),
                          color: kHyppeLightSurface,
                          child: VidTutor(
                            scrollController: context.read<MainNotifier>().globalKey.currentState?.innerController,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  final events = [];

  @override
  void afterFirstLayout(BuildContext context) async {
    print("afterrrrrrr============");
    CustomRouteObserver.routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute<dynamic>);
    var homneNotifier = context.read<HomeNotifier>();
    if (homneNotifier.preventReloadAfterUploadPost) {
      if (homneNotifier.uploadedPostType == FeatureType.pic) {
        homneNotifier.tabIndex = 0;
      } else if (homneNotifier.uploadedPostType == FeatureType.diary) {
        var diary = context.read<PreviewDiaryNotifier>();
        homneNotifier.tabIndex = 1;
        if (diary.diaryData == null) {
          // diary.initialDiary(context, reload: true);
        }
      } else if (homneNotifier.uploadedPostType == FeatureType.vid) {
        var vid = context.read<PreviewVidNotifier>();
        homneNotifier.tabIndex = 2;
        if (vid.vidData == null) {
          // await notifier.initNewHome(context, mounted, isreload: true);
          // vid.initialVid(context, reload: true);
        }
      }
      homneNotifier.initNewHome(context, mounted, isreload: false, isNew: true);
      homeClick = true;
      (Routing.navigatorKey.currentContext ?? context).read<MainNotifier>().scrollController.animateTo(0, duration: const Duration(milliseconds: 1000), curve: Curves.ease);
    }
    _tabController.index = homneNotifier.tabIndex;
    _tabController.animation?.addListener(() {
      homneNotifier.tabIndex = _tabController.index;
      print("masuk tab slide");
      if (homneNotifier.lastCurIndex != homneNotifier.tabIndex) {
        homneNotifier.initNewHome(context, mounted, isreload: false, isNew: true);
      }
      homneNotifier.lastCurIndex = homneNotifier.tabIndex;
    });
    if (isHomeScreen) {
      print("isOnHomeScreen hit ads");
      homneNotifier.getAdsApsara(context, true);
    }
    // System().popUpChallange(context);
  }
}

class ShowCaseView extends StatefulWidget {
  final GlobalKey globalKey;
  final Widget child;
  const ShowCaseView({super.key, required this.globalKey, required this.child});

  @override
  State<ShowCaseView> createState() => _ShowCaseViewState();
}

class _ShowCaseViewState extends State<ShowCaseView> {
  @override
  Widget build(BuildContext context) {
    return Showcase(
      key: widget.globalKey,
      // container: Column(
      //   children: [],
      // ),
      blurValue: 0,
      // height: 10,
      // width: 10,
      description: "sdsdsd",
      child: widget.child,
    );
  }
}
