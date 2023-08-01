import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hyppe/core/arguments/general_argument.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/utils/dynamic_link/dynamic_link.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/show_general_dialog.dart';
import 'package:hyppe/ui/constant/widget/after_first_layout_mixin.dart';
import 'package:hyppe/ui/constant/widget/custom_base_cache_image.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/leaderboard/detail/list_end_detail.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/leaderboard/detail/list_ongoing_detail.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/leaderboard/widget/list_end.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/leaderboard/widget/shimmer_list.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/notifier.dart';
import 'package:hyppe/ui/inner/main/notifier.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ux/routing.dart';
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
  int _lastCurrent = 0;
  String chllangeid = "";
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
      cn.initLeaderboardDetail(context, widget.arguments?.id ?? '');
      chllangeid = widget.arguments?.id ?? '';

      _tabController.animation?.addListener(() {
        _tabController.animation?.addListener(() {
          _current = _tabController.index;
          if (_lastCurrent != _current) {
            if (_current == 1) {
              print("masuk tab slide ${_tabController.index}");
              print("masuk tab slide");
              cn.getLeaderBoard(
                context,
                chllangeid,
                oldLeaderboard: true,
                isDetail: true,
              );
            }
            // homneNotifier.initNewHome(context, mounted, isreload: false, isNew: true);
          }
          _lastCurrent = _current;
        });
      });

      if (widget.arguments?.index == 1) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _tabController.index = widget.arguments?.index ?? 0;
          cn.getLeaderBoard(
            context,
            chllangeid,
            oldLeaderboard: true,
            isDetail: true,
          );
          Future.delayed(const Duration(milliseconds: 500), () {
            ShowGeneralDialog.winChallange(context);
          });
        });
      }

      if (widget.arguments?.session != null) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _tabController.index = 1;
          cn.selectOptionSession = widget.arguments?.session ?? 0;
          cn.getLeaderBoard(
            context,
            chllangeid,
            oldLeaderboard: true,
            isDetail: true,
          );
        });
      }
    });

    super.initState();
  }

  @override
  void afterFirstLayout(BuildContext context) {}

  void toHideTab(ChallangeNotifier cn) {
    if ((cn.leaderBoardDetailData?.onGoing == true && cn.leaderBoardDetailData?.session == 1) || cn.leaderBoardDetailData?.session == 1 || cn.leaderBoardDetailData?.status == 'BERAKHIR') {
      hideTab = true;
    } else {
      hideTab = false;
    }

    String inTime = '';

    switch (cn.leaderBoardDetailData?.noteTime) {
      case "inDays":
        inTime = "Hari";
        break;
      case "inHours":
        inTime = "Jam";
        break;
      default:
        inTime = "Menit";
    }

    if (cn.leaderBoardDetailData?.onGoing == true) {
      dateText = "Berakhir dalam ${cn.leaderBoardDetailData?.totalDays} $inTime Lagi";
    } else {
      dateText = "Mulai  dalam ${cn.leaderBoardDetailData?.totalDays} $inTime Lagi";
    }
  }

  @override
  Widget build(BuildContext context) {
    var cn = context.watch<ChallangeNotifier>();
    var tn = context.read<TranslateNotifierV2>();
    toHideTab(cn);

    return Scaffold(
      backgroundColor: kHyppeLightSurface,
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
              onPressed: () {
                Routing().moveBack();
              },
            ),
            title: Text(
              cn.leaderBoardDetailData?.challengeData?[0].nameChallenge == null ? '' : '${cn.leaderBoardDetailData?.challengeData?[0].nameChallenge}',
              style: const TextStyle(
                fontSize: 16,
                fontFamily: 'Lato',
                fontWeight: FontWeight.w700,
              ),
            ),
            titleSpacing: 0,
            actions: [
              cn.isLoadingLeaderboard || cn.leaderBoardDetailData?.sId == null
                  ? Container()
                  : IconButton(
                      onPressed: () {
                        String thumb = cn.leaderBoardDetailData?.challengeData?[0].leaderBoard?[0].bannerLeaderboard ?? '';
                        String desc = 'Ikuti challange dan menangkan kesempatan menang';
                        String fullname = "${cn.leaderBoardDetailData?.challengeData?[0].nameChallenge ?? ''} | Hyppe Challange";
                        String postId = cn.leaderBoardDetailData?.challengeId ?? '';
                        String routes = "/chalenge-detail";
                        DynamicLinkData dynamicLinkData = DynamicLinkData(description: desc, fullName: fullname, postID: postId, routes: routes, thumb: thumb);
                        System().createdDynamicLink(context, dynamicLinkData: dynamicLinkData);
                      },
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
          child: cn.isLoadingLeaderboard
              //  || (cn.leaderBoardDetailData?.sId == null || cn.leaderBoardDetaiEndlData?.sId == null)
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
                              CustomBaseCacheImage(
                                memCacheWidth: 100,
                                memCacheHeight: 100,
                                widthPlaceHolder: 80,
                                heightPlaceHolder: 80,
                                imageUrl: (cn.leaderBoardDetailData?.challengeData?[0].leaderBoard?[0].bannerLeaderboard),
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
                              // GestureDetector(
                              //     onTap: () {
                              //       ShowGeneralDialog.winChallange(context);
                              //     },
                              //     child: Text("hahaha")),
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
                              Center(
                                child: Container(
                                    width: SizeConfig.screenWidth,
                                    padding: const EdgeInsets.only(top: 24, bottom: 24),
                                    margin: const EdgeInsets.only(top: 16, left: 16.0, right: 16),
                                    decoration: ShapeDecoration(
                                      color: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8))),
                                    ),
                                    child: Center(
                                      child: Text("Leaderboard",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          )),
                                    )),
                              ),
                              //Tab
                              hideTab
                                  ? Container()
                                  : Container(
                                      margin: const EdgeInsets.only(left: 16.0, right: 16),
                                      padding: const EdgeInsets.only(top: 16, left: 16.0, right: 16),
                                      color: Colors.white,
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
                        ListOnGoingDetail(),
                        ListEndDetail(),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
