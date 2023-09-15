import 'package:flutter/material.dart';
import 'package:hyppe/core/arguments/general_argument.dart';
import 'package:hyppe/core/arguments/other_profile_argument.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/chalange/leaderboard_challange_model.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
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
    TranslateNotifierV2 tn = context.read<TranslateNotifierV2>();
    return Consumer<ChallangeNotifier>(builder: (_, cn, __) {
      var participant = 0;
      var boollUser = false;

      for (Getlastrank e in cn.leaderBoardData?.getlastrank ?? []) {
        if (e.isUserLogin == true) {
          boollUser = true;
          break;
        }
      }

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
                ? Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CustomCommingSoon(
                      title: '${tn.translate.letsJoinTheCompetition}',
                      subtitle: '${tn.translate.getFirstPlaceByEnteringThisExcitingCompetition}',
                    ),
                  )
                : cn.isLoadingLeaderboard
                    ? Container()
                    : cn.leaderBoardData?.getlastrank?.isEmpty ?? [].isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: CustomEmptyWidget(
                              title: '${tn.translate.theresNoLeaderboardAvailable}',
                              subtitle: '${tn.translate.getFirstPlaceByFollowingThisExciting}',
                            ),
                          )
                        : cn.leaderBoardData?.getlastrank?[0].score == 0 || participant == 0
                            ? Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: CustomEmptyWidget(
                                  title: '${tn.translate.theresNoLeaderboardAvailable}',
                                  subtitle: '${tn.translate.getFirstPlaceByFollowingThisExciting}',
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
                                                System().navigateToProfile(context, cn.leaderBoardData?.getlastrank?[index].email ?? '');
                                                // Routing().move(Routes.otherProfile, argument: OtherProfileArgument(senderEmail: cn.leaderBoardData?.getlastrank?[index].email));
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
                  text: boollUser ? tn.translate.viewChallenge : tn.translate.joinTheChallengeNow,
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
                          tn.translate.joinOtherInterestingChallenges ?? '',
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
                              dateText = "${tn.translate.endsIn} ${cn.listChallangeData[index].totalDays} ${tn.translate.hariLagi}";
                            } else {
                              dateText = "${tn.translate.startIn} ${cn.listChallangeData[index].totalDays} ${tn.translate.hariLagi}";
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
