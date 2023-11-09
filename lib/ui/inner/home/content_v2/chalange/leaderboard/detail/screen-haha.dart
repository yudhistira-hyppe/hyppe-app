import 'dart:io';
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
import 'package:hyppe/ui/constant/overlay/general_dialog/show_general_dialog.dart';
import 'package:hyppe/ui/constant/widget/after_first_layout_mixin.dart';
import 'package:hyppe/ui/constant/widget/custom_base_cache_image.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/leaderboard/detail/body_detail.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/notifier.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class ChalangeDetailScreen2 extends StatefulWidget {
  final GeneralArgument? arguments;
  const ChalangeDetailScreen2({Key? key, this.arguments}) : super(key: key);

  @override
  State<ChalangeDetailScreen2> createState() => _ChalangeDetailScreen2State();
}

class _ChalangeDetailScreen2State extends State<ChalangeDetailScreen2> with RouteAware, AfterFirstLayoutMixin, SingleTickerProviderStateMixin {
  final GlobalKey<NestedScrollViewState> globalKey = GlobalKey();

  late TabController _tabController;
  double offset = 0.0;
  List nameTab = [];
  int _current = 0;
  int _lastCurrent = 0;
  String chllangeid = "";
  // final CarouselController _controller = CarouselController();
  bool hideTab = false;
  String dateText = '';
  Color bgColor = kHyppeLightSurface;

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
      cn.initLeaderboardDetail(context, mounted, widget.arguments?.id ?? '');
      chllangeid = widget.arguments?.id ?? '';

      _tabController.animation?.addListener(() {
        _tabController.animation?.addListener(() {
          _current = _tabController.index;
          if (_lastCurrent != _current) {
            if (_current == 1) {
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
            ShowGeneralDialog.winChallange(context, widget.arguments?.title ?? '', widget.arguments?.body ?? '');
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
    if ((cn.leaderBoardDetailData?.status == "BERLANGSUNG" && cn.leaderBoardDetailData?.session == 1)) {
      hideTab = true;
    } else {
      hideTab = false;
    }

    String inTime = '';

    switch (cn.leaderBoardDetailData?.noteTime) {
      case "inDays":
        inTime = lang?.hariLagi ?? "Hari Lagi";
        break;
      case "inHours":
        inTime = lang?.jamLagi ?? "Jam Lagi";
        break;
      default:
        inTime = lang?.menitLagi ?? "Menit Lagi";
    }

    if (cn.leaderBoardDetailData?.status == "BERAKHIR") {
      dateText = lang?.thecompetitionhasended ?? "Kompetisi telah berakhir";
    } else {
      if (cn.leaderBoardDetailData?.onGoing == true) {
        dateText = " ${lang?.endsIn} ${cn.leaderBoardDetailData?.totalDays} $inTime";
      } else {
        dateText = "${lang?.startIn} ${cn.leaderBoardDetailData?.totalDays} $inTime";
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var cn = context.watch<ChallangeNotifier>();
    var tn = context.read<TranslateNotifierV2>();
    toHideTab(cn);

    if (!cn.isLoadingLeaderboard || cn.leaderBoardDetailData?.sId != null) {
      bgColor = System().colorFromHex(cn.leaderBoardDetailData?.challengeData?[0].leaderBoard?[0].warnaBackground ?? "#F5F5F5");
    }

    return WillPopScope(
      onWillPop: () async {
        if (cn.isLoadingLeaderboard) {
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
          backgroundColor: bgColor,
          appBar: PreferredSize(
              preferredSize: const Size.fromHeight(SizeWidget.appBarHome),
              child: AppBar(
                backgroundColor: Colors.white,
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
          body: SingleChildScrollView(
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
                await cn.initLeaderboardDetail(context, mounted, widget.arguments?.id ?? '');
              },
              child: Column(
                children: [
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
                  sixPx,
                  BodyDetailWidget(),
                ],
              ),
            ),
          )),
    );
  }
}
