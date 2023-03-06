import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/ui/inner/search_v2/notifier.dart';
import 'package:provider/provider.dart';

import '../../../../../core/models/collection/search/search_content.dart';
import '../../widget/grid_content_view.dart';
import 'hastag_tab.dart';

// class BottomDetail extends StatefulWidget {
//   SearchContentModel data;
//   BottomDetail({Key? key, required this.data}) : super(key: key);
//
//   @override
//   State<BottomDetail> createState() => _BottomDetailState();
// }
//
// class _BottomDetailState extends State<BottomDetail> {
//   @override
//   Widget build(BuildContext context) {
//     return
//   }
// }

class BottomDetail extends StatelessWidget {
  SearchContentModel? data;
  BottomDetail({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchNotifier>(builder: (context, notifier, _) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
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
                      // data: data.vid ?? [],
                      type: HyppeType.HyppeVid,
                    )),
                Expanded(
                    child: HashtagTab(
                        onTap: (value) {
                          notifier.hashtagTab = value;
                        },
                        isActive: notifier.hashtagTab == HyppeType.HyppeDiary,
                        // data: data.diary ?? [],
                        type: HyppeType.HyppeDiary)),
                Expanded(
                    child: HashtagTab(
                        onTap: (value) {
                          notifier.hashtagTab = value;
                        },
                        isActive: notifier.hashtagTab == HyppeType.HyppePic,
                        // data: data.pict ?? [],
                        type: HyppeType.HyppePic)),
              ],
            ),
          ),
          Expanded(
            child: Builder(
                builder: (context) {
                  final type = notifier.hashtagTab;
                  switch(type){
                    case HyppeType.HyppeVid:
                      return GridContentView(type: type, data: notifier.searchVid ?? []);
                    case HyppeType.HyppeDiary:
                      return GridContentView(type: type, data: notifier.searchDiary ?? []);
                    case HyppeType.HyppePic:
                      return GridContentView(type: type, data: notifier.searchPic ?? []);
                  }
                }
            ),
          )
        ],
      );
    });
  }


}

