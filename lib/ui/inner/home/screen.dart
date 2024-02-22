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
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/entities/follow/notifier.dart';
import 'package:hyppe/ui/constant/entities/report/notifier.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/player/landing_diary.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/preview/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/notifier.dart';
import 'package:hyppe/ui/inner/home/widget/home_app_bar.dart';
import 'package:hyppe/ui/inner/main/notifier.dart';
import 'package:hyppe/ui/inner/upload/pre_upload_content/notifier.dart';
import 'package:hyppe/ui/inner/upload/pre_upload_content/widget/process_upload_component.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/ui/inner/home/notifier_v2.dart';
// v2 view
import 'package:hyppe/ui/inner/home/content_v2/pic/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/stories/preview/screen.dart';
import '../../../core/services/route_observer_service.dart';
import '../../constant/widget/after_first_layout_mixin.dart';
import 'package:move_to_background/move_to_background.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  final bool canShowAds;

  const HomeScreen({Key? key, required this.canShowAds}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware, AfterFirstLayoutMixin, SingleTickerProviderStateMixin {
  // final GlobalKey<RefreshIndicatorState> _globalKey = GlobalKey<RefreshIndicatorState>();
  final GlobalKey<NestedScrollViewState> globalKey = GlobalKey();
  bool appbarSeen = true;
  bool afterUploading = false;
  late TabController _tabController;
  double offset = 0.0;
  List filterList = [
    {"id": '1', 'name': "Pic"},
    {"id": '2', 'name': "Diary"},
    {"id": '3', 'name': "Vid"},
  ];

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
  }

  @override
  void dispose() {
    CustomRouteObserver.routeObserver.unsubscribe(this);
    globalKey.currentState?.innerController.dispose();
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
    if (fromGuest) {
      final vid = Provider.of<PreviewVidNotifier>(Routing.navigatorKey.currentContext ?? context, listen: false);
      final diary = Provider.of<PreviewDiaryNotifier>(Routing.navigatorKey.currentContext ?? context, listen: false);
      final pic = Provider.of<PreviewPicNotifier>(Routing.navigatorKey.currentContext ?? context, listen: false);
      vid.vidData = null;
      diary.diaryData = null;
      pic.pic = null;
      final notifier = context.read<HomeNotifier>();
      notifier.initNewHome(context, mounted, isreload: true, isNew: true);
      fromGuest = false;
    }

    super.didPushNext();
  }

  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'HomeScreen');
    isHomeScreen = widget.canShowAds;
    'initState isOnHomeScreen $isHomeScreen'.logger();
    _tabController = TabController(length: 3, vsync: this);

    Future.delayed(Duration.zero, () {
      // _tabController.index = 0;
      final notifier = context.read<HomeNotifier>();
      notifier.setSessionID();
      // notifier.tabIndex = 0;
      _language = context.read<TranslateNotifierV2>().translate;
      final notifierFollow = context.read<FollowRequestUnfollowNotifier>();
      final notifierMain = context.read<MainNotifier>();
      // notifierMain.globalKey = globalKey;

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
      Future.delayed(Duration(milliseconds: 500), () {
        notifierMain.globalKey?.currentState?.innerController.addListener(() {
          try {
            if ((notifierMain.globalKey?.currentState?.innerController.position.pixels ?? 0) >= (notifierMain.globalKey?.currentState?.innerController.position.maxScrollExtent ?? 0) &&
                !(notifierMain.globalKey?.currentState?.innerController.position.outOfRange ?? true)) {
              notifier.initNewHome(context, mounted, isreload: false, isgetMore: true);
            }
          } catch (e) {
            e.logger();
          }
        });
      });

      globalKey.currentState?.innerController.addListener(() {
        setState(() {
          offset = globalKey.currentState?.innerController.position.pixels ?? 0;
          // print("======offset ${offset}");
        });
      });

      Routing.navigatorKey.currentContext?.read<MainNotifier>().scrollController.addListener(() {
        // print(context.read<MainNotifier>().scrollController.offset);
        try {
          if (mounted) {
            if ((Routing.navigatorKey.currentContext?.read<MainNotifier>().scrollController.offset ?? 0) >= 160) {
              setState(() {
                appbarSeen = false;
              });
            } else {
              setState(() {
                appbarSeen = true;
              });
            }
          } else {
            if ((Routing.navigatorKey.currentContext?.read<MainNotifier>().scrollController.offset ?? 0) >= 160) {
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
    System().analyticSetScreen('landingpage');
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
    print("==========iz zoomm = ${val}");
    setState(() {
      isZoom = val;
    });
  }

  @override
  Widget build(BuildContext context) {
    // final notifierMain = context.read<MainNotifier>();
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
            child: HomeAppBar(name: "${selfnotifier.user.profile?.fullName}", offset: offset),
          ),
          body: DefaultTabController(
            length: 3,
            child: RefreshIndicator(
              color: kHyppePrimary,
              notificationPredicate: (notification) {
                if (notifier.isLoadingPict || notifier.isLoadingDiary || notifier.isLoadingVid) {
                  return false;
                } else {
                  // with NestedScrollView local(depth == 2) OverscrollNotification are not sent
                  // if (notification is OverscrollNotification || Platform.isIOS) {
                  //   return notification.depth == 2;
                  // }
                  // return notification.depth == 0;
                  return true;
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
                absorbing: false,
                // absorbing: isZoom,
                child: NestedScrollView(
                  // key: context.read<MainNotifier>().globalKey,
                  key: globalKey,
                  controller: context.read<MainNotifier>().scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  // dragStartBehavior: DragStartBehavior.start,
                  headerSliverBuilder: (context, bool innerBoxIsScrolled) {
                    return [
                      SliverOverlapAbsorber(
                        handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            // Text("${globalKey.currentState?.innerController}"),
                            // Text("${Size.fromHeight(SizeWidget.appBarHome).height}"),
                            const ProcessUploadComponent(),
                            sixPx,
                            const HyppePreviewStories(),
                            sixPx,

                            // GestureDetector(
                            //     onTap: () {
                            //       setState(() {
                            //         changeTab(FeatureType.diary);
                            //       });
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
                                      return Padding(
                                        padding: EdgeInsets.all(9),
                                        child: Text(
                                          filterList[index]['name'],
                                          style: TextStyle(fontFamily: 'Lato', fontSize: 14),
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
                    // physics: isZoom ? const NeverScrollableScrollPhysics() : const AlwaysScrollableScrollPhysics(),
                    children: [
                      // Pict
                      Container(
                        height: 40,
                        padding: const EdgeInsets.only(left: 6.0, right: 6),
                        color: kHyppeLightSurface,
                        child: HyppePreviewPic(
                          onScaleStart: () {
                            // zoom(true);
                            // globalTultipShow = true;
                          },
                          onScaleStop: () {
                            // zoom(false);
                            // globalTultipShow = false;
                          },
                          appbarSeen: appbarSeen,
                          scrollController: globalKey.currentState?.innerController,
                          // scrollController: context.read<MainNotifier>().globalKey?.currentState?.innerController,
                          // offset: offset,
                        ),
                      ),
                      // Container(
                      //     padding: const EdgeInsets.only(left: 6.0, right: 6),
                      //     color: kHyppeLightSurface,
                      //     child: ListView.builder(
                      //       itemCount: 100,
                      //       itemBuilder: (context, index) {
                      //         return Container(
                      //           margin: EdgeInsets.only(bottom: 30),
                      //           height: 50,
                      //           width: 50,
                      //           color: Colors.red,
                      //         );
                      //       },
                      //     )),
                      Container(
                        padding: const EdgeInsets.only(left: 6.0, right: 6),
                        color: kHyppeLightSurface,
                        child: LandingDiaryPage(
                          scrollController: globalKey.currentState?.innerController,
                          // scrollController: context.read<MainNotifier>().globalKey?.currentState?.innerController,
                        ),
                      ),
                      // second tab bar viiew widget
                      Container(
                        padding: const EdgeInsets.only(left: 16.0, right: 16),
                        color: kHyppeLightSurface,
                        child: HyppePreviewVid(
                          scrollController: globalKey.currentState?.innerController,
                          // scrollController: context.read<MainNotifier>().globalKey?.currentState?.innerController,
                          afterUploading: afterUploading,
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
    );
  }

  @override
  void afterFirstLayout(BuildContext context) async {
    CustomRouteObserver.routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute<dynamic>);
    var homneNotifier = context.read<HomeNotifier>();
    if (homneNotifier.preventReloadAfterUploadPost) {
      afterUploading = true;
      changeTab(homneNotifier.uploadedPostType);
      homneNotifier.initNewHome(context, mounted, isreload: false, isNew: true);
      homeClick = true;
      (Routing.navigatorKey.currentContext ?? context).read<MainNotifier>().scrollController.animateTo(0, duration: const Duration(milliseconds: 1000), curve: Curves.ease);
      Future.delayed(Duration(milliseconds: 500), () {
        afterUploading = false;
      });
    }

    setState(() {
      _tabController.index = homneNotifier.tabIndex;
    });

    _tabController.animation?.addListener(() {
      homneNotifier.tabIndex = _tabController.index;

      if (homneNotifier.lastCurIndex != homneNotifier.tabIndex) {
        homneNotifier.initNewHome(context, mounted, isreload: false, isNew: true);
      }
      homneNotifier.lastCurIndex = homneNotifier.tabIndex;
    });
    if (isHomeScreen) {
      homneNotifier.getAdsApsara(context, true);
    }
    var pic = Provider.of<PreviewPicNotifier>(Routing.navigatorKey.currentContext ?? context, listen: false);
    if (context.read<MainNotifier>().tutorialData.isEmpty && (pic.pic?.isNotEmpty ?? [].isEmpty)) {
      context.read<MainNotifier>().tutorialData = pic.pic?.first.tutorial ?? [];
    }
    //
  }

  void changeTab(postType) {
    var homneNotifier = context.read<HomeNotifier>();
    if (postType == FeatureType.pic) {
      homneNotifier.tabIndex = 0;
    } else if (homneNotifier.uploadedPostType == FeatureType.diary) {
      setState(() {
        homneNotifier.tabIndex = 1;
      });
    } else if (postType == FeatureType.vid) {
      var vid = context.read<PreviewVidNotifier>();
      homneNotifier.tabIndex = 2;

      if (vid.vidData == null) {
        // await notifier.initNewHome(context, mounted, isreload: true);
        // vid.initialVid(context, reload: true);
      }
    }
  }
}
