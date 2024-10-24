import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/utils.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/search_v2/hashtag/widget/hashtag_item.dart';
import 'package:hyppe/ui/inner/search_v2/notifier.dart';
import 'package:provider/provider.dart';

import '../search_more_complete/widget/all_search_shimmer.dart';
import '../widget/search_no_result.dart';

class HashtagTabScreen extends StatefulWidget {
  const HashtagTabScreen({Key? key}) : super(key: key);

  @override
  State<HashtagTabScreen> createState() => _HashtagTabScreenState();
}

class _HashtagTabScreenState extends State<HashtagTabScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'HashtagTabScreen');
    _scrollController.addListener(() {
      if (_scrollController.offset >=
              _scrollController.position.maxScrollExtent &&
          !_scrollController.position.outOfRange) {
        final notifier = context.read<SearchNotifier>();
        final lenght = notifier.searchHashtag?.length;
        if (lenght != null) {
          if (lenght % 12 == 0) {
            notifier.getDataSearch(context,
                typeSearch: SearchLoadData.hashtag, reload: false, forceLoad: true);
          }
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchNotifier>(builder: (context, notifier, _) {
      final values = notifier.searchHashtag;
      // if (values != null) {
      //   for (final value in values) {
      //     print('searchHashtag data ${value.tag}');
      //   }
      // } else {
      //   print('searchHashtag data is null');
      // }

      // final keyword = notifier.searchController.text;

      return !notifier.isLoading ? Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomTextWidget(
              textToDisplay: notifier.language.hashtags ?? 'Hashtags',
              textStyle: context.getTextTheme().bodyText1?.copyWith(
                  color: context.getColorScheme().onBackground,
                  fontWeight: FontWeight.w700),
            ),
          ),
          values.isNotNullAndEmpty() ? Expanded(
              child: RefreshIndicator(
                          strokeWidth: 2.0,
                          color: context.getColorScheme().primary,
                          onRefresh: () => notifier.getDataSearch(context, forceLoad: true),
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            child: Column(
                              children: [
                                ...(List<Widget>.generate(
                                  notifier.searchHashtag?.length ?? 0,
                                  (int index) {
                                    final data = notifier.searchHashtag?[index];
                                    if (data != null) {
                                      return HashtagItem(
                                          onTap: () {
                                            notifier.selectedHashtag = data;
                                            if(notifier.layout == SearchLayout.searchMore){
                                              notifier.isFromComplete = true;
                                            }
                                            notifier.layout =
                                                SearchLayout.hashtagDetail;
                                          },
                                          title: '${data.tag}',
                                          count: data.total ?? 0,
                                          countContainer:
                                              notifier.language.posts ??
                                                  'Posts');
                                    } else {
                                      return const SizedBox.shrink();
                                    }
                                  },
                                ).toList()),
                                ...((notifier.searchHashtag?.length ?? 0) % limitSearch == 0
                                    ? [
                                        Container(
                                          width: double.infinity,
                                          height: 50,
                                          alignment: Alignment.center,
                                          child: const CustomLoading(),
                                        )
                                      ]
                                    : [])
                              ],
                            ),
                          ),
                        ),
              // ListView.builder(
              //             controller: _scrollController,
              //             itemCount: notifier.searchHashtag?.length ?? 0,
              //             itemBuilder: (context, index) {
              //               final data = notifier.searchHashtag?[index];
              //               if (data != null) {
              //                 return HashtagItem(
              //                     onTap: () {},
              //                     title: '#${data.tag}',
              //                     count: data.total ?? 0,
              //                     countContainer:
              //                         notifier.language.posts ?? 'Posts');
              //               }
              //             }),
              ): SearchNoResult(locale: notifier.language, keyword: notifier.searchController.text, margin: const EdgeInsets.only(left: 16),)
        ],
      ): const AllSearchShimmer();
    });
  }
}
