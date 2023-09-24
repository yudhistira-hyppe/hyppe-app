import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hyppe/app.dart';
import 'package:hyppe/core/arguments/general_argument.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/services/route_observer_service.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/after_first_layout_mixin.dart';
import 'package:hyppe/ui/constant/widget/custom_base_cache_image.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/leaderboard/widget/list_end.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/leaderboard/widget/list_ongoing.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/leaderboard/widget/shimmer_list.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/notifier.dart';
import 'package:hyppe/ui/inner/main/notifier.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class ChalangeScreen extends StatefulWidget {
  const ChalangeScreen({Key? key}) : super(key: key);

  @override
  State<ChalangeScreen> createState() => _ChalangeScreenState();
}

class _ChalangeScreenState extends State<ChalangeScreen> with RouteAware, AfterFirstLayoutMixin, SingleTickerProviderStateMixin {
  final GlobalKey<NestedScrollViewState> globalKey = GlobalKey();
  final CarouselController _controller = CarouselController();

  late TabController _tabController;
  double offset = 0.0;
  List nameTab = [];
  int _currentSlidder = 0;
  int _currentTab = 0;
  int _lastCurrentTab = 0;
  String chllangeid = "";
  String lastchallangeid = "";
  bool hideTab = false;

  LocalizationModelV2? lang;
  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'Chalange Screen');

    _tabController = TabController(length: 2, vsync: this);
    lang = context.read<TranslateNotifierV2>().translate;
    nameTab = [lang?.goingOn, lang?.end];
    offset = 0;
    Future.delayed(Duration.zero, () {
      globalKey.currentState?.innerController.addListener(() {
        if ((globalKey.currentState?.innerController.position.pixels ?? 0) >= (globalKey.currentState?.innerController.position.maxScrollExtent ?? 0) &&
            !(globalKey.currentState?.innerController.position.outOfRange ?? true)) {}
      });

      var cn = context.read<ChallangeNotifier>();
      cn.initLeaderboard(context);

      _tabController.animation?.addListener(() {
        _tabController.animation?.addListener(() {
          _currentTab = _tabController.index;
          if (_lastCurrentTab != _currentTab) {
            if (_currentTab == 1) {
              cn.getLeaderBoard(
                context,
                chllangeid,
                oldLeaderboard: true,
              );
            }
            // homneNotifier.initNewHome(context, mounted, isreload: false, isNew: true);
          }
          _lastCurrentTab = _currentTab;
        });
      });
    });
    print("build==============");

    super.initState();
  }

  @override
  void afterFirstLayout(BuildContext context) {}

  void toHideTab(ChallangeNotifier cn) {
    // print("!!!@@@@ hide ${((cn.leaderBoardData?.onGoing == true && cn.leaderBoardData?.session == 1) || cn.leaderBoardData?.session == 1)}");
    // print("${cn.leaderBoardData?.session}");
    if ((cn.leaderBoardData?.onGoing == true && cn.leaderBoardData?.session == 1) || cn.leaderBoardData?.session == 1) {
      hideTab = true;
    } else {
      hideTab = false;
    }
  }

  @override
  void didChangeDependencies() {
    CustomRouteObserver.routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
    super.didChangeDependencies();
  }

  @override
  void didPopNext() {
    print("======121212");
    print(_currentSlidder);
    _controller.jumpToPage(_currentSlidder);
    super.didPopNext();
  }

  @override
  Widget build(BuildContext context) {
    var cn = context.watch<ChallangeNotifier>();
    isFromSplash = false;
    toHideTab(cn);
    if (chllangeid == '' && cn.bannerLeaderboardData.isNotEmpty) {
      chllangeid = cn.bannerLeaderboardData[0].sId ?? '';
    }

    return Scaffold(
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(SizeWidget.appBarHome),
          child: AppBar(
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_sharp,
                color: kHyppeTextLightPrimary,
                size: 16,
              ),
              onPressed: () {
                Routing().moveBack();
              },
            ),
            title: Text(
              '${lang?.challengePage}',
              style: const TextStyle(
                fontSize: 16,
                fontFamily: 'Lato',
                fontWeight: FontWeight.w700,
              ),
            ),
            titleSpacing: 0,
            actions: [
              IconButton(
                onPressed: () {
                  Routing().move(Routes.chalengeAchievement, argument: GeneralArgument(id: cn.leaderBoardData?.challengeId));
                },
                icon: const CustomIconWidget(
                  iconData: "${AssetPath.vectorPath}achievement.svg",
                  defaultColor: false,
                  height: 20,
                ),
              )
            ],
          )),
      body: DefaultTabController(
        length: 2,
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
            await cn.initLeaderboard(context);
          },
          child: cn.isLoadingLeaderboard || cn.leaderBoardData?.sId == null
              ? const ShimmerListLeaderboard()
              : ScrollConfiguration(
                  behavior: const ScrollBehavior().copyWith(overscroll: false),
                  child: NestedScrollView(
                    key: globalKey,
                    controller: context.read<MainNotifier>().scrollController,
                    physics: const NeverScrollableScrollPhysics(),
                    // dragStartBehavior: DragStartBehavior.start,
                    headerSliverBuilder: (context, bool innerBoxIsScrolled) {
                      return [
                        SliverOverlapAbsorber(
                          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
                                child: Text(lang?.mainChallenge ?? '',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    )),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: CarouselSlider(
                                  carouselController: _controller,
                                  options: CarouselOptions(
                                      enlargeCenterPage: true,
                                      enableInfiniteScroll: false,
                                      viewportFraction: 0.8,
                                      // aspectRatio: 343 / 103,
                                      // height: 176,
                                      height: SizeConfig.screenWidth! * 0.29,
                                      onPageChanged: (index, reason) async {
                                        setState(() {
                                          _currentSlidder = index;
                                          _tabController.index = 0;
                                          chllangeid = cn.bannerLeaderboardData[index].sId ?? '';
                                          Future.delayed(Duration(milliseconds: 500), () {
                                            lastchallangeid = cn.bannerLeaderboardData[index].sId ?? '';
                                            if (lastchallangeid == chllangeid) {
                                              cn.getLeaderBoard(context, cn.bannerLeaderboardData[index].sId ?? '');
                                            }
                                          });
                                        });
                                      }),
                                  items: cn.bannerLeaderboardData
                                      .map((item) => ClipRRect(
                                            borderRadius: BorderRadius.circular(10),
                                            child: Center(
                                              //     child: CustomBaseCacheImage(
                                              //   memCacheWidth: 100,
                                              //   memCacheHeight: 100,
                                              //   widthPlaceHolder: 80,
                                              //   heightPlaceHolder: 80,
                                              //   imageUrl: item.bannerLandingpage ?? '',
                                              //   imageBuilder: (context, imageProvider) => ClipRRect(
                                              //     borderRadius: BorderRadius.circular(20), // Image border
                                              //     child: Image(
                                              //       image: imageProvider,
                                              //       fit: BoxFit.fitHeight,
                                              //       width: SizeConfig.screenWidth,
                                              //     ),
                                              //   ),
                                              //   errorWidget: (context, url, error) {
                                              //     return Container(
                                              //       // const EdgeInsets.symmetric(horizontal: 4.5),
                                              //       // height: 500,
                                              //       decoration: BoxDecoration(
                                              //         image: const DecorationImage(
                                              //           image: AssetImage('${AssetPath.pngPath}content-error.png'),
                                              //           fit: BoxFit.cover,
                                              //         ),
                                              //         borderRadius: BorderRadius.circular(8.0),
                                              //       ),
                                              //     );
                                              //   },
                                              //   emptyWidget: Container(
                                              //     // const EdgeInsets.symmetric(horizontal: 4.5),
                                              //     // height: 500,
                                              //     decoration: BoxDecoration(
                                              //       image: const DecorationImage(
                                              //         image: AssetImage('${AssetPath.pngPath}content-error.png'),
                                              //         fit: BoxFit.cover,
                                              //       ),
                                              //       borderRadius: BorderRadius.circular(8.0),
                                              //     ),
                                              //   ),
                                              // )
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(20), // Image border
                                                child: Image.network(
                                                  item.bannerLandingpage ?? '',
                                                  width: SizeConfig.screenWidth,
                                                  fit: BoxFit.cover,
                                                  loadingBuilder: (context, child, loadingProgress) {
                                                    if (loadingProgress == null) return child;
                                                    return Center(
                                                      child: Container(
                                                        height: SizeConfig.screenHeight,
                                                        width: SizeConfig.screenWidth,
                                                        color: Colors.black,
                                                        child: UnconstrainedBox(
                                                          child: Container(
                                                            height: 50,
                                                            width: 50,
                                                            child: CircularProgressIndicator(
                                                                // value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null,
                                                                ),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                ),
                              ),
                              sixPx,
                              //Tab
                              hideTab
                                  ? Container()
                                  : Container(
                                      padding: const EdgeInsets.all(16),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          color: kHyppeLightSurface,
                                        ),
                                        child: TabBar(
                                          controller: _tabController,
                                          indicator: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              8.0,
                                            ),
                                            color: kHyppeLightButtonText,
                                          ),
                                          labelPadding: const EdgeInsets.symmetric(vertical: 0),
                                          labelColor: kHyppeTextLightPrimary,
                                          unselectedLabelColor: Theme.of(context).tabBarTheme.unselectedLabelColor,
                                          labelStyle: TextStyle(fontFamily: "Lato", fontWeight: FontWeight.w700, fontSize: 14 * SizeConfig.scaleDiagonal),
                                          // indicator: UnderlineTabIndicator(borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.0)),
                                          unselectedLabelStyle: TextStyle(fontFamily: "Roboto", fontWeight: FontWeight.w400, fontSize: 14 * SizeConfig.scaleDiagonal),
                                          tabs: [
                                            ...List.generate(
                                              nameTab.length,
                                              (index) => Padding(
                                                padding: EdgeInsets.all(9),
                                                child: Text(
                                                  nameTab[index],
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
                        ),

                        // FilterLanding(),
                        // HyppePreviewVid(),
                        // HyppePreviewDiary(),
                      ];
                    },
                    body: TabBarView(
                      controller: _tabController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: const [
                        ListOnGoing(),
                        ListEnd(),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
