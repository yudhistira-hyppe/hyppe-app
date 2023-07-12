import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hyppe/core/arguments/general_argument.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/after_first_layout_mixin.dart';
import 'package:hyppe/ui/constant/widget/custom_base_cache_image.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/leaderboard/detail/list_ongoing_detail.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/leaderboard/widget/shimmer_list.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/notifier.dart';
import 'package:hyppe/ui/inner/main/notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChalangeDetailScreen extends StatefulWidget {
  final GeneralArgument? arguments;
  const ChalangeDetailScreen({Key? key, this.arguments}) : super(key: key);

  @override
  State<ChalangeDetailScreen> createState() => _ChalangeDetailScreenState();
}

class _ChalangeDetailScreenState extends State<ChalangeDetailScreen> with RouteAware, AfterFirstLayoutMixin, SingleTickerProviderStateMixin {
  final GlobalKey<NestedScrollViewState> globalKey = GlobalKey();

  late TabController _tabController;
  double offset = 0.0;
  List nameTab = [];
  int _current = 0;
  final CarouselController _controller = CarouselController();
  bool hideTab = false;
  String dateText = '';

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
      cn.initLeaderboardDetail(context);
      toHideTab(cn);
    });

    super.initState();
  }

  @override
  void afterFirstLayout(BuildContext context) {}

  void toHideTab(ChallangeNotifier cn) {
    if ((cn.leaderBoardData?.onGoing == true && cn.leaderBoardData?.session == 1) || cn.leaderBoardData?.session == 1) {
      hideTab = true;
    } else {
      hideTab = false;
    }

    if (cn.leaderBoardData?.onGoing == true) {
      dateText = "Berakhir dalam ${cn.leaderBoardData?.totalDays} Hari Lagi";
    } else {
      dateText = "Mulai  dalam ${cn.leaderBoardData?.totalDays} Hari Lagi";
    }
  }

  @override
  Widget build(BuildContext context) {
    var cn = context.watch<ChallangeNotifier>();
    var tn = context.read<TranslateNotifierV2>();
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(SizeWidget.appBarHome),
          child: AppBar(
            backgroundColor: Colors.white,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_sharp,
                color: kHyppeTextLightPrimary,
                size: 16,
              ),
              onPressed: () {},
            ),
            title: Text(
              '${cn.leaderBoardData?.sId}',
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
                  iconData: "${AssetPath.vectorPath}share2.svg",
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
          child: ScrollConfiguration(
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
                        CustomBaseCacheImage(
                          memCacheWidth: 100,
                          memCacheHeight: 100,
                          widthPlaceHolder: 80,
                          heightPlaceHolder: 80,
                          imageUrl: (cn.leaderBoardData?.bannerSearch),
                          imageBuilder: (context, imageProvider) => Image(
                            image: imageProvider,
                            fit: BoxFit.fitHeight,
                            width: SizeConfig.screenWidth,
                          ),
                          emptyWidget: GestureDetector(
                            onTap: () {},
                            child: Container(
                                decoration: BoxDecoration(color: kHyppeNotConnect),
                                width: SizeConfig.screenWidth,
                                height: 250,
                                alignment: Alignment.center,
                                child: CustomTextWidget(textToDisplay: tn.translate.couldntLoadImage ?? 'Error')),
                          ),
                          errorWidget: (context, url, error) {
                            return GestureDetector(
                              onTap: () {},
                              child: Container(
                                  decoration: BoxDecoration(color: kHyppeNotConnect),
                                  width: SizeConfig.screenWidth,
                                  height: 250,
                                  alignment: Alignment.center,
                                  child: CustomTextWidget(textToDisplay: tn.translate.couldntLoadImage ?? 'Error')),
                            );
                          },
                        ),
                        twelvePx,
                        Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: ShapeDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                ),
                                child: Text(
                                  dateText,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
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
                children: [
                  cn.isLoadingLeaderboard || cn.leaderBoardData?.sId != null ? const ShimmerListLeaderboard() : const ListOnGoingDetail(),
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
      ),
    );
  }
}
