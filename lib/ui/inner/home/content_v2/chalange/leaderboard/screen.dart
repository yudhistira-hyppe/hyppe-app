import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/rendering.dart';
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
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/leaderboard/widget/list_end.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/leaderboard/widget/list_ongoing.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/leaderboard/widget/shimmer_leaderboard.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/notifier.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/leaderboard/widget/card_chalange.dart';

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
  bool isDidpop = false;

  LocalizationModelV2? lang;
  List<Widget>? _tabs;

  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'Chalange Screen');

    _tabController = TabController(length: 2, vsync: this);
    lang = context.read<TranslateNotifierV2>().translate;
    nameTab = [lang?.goingOn, lang?.end];
    offset = 0;

    Future.delayed(Duration.zero, () {
      _preprareTabItems();

      globalKey.currentState?.innerController.addListener(() {
        if ((globalKey.currentState?.innerController.position.pixels ?? 0) >= (globalKey.currentState?.innerController.position.maxScrollExtent ?? 0) &&
            !(globalKey.currentState?.innerController.position.outOfRange ?? true)) {}
      });

      var cn = context.read<ChallangeNotifier>();
      cn.initLeaderboard(context);

      _tabController.animation?.addListener(() {
        _tabController.animation?.addListener(() {
          setState(() {
            _currentTab = _tabController.index;
          });

          if (_lastCurrentTab != _currentTab) {
            if (_currentTab == 1) {
              cn.getLeaderBoard(
                context,
                chllangeid,
                oldLeaderboard: true,
                session: (cn.leaderBoardData?.session ?? 0) - 1,
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
    print("!!!@@@@ hide ${((cn.leaderBoardData?.onGoing == true && cn.leaderBoardData?.session == 1) || cn.leaderBoardData?.session == 1)}");
    print("${cn.leaderBoardData?.session}");
    if ((cn.leaderBoardData?.onGoing == true && cn.leaderBoardData?.session == 1) || cn.leaderBoardData?.session == 1) {
      hideTab = true;
    } else {
      hideTab = false;
    }
  }

  List<Widget> _preprareTabItems() {
    return _tabs = <Widget>[
      const ListOnGoing(),
      const ListEnd(),
    ];
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
    isDidpop = true;
    _controller.jumpToPage(_currentSlidder);
    // Future.delayed(Duration(milliseconds: 150), () {
    //   isDidpop = false;
    // });
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

    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
        body: RefreshIndicator(
          color: kHyppePrimary,
          onRefresh: () async {
            _currentTab = 0;
            _tabController.index = 0;
            await cn.initLeaderboard(context);
          },
          child: cn.isLoadingLeaderboard
              ? const ShimmerLeaderboard()
              : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
                        child: Text(lang?.mainChallenge ?? '',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            )),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: NotificationListener<UserScrollNotification>(
                          onNotification: (notification) {
                            final ScrollDirection direction = notification.direction;
                            setState(() {
                              isDidpop = false;
                            });
                            print("-=-=-=-=-=-=-=-=- scrolll direction $direction");
                            return true;
                          },
                          child: CarouselSlider(
                            carouselController: _controller,
                            options: CarouselOptions(
                                enlargeCenterPage: true,
                                enableInfiniteScroll: false,
                                viewportFraction: 0.8,
                                // aspectRatio: 343 / 103,
                                // height: 176,
                                height: SizeConfig.screenWidth! * 0.27,
                                onPageChanged: (index, reason) async {
                                  setState(() {
                                    _currentSlidder = index;
                                    _tabController.index = 0;

                                    Future.delayed(Duration(milliseconds: 500), () {
                                      chllangeid = cn.bannerLeaderboardData[index].sId ?? '';
                                      if (lastchallangeid == chllangeid && !isDidpop) {
                                        cn.getLeaderBoard(context, cn.bannerLeaderboardData[index].sId ?? '');
                                      }
                                    });
                                    lastchallangeid = cn.bannerLeaderboardData[index].sId ?? '';
                                  });
                                }),
                            items: cn.bannerLeaderboardData
                                .map((item) => Container(
                                      margin: EdgeInsets.only(bottom: 10),
                                      decoration: BoxDecoration(boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.8),
                                          offset: Offset(5, 8),
                                          blurRadius: 5,
                                          spreadRadius: -5,
                                        ),
                                      ]),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10), //
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
                                                    child: const CircularProgressIndicator(
                                                        // value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                      ),
                      sixPx,
                      hideTab
                          ? Container()
                          : Container(
                              height: 50,
                              padding: const EdgeInsets.all(6),
                              margin: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: kHyppeLightSurface,
                              ),
                              child: AppBar(
                                bottom: TabBar(
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
                                  isScrollable: false,
                                  unselectedLabelStyle: TextStyle(fontFamily: "Roboto", fontWeight: FontWeight.w400, fontSize: 14 * SizeConfig.scaleDiagonal),
                                  controller: _tabController,

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
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: _tabs![_currentTab],
                      ),
                      cn.listChallangeData.isEmpty
                          ? Container()
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 20,
                                  color: kHyppeLightSurface,
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                                  child: Text(
                                    lang?.joinOtherInterestingChallenges ?? '',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 200,
                                  child: ListView.builder(
                                    itemCount: cn.listChallangeData.length,
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: false,
                                    itemBuilder: (context, index) {
                                      var dateText = "";
                                      if (cn.listChallangeData[index].onGoing == true) {
                                        dateText = "${lang?.endsIn} ${cn.listChallangeData[index].totalDays} ${lang?.hariLagi}";
                                      } else {
                                        dateText = "${lang?.startIn} ${cn.listChallangeData[index].totalDays} ${lang?.hariLagi}";
                                      }
                                      return CardChalange(
                                        data: cn.listChallangeData[index],
                                        dateText: dateText,
                                        last: index == cn.listChallangeData.length - 1,
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
