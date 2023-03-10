import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/ui/inner/search_v2/notifier.dart';
import 'package:hyppe/ui/inner/search_v2/widget/search_no_result_image.dart';
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
  final scrollController;
  Tags hashtag;
  BottomDetail({Key? key, required this.hashtag, required this.scrollController}) : super(key: key);

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
            child: RefreshIndicator(
              strokeWidth: 2.0,
              color: context.getColorScheme().primary,
              onRefresh: () => notifier.getDetail(context, hashtag.tag ?? 'tag', TypeApiSearch.detailHashTag),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Builder(
                    builder: (context) {
                      final type = notifier.hashtagTab;
                      final vid = notifier.hashtagVid;
                      final diary = notifier.hashtagDiary;
                      final pic = notifier.hashtagPic;
                      // if(fixData != null){
                      //   switch(type){
                      //     case HyppeType.HyppeVid:
                      //       return fixData.vid.isNotNullAndEmpty() ? GridContentView(type: type, data: data?.vid ?? [], hasNext: notifier.hasNext,) : SearchNoResultImage(locale: notifier.language, keyword: hashtag.tag ?? '');
                      //     case HyppeType.HyppeDiary:
                      //       return fixData.diary.isNotNullAndEmpty() ? GridContentView(type: type, data: data?.diary ?? [], hasNext: notifier.hasNext,) : SearchNoResultImage(locale: notifier.language, keyword: hashtag.tag ?? '');
                      //     case HyppeType.HyppePic:
                      //       return fixData.pict.isNotNullAndEmpty() ? GridContentView(type: type, data: data?.pict ?? [], hasNext: notifier.hasNext,) : SearchNoResultImage(locale: notifier.language, keyword: hashtag.tag ?? '');
                      //   }
                      // }else{
                      //   return SearchNoResultImage(locale: notifier.language, keyword: hashtag.tag ?? '');
                      // }

                      switch(type){
                        case HyppeType.HyppeVid:
                          if(vid.isNotNullAndEmpty()){
                            return vid.isNotNullAndEmpty() ? GridContentView(type: type, data: vid ?? []) : SearchNoResultImage(locale: notifier.language, keyword: hashtag.tag ?? '');
                          }else{
                            return SearchNoResultImage(locale: notifier.language, keyword: hashtag.tag ?? '');
                          }

                        case HyppeType.HyppeDiary:
                          if(vid.isNotNullAndEmpty()){
                            return diary.isNotNullAndEmpty() ? GridContentView(type: type, data: diary ?? []) : SearchNoResultImage(locale: notifier.language, keyword: hashtag.tag ?? '');
                          }else{
                            return SearchNoResultImage(locale: notifier.language, keyword: hashtag.tag ?? '');
                          }

                        case HyppeType.HyppePic:
                          if(vid.isNotNullAndEmpty()){
                            return pic.isNotNullAndEmpty() ? GridContentView(type: type, data: pic ?? []) : SearchNoResultImage(locale: notifier.language, keyword: hashtag.tag ?? '');
                          }else{
                            return SearchNoResultImage(locale: notifier.language, keyword: hashtag.tag ?? '');
                          }
                      }

                    }
                ),
              ),
            ),
          )
        ],
      );
    });
  }


}

