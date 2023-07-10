import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
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
    return Consumer<ChallangeNotifier>(
      builder: (_, cn, __) => SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            cn.isLoadingLeaderboard
                ? Container()
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
            Container(
              height: 20,
              color: kHyppeLightSurface,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Text(
                "Challenge Utama",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SizedBox(
              height: 200,
              child: ListView.builder(
                itemCount: 10,
                scrollDirection: Axis.horizontal,
                shrinkWrap: false,
                itemBuilder: (context, index) {
                  return CardChalange();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
