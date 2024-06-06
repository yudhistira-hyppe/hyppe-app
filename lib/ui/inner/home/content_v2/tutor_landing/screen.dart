import 'dart:async';
import 'dart:io';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hyppe/app.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/tutor_landing/widget/diary.dart';
import 'package:hyppe/ui/inner/home/content_v2/tutor_landing/widget/pic.dart';
import 'package:hyppe/ui/inner/home/content_v2/tutor_landing/widget/story.dart';
import 'package:hyppe/ui/inner/home/content_v2/tutor_landing/widget/vid.dart';
import 'package:hyppe/ui/inner/home/widget/home_app_bar.dart';
import 'package:hyppe/ui/inner/main/notifier.dart';
import 'package:hyppe/ui/inner/upload/pre_upload_content/notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/ui/inner/home/notifier_v2.dart';
// v2 view
import 'package:showcaseview/showcaseview.dart';
import '../../../../../core/services/route_observer_service.dart';
import '../../../../constant/widget/after_first_layout_mixin.dart';
import 'package:move_to_background/move_to_background.dart';

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
  late TabController _tabController2;
  double offset = 0.0;
  List filterList = [
    {"id": '1', 'name': "Pic"},
    // {"id": '2', 'name': "Dairy"},
    {"id": '2', 'name': "Vid"},
  ];

  GlobalKey keyButton = GlobalKey();
  // GlobalKey keyButton1 = GlobalKey();
  GlobalKey keyButton2 = GlobalKey();
  LocalizationModelV2? _language;

  @override
  void dispose() {
    super.dispose();
    _tabController2.dispose();
  }

  void show() {
    // ShowCaseWidget.of(context).startShowCase([keyButton, keyButton1, keyButton2, keyButton1, widget.keyButton]);
    ShowCaseWidget.of(context).startShowCase([keyButton,  keyButton2, widget.keyButton]);
  }

  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'HomeScreen');

    'initState isOnHomeScreen $isHomeScreen'.logger();
    _tabController2 = TabController(length: 2, vsync: this);

    offset = 0;
    WidgetsBinding.instance.addPostFrameCallback((_) => show());

    Future.delayed(Duration.zero, () {
      final notifier = context.read<HomeNotifier>();
      notifier.setSessionID();
      _language = context.read<TranslateNotifierV2>().translate;
    });

    context.read<PreUploadContentNotifier>().onGetInterest(context);

    if (mounted) {
      setState(() => {});
    }
    super.initState();
    '++++++++++++++++ iniststate'.logger();
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
              length: 2,
              child: RefreshIndicator(
                color: kHyppePrimary,
                notificationPredicate: (notification) {
                  if (notifier.isLoadingPict  || notifier.isLoadingVid) {
                    return false;
                  } else {
                    // with NestedScrollView local(depth == 2) OverscrollNotification are not sent
                    if (notification is OverscrollNotification || Platform.isIOS) {
                      return notification.depth == 2;
                    }
                    return notification.depth == 0;
                    // if (_tabController2.index != 0) {}
                    // return notification.depth == 0;
                  }
                },
                onRefresh: () async {
                  if (!isZoom) {
                    Future.delayed(const Duration(milliseconds: 400), () async {
                      imageCache.clear();
                      imageCache.clearLiveImages();
                      await notifier.initNewHome(context, mounted, isreload: true);
                    });
                  }
                },
                child: AbsorbPointer(
                  absorbing: isZoom,
                  child: NestedScrollView(
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
                                    controller: _tabController2,
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
                                          // case 1:
                                            // if (_tabController2.index == 1) {
                                            //   titleCase = 'Diary! 🎥';
                                            //   descCase = _language?.tutorLanding2 ?? '';
                                            //   stepTitle = "2/6";
                                            // } else {
                                            //   titleCase = 'Geser 👆';
                                            //   descCase = _language?.tutorLanding4 ?? '';
                                            //   stepTitle = "4/6";
                                            // }
                                            // break;
                                          case 1:
                                            titleCase = 'Video! 🎥';
                                            descCase = _language?.tutorLanding3 ?? '';
                                            stepTitle = "3/6";
                                            break;
                                        }
                                        return Padding(
                                          padding: const EdgeInsets.all(9),
                                          child: Showcase(
                                            key: index == 0
                                                ? keyButton
                                                : keyButton2,
                                            tooltipBackgroundColor: kHyppeTextLightPrimary,
                                            overlayOpacity: 0,
                                            targetPadding: const EdgeInsets.all(0),
                                            tooltipPosition: TooltipPosition.bottom,
                                            title: titleCase,
                                            titleTextStyle: const TextStyle(fontSize: 12, color: kHyppeNotConnect),
                                            titlePadding: const EdgeInsets.all(6),
                                            description: descCase,
                                            descTextStyle: const TextStyle(fontSize: 10, color: kHyppeNotConnect),
                                            descriptionPadding: const EdgeInsets.all(6),
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
                                                    style: const TextStyle(color: kHyppeBurem, fontSize: 10),
                                                  ),
                                                  GestureDetector(
                                                      onTap: () {
                                                        ShowCaseWidget.of(context).next();
                                                        switch (index) {
                                                          case 0:
                                                            setState(() {
                                                              _tabController2.index = 1;
                                                            });
                                                            break;
                                                          case 1:
                                                            // setState(() {
                                                            //   if (_tabController2.index == 1) {
                                                            //     _tabController2.index = 2;
                                                            //   } else {}
                                                            // });
                                                            break;
                                                          case 2:
                                                            // _tabController2.index = 0;
                                                            break;
                                                        }
                                                      },
                                                      child: Text(
                                                        _language?.next ?? 'Selanjutnya',
                                                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                                      ))
                                                ],
                                              ),
                                            ),
                                            child: Text(
                                              filterList[index]['name'],
                                              style: const TextStyle(fontFamily: 'Lato', fontSize: 14),
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
                      controller: _tabController2,
                      physics: isZoom ? const NeverScrollableScrollPhysics() : const AlwaysScrollableScrollPhysics(),
                      children: [
                        // Pict
                        Container(
                          height: 40,
                          padding: const EdgeInsets.only(left: 6.0, right: 6),
                          color: kHyppeLightSurface,
                          child: PicTutor(
                            appbarSeen: appbarSeen,
                            scrollController: context.read<MainNotifier>().globalKey?.currentState?.innerController,
                            // offset: offset,
                          ),
                        ),
                        // Container(
                        //   padding: const EdgeInsets.only(left: 6.0, right: 6),
                        //   color: kHyppeLightSurface,
                        //   child: DiaryTutor(
                        //     scrollController: context.read<MainNotifier>().globalKey?.currentState?.innerController,
                        //   ),
                        // ),
                        // second tab bar viiew widget
                        Container(
                          padding: const EdgeInsets.only(left: 6.0, right: 6),
                          color: kHyppeLightSurface,
                          child: VidTutor(
                            scrollController: context.read<MainNotifier>().globalKey?.currentState?.innerController,
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

    _tabController2.index = homneNotifier.tabIndex;
    _tabController2.animation?.addListener(() {});
    // System().popUpChallange(context);
  }
}
