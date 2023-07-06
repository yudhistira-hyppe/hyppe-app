import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/search/search_content.dart';
import 'package:hyppe/ui/constant/widget/after_first_layout_mixin.dart';
import 'package:hyppe/ui/inner/search_v2/interest/widget/diary_scroll_screen.dart';
import 'package:hyppe/ui/inner/search_v2/interest/widget/pic_scroll_screen.dart';
import 'package:hyppe/ui/inner/search_v2/interest/widget/vid_scroll_screen.dart';
import 'package:hyppe/ui/inner/search_v2/notifier.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:measured_size/measured_size.dart';
import 'package:provider/provider.dart';

import '../../../../../core/constants/enum.dart';
import '../../../../../core/services/system.dart';
import '../../../../constant/widget/custom_loading.dart';
import '../../../../constant/widget/custom_text_widget.dart';
import '../../../home/content_v2/profile/widget/both_profile_content_shimmer.dart';
import '../../search_more_complete/widget/all_search_shimmer.dart';
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
      if (scrollController.offset >= scrollController.position.maxScrollExtent && !scrollController.position.outOfRange) {
        final fixContext = Routing.navigatorKey.currentContext ?? context;
        final notifier = fixContext.read<SearchNotifier>();
        final key = widget.interest.id ?? '';
        notifier.getDetailInterest(fixContext, key, reload: false, hyppe: currentType);
        switch(currentType){
          case HyppeType.HyppePic:
            if (!notifier.intHasNextPic) {
              notifier.getDetailInterest(Routing.navigatorKey.currentContext ?? context, widget.interest.id ?? '', reload: false, hyppe: HyppeType.HyppeVid);

            }
            break;
          case HyppeType.HyppeDiary:
            if (!notifier.intHasNextDiary) {
              notifier.getDetailInterest(Routing.navigatorKey.currentContext ?? context, widget.interest.id ?? '', reload: false, hyppe: HyppeType.HyppeVid);

            }
            break;
          case HyppeType.HyppeVid:
            if (!notifier.intHasNextVid) {
              notifier.getDetailInterest(Routing.navigatorKey.currentContext ?? context, widget.interest.id ?? '', reload: false, hyppe: HyppeType.HyppeVid);

            }
            break;
        }
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
      return Container(
                  color: context.getColorScheme().surface,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: AbsorbPointer(
                          absorbing: notifier.isZoom,
                          child: RefreshIndicator(
                            strokeWidth: 2.0,
                            color: context.getColorScheme().primary,
                            onRefresh: () => notifier.getDetailInterest(context, widget.interest.id ?? ''),
                            child: SingleChildScrollView(
                              controller: scrollController,
                              scrollDirection: Axis.vertical,
                              physics: notifier.isZoom && currentType == HyppeType.HyppePic ? const NeverScrollableScrollPhysics() : const AlwaysScrollableScrollPhysics(),
                              child: Column(
                                children: [
                                  MeasuredSize(
                                    onChange: (value){
                                      setState(() {
                                        heightTab = value.height;
                                      });
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(left: 16, right: 12, top: 10, bottom: 0),
                                      padding: const EdgeInsets.all(3),
                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), color: context.getColorScheme().background),
                                      child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: listTab.map((e) {
                                            final isActive = e == currentType;
                                            return Flexible(
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
                                  getLayout(data, notifier),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      loadingWidget(notifier)
                    ],
                  ),
                );
    });
  }

  Widget loadingWidget(SearchNotifier notifier){
    final type = currentType;


    switch (type) {
      case HyppeType.HyppeVid:
        return notifier.intHasNextVid
            ? const SizedBox(
          height: 50,
          child: Center(child: CustomLoading()),
        )
            : Container();
      case HyppeType.HyppeDiary:
        return notifier.intHasNextDiary
            ? const SizedBox(
          height: 50,
          child: Center(child: CustomLoading()),
        )
            : Container();
      case HyppeType.HyppePic:
        return notifier.intHasNextPic
            ? const SizedBox(
          height: 50,
          child: Center(child: CustomLoading()),
        )
            : Container();
    }
  }

  Widget getLayout(SearchContentModel? data, SearchNotifier notifier){
    final type = currentType;
    if (data != null) {
      switch (type) {
        case HyppeType.HyppeVid:
          if(notifier.loadIntDetailVid){
            return const AllSearchShimmer();
          }
          return data.vid.isNotNullAndEmpty() ? VidScrollScreen(interestKey: widget.interest.id ?? ''): SearchNoResultImage(locale: notifier.language, keyword: widget.interest.interestName ?? '');
        case HyppeType.HyppeDiary:
          if(notifier.loadIntDetailDiary){
            return const AllSearchShimmer();
          }
          return data.diary.isNotNullAndEmpty() ? DiaryScrollScreen(interestKey: widget.interest.id ?? ''): SearchNoResultImage(locale: notifier.language, keyword: widget.interest.interestName ?? '');
        case HyppeType.HyppePic:
          if(notifier.loadIntDetailPic){
            return const AllSearchShimmer();
          }
          return data.pict.isNotNullAndEmpty() ? PicScrollScreen(interestKey: widget.interest.id ?? ''): SearchNoResultImage(locale: notifier.language, keyword: widget.interest.interestName ?? '');
      }
    } else {
      return const AllSearchShimmer();
      return SearchNoResultImage(locale: notifier.language, keyword: widget.interest.interestName ?? '');
    }
  }
}
