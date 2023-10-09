import 'package:flutter/material.dart';
import 'package:hyppe/core/arguments/general_argument.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/chalange/leaderboard_challange_model.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_commingsoon_page.dart';
import 'package:hyppe/ui/constant/widget/custom_empty_page.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/leaderboard/widget/button_challange.dart';
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
        child: Container(
          padding: EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              cn.isLoading
                  ? SizedBox(
                      height: SizeConfig.screenWidth,
                      width: SizeConfig.screenWidth,
                      child: const Center(
                        child: SizedBox(
                          height: 60,
                          child: CustomLoading(),
                        ),
                      ),
                    )
                  : cn.leaderBoardData?.onGoing == false
                      ? Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Center(
                            child: CustomCommingSoon(
                              title: '${tn.translate.letsJoinTheCompetition}',
                              subtitle: '${tn.translate.getFirstPlaceByEnteringThisExcitingCompetition}',
                            ),
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
                                              return Container(
                                                  // child: Text("${cn.leaderBoardData?.getlastrank?[index].score}"),
                                                  );
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
                                                    },
                                                    child: ItemLeader(data: cn.leaderBoardData?.getlastrank?[index], dataStatusLead: cn.leaderBoardData?.challengeData?[0].leaderBoard?[0]));
                                              }
                                            }
                                          },
                                        ),
                                      ),
                                    ),
              cn.isLoading
                  ? Container()
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: ButtonChallangeWidget(
                          bgColor: kHyppePrimary,
                          text: boollUser ? tn.translate.viewChallenge : tn.translate.joinTheChallengeNow,
                          function: () {
                            // print(cn.leaderBoardData?.challengeId);
                            Routing().move(Routes.chalengeDetail, argument: GeneralArgument(id: cn.leaderBoardData?.challengeId));
                          }),
                    ),
            ],
          ),
        ),
      );
    });
  }
}
