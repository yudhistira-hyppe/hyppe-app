import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/search_v2/notifier.dart';
import 'package:hyppe/ui/inner/search_v2/widget/grid_content_view.dart';
import 'package:provider/provider.dart';

import '../../widget/search_no_result_image.dart';

class SearchContentsTab extends StatefulWidget {
  const SearchContentsTab({Key? key}) : super(key: key);

  @override
  State<SearchContentsTab> createState() => _SearchContentsTabState();
}

class _SearchContentsTabState extends State<SearchContentsTab> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _scrollController.addListener(() {
      if (_scrollController.offset >= _scrollController.position.maxScrollExtent && !_scrollController.position.outOfRange) {
        print('_SearchContentsTabState test ');
        final notifier = context.read<SearchNotifier>();
        final lenghtVid = notifier.searchVid?.length ?? 0;
        final lenghtDiary = notifier.searchDiary?.length ?? 0;
        final lenghtPic = notifier.searchPic?.length ?? 0;
        final currentSkip = [lenghtVid, lenghtDiary, lenghtPic].reduce(max);
        if(currentSkip%12 == 0){
          notifier.getDataSearch(context, typeSearch: SearchLoadData.content, reload: false);
        }


      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final listTab = [
      HyppeType.HyppeVid,
      HyppeType.HyppeDiary,
      HyppeType.HyppePic
    ];
    return Consumer<SearchNotifier>(builder: (context, notifier, _) {
      final language = notifier.language;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(left: 16, top: 16),
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 16),
            child: CustomTextWidget(
              textToDisplay: language.contents ?? 'Contents',
              textStyle: context.getTextTheme().bodyText1?.copyWith(color: context.getColorScheme().onBackground, fontWeight: FontWeight.w700),
              textAlign: TextAlign.start,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 16),
            child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: listTab.map((e) {
                  final isActive = e == notifier.contentTab;
                  return Container(
                    margin:
                    const EdgeInsets.only(right: 12, top: 10, bottom: 16),
                    child: Material(
                      color: Colors.transparent,
                      child: Ink(
                        height: 36,
                        decoration: BoxDecoration(
                          color: isActive
                              ? context.getColorScheme().primary
                              : context.getColorScheme().background,
                          borderRadius:
                          const BorderRadius.all(Radius.circular(18)),
                        ),
                        child: InkWell(
                          onTap: () {
                            notifier.contentTab = e;
                          },
                          borderRadius: const BorderRadius.all(Radius.circular(18)),
                          splashColor: context.getColorScheme().primary,
                          child: Container(
                            alignment: Alignment.center,
                            height: 36,
                            padding: const EdgeInsets.symmetric( horizontal: 16),
                            decoration: BoxDecoration(
                                borderRadius:
                                const BorderRadius.all(Radius.circular(18)),
                                border: !isActive
                                    ? Border.all(
                                    color:
                                    context.getColorScheme().secondary,
                                    width: 1)
                                    : null),
                            child: CustomTextWidget(
                              textToDisplay:
                              System().getTitleHyppe(e),
                              textStyle: context.getTextTheme().bodyText2?.copyWith(color: isActive ? context.getColorScheme().background : context.getColorScheme().secondary),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList()),
          ),
          Expanded(
            child: RefreshIndicator(
              strokeWidth: 2.0,
              color: context.getColorScheme().primary,
              onRefresh: () => notifier.getDataSearch(context),
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Builder(
                  builder: (context) {
                    final type = notifier.contentTab;
                    switch(type){
                      case HyppeType.HyppeVid:
                        return notifier.searchVid.isNotNullAndEmpty() ? GridContentView(type: type, data: notifier.searchVid ?? [], hasNext: notifier.hasNext,) : SearchNoResultImage(locale: notifier.language, keyword: notifier.searchController.text,);
                      case HyppeType.HyppeDiary:
                        return notifier.searchDiary.isNotNullAndEmpty() ? GridContentView(type: type, data: notifier.searchDiary ?? [], hasNext: notifier.hasNext) : SearchNoResultImage(locale: notifier.language, keyword: notifier.searchController.text);
                      case HyppeType.HyppePic:
                        return notifier.searchPic.isNotNullAndEmpty() ? GridContentView(type: type, data: notifier.searchPic ?? [], hasNext: notifier.hasNext) : SearchNoResultImage(locale: notifier.language, keyword: notifier.searchController.text);
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
