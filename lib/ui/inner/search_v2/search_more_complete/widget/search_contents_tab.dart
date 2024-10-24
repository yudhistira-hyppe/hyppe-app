import 'dart:math';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/search_v2/notifier.dart';
import 'package:hyppe/ui/inner/search_v2/widget/grid_content_view.dart';
import 'package:measured_size/measured_size.dart';
import 'package:provider/provider.dart';

import '../../../../../core/services/route_observer_service.dart';
import '../../widget/search_no_result.dart';
import '../../widget/search_no_result_image.dart';
import 'all_search_shimmer.dart';

class SearchContentsTab extends StatefulWidget {
  final String keyword;
  const SearchContentsTab({Key? key, required this.keyword}) : super(key: key);

  @override
  State<SearchContentsTab> createState() => _SearchContentsTabState();
}

class _SearchContentsTabState extends State<SearchContentsTab> with RouteAware {
  final ScrollController _scrollController = ScrollController();
  double heightTab = 0;

  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'AllSearchShimmer');
    _scrollController.addListener(() {
      if (_scrollController.offset >= _scrollController.position.maxScrollExtent && !_scrollController.position.outOfRange) {
        print('_SearchContentsTabState test ');
        final notifier = context.read<SearchNotifier>();
        final lenghtVid = notifier.searchVid?.length ?? 0;
        final lenghtDiary = notifier.searchDiary?.length ?? 0;
        final lenghtPic = notifier.searchPic?.length ?? 0;
        final currentSkip = [lenghtVid, lenghtDiary, lenghtPic].reduce(max);
        if (currentSkip % 12 == 0) {
          notifier.getDataSearch(context, typeSearch: SearchLoadData.content, reload: false, forceLoad: true);
        }
      }
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    CustomRouteObserver.routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
    super.didChangeDependencies();
  }

  @override
  void didPopNext() {
    super.didPopNext();
  }

  @override
  void didPop() {
    print("==========pop===========");
    super.didPop();
  }

  @override
  void didPushNext() {
    print("========= didPushNext prfile =====");
    super.didPushNext();
  }

  @override
  Widget build(BuildContext context) {
    final listTab = [
      HyppeType.HyppePic,
      // HyppeType.HyppeDiary,
      HyppeType.HyppeVid
    ];
    return Consumer<SearchNotifier>(builder: (context, notifier, _) {
      final language = notifier.language;
      final isAllEmpty = !notifier.searchVid.isNotNullAndEmpty() && !notifier.searchDiary.isNotNullAndEmpty() && !notifier.searchPic.isNotNullAndEmpty();
      print('isAllEmty: $isAllEmpty');
      return !notifier.isLoading
          ? Column(
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
                Expanded(
                    child: isAllEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: SearchNoResult(
                              locale: notifier.language,
                              keyword: notifier.searchController.text,
                            ),
                          )
                        : MeasuredSize(
                            onChange: (value) {
                              if (mounted) {
                                setState(() {
                                  heightTab = value.height;
                                });
                              }
                            },
                            child: Column(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(left: 16),
                                  child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: listTab.map((e) {
                                        final isActive = e == notifier.contentTab;
                                        return Expanded(
                                          child: Container(
                                            margin: const EdgeInsets.only(right: 12, top: 10, bottom: 16),
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
                                                    notifier.contentTab = e;
                                                  },
                                                  borderRadius: const BorderRadius.all(Radius.circular(18)),
                                                  splashColor: context.getColorScheme().primary,
                                                  child: Container(
                                                    alignment: Alignment.center,
                                                    height: 36,
                                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                                    decoration: BoxDecoration(
                                                        borderRadius: const BorderRadius.all(Radius.circular(18)),
                                                        border: !isActive ? Border.all(color: context.getColorScheme().secondary, width: 1) : null),
                                                    child: CustomTextWidget(
                                                      textToDisplay: System().getTitleHyppe(e),
                                                      textStyle: context.getTextTheme().bodyText2?.copyWith(color: isActive ? context.getColorScheme().background : context.getColorScheme().secondary),
                                                    ),
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
                                    onRefresh: () => notifier.getDataSearch(context, forceLoad: true),
                                    child: SingleChildScrollView(
                                      controller: _scrollController,
                                      child: Builder(builder: (context) {
                                        final type = notifier.contentTab;
                                        switch (type) {
                                          case HyppeType.HyppeVid:
                                            return notifier.searchVid.isNotNullAndEmpty()
                                                ? GridContentView(
                                                    type: type,
                                                    data: notifier.searchVid ?? [],
                                                    isLoading: notifier.isHasNextVid,
                                                    keyword: widget.keyword,
                                                    api: TypeApiSearch.normal,
                                                    controller: _scrollController,
                                                    heightTab: heightTab,
                                                  )
                                                : SearchNoResultImage(
                                                    locale: notifier.language,
                                                    keyword: notifier.searchController.text,
                                                  );
                                          case HyppeType.HyppeDiary:
                                            return notifier.searchDiary.isNotNullAndEmpty()
                                                ? GridContentView(
                                                    type: type,
                                                    data: notifier.searchDiary ?? [],
                                                    isLoading: notifier.isHasNextDiary,
                                                    keyword: widget.keyword,
                                                    api: TypeApiSearch.normal,
                                                    controller: _scrollController,
                                                    heightTab: heightTab)
                                                : SearchNoResultImage(locale: notifier.language, keyword: notifier.searchController.text);
                                          case HyppeType.HyppePic:
                                            return notifier.searchPic.isNotNullAndEmpty()
                                                ? GridContentView(
                                                    type: type,
                                                    data: notifier.searchPic ?? [],
                                                    isLoading: notifier.isHasNextPic,
                                                    keyword: widget.keyword,
                                                    api: TypeApiSearch.normal,
                                                    controller: _scrollController,
                                                    heightTab: heightTab)
                                                : SearchNoResultImage(locale: notifier.language, keyword: notifier.searchController.text);
                                        }
                                      }),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ))
              ],
            )
          : const AllSearchShimmer();
    });
  }
}
