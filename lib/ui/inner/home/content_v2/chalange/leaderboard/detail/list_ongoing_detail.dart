import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/show_general_dialog.dart';
import 'package:hyppe/ui/constant/widget/custom_commingsoon_page.dart';
import 'package:hyppe/ui/constant/widget/custom_empty_page.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/leaderboard/detail/footer_detail.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/leaderboard/widget/button_challange.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/leaderboard/widget/litem_leader.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/notifier.dart';
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
    return Consumer<ChallangeNotifier>(builder: (_, cn, __) {
      return SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 16, left: 16.0, right: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
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
                              : ScrollConfiguration(
                                  behavior: const ScrollBehavior().copyWith(overscroll: false),
                                  child: ListView.builder(
                                    itemCount: cn.leaderBoardData?.getlastrank?.length,
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      return ItemLeader(data: cn.leaderBoardData?.getlastrank?[index]);
                                    },
                                  ),
                                ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                    child: ButtonChallangeWidget(
                        bgColor: kHyppePrimary,
                        text: "Ikuti Challange",
                        isloading: false,
                        function: () async {
                          if (!isloadingButton) {
                            isloadingButton = true;
                            await cn.joinChallange(context, cn.leaderBoardData?.challengeId ?? '').then((value) {
                              if (value == true) {
                                isloadingButton = false;
                                ShowGeneralDialog.joinChallange(context).then((value) => print("kelar om")).whenComplete(() {
                                  cn.initLeaderboardDetail(context, cn.leaderBoardData?.challengeId ?? '');
                                });
                              } else {
                                isloadingButton = false;
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
                    Text(
                      "Deskripsi",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    twentyPx,
                    Text("${cn.leaderBoardData?.challengeData?[0].description}"),
                  ],
                )),
            Container(
                width: SizeConfig.screenWidth,
                margin: const EdgeInsets.only(top: 16, left: 16.0, right: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: FooterChallangeDetail()),
          ],
        ),
      );
    });
  }
}