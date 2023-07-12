import 'package:flutter/material.dart';
import 'package:hyppe/core/arguments/general_argument.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/show_general_dialog.dart';
import 'package:hyppe/ui/constant/widget/custom_commingsoon_page.dart';
import 'package:hyppe/ui/constant/widget/custom_empty_page.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/leaderboard/widget/button_challange.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/leaderboard/widget/card_chalange.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/leaderboard/widget/litem_leader.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class ListOnGoingDetail extends StatefulWidget {
  const ListOnGoingDetail({super.key});

  @override
  State<ListOnGoingDetail> createState() => _ListOnGoingDetailState();
}

class _ListOnGoingDetailState extends State<ListOnGoingDetail> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ChallangeNotifier>(builder: (_, cn, __) {
      return SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            cn.leaderBoardData?.onGoing == true && cn.leaderBoardData?.session == 1
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
                  text: "Yuk, Join Challenge Sekarang",
                  function: () {
                    ShowGeneralDialog.joinChallange(context);
                  }),
            ),
          ],
        ),
      );
    });
  }
}
