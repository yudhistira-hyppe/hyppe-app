import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/show_general_dialog.dart';
import 'package:hyppe/ui/constant/widget/custom_commingsoon_page.dart';
import 'package:hyppe/ui/constant/widget/custom_empty_page.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/leaderboard/detail/footer_detail.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/leaderboard/widget/button_challange.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/leaderboard/widget/content_leader.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/leaderboard/widget/litem_leader.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/notifier.dart';
import 'package:provider/provider.dart';

class ListOnGoingDetail extends StatefulWidget {
  final GlobalKey<NestedScrollViewState>? globalKey;
  const ListOnGoingDetail({super.key, this.globalKey});

  @override
  State<ListOnGoingDetail> createState() => _ListOnGoingDetailState();
}

class _ListOnGoingDetailState extends State<ListOnGoingDetail> {
  bool isloadingButton = false;

  @override
  Widget build(BuildContext context) {
    TranslateNotifierV2 tn = context.read<TranslateNotifierV2>();
    return Consumer<ChallangeNotifier>(builder: (_, cn, __) {
      var boollUser = false;
      var participant = 0;
      cn.leaderBoardDetailData?.getlastrank?.forEach((e) {
        // print("=hahaha=");
        if (e.isUserLogin == true) {
          boollUser = true;
        }
        if (cn.leaderBoardDetailData?.challengeData?[0].objectChallenge == "KONTEN") {
          if (e.postChallengess?.isNotEmpty ?? [].isEmpty) {
            participant++;
          }
        } else {
          // print("=hihihi= ${participant++}");
          participant++;
        }
      });
      if (cn.newJoinChallenge) {
        Future.delayed(const Duration(milliseconds: 400), () {
          widget.globalKey?.currentState?.innerController.animateTo(
            widget.globalKey?.currentState?.innerController.position.maxScrollExtent ?? 1000,
            duration: const Duration(milliseconds: 500),
            curve: Curves.ease,
          );
          cn.newJoinChallenge = false;
        });
      }
      return SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            cn.leaderBoardDetailData?.onGoing == false
                ? Container()
                : Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
                    ),
                    child: Column(
                      children: [
                        // GestureDetector(
                        //     onTap: () {
                        //       ShowGeneralDialog.joinChallange(context, mounted, cn.leaderBoardDetailData?.challengeId ?? '');
                        //     },
                        //     child: Text("sdsd")),
                        cn.isLoadingLeaderboard
                            ? Container()
                            : cn.leaderBoardDetailData?.getlastrank?.isEmpty ?? [].isEmpty
                                ? Padding(
                                    padding: const EdgeInsets.all(32.0),
                                    child: CustomEmptyWidget(
                                      title: tn.translate.theresNoLeaderboardAvailable ?? 'Belum ada Leaderboard Tersedia',
                                      subtitle: tn.translate.getFirstPlaceByFollowingThisExciting ?? "Raih peringkat pertama dengan mengikuti kompetisi yang seru ini, yuk!",
                                    ),
                                  )
                                : cn.leaderBoardDetailData?.getlastrank?[0].score == 0 || participant == 0
                                    ? Padding(
                                        padding: const EdgeInsets.all(32.0),
                                        child: CustomEmptyWidget(
                                          title: tn.translate.theresNoLeaderboardAvailable ?? 'Belum ada Leaderboard Tersedia',
                                          subtitle: tn.translate.getFirstPlaceByFollowingThisExciting ?? "Raih peringkat pertama dengan mengikuti kompetisi yang seru ini, yuk!",
                                        ),
                                      )
                                    : ScrollConfiguration(
                                        behavior: const ScrollBehavior().copyWith(overscroll: false),
                                        child: Padding(
                                          padding: const EdgeInsets.only(bottom: 24),
                                          child: ListView.builder(
                                            itemCount: cn.leaderBoardDetailData?.getlastrank?.length,
                                            shrinkWrap: true,
                                            physics: const NeverScrollableScrollPhysics(),
                                            itemBuilder: (context, index) {
                                              if (cn.leaderBoardDetailData?.getlastrank?[index].score == 0) {
                                                return Container();
                                              } else {
                                                if (cn.leaderBoardDetailData?.challengeData?[0].objectChallenge == 'KONTEN') {
                                                  return GestureDetector(
                                                      onTap: () {
                                                        var post = cn.leaderBoardDetailData?.getlastrank?[index].postChallengess?[0];
                                                        var email = cn.leaderBoardDetailData?.getlastrank?[index].email;
                                                        cn.navigateToScreen(context, post?.index, email, post?.postType);
                                                      },
                                                      child: ContentLeaderboard(data: cn.leaderBoardDetailData?.getlastrank?[index]));
                                                } else {
                                                  return GestureDetector(
                                                      onTap: () {
                                                        System().navigateToProfile(context, cn.leaderBoardDetailData?.getlastrank?[index].email ?? '');
                                                      },
                                                      child: ItemLeader(
                                                        data: cn.leaderBoardDetailData?.getlastrank?[index],
                                                        dataStatusLead: cn.leaderBoardDetailData?.challengeData?[0].leaderBoard?[0],
                                                      ));
                                                }
                                              }

                                              // return ItemLeader(data: cn.leaderBoardDetailData?.getlastrank?[index]);
                                            },
                                          ),
                                        ),
                                      ),
                        cn.leaderBoardDetailData?.onGoing == false
                            ? Container()
                            : boollUser
                                ? Container()
                                : Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                                    child: ButtonChallangeWidget(
                                      bgColor: cn.leaderBoardDetailData?.joined == 'NOT ALLOWED' ? kHyppeBottomNavBarIcon : kHyppePrimary,
                                      text: "${tn.translate.joinTheChallengeNow}",
                                      isloading: isloadingButton,
                                      function: () async {
                                        if (cn.leaderBoardDetailData?.joined != 'NOT ALLOWED') {
                                          if (!isloadingButton) {
                                            setState(() {
                                              isloadingButton = true;
                                            });
                                            print(cn.leaderBoardDetailData?.joined);
                                            await cn.joinChallange(context, cn.leaderBoardDetailData?.challengeId ?? '').then((value) {
                                              if (value == true) {
                                                setState(() {
                                                  isloadingButton = false;
                                                });
                                                ShowGeneralDialog.joinChallange(context, mounted, cn.leaderBoardDetailData?.challengeId ?? '').then((value) => print("kelar om")).whenComplete(() {
                                                  // cn.initLeaderboardDetail(context, mounted, cn.leaderBoardDetailData?.challengeId ?? '');
                                                });
                                              } else {
                                                setState(() {
                                                  isloadingButton = false;
                                                });
                                              }
                                            });
                                          }
                                        }
                                      },
                                    ),
                                  ),
                      ],
                    ),
                  ),
          ],
        ),
      );
    });
  }
}
