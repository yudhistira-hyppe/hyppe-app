import 'package:flutter/material.dart';
import 'package:hyppe/core/arguments/general_argument.dart';
import 'package:hyppe/core/arguments/other_profile_argument.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
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

class ListOnGoing extends StatefulWidget {
  const ListOnGoing({super.key});

  @override
  State<ListOnGoing> createState() => _ListOnGoingState();
}

class _ListOnGoingState extends State<ListOnGoing> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ChallangeNotifier>(builder: (_, cn, __) {
      var participant = 0;
      if (cn.leaderBoardData?.challengeData?[0].objectChallenge == "KONTEN") {
        cn.leaderBoardData?.getlastrank?.forEach((element) {
          if (element.postChallengess?.isNotEmpty ?? [].isEmpty) {
            participant++;
          }
        });
      } else {
        cn.leaderBoardData?.getlastrank?.forEach((element) {
          participant++;
        });
      }

      return SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            cn.leaderBoardData?.onGoing == false
                ? const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CustomCommingSoon(
                      title: 'Yuk, Ikut Kompetisi Menarik',
                      subtitle: "Raih peringkat pertama dengan mengikuti kompetisi yang seru ini, yuk!",
                    ),
                  )
                : cn.isLoadingLeaderboard
                    ? Container()
                    : cn.leaderBoardData?.getlastrank?.isEmpty ?? [].isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(32.0),
                            child: CustomEmptyWidget(
                              title: 'Belum ada Leaderboard Tersedia',
                              subtitle: "Raih peringkat pertama dengan mengikuti kompetisi yang seru ini, yuk!",
                            ),
                          )
                        : cn.leaderBoardData?.getlastrank?[0].score == 0 || participant == 0
                            ? const Padding(
                                padding: EdgeInsets.all(32.0),
                                child: CustomEmptyWidget(
                                  title: 'Belum ada Leaderboard Tersedia',
                                  subtitle: "Raih peringkat pertama dengan mengikuti kompetisi yang seru ini, yuk!",
                                ),
                              )
                            : ScrollConfiguration(
                                behavior: const ScrollBehavior().copyWith(overscroll: false),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 20),
                                  child: ListView.builder(
                                    itemCount: cn.leaderBoardData?.getlastrank?.length,
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      if (cn.leaderBoardData?.getlastrank?[index].score == 0) {
                                        return Container();
                                      } else {
                                        if (cn.leaderBoardData?.challengeData?[0].objectChallenge == 'KONTEN') {
                                          return GestureDetector(
                                              onTap: () {
                                                var post = cn.leaderBoardData?.getlastrank?[index].postChallengess?[0];
                                                var email = cn.leaderBoardData?.getlastrank?[index].email;
                                                cn.navigateToScreen(context, post?.index, email, post?.postType);
                                              },
                                              child: ContentLeaderboard(data: cn.leaderBoardData?.getlastrank?[index]));
                                        } else {
                                          return GestureDetector(
                                              onTap: () {
                                                Routing().move(Routes.otherProfile, argument: OtherProfileArgument(senderEmail: cn.leaderBoardData?.getlastrank?[index].email));
                                              },
                                              child: ItemLeader(data: cn.leaderBoardData?.getlastrank?[index]));
                                        }
                                      }
                                    },
                                  ),
                                ),
                              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: ButtonChallangeWidget(
                  bgColor: kHyppePrimary,
                  text: "Yuk, Join Challenge Sekarang",
                  function: () {
                    // print(cn.leaderBoardData?.challengeId);
                    Routing().move(Routes.chalengeDetail, argument: GeneralArgument(id: cn.leaderBoardData?.challengeId));
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
