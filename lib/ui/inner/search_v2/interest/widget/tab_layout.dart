import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/search/search_content.dart';
import 'package:hyppe/ui/constant/widget/after_first_layout_mixin.dart';
import 'package:hyppe/ui/inner/search_v2/notifier.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:measured_size/measured_size.dart';
import 'package:provider/provider.dart';

import '../../../../../core/constants/enum.dart';
import '../../../../../core/services/system.dart';
import '../../../../constant/widget/custom_spacer.dart';
import '../../../../constant/widget/custom_text_widget.dart';
import '../../../home/content_v2/profile/self_profile/widget/offline_mode.dart';
import '../../search_more_complete/widget/all_search_shimmer.dart';
import '../../widget/grid_content_view.dart';
import '../../widget/search_no_result_image.dart';

class InterestTabLayout extends StatefulWidget {
  // SearchContentModel data;
  Interest interest;
  // ScrollController scrollController;

  InterestTabLayout({Key? key, required this.interest}) : super(key: key);

  @override
  State<InterestTabLayout> createState() => _InterestTabLayoutState();
}

class _InterestTabLayoutState extends State<InterestTabLayout> with AfterFirstLayoutMixin {
  HyppeType currentType = HyppeType.HyppeVid;

  double heightTab = 0.0;
  // final _scrollController = ScrollController();
  final ScrollController scrollController = ScrollController();
  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'InterestTabLayout');
    currentType = HyppeType.HyppePic;
    final notifier = context.read<SearchNotifier>();
    notifier.initDetailInterest();
    super.initState();
    scrollController.addListener(() {
      print(scrollController.position.maxScrollExtent);
      if (scrollController.offset >= (scrollController.position.maxScrollExtent)) {
        final fixContext = Routing.navigatorKey.currentContext ?? context;
        final notifier = fixContext.read<SearchNotifier>();
        final key = widget.interest.id ?? '';
        notifier.getDetailInterest(fixContext, key, reload: false, hyppe: currentType);

        // final key = widget.interest.id;
        // final lenghtVid = notifier.interestContents[key]?.vid?.length ?? 0;
        // final lenghtDiary = notifier.interestContents[key]?.diary?.length ?? 0;
        // final lenghtPic = notifier.interestContents[key]?.pict?.length ?? 0;
        // final currentSkip =  currentType == HyppeType.HyppeVid ? lenghtVid :
        // currentType == HyppeType.HyppeDiary ? lenghtDiary : lenghtPic;
        // if(currentSkip%12 == 0){
        //   final hasNext = notifier.hasNext;
        //   if(!hasNext){
        //     notifier.getDetail(context, widget.interest.id ?? '', TypeApiSearch.detailInterest, reload: false, hyppe: currentType);
        //   }
        // }
      }
    });
  }

  @override
  void afterFirstLayout(BuildContext context) {
    final notifier = context.read<SearchNotifier>();
    notifier.getDetailInterest(context, widget.interest.id ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final listTab = [HyppeType.HyppePic, HyppeType.HyppeDiary, HyppeType.HyppeVid];
    return Consumer<SearchNotifier>(builder: (context, notifier, _) {
      final data = notifier.interestContents[widget.interest.id];
      print('size pic (${widget.interest.id}): ${data?.pict?.length}');
      return notifier.connectionError
          ? OfflineMode(
              function: () {
                notifier.checkConnection();
                notifier.getDetailInterest(context, widget.interest.id ?? '');
              },
            )
          : !notifier.loadIntDetail
              ? Container(
                  color: context.getColorScheme().surface,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      MeasuredSize(
                        onChange: (value){
                          if(mounted){
                            setState(() {
                              heightTab = value.height;
                            });
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.only(left: 16, right: 12, top: 10, bottom: 16),
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), color: context.getColorScheme().background),
                          child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: listTab.map((e) {
                                final isActive = e == currentType;
                                return Expanded(
                                  child: Material(
                                      color: Colors.transparent,
                                      child: Ink(
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: isActive ? context.getColorScheme().primary : context.getColorScheme().background,
                                          borderRadius: const BorderRadius.all(Radius.circular(18)),
                                        ),
                                        child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              currentType = e;
                                              scrollController..animateTo(0, duration: Duration(milliseconds: 70), curve: Curves.fastOutSlowIn);
                                            });
                                          },
                                          borderRadius: const BorderRadius.all(Radius.circular(18)),
                                          splashColor: context.getColorScheme().primary,
                                          child: Container(
                                            alignment: Alignment.center,
                                            height: 36,
                                            padding: const EdgeInsets.symmetric(horizontal: 16),
                                            decoration: const BoxDecoration(
                                              borderRadius: BorderRadius.all(Radius.circular(18)),
                                            ),
                                            child: CustomTextWidget(
                                              textToDisplay: System().getTitleHyppe(e),
                                              textStyle: context.getTextTheme().bodyText2?.copyWith(color: isActive ? context.getColorScheme().background : context.getColorScheme().secondary),
                                            ),
                                          ),
                                        ),
                                      )),
                                );
                              }).toList()),
                        ),
                      ),
                      Expanded(
                        child: RefreshIndicator(
                          strokeWidth: 2.0,
                          color: context.getColorScheme().primary,
                          onRefresh: () => notifier.getDetailInterest(context, widget.interest.id ?? ''),
                          child: SingleChildScrollView(
                            controller: scrollController,
                            physics: const ClampingScrollPhysics(),
                            child: Column(
                              children: [
                                Builder(builder: (context) {
                                  final type = currentType;
                                  if (data != null) {
                                    switch (type) {
                                      case HyppeType.HyppeVid:
                                        return data.vid.isNotNullAndEmpty()
                                            ? GridContentView(
                                                type: type,
                                                data: data.vid ?? [],
                                                isLoading: notifier.isHasNextVid,
                                                keyword: widget.interest.id ?? '',
                                                api: TypeApiSearch.detailInterest,
                                                controller: scrollController,
                                          heightTab: heightTab,
                                              )
                                            : SearchNoResultImage(locale: notifier.language, keyword: widget.interest.interestName ?? '');
                                      case HyppeType.HyppeDiary:
                                        return data.diary.isNotNullAndEmpty()
                                            ? GridContentView(
                                                type: type,
                                                data: data.diary ?? [],
                                                isLoading: notifier.isHasNextDiary,
                                                keyword: widget.interest.id ?? '',
                                                api: TypeApiSearch.detailInterest,
                                                controller: scrollController,
                                          heightTab: heightTab,
                                              )
                                            : SearchNoResultImage(locale: notifier.language, keyword: widget.interest.interestName ?? '');
                                      case HyppeType.HyppePic:
                                        return data.pict.isNotNullAndEmpty()
                                            ? GridContentView(
                                                type: type,
                                                data: data.pict ?? [],
                                                isLoading: notifier.isHasNextPic,
                                                keyword: widget.interest.id ?? '',
                                                api: TypeApiSearch.detailInterest,
                                                controller: scrollController,
                                          heightTab: heightTab,
                                              )
                                            : SearchNoResultImage(locale: notifier.language, keyword: widget.interest.interestName ?? '');
                                    }
                                  } else {
                                    return SearchNoResultImage(locale: notifier.language, keyword: widget.interest.interestName ?? '');
                                  }
                                }),
                                fortyPx
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              : const AllSearchShimmer();
    });
  }
}
