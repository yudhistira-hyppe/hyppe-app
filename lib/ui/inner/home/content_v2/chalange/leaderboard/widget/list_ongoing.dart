import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/custom_commingsoon_page.dart';
import 'package:hyppe/ui/constant/widget/custom_empty_page.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/leaderboard/widget/button_challange.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/leaderboard/widget/card_chalange.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/leaderboard/widget/litem_leader.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/notifier.dart';
import 'package:provider/provider.dart';

class ListOnGoing extends StatefulWidget {
  const ListOnGoing({super.key});

  @override
  State<ListOnGoing> createState() => _ListOnGoingState();
}

class _ListOnGoingState extends State<ListOnGoing> {
  @override
  Widget build(BuildContext context) {
    // ChallangeNotifier cn = context.watch<ChallangeNotifier>();
    return Consumer<ChallangeNotifier>(builder: (_, cn, __) {
      var dateChallange = System().compareDate(cn.leaderBoardData?.startDatetime ?? '', cn.leaderBoardData?.endDatetime ?? '');
      return SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            dateChallange[0] == false && cn.leaderBoardData?.session == 1
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
                    print('hahahaha');
                  }),
            ),
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
                  return CardChalange(
                    data: cn.listChallangeData[index],
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }
}
