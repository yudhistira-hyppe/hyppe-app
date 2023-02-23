import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/ui/inner/search_v2/notifier.dart';
import 'package:provider/provider.dart';

import 'contents_screen.dart';
import 'hastag_tab.dart';

class BottomDetail extends StatefulWidget {
  const BottomDetail({Key? key}) : super(key: key);

  @override
  State<BottomDetail> createState() => _BottomDetailState();
}

class _BottomDetailState extends State<BottomDetail> {
  @override
  Widget build(BuildContext context) {
    return Consumer<SearchNotifier>(builder: (context, notifier, _) {
      return SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 64,
              child: Row(
                children: [
                  Expanded(
                      child: HashtagTab(
                    onTap: (value) {
                      notifier.hashtagTab = value;
                    },
                    isActive: notifier.hashtagTab == HyppeType.HyppeVid,
                    type: HyppeType.HyppeVid,
                  )),
                  Expanded(
                      child: HashtagTab(
                          onTap: (value) {
                            notifier.hashtagTab = value;
                          },
                          isActive: notifier.hashtagTab == HyppeType.HyppeDiary,
                          type: HyppeType.HyppeDiary)),
                  Expanded(
                      child: HashtagTab(
                          onTap: (value) {
                            notifier.hashtagTab = value;
                          },
                          isActive: notifier.hashtagTab == HyppeType.HyppePic,
                          type: HyppeType.HyppePic)),
                ],
              ),
            ),
            Container(
              height: 500,
              child: HashtagContentsScreen(
                type: notifier.hashtagTab,
              ),
            )
          ],
        ),
      );
    });
  }
}
