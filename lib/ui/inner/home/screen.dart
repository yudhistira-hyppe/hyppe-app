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
import 'package:hyppe/ui/inner/home/widget/filter.dart';
import 'package:hyppe/ui/inner/home/widget/home_app_bar.dart';
import 'package:hyppe/ui/inner/upload/pre_upload_content/notifier.dart';
import 'package:hyppe/ui/inner/upload/pre_upload_content/widget/process_upload_component.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/ui/inner/home/notifier_v2.dart';
// v2 view
import 'package:hyppe/ui/inner/home/content_v2/pic/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/preview/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/stories/preview/screen.dart';
import '../../../core/services/route_observer_service.dart';
import '../../constant/widget/after_first_layout_mixin.dart';
import 'package:move_to_background/move_to_background.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware, AfterFirstLayoutMixin, SingleTickerProviderStateMixin {
  final GlobalKey<RefreshIndicatorState> _globalKey = GlobalKey<RefreshIndicatorState>();
  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;
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
    isHomeScreen = false;
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
    'deactivate isOnHomeScreen $isHomeScreen'.logger();
    super.deactivate();
  }

  @override
  void didPush() {
    'didPush isOnHomeScreen $isHomeScreen'.logger();
  }

  @override
  void initState() {
    isHomeScreen = true;
    'isOnHomeScreen $isHomeScreen'.logger();
    _tabController = TabController(length: 3, vsync: this);
    Future.delayed(Duration.zero, () {
      final notifier = context.read<HomeNotifier>();
      notifier.setSessionID();
      final _language = context.read<TranslateNotifierV2>().translate;
      final notifierFollow = context.read<FollowRequestUnfollowNotifier>();

      notifier.initHome(context, mounted);
      if (notifierFollow.listFollow.isEmpty) {
        notifierFollow.listFollow = [
          {'name': "${_language.follow}", 'code': 'TOFOLLOW'},
          {'name': "${_language.following}", 'code': 'FOLLOWING'},
        ];
      }
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
    return Consumer<HomeNotifier>(
      builder: (_, notifier, __) => WillPopScope(
        onWillPop: () async {
          MoveToBackground.moveTaskToBack();
          return false;
        },
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(SizeWidget.appBarHome),
            child: HomeAppBar(),
          ),
          body: DefaultTabController(
            length: 3,
            child: NestedScrollView(
              headerSliverBuilder: (context, _) {
                return [
                  SliverList(
                    delegate: SliverChildListDelegate([
                      const ProcessUploadComponent(),
                      const HyppePreviewStories(),
                      Material(
                        color: Colors.black,
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
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            // first tab bar view widget
                            Container(
                                color: Colors.red,
                                child: ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: 20,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      width: 100,
                                      height: 20,
                                      color: Colors.blue,
                                      margin: EdgeInsets.all(10),
                                    );
                                  },
                                )),
                            Container(
                              color: Colors.red,
                              child: Center(
                                child: Text(
                                  'Bike',
                                ),
                              ),
                            ),
                            // second tab bar viiew widget
                            Container(
                              color: Colors.pink,
                              child: Center(
                                child: Text(
                                  'Car',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]),
                  ),

                  // Expanded(
                  //   child: Container(
                  //     color: kHyppeLightSurface,
                  //     padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
                  //     child: Column(
                  //       children: [
                  //         Material(
                  //           color: Colors.black,
                  //           child: TabBar(
                  //             controller: _tabController,
                  //             indicator: BoxDecoration(
                  //               borderRadius: BorderRadius.circular(
                  //                 25.0,
                  //               ),
                  //               color: kHyppePrimary,
                  //             ),
                  //             labelPadding: const EdgeInsets.symmetric(vertical: 0),
                  //             labelColor: kHyppeLightButtonText,
                  //             unselectedLabelColor: Theme.of(context).tabBarTheme.unselectedLabelColor,
                  //             labelStyle: TextStyle(fontFamily: "Gotham", fontWeight: FontWeight.w400, fontSize: 14 * SizeConfig.scaleDiagonal),
                  //             // indicator: UnderlineTabIndicator(borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.0)),
                  //             unselectedLabelStyle: TextStyle(fontFamily: "Roboto", fontWeight: FontWeight.w400, fontSize: 14 * SizeConfig.scaleDiagonal),
                  //             tabs: [
                  //               ...List.generate(
                  //                 filterList.length,
                  //                 (index) => Padding(
                  //                   padding: EdgeInsets.all(9),
                  //                   child: Text(
                  //                     filterList[index]['name'],
                  //                   ),
                  //                 ),
                  //               ),
                  //             ],
                  //           ),
                  //         ),
                  //         Expanded(
                  //           child: TabBarView(
                  //             controller: _tabController,
                  //             children: [
                  //               // first tab bar view widget
                  //               Container(
                  //                   color: Colors.red,
                  //                   child: ListView.builder(
                  //                     physics: const NeverScrollableScrollPhysics(),
                  //                     itemCount: 20,
                  //                     itemBuilder: (context, index) {
                  //                       return Container(
                  //                         width: 100,
                  //                         height: 20,
                  //                         color: Colors.blue,
                  //                         margin: EdgeInsets.all(10),
                  //                       );
                  //                     },
                  //                   )),
                  //               Container(
                  //                 color: Colors.red,
                  //                 child: Center(
                  //                   child: Text(
                  //                     'Bike',
                  //                   ),
                  //                 ),
                  //               ),
                  //               // second tab bar viiew widget
                  //               Container(
                  //                 color: Colors.pink,
                  //                 child: Center(
                  //                   child: Text(
                  //                     'Car',
                  //                   ),
                  //                 ),
                  //               ),
                  //             ],
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),

                  // FilterLanding(),
                  // HyppePreviewVid(),
                  // HyppePreviewDiary(),
                  // HyppePreviewPic(),
                ];
              },
              body: Column(
                children: [
                  Material(
                    color: Colors.black,
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
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // first tab bar view widget
                        Container(
                            color: Colors.red,
                            child: ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: 20,
                              itemBuilder: (context, index) {
                                return Container(
                                  width: 100,
                                  height: 20,
                                  color: Colors.blue,
                                  margin: EdgeInsets.all(10),
                                );
                              },
                            )),
                        Container(
                          color: Colors.red,
                          child: Center(
                            child: Text(
                              'Bike',
                            ),
                          ),
                        ),
                        // second tab bar viiew widget
                        Container(
                          color: Colors.pink,
                          child: Center(
                            child: Text(
                              'Car',
                            ),
                          ),
                        ),
                      ],
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

  @override
  void afterFirstLayout(BuildContext context) {
    print("afterrrrrrr============");
    CustomRouteObserver.routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute<dynamic>);
    var homneNotifier = context.read<HomeNotifier>();
    _tabController.index = homneNotifier.tabIndex;
    _tabController.animation?.addListener(() {
      homneNotifier.tabIndex = _tabController.index;
    });
    if (isHomeScreen) {
      print("isOnHomeScreen hit ads");
      homneNotifier.getAdsApsara(context, true);
    }
  }
}
