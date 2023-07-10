import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hyppe/app.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/after_first_layout_mixin.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/leaderboard/widget/list_ongoing.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/notifier.dart';
import 'package:hyppe/ui/inner/main/notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChalangeScreen extends StatefulWidget {
  const ChalangeScreen({Key? key}) : super(key: key);

  @override
  State<ChalangeScreen> createState() => _ChalangeScreenState();
}

class _ChalangeScreenState extends State<ChalangeScreen> with RouteAware, AfterFirstLayoutMixin, SingleTickerProviderStateMixin {
  final GlobalKey<NestedScrollViewState> globalKey = GlobalKey();

  final List<String> imgList = [
    'https://images.unsplash.com/photo-1603486002664-a7319421e133?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1842&q=80',
    'https://images.unsplash.com/photo-1580757468214-c73f7062a5cb?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1932&q=80',
    'https://images.unsplash.com/photo-1626593261859-4fe4865d8cb1?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2940&q=80'
  ];

  late TabController _tabController;
  double offset = 0.0;
  List nameTab = [];
  int _current = 0;
  final CarouselController _controller = CarouselController();

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
    });

    super.initState();
  }

  @override
  void afterFirstLayout(BuildContext context) {}

  @override
  Widget build(BuildContext context) {
    var cn = context.watch<ChallangeNotifier>();
    isFromSplash = false;
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(SizeWidget.appBarHome),
          child: AppBar(
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_sharp,
                color: kHyppeTextLightPrimary,
                size: 16,
              ),
              onPressed: () {},
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
                onPressed: () {},
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
          onRefresh: () async {},
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
                        child: Text("Challenge Utama",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            )),
                      ),
                      Container(
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
                        child: CarouselSlider(
                          options: CarouselOptions(
                              // height: 300
                              enlargeCenterPage: true,
                              enableInfiniteScroll: false,
                              // viewportFraction: 1.0,
                              aspectRatio: 16 / 7,
                              autoPlayInterval: const Duration(seconds: 3),
                              onPageChanged: (index, reason) {
                                setState(() {
                                  _current = index;
                                });
                              }),
                          items: imgList
                              .map((item) => ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Center(
                                        child: Image.network(
                                      item,
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
                                    )),
                                  ))
                              .toList(),
                        ),
                      ),
                      sixPx,
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: kHyppeLightSurface,
                          ),
                          child: TabBar(
                            // controller: _tabController,
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
              // controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),

              children: [
                cn.isLoadingLeaderboard || cn.leaderBoardData?.sId == null ? Container() : ListOnGoing(),
                // Container(
                //   height: 40,
                //   padding: const EdgeInsets.only(left: 6.0, right: 6),
                // ),
                Container(
                  height: 40,
                  padding: const EdgeInsets.only(left: 6.0, right: 6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
