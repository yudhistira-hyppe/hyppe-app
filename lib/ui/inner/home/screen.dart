import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hyppe/app.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/entities/follow/notifier.dart';
import 'package:hyppe/ui/constant/entities/report/notifier.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/player/landing_diary.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/notifier.dart';
import 'package:hyppe/ui/inner/home/widget/home_app_bar.dart';
import 'package:hyppe/ui/inner/upload/pre_upload_content/notifier.dart';
import 'package:hyppe/ui/inner/upload/pre_upload_content/widget/process_upload_component.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/ui/inner/home/notifier_v2.dart';
// v2 view
import 'package:hyppe/ui/inner/home/content_v2/pic/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/stories/preview/screen.dart';
import '../../../core/services/route_observer_service.dart';
import '../../constant/widget/after_first_layout_mixin.dart';
import 'package:move_to_background/move_to_background.dart';

class HomeScreen extends StatefulWidget {
  final bool canShowAds;
  HomeScreen({Key? key, required this.canShowAds}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware, AfterFirstLayoutMixin, SingleTickerProviderStateMixin {
  final GlobalKey<RefreshIndicatorState> _globalKey = GlobalKey<RefreshIndicatorState>();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<NestedScrollViewState> globalKey = GlobalKey();

  late TabController _tabController;
  double offset = 0.0;
  List filterList = [
    {"id": '1', 'name': "Pic"},
    {"id": '2', 'name': "Diary"},
    {"id": '3', 'name': "Vid"},
  ];

  @override
  void didChangeDependencies() {
    CustomRouteObserver.routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
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
      isHomeScreen = true;
      globalScroller = _scrollController;
      'didPopNext isOnHomeScreen $isHomeScreen'.logger();
      context.read<ReportNotifier>().inPosition = contentPosition.home;
      if (isHomeScreen) {
        print("isOnHomeScreen hit ads");
        var homneNotifier = context.read<HomeNotifier>();
        await homneNotifier.getAdsApsara(context, true);
      }
    });

    // System().disposeBlock();

    super.didPopNext();
  }

  @override
  void didPushNext() {
    isHomeScreen = widget.canShowAds;
    globalScroller = _scrollController;
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
    globalScroller = null;
    'deactivate isOnHomeScreen $isHomeScreen'.logger();
    super.deactivate();
  }

  @override
  void didPush() {
    'didPush isOnHomeScreen $isHomeScreen'.logger();
  }

  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'HomeScreen');
    isHomeScreen = widget.canShowAds;
    'initState isOnHomeScreen $isHomeScreen'.logger();
    _tabController = TabController(length: 3, vsync: this);
    globalScroller = _scrollController;

    offset = 0;
    Future.delayed(Duration.zero, () {
      final notifier = context.read<HomeNotifier>();
      notifier.setSessionID();
      final _language = context.read<TranslateNotifierV2>().translate;
      final notifierFollow = context.read<FollowRequestUnfollowNotifier>();

      notifier.initNewHome(context, mounted, isreload: false, isNew: true);
      if (notifierFollow.listFollow.isEmpty) {
        notifierFollow.listFollow = [
          {'name': "${_language.follow}", 'code': 'TOFOLLOW'},
          {'name': "${_language.following}", 'code': 'FOLLOWING'},
        ];
      }

      globalKey.currentState?.innerController.addListener(() {
        if ((globalKey.currentState?.innerController.position.pixels ?? 0) >= (globalKey.currentState?.innerController.position.maxScrollExtent ?? 0) &&
            !(globalKey.currentState?.innerController.position.outOfRange ?? true)) {
          notifier.initNewHome(context, mounted, isreload: false, isgetMore: true);
        }
      });

      _scrollController.addListener(() {
        setState(() {
          offset = _scrollController.offset;
        });
      });
      context.read<ReportNotifier>().inPosition = contentPosition.home;
    });

    context.read<PreUploadContentNotifier>().onGetInterest(context);

    if (mounted) {
      setState(() => {});
    }
    super.initState();
    'ini iniststate home'.logger();
  }

  @override
  Widget build(BuildContext context) {
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
          body: DefaultTabController(
            length: 3,
            child: RefreshIndicator(
              color: kHyppePrimary,
              notificationPredicate: (notification) {
                // with NestedScrollView local(depth == 2) OverscrollNotification are not sent
                if (notification is OverscrollNotification || Platform.isIOS) {
                  return notification.depth == 2;
                }
                return notification.depth == 0;
              },
              onRefresh: () async {
                imageCache.clear();
                imageCache.clearLiveImages();
                await notifier.initNewHome(context, mounted, isreload: true);
              },
              child: NestedScrollView(
                key: globalKey,
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                headerSliverBuilder: (context, bool innerBoxIsScrolled) {
                  return [
                    SliverList(
                      delegate: SliverChildListDelegate([
                        const ProcessUploadComponent(),
                        sixPx,
                        const HyppePreviewStories(),
                        sixPx,
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
                                ...List.generate(
                                  filterList.length,
                                  (index) => Padding(
                                    padding: EdgeInsets.all(9),
                                    child: Text(
                                      filterList[index]['name'],
                                      style: TextStyle(fontFamily: 'Lato', fontSize: 14),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ]),
                    ),

                    // FilterLanding(),
                    // HyppePreviewVid(),
                    // HyppePreviewDiary(),
                  ];
                },
                body: TabBarView(
                  controller: _tabController,
                  children: [
                    // Pict
                    Container(
                      padding: const EdgeInsets.only(left: 6.0, right: 6),
                      color: kHyppeLightSurface,
                      child: const HyppePreviewPic(),
                    ),
                    Container(
                      padding: const EdgeInsets.only(left: 6.0, right: 6),
                      color: kHyppeLightSurface,
                      child: const LandingDiaryPage(),
                    ),
                    // second tab bar viiew widget
                    Container(
                      padding: const EdgeInsets.only(left: 16.0, right: 16),
                      color: kHyppeLightSurface,
                      child: const HyppePreviewVid(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void afterFirstLayout(BuildContext context) {
    print("afterrrrrrr============");
    CustomRouteObserver.routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute<dynamic>);
    var homneNotifier = context.read<HomeNotifier>();
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
  }
}
