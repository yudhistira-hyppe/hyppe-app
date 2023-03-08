import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/ui/constant/widget/after_first_layout_mixin.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/inner/search_v2/hashtag/widget/hashtag_item.dart';
import 'package:hyppe/ui/inner/search_v2/hashtag/widget/shimmer.dart';
import 'package:hyppe/ui/inner/search_v2/notifier.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/size_config.dart';
import '../../../../core/constants/themes/hyppe_colors.dart';

class HashtagScreen extends StatefulWidget {
  const HashtagScreen({Key? key}) : super(key: key);

  @override
  State<HashtagScreen> createState() => _HashtagScreenState();
}

class _HashtagScreenState extends State<HashtagScreen> with AfterFirstLayoutMixin{
  @override
  void initState() {

    super.initState();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    // final notifier = Provider.of<SearchNotifier>(context, listen: false);
    // Future.delayed(Duration.zero, () => notifier.initHashTag(context));
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Consumer<SearchNotifier>(builder: (context, notifier, child) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
            child: Text(
              notifier.language.popularHashtag ?? 'Popular Hashtag',
              style: const TextStyle(
                  color: kHyppeLightSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold),
            ),
          ),
          eightPx,
          notifier.loadLandingPage
              ? ListView.builder(
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return const HashtagShimmer();
            },
            itemCount: 3,
          )
              : ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: 5,
              itemBuilder: (context, index) {
                return HashtagItem(
                  title: notifier.listHashtag?[index].tag ?? "",
                  count: notifier.listHashtag?[index].total ?? 0,
                  countContainer: notifier.language.posts ?? 'Posts',
                  onTap: () {
                    notifier.selectedHashtag = notifier.listHashtag?[index];
                    notifier.layout = SearchLayout.hashtagDetail;
                  },
                );})
        ],
      );
    });
  }


}
