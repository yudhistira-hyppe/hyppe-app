import 'dart:async';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hyppe/core/arguments/general_argument.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/chalange/leaderboard_challange_model.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/utils/dynamic_link/dynamic_link.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/show_general_dialog.dart';
import 'package:hyppe/ui/constant/widget/after_first_layout_mixin.dart';
import 'package:hyppe/ui/constant/widget/custom_base_cache_image.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/leaderboard/detail/footer_detail.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/leaderboard/detail/list_end_detail.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/leaderboard/detail/list_ongoing_detail.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/leaderboard/widget/shimmer_list.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/notifier.dart';
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
  final ScrollController scrollController = ScrollController();

  late TabController _tabController;
  double offset = 0.0;
  List nameTab = [];
  int _current = 0;
  int _lastCurrent = -1;
  String chllangeid = "";
  final CarouselController _controller = CarouselController();
  bool hideTab = false;
  String dateText = '';
  Color bgColor = kHyppeLightSurface;

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
      cn.clearData();

      print("hahahaha hihihihihihi");

      if (widget.arguments?.index == 1) {
        // Future.delayed(const Duration(milliseconds: 500), () {
        _tabController.index = 1;
        _current = 1;
        cn.optionData = DetailSub();
        cn.getLeaderBoard(
          context,
          widget.arguments?.id ?? chllangeid,
          oldLeaderboard: true,
          isDetail: true,
          session: widget.arguments?.session,
        );

        if (widget.arguments?.isTrue ?? false) {
          Future.delayed(const Duration(milliseconds: 500), () {
            ShowGeneralDialog.winChallange(context, widget.arguments?.title ?? '', widget.arguments?.body ?? '');
          });
        }
        // });
      } else {
        cn.initLeaderboardDetail(context, mounted, widget.arguments?.id ?? '');
      }

      chllangeid = widget.arguments?.id ?? '';

      _tabController.animation?.addListener(() {
        setState(() {
          _current = _tabController.index;
        });
        print("haha tab conotrol $_current");
        if (_lastCurrent != _current) {
          if (_current == 1) {
            cn.getLeaderBoard(
              context,
              chllangeid,
              oldLeaderboard: true,
              isDetail: true,
              session: (cn.leaderBoardDetailData?.session ?? 1) - 1,
            );
          } else if (_current == 0) {
            if (cn.leaderBoardDetailData?.sId == null) {
              cn.getLeaderBoard(
                context,
                chllangeid,
                oldLeaderboard: false,
                isDetail: true,
                isWinner: true,
              );
            }
          }
          // homneNotifier.initNewHome(context, mounted, isreload: false, isNew: true);
        }
        _lastCurrent = _current;
      });

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

  List<Widget> _preprareTabItems() {
    return _tabs = <Widget>[
      ListOnGoingDetail(
        scrollController: scrollController,
      ),
      ListEndDetail(isWinner: widget.arguments?.index == 1 ? true : false),
    ];
  }

  void toHideTab(ChallangeNotifier cn) {
    if ((cn.leaderBoardDetailData?.status == "BERLANGSUNG" && cn.leaderBoardDetailData?.session == 1)) {
      hideTab = true;
    } else {
      hideTab = false;
    }

    String inTime = '';
    LeaderboardChallangeModel data;
    if (cn.leaderBoardDetailData?.challengeData == null) {
      data = cn.leaderBoardDetaiEndlData ?? LeaderboardChallangeModel();
    } else {
      data = cn.leaderBoardDetailData ?? LeaderboardChallangeModel();
    }

    switch (data.noteTime) {
      case "inDays":
        inTime = lang?.hariLagi ?? "Hari Lagi";
        break;
      case "inHours":
        inTime = lang?.jamLagi ?? "Jam Lagi";
        break;
      default:
        inTime = lang?.menitLagi ?? "Menit Lagi";
    }

    if (data.status == "BERAKHIR") {
      dateText = lang?.thecompetitionhasended ?? "Kompetisi telah berakhir";
    } else {
      if (data.onGoing == true) {
        dateText = " ${lang?.endsIn} ${data.totalDays} $inTime";
      } else {
        dateText = "${lang?.startIn} ${data.totalDays} $inTime";
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var cn = context.watch<ChallangeNotifier>();
    var tn = context.read<TranslateNotifierV2>();
    toHideTab(cn);
    var boollUser = false;
    var image = '';
    var desc = '';
    var participant = 0;

    String title = '';

    if (!cn.isLoadingLeaderboard && cn.leaderBoardDetailData?.sId != null) {
      bgColor = System().colorFromHex(cn.leaderBoardDetailData?.challengeData?[0].leaderBoard?[0].warnaBackground ?? "#F5F5F5");
      title = cn.leaderBoardDetailData?.challengeData?[0].nameChallenge ?? '';
    } else if (!cn.isLoadingLeaderboard && cn.leaderBoardDetaiEndlData?.sId != null) {
      bgColor = System().colorFromHex(cn.leaderBoardDetaiEndlData?.challengeData?[0].leaderBoard?[0].warnaBackground ?? "#F5F5F5");
      title = cn.leaderBoardDetaiEndlData?.challengeData?[0].nameChallenge ?? '';
    }
    cn.leaderBoardDetailData?.getlastrank?.forEach((e) {
      // print("=hahaha=");
      if (e.isUserLogin == true) {
        boollUser = true;
      }
    });

    if (cn.leaderBoardDetailData?.challengeData != null) {
      image = cn.leaderBoardDetailData?.challengeData?[0].leaderBoard?[0].bannerLeaderboard ?? '';
      desc = cn.leaderBoardDetailData?.challengeData?[0].description ?? '';
      if (cn.leaderBoardDetailData?.getlastrank?.isNotEmpty ?? [].isNotEmpty) {
        participant = 1;
      }
    } else {
      if (cn.leaderBoardDetaiEndlData?.challengeData != null) {
        image = cn.leaderBoardDetaiEndlData?.challengeData?[0].leaderBoard?[0].bannerLeaderboard ?? '';
        desc = cn.leaderBoardDetaiEndlData?.challengeData?[0].description ?? '';
        if (cn.leaderBoardDetaiEndlData?.getlastrank?.isNotEmpty ?? [].isNotEmpty) {
          participant = 1;
        }
      }
    }

    return cn.isLoadingLeaderboard
        //  || (cn.leaderBoardDetailData?.sId == null || cn.leaderBoardDetaiEndlData?.sId == null)
        ? const ShimmerListLeaderboard()
        : Scaffold(
            backgroundColor: bgColor,
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
                      if (!cn.isLoadingLeaderboard) {
                        Routing().moveBack();
                      }
                    },
                  ),
                  title: Text(
                    title,
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
                              unawaited(
                                Navigator.of(context, rootNavigator: true).push(
                                  PageRouteBuilder(
                                    pageBuilder: (_, __, ___) => WillPopScope(
                                      onWillPop: () async => false,
                                      child: const Scaffold(
                                        backgroundColor: Colors.transparent,
                                        body: Center(
                                          child: CircularProgressIndicator.adaptive(),
                                        ),
                                      ),
                                    ),
                                    transitionDuration: Duration.zero,
                                    barrierDismissible: false,
                                    barrierColor: Colors.black45,
                                    opaque: false,
                                  ),
                                ),
                              );
                              String thumb = cn.leaderBoardDetailData?.challengeData?[0].leaderBoard?[0].bannerLeaderboard ?? '';
                              String desc = 'Ikuti challange dan menangkan kesempatan menang';
                              String fullname = "${cn.leaderBoardDetailData?.challengeData?[0].nameChallenge ?? ''} | Hyppe Challange";
                              String postId = cn.leaderBoardDetailData?.challengeId ?? '';
                              String routes = "/chalenge-detail";
                              DynamicLinkData dynamicLinkData = DynamicLinkData(description: desc, fullName: fullname, postID: postId, routes: routes, thumb: thumb);

                              System().createdDynamicLink(context, dynamicLinkData: dynamicLinkData).then((value) => Routing().moveBack());
                            },
                            icon: const CustomIconWidget(
                              iconData: "${AssetPath.vectorPath}share2.svg",
                              defaultColor: false,
                              height: 20,
                            ),
                          )
                  ],
                )),
            body: RefreshIndicator(
              color: kHyppePrimary,
              onRefresh: () async {
                await cn.initLeaderboardDetail(context, mounted, widget.arguments?.id ?? '', isWinner: true);
              },
              child: SingleChildScrollView(
                controller: scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                child: Container(
                  color: bgColor,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Text(_current.toString()),
                      CustomBaseCacheImage(
                        memCacheWidth: 100,
                        memCacheHeight: 100,
                        widthPlaceHolder: 80,
                        heightPlaceHolder: 80,
                        imageUrl: image,
                        imageBuilder: (context, imageProvider) => Image(
                          image: imageProvider,
                          fit: BoxFit.fitHeight,
                          width: SizeConfig.screenWidth,
                        ),
                        emptyWidget: GestureDetector(
                          onTap: () {},
                          child: Container(
                              decoration: const BoxDecoration(color: kHyppeNotConnect),
                              width: SizeConfig.screenWidth,
                              height: 250,
                              alignment: Alignment.center,
                              child: CustomTextWidget(textToDisplay: tn.translate.couldntLoadImage ?? 'Error')),
                        ),
                        errorWidget: (context, url, error) {
                          return GestureDetector(
                            onTap: () {},
                            child: Container(
                                decoration: const BoxDecoration(color: kHyppeNotConnect),
                                width: SizeConfig.screenWidth,
                                height: 250,
                                alignment: Alignment.center,
                                child: CustomTextWidget(textToDisplay: tn.translate.couldntLoadImage ?? 'Error')),
                          );
                        },
                      ),
                      twelvePx,
                      sixPx,
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: ShapeDecoration(
                                color: Colors.black.withOpacity(0.5),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              ),
                              child: Text(
                                dateText,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      cn.leaderBoardDetailData?.onGoing == false
                          ? Container()
                          : Container(
                              margin: const EdgeInsets.only(top: 16, left: 16.0, right: 16),
                              decoration: const ShapeDecoration(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    topRight: Radius.circular(8),
                                    bottomLeft: Radius.circular(8),
                                    bottomRight: Radius.circular(8),
                                  ),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Center(
                                    child: Container(
                                        width: SizeConfig.screenWidth,
                                        padding: const EdgeInsets.only(top: 24, bottom: 24),
                                        child: const Center(
                                          child: Text("Leaderboard",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                              )),
                                        )),
                                  ),
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
                                                    padding: const EdgeInsets.all(9),
                                                    child: Text(
                                                      nameTab[index],
                                                      style: const TextStyle(fontFamily: 'Lato', fontSize: 14),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                    child: _tabs?[_current],
                                  ),
                                ],
                              ),
                            ),
                      Container(
                        width: SizeConfig.screenWidth,
                        margin: EdgeInsets.only(
                          top: 16,
                          left: 16.0,
                          right: 16,
                          bottom: participant > 0 || (cn.leaderBoardDetailData?.onGoing ?? false) ? 16 : SizeConfig.screenHeight! * 0.7,
                        ),
                        padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Text(
                                tn.translate.description ?? "Deskripsi",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            twentyPx,
                            Text(desc),
                          ],
                        ),
                      ),
                      cn.leaderBoardDetailData?.onGoing == false || !boollUser
                          ? Container()
                          : Container(
                              width: SizeConfig.screenWidth,
                              margin: const EdgeInsets.only(left: 16.0, right: 16, bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: _current == 0 ? const FooterChallangeDetail() : Container(),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
