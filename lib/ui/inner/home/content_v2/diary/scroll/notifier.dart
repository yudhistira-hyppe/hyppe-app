import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/other_profile/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/notifier.dart';
import 'package:provider/provider.dart';

import '../../../../search_v2/notifier.dart';

class ScrollDiaryNotifier with ChangeNotifier {
  bool _isLoadingLoadmore = false;
  bool get isLoadingLoadmore => _isLoadingLoadmore;
  set isLoadingLoadmore(bool state) {
    _isLoadingLoadmore = state;
    notifyListeners();
  }

  bool _connectionError = false;
  bool get connectionError => _connectionError;
  set connectionError(bool state) {
    _connectionError = state;
    notifyListeners();
  }

  Future checkConnection() async {
    bool connect = await System().checkConnections();
    connectionError = !connect;
  }

  List<ContentData>? diaryData = [];

  Future loadMore(BuildContext context, ScrollController scrollController, PageSrc pageSrc, String key) async {
    isLoadingLoadmore = true;
    bool connect = await System().checkConnections();
    // final searchNotifier = context.read<SearchNotifier>();
    connectionError = !connect;
    if (connect) {
      if (pageSrc == PageSrc.selfProfile) {
        final sp = context.read<SelfProfileNotifier>();
        sp.pageIndex = 1;
        await sp.onScrollListener(context, scrollController, isLoad: true);
        diaryData = sp.user.diaries;
        isLoadingLoadmore = false;
      }

      if (pageSrc == PageSrc.otherProfile) {
        final op = context.read<OtherProfileNotifier>();
        op.pageIndex = 1;
        await op.onScrollListener(context, scrollController, isLoad: true);
        diaryData = op.manyUser.last.diaries;
        isLoadingLoadmore = false;
      }

      final searchNotifier = context.read<SearchNotifier>();

      if (pageSrc == PageSrc.searchData) {
        final data = await searchNotifier.getDetailContents(context, key, HyppeType.HyppeDiary, TypeApiSearch.normal, 12, skip: searchNotifier.searchDiary?.length ?? 0);
        searchNotifier.searchDiary?.addAll(data);
        diaryData = searchNotifier.searchDiary;
        isLoadingLoadmore = false;
      }

      if (pageSrc == PageSrc.hashtag) {
        final data = await searchNotifier.getDetailContents(context, key, HyppeType.HyppeDiary, TypeApiSearch.detailHashTag, 12, skip: searchNotifier.mapDetailHashtag[key]?.diary?.length ?? 0);
        searchNotifier.mapDetailHashtag[key]?.diary?.addAll(data);
        diaryData = searchNotifier.mapDetailHashtag[key]?.diary;
        isLoadingLoadmore = false;
      }

      if (pageSrc == PageSrc.interest) {
        final data = await searchNotifier.getDetailContents(context, key, HyppeType.HyppeDiary, TypeApiSearch.detailInterest, 12, skip: searchNotifier.interestContents[key]?.diary?.length ?? 0);
        searchNotifier.interestContents[key]?.diary?.addAll(data);
        diaryData = searchNotifier.interestContents[key]?.diary;
        isLoadingLoadmore = false;
      }
    } else {
      isLoadingLoadmore = false;
    }
  }

  Future reload(BuildContext context, PageSrc pageSrc, {String key = ""}) async {
    bool connect = await System().checkConnections();
    // final searchNotifier = context.read<SearchNotifier>();
    connectionError = !connect;
    if (connect) {
      if (pageSrc == PageSrc.selfProfile) {
        final sp = context.read<SelfProfileNotifier>();
        sp.pageIndex = 1;
        await sp.getDataPerPgage(context, isReload: true);
        diaryData = sp.user.diaries;
        isLoadingLoadmore = false;
        notifyListeners();
      }

      if (pageSrc == PageSrc.otherProfile) {
        final op = context.read<OtherProfileNotifier>();
        op.pageIndex = 1;
        await op.initialOtherProfile(context);
        diaryData = op.manyUser.last.diaries;
        isLoadingLoadmore = false;
        notifyListeners();
      }

      final searchNotifier = context.read<SearchNotifier>();

      if (pageSrc == PageSrc.searchData) {
        final data = await searchNotifier.getDetailContents(context, key, HyppeType.HyppeDiary, TypeApiSearch.normal, 12);
        searchNotifier.searchDiary = data;
        diaryData = searchNotifier.searchDiary;
        isLoadingLoadmore = false;
      }

      if (pageSrc == PageSrc.hashtag) {
        final data = await searchNotifier.getDetailContents(context, key, HyppeType.HyppeDiary, TypeApiSearch.detailHashTag, 12);
        searchNotifier.mapDetailHashtag[key]?.diary = data;
        diaryData = searchNotifier.mapDetailHashtag[key]?.diary;
        isLoadingLoadmore = false;
      }

      if (pageSrc == PageSrc.interest) {
        final data = await searchNotifier.getDetailContents(context, key, HyppeType.HyppeDiary, TypeApiSearch.detailInterest, 12);
        searchNotifier.interestContents[key]?.diary = data;
        diaryData = searchNotifier.interestContents[key]?.diary;
        isLoadingLoadmore = false;
      }
    } else {
      isLoadingLoadmore = false;
    }
  }
}
