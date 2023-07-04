import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/leaderboard/widget/litem_leader.dart';

class ListOnGoing extends StatefulWidget {
  const ListOnGoing({super.key});

  @override
  State<ListOnGoing> createState() => _ListOnGoingState();
}

class _ListOnGoingState extends State<ListOnGoing> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          ScrollConfiguration(
            behavior: const ScrollBehavior().copyWith(overscroll: false),
            child: ListView.builder(
              itemCount: 10,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return ItemLeader();
              },
            ),
          ),
          Container(
            height: 20,
            color: kHyppeLightSurface,
          ),
          Text("hahahaha"),
        ],
      ),
    );
  }
}
