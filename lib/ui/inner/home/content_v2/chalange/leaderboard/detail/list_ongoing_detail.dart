import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
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
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class ListOnGoingDetail extends StatefulWidget {
  const ListOnGoingDetail({super.key});

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
        if (e.isUserLogin == true) {
          boollUser = true;
        }
        if (cn.leaderBoardData?.challengeData?[0].objectChallenge == "KONTEN") {
          if (e.postChallengess?.isNotEmpty ?? [].isEmpty) {
            participant++;
          }
        } else {
          participant++;
        }
      });
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
                children: [
                  // GestureDetector(
                  //     onTap: () {
                  //       ShowGeneralDialog.joinChallange(context, mounted, cn.leaderBoardDetailData?.challengeId ?? '');
                  //     },
                  //     child: Text("sdsd")),
                  cn.leaderBoardDetailData?.onGoing == false
                      ? const Padding(
                          padding: EdgeInsets.all(32.0),
                          child: CustomCommingSoon(
                            title: 'Yuk, Ikut Kompetisi Menarik',
                            subtitle: "Raih peringkat pertama dengan mengikuti kompetisi yang seru ini, yuk!",
                          ),
                        )
                      : cn.isLoadingLeaderboard
                          ? Container()
                          : cn.leaderBoardDetailData?.getlastrank?.isEmpty ?? [].isEmpty
                              ? const Padding(
                                  padding: EdgeInsets.all(32.0),
                                  child: CustomEmptyWidget(
                                    title: 'Belum ada Leaderboard Tersedia',
                                    subtitle: "Raih peringkat pertama dengan mengikuti kompetisi yang seru ini, yuk!",
                                  ),
                                )
                              : cn.leaderBoardDetailData?.getlastrank?[0].score == 0 || participant == 0
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
                                        padding: const EdgeInsets.symmetric(vertical: 24),
                                        child: ListView.builder(
                                          itemCount: cn.leaderBoardDetailData?.getlastrank?.length,
                                          shrinkWrap: true,
                                          physics: const NeverScrollableScrollPhysics(),
                                          itemBuilder: (context, index) {
                                            if (cn.leaderBoardData?.getlastrank?[index].score == 0) {
                                              return Container();
                                            } else {
                                              if (cn.leaderBoardDetailData?.challengeData?[0].objectChallenge == 'KONTEN') {
                                                return ContentLeaderboard(data: cn.leaderBoardDetailData?.getlastrank?[index]);
                                              } else {
                                                return ItemLeader(data: cn.leaderBoardDetailData?.getlastrank?[index]);
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
                                    if (!isloadingButton) {
                                      setState(() {
                                        isloadingButton = true;
                                      });
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
                                  }),
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
                    const Text(
                      "Deskripsi",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    twentyPx,
                    Text("${cn.leaderBoardDetailData?.challengeData?[0].description}"),
                  ],
                )),
            cn.leaderBoardDetailData?.onGoing == false || !boollUser || participant == 0
                ? Container()
                : Container(
                    width: SizeConfig.screenWidth,
                    margin: const EdgeInsets.only(top: 16, left: 16.0, right: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const FooterChallangeDetail(),
                  ),
          ],
        ),
      );
    });
  }
}
