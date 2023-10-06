import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/widget/custom_commingsoon_page.dart';
import 'package:hyppe/ui/constant/widget/custom_empty_page.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/leaderboard/widget/content_leader.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/leaderboard/widget/litem_leader.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/notifier.dart';
import 'package:provider/provider.dart';

class ListEnd extends StatefulWidget {
  const ListEnd({super.key});

  @override
  State<ListEnd> createState() => _ListEndState();
}

class _ListEndState extends State<ListEnd> {
  @override
  Widget build(BuildContext context) {
    TranslateNotifierV2 tn = context.read<TranslateNotifierV2>();
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
                // margin: EdgeInsets.all(16),
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                decoration: BoxDecoration(color: Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(4)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${tn.translate.challengePeriod} ${cn.selectOptionSession}',
                      style: const TextStyle(
                        color: Color(0xFF9B9B9B),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: kHyppeTextLightPrimary,
                    )
                  ],
                ),
              ),
            ),
            cn.leaderBoardEndData?.onGoing == false
                ? Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: CustomEmptyWidget(
                      title: '${tn.translate.theresNoLeaderboardAvailable}',
                      subtitle: '${tn.translate.getFirstPlaceByFollowingThisExciting}',
                    ),
                  )
                : cn.isLoadingLeaderboard
                    ? Container()
                    : (cn.leaderBoardEndData?.getlastrank?.isEmpty ?? [].isEmpty) || cn.leaderBoardEndData?.status == "BERLANGSUNG"
                        ? Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: CustomEmptyWidget(
                              title: '${tn.translate.theresNoLeaderboardAvailable}',
                              subtitle: '${tn.translate.getFirstPlaceByFollowingThisExciting}',
                            ),
                          )
                        : cn.leaderBoardEndData?.getlastrank?[0].score == 0 || participant == 0
                            ? Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: CustomEmptyWidget(
                                  title: '${tn.translate.theresNoLeaderboardAvailable}',
                                  subtitle: '${tn.translate.getFirstPlaceByFollowingThisExciting}',
                                ),
                              )
                            : ScrollConfiguration(
                                behavior: const ScrollBehavior().copyWith(overscroll: false),
                                child: ListView.builder(
                                  itemCount: cn.leaderBoardEndData?.getlastrank?.length,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    if (cn.leaderBoardEndData?.getlastrank?[index].score == 0) {
                                      return Container();
                                    } else {
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
                                              System().navigateToProfile(context, cn.leaderBoardEndData?.getlastrank?[index].email ?? '');
                                              // Routing().move(Routes.otherProfile, argument: OtherProfileArgument(senderEmail: cn.leaderBoardEndData?.getlastrank?[index].email));
                                            },
                                            child: ItemLeader(
                                              data: cn.leaderBoardEndData?.getlastrank?[index],
                                              dataStatusLead: cn.leaderBoardEndData?.challengeData?[0].leaderBoard?[0],
                                            ));
                                      }
                                    }
                                  },
                                ),
                              ),
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            //   child: ButtonChallangeWidget(
            //       bgColor: kHyppePrimary,
            //       text: "Yuk, Join Challenge Sekarang",
            //       function: () {
            //         // print(cn.leaderBoardEndData?.challengeId);
            //         Routing().move(Routes.chalengeDetail, argument: GeneralArgument(id: cn.leaderBoardEndData?.challengeId));
            //       }),
            // ),
            // cn.listChallangeData.isEmpty
            //     ? Container()
            //     : Column(
            //         crossAxisAlignment: CrossAxisAlignment.start,
            //         children: [
            //           Container(
            //             height: 20,
            //             color: kHyppeLightSurface,
            //           ),
            //           Container(
            //             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            //             child: Text(
            //               tn.translate.joinOtherInterestingChallenges ?? '',
            //               style: TextStyle(
            //                 fontSize: 14,
            //                 fontWeight: FontWeight.w700,
            //               ),
            //             ),
            //           ),
            //           SizedBox(
            //             height: 200,
            //             child: ListView.builder(
            //               itemCount: cn.listChallangeData.length,
            //               scrollDirection: Axis.horizontal,
            //               shrinkWrap: false,
            //               itemBuilder: (context, index) {
            //                 var dateText = "";
            //                 if (cn.listChallangeData[index].onGoing == true) {
            //                   dateText = "${tn.translate.endsIn} ${cn.listChallangeData[index].totalDays} ${tn.translate.hariLagi}";
            //                 } else {
            //                   dateText = "${tn.translate.startIn} ${cn.listChallangeData[index].totalDays} ${tn.translate.hariLagi}";
            //                 }
            //                 return CardChalange(
            //                   data: cn.listChallangeData[index],
            //                   dateText: dateText,
            //                 );
            //               },
            //             ),
            //           ),
            //         ],
            //       ),
          ],
        ),
      );
    });
  }
}
