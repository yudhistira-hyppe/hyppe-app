import 'package:flutter/material.dart';
import 'package:hyppe/core/arguments/general_argument.dart';
import 'package:hyppe/core/arguments/other_profile_argument.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/widget/custom_commingsoon_page.dart';
import 'package:hyppe/ui/constant/widget/custom_empty_page.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/leaderboard/detail/footer_detail.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/leaderboard/widget/button_challange.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/leaderboard/widget/card_chalange.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/leaderboard/widget/content_leader.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/leaderboard/widget/litem_leader.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class ListEndDetail extends StatefulWidget {
  const ListEndDetail({super.key});

  @override
  State<ListEndDetail> createState() => _ListEndDetailState();
}

class _ListEndDetailState extends State<ListEndDetail> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ChallangeNotifier>(builder: (_, cn, __) {
      var participant = 0;
      if (cn.leaderBoardDetaiEndlData?.challengeData?[0].objectChallenge == "KONTEN") {
        cn.leaderBoardDetaiEndlData?.getlastrank?.forEach((element) {
          if (element.postChallengess?.isNotEmpty ?? [].isEmpty) {
            participant++;
          }
        });
      } else {
        cn.leaderBoardDetaiEndlData?.getlastrank?.forEach((element) {
          participant++;
        });
      }

      return SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(left: 16.0, right: 16),
              padding: const EdgeInsets.only(bottom: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      ShowBottomSheet.onPeriodChallange(context, cn.leaderBoardDetailData?.challengeId ?? '', true, cn.selectOptionSession);
                      print(cn.selectOptionSession);
                    },
                    child: Container(
                      margin: EdgeInsets.all(16),
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                      decoration: BoxDecoration(color: Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(4)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Challenge Periode ${cn.selectOptionSession}',
                            style: TextStyle(
                              color: Color(0xFF9B9B9B),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: kHyppeTextLightPrimary,
                          )
                        ],
                      ),
                    ),
                  ),
                  cn.leaderBoardDetaiEndlData?.onGoing == false
                      ? Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: CustomCommingSoon(
                            title: cn.language.letsJoinTheCompetition ?? 'Yuk, Ikut Kompetisi Menarik',
                            subtitle: cn.language.getFirstPlaceByEnteringThisExcitingCompetition ?? "Raih peringkat pertama dengan mengikuti kompetisi yang seru ini, yuk!",
                          ),
                        )
                      : cn.isLoadingLeaderboard
                          ? Container()
                          : cn.leaderBoardDetaiEndlData?.getlastrank?.isEmpty ?? [].isEmpty
                              ? Padding(
                                  padding: const EdgeInsets.all(32.0),
                                  child: CustomEmptyWidget(
                                    title: cn.language.theresNoLeaderboardAvailable ?? 'Belum ada Leaderboard Tersedia',
                                    subtitle: cn.language.getFirstPlaceByEnteringThisExcitingCompetition ?? "Raih peringkat pertama dengan mengikuti kompetisi yang seru ini, yuk!",
                                  ),
                                )
                              : cn.leaderBoardDetaiEndlData?.getlastrank?[0].score == 0 || participant == 0
                                  ? Padding(
                                      padding: EdgeInsets.all(32.0),
                                      child: CustomEmptyWidget(
                                        title: cn.language.theresNoLeaderboardAvailable ?? 'Belum ada Leaderboard Tersedia',
                                        subtitle: cn.language.getFirstPlaceByFollowingThisExciting ?? "Raih peringkat pertama dengan mengikuti kompetisi yang seru ini, yuk!",
                                      ),
                                    )
                                  : ScrollConfiguration(
                                      behavior: const ScrollBehavior().copyWith(overscroll: false),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 24),
                                        child: ListView.builder(
                                          itemCount: cn.leaderBoardDetaiEndlData?.getlastrank?.length,
                                          shrinkWrap: true,
                                          physics: const NeverScrollableScrollPhysics(),
                                          itemBuilder: (context, index) {
                                            if (cn.leaderBoardEndData?.getlastrank?[index].score == 0) {
                                              return Container();
                                            } else {
                                              if (cn.leaderBoardDetaiEndlData?.challengeData?[0].objectChallenge == 'KONTEN') {
                                                return GestureDetector(
                                                    onTap: () {
                                                      var post = cn.leaderBoardDetaiEndlData?.getlastrank?[index].postChallengess?[0];
                                                      var email = cn.leaderBoardDetaiEndlData?.getlastrank?[index].email;
                                                      cn.navigateToScreen(context, post?.index, email, post?.postType);
                                                    },
                                                    child: ContentLeaderboard(data: cn.leaderBoardDetaiEndlData?.getlastrank?[index]));
                                              } else {
                                                return GestureDetector(
                                                    onTap: () {
                                                      Routing().move(Routes.otherProfile, argument: OtherProfileArgument(senderEmail: cn.leaderBoardDetaiEndlData?.getlastrank?[index].email));
                                                    },
                                                    child: ItemLeader(data: cn.leaderBoardDetaiEndlData?.getlastrank?[index]));
                                              }
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                ],
              ),
            ),
            Container(
                width: SizeConfig.screenWidth,
                margin: const EdgeInsets.only(top: 16, left: 16.0, right: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      cn.language.description ?? "Deskripsi",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    twentyPx,
                    Text("${cn.leaderBoardDetailData?.challengeData?[0].description}"),
                  ],
                )),
          ],
        ),
      );
    });
  }
}
