import 'package:flutter/material.dart';
import 'package:hyppe/core/arguments/general_argument.dart';
import 'package:hyppe/core/arguments/other_profile_argument.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/widget/custom_commingsoon_page.dart';
import 'package:hyppe/ui/constant/widget/custom_empty_page.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/leaderboard/widget/button_challange.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/leaderboard/widget/card_chalange.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/leaderboard/widget/content_leader.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/leaderboard/widget/litem_leader.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class ListEnd extends StatefulWidget {
  const ListEnd({super.key});

  @override
  State<ListEnd> createState() => _ListEndState();
}

class _ListEndState extends State<ListEnd> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ChallangeNotifier>(builder: (_, cn, __) {
      var participant = 0;
      if (cn.leaderBoardEndData?.challengeData?[0].objectChallenge == "KONTEN") {
        cn.leaderBoardEndData?.getlastrank?.forEach((element) {
          if (element.postChallengess?.isNotEmpty ?? [].isEmpty) {
            participant++;
          }
        });
      } else {
        cn.leaderBoardEndData?.getlastrank?.forEach((element) {
          participant++;
        });
      }

      return SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                ShowBottomSheet.onPeriodChallange(context, cn.leaderBoardData?.challengeId ?? '', false, cn.selectOptionSession);
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
            cn.leaderBoardEndData?.onGoing == false
                ? const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CustomCommingSoon(
                      title: 'Yuk, Ikut Kompetisi Menarik',
                      subtitle: "Raih peringkat pertama dengan mengikuti kompetisi yang seru ini, yuk!",
                    ),
                  )
                : cn.isLoadingLeaderboard
                    ? Container()
                    : cn.leaderBoardEndData?.getlastrank?.isEmpty ?? [].isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(32.0),
                            child: CustomEmptyWidget(
                              title: 'Belum ada Leaderboard Tersedia',
                              subtitle: "Raih peringkat pertama dengan mengikuti kompetisi yang seru ini, yuk!",
                            ),
                          )
                        : cn.leaderBoardEndData?.getlastrank?[0].score == 0 || participant == 0
                            ? const Padding(
                                padding: EdgeInsets.all(32.0),
                                child: CustomEmptyWidget(
                                  title: 'Belum ada Leaderboard Tersedia',
                                  subtitle: "Raih peringkat pertama dengan mengikuti kompetisi yang seru ini, yuk!",
                                ),
                              )
                            : ScrollConfiguration(
                                behavior: const ScrollBehavior().copyWith(overscroll: false),
                                child: ListView.builder(
                                  itemCount: cn.leaderBoardEndData?.getlastrank?.length,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    if (cn.leaderBoardEndData?.challengeData?[0].objectChallenge == 'KONTEN') {
                                      return GestureDetector(
                                          onTap: () {
                                            var post = cn.leaderBoardEndData?.getlastrank?[index].postChallengess?[0];
                                            var email = cn.leaderBoardEndData?.getlastrank?[index].email;
                                            cn.navigateToScreen(context, post?.index, email, post?.postType);
                                          },
                                          child: ContentLeaderboard(data: cn.leaderBoardEndData?.getlastrank?[index]));
                                    } else {
                                      return GestureDetector(
                                          onTap: () {
                                            Routing().move(Routes.otherProfile, argument: OtherProfileArgument(senderEmail: cn.leaderBoardEndData?.getlastrank?[index].email));
                                          },
                                          child: ItemLeader(data: cn.leaderBoardEndData?.getlastrank?[index]));
                                    }
                                  },
                                ),
                              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: ButtonChallangeWidget(
                  bgColor: kHyppePrimary,
                  text: "Yuk, Join Challenge Sekarang",
                  function: () {
                    // print(cn.leaderBoardEndData?.challengeId);
                    Routing().move(Routes.chalengeDetail, argument: GeneralArgument(id: cn.leaderBoardEndData?.challengeId));
                  }),
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
                          "Ikuti Challenge Menarik Lainnya",
                          style: TextStyle(
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
                              dateText = "Berakhir dalam ${cn.listChallangeData[index].totalDays} Hari Lagi";
                            } else {
                              dateText = "Mulai dalam ${cn.listChallangeData[index].totalDays} Hari Lagi";
                            }
                            return CardChalange(
                              data: cn.listChallangeData[index],
                              dateText: dateText,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      );
    });
  }
}
