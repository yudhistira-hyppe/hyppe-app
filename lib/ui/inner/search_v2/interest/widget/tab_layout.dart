import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/search/search_content.dart';
import 'package:hyppe/ui/constant/widget/after_first_layout_mixin.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/inner/search_v2/notifier.dart';
import 'package:provider/provider.dart';

import '../../../../../core/constants/enum.dart';
import '../../../../../core/services/system.dart';
import '../../../../constant/widget/custom_text_widget.dart';
import '../../widget/grid_content_view.dart';
import '../../widget/search_no_result_image.dart';

class InterestTabLayout extends StatefulWidget {
  // SearchContentModel data;
  Interest interest;

  InterestTabLayout({Key? key, required this.interest}) : super(key: key);

  @override
  State<InterestTabLayout> createState() => _InterestTabLayoutState();
}

class _InterestTabLayoutState extends State<InterestTabLayout> with AfterFirstLayoutMixin{
  HyppeType currentType = HyppeType.HyppeVid;
  final _scrollController = ScrollController();

  @override
  void initState() {
    currentType = HyppeType.HyppeVid;
    _scrollController.addListener(() {
      if (_scrollController.offset >= _scrollController.position.maxScrollExtent && !_scrollController.position.outOfRange) {
        final notifier = context.read<SearchNotifier>();
        final key = widget.interest.id;
        final lenghtVid = notifier.interestContents[key]?.vid?.length ?? 0;
        final lenghtDiary = notifier.interestContents[key]?.diary?.length ?? 0;
        final lenghtPic = notifier.interestContents[key]?.diary?.length ?? 0;
        final currentSkip = [lenghtVid, lenghtDiary, lenghtPic].reduce(max);
        if(currentSkip%12 == 0){
          notifier.getDetail(context, widget.interest.id ?? '', TypeApiSearch.detailInterest, reload: false);
        }
      }
    });
    super.initState();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    final notifier = context.read<SearchNotifier>();
    notifier.getDetail(context, widget.interest.id ?? '', TypeApiSearch.detailInterest);
  }
  
  @override
  Widget build(BuildContext context) {
    final listTab = [
      HyppeType.HyppeVid,
      HyppeType.HyppeDiary,
      HyppeType.HyppePic
    ];
    return Consumer<SearchNotifier>(builder: (context, notifier, _) {
      final data = notifier.interestContents[widget.interest.id];
      return data != null ? Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(left: 16),
            child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: listTab.map((e) {
                  final isActive = e == currentType;
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
                            setState((){
                              currentType = e;
                            });

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
              onRefresh: () => notifier.getDetail(context, widget.interest.id ?? '', TypeApiSearch.detailInterest),
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Builder(
                    builder: (context) {
                      final type = currentType;
                      switch(type){
                        case HyppeType.HyppeVid:
                          return data.vid.isNotNullAndEmpty() ? GridContentView(type: type, data: data.vid ?? [], hasNext: notifier.hasNext,) : SearchNoResultImage(locale: notifier.language, keyword: widget.interest.interestName ?? '');
                        case HyppeType.HyppeDiary:
                          return data.diary.isNotNullAndEmpty() ? GridContentView(type: type, data: data.diary ?? [], hasNext: notifier.hasNext,) : SearchNoResultImage(locale: notifier.language, keyword: widget.interest.interestName ?? '');
                        case HyppeType.HyppePic:
                          return data.pict.isNotNullAndEmpty() ? GridContentView(type: type, data: data.pict ?? [], hasNext: notifier.hasNext,) : SearchNoResultImage(locale: notifier.language, keyword: widget.interest.interestName ?? '');
                      }
                    }
                ),
              ),
            ),
          )
        ],
      ) : const Center(child: CustomLoading(),);
    });
  }


}

