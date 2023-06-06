import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/other_profile/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/notifier.dart';
import 'package:provider/provider.dart';

import '../../../../search_v2/notifier.dart';

class ScrollDiaryNotifier with ChangeNotifier {
  bool isLoadingLoadmore = false;
  List<ContentData>? diaryData = [];

  Future loadMore(BuildContext context, ScrollController scrollController, PageSrc pageSrc, String key) async {
    if (pageSrc == PageSrc.selfProfile) {
      final sp = context.read<SelfProfileNotifier>();
      sp.pageIndex = 1;
      await sp.onScrollListener(context, scrollController, isLoad: true);
      diaryData = sp.user.diaries;
      notifyListeners();
    }

    if (pageSrc == PageSrc.otherProfile) {
      final op = context.read<OtherProfileNotifier>();
      op.pageIndex = 1;
      await op.onScrollListener(context, scrollController, isLoad: true);
      diaryData = op.user.diaries;
      notifyListeners();
    }

    final searchNotifier = context.read<SearchNotifier>();

    if(pageSrc == PageSrc.searchData){
      final data = await searchNotifier.getDetailContents(context, key, HyppeType.HyppeDiary, TypeApiSearch.normal, 12, skip: searchNotifier.searchDiary?.length ?? 0);
      searchNotifier.searchDiary?.addAll(data);
      diaryData = searchNotifier.searchDiary;
      isLoadingLoadmore = false;
    }

    if(pageSrc == PageSrc.hashtag){
      final data = await searchNotifier.getDetailContents(context, key, HyppeType.HyppeDiary, TypeApiSearch.detailHashTag, 12, skip: searchNotifier.mapDetailHashtag[key]?.diary?.length ?? 0);
      searchNotifier.mapDetailHashtag[key]?.diary?.addAll(data);
      diaryData = searchNotifier.mapDetailHashtag[key]?.diary;
      isLoadingLoadmore = false;
    }

    if(pageSrc == PageSrc.interest){
      final data = await searchNotifier.getDetailContents(context, key, HyppeType.HyppeDiary, TypeApiSearch.detailHashTag, 12, skip: searchNotifier.interestContents[key]?.diary?.length ?? 0);
      searchNotifier.interestContents[key]?.diary?.addAll(data);
      diaryData = searchNotifier.interestContents[key]?.diary;
      isLoadingLoadmore = false;
    }
  }

  Future reload(BuildContext context, PageSrc pageSrc, {String key = ""}) async {
    if (pageSrc == PageSrc.selfProfile) {
      final sp = context.read<SelfProfileNotifier>();
      sp.pageIndex = 0;
      await sp.getDataPerPgage(context, isReload: true);
      diaryData = sp.user.diaries;
      isLoadingLoadmore = false;
      notifyListeners();
    }

    if (pageSrc == PageSrc.otherProfile) {
      final op = context.read<OtherProfileNotifier>();
      op.pageIndex = 0;
      await op.initialOtherProfile(context, refresh: true);
      diaryData = op.user.diaries;
      isLoadingLoadmore = false;
      notifyListeners();
    }

    final searchNotifier = context.read<SearchNotifier>();

    if(pageSrc == PageSrc.searchData){
      final data = await searchNotifier.getDetailContents(context, key, HyppeType.HyppeDiary, TypeApiSearch.normal, 12);
      searchNotifier.searchDiary = data;
      diaryData = searchNotifier.searchDiary;
      isLoadingLoadmore = false;
    }

    if(pageSrc == PageSrc.hashtag){
      final data = await searchNotifier.getDetailContents(context, key, HyppeType.HyppeDiary, TypeApiSearch.detailHashTag, 12);
      searchNotifier.mapDetailHashtag[key]?.diary = data;
      diaryData = searchNotifier.mapDetailHashtag[key]?.diary;
      isLoadingLoadmore = false;
    }

    if(pageSrc == PageSrc.interest){
      final data = await searchNotifier.getDetailContents(context, key, HyppeType.HyppeDiary, TypeApiSearch.detailHashTag, 12);
      searchNotifier.interestContents[key]?.diary = data;
      diaryData = searchNotifier.interestContents[key]?.diary;
      isLoadingLoadmore = false;
    }
  }
}
