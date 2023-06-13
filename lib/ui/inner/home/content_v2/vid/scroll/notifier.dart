import 'package:flutter/material.dart';
import 'package:flutter_aliplayer/flutter_aliplayer.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/other_profile/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/notifier.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/services/system.dart';
import '../../../../../../initial/hyppe/translate_v2.dart';
import '../../../../search_v2/notifier.dart';

class ScrollVidNotifier with ChangeNotifier {
  List<ContentData>? vidData = [];
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

  Future loadMore(BuildContext context, ScrollController scrollController, PageSrc pageSrc, String key) async {
    isLoadingLoadmore = true;
    bool connect = await System().checkConnections();
    final searchNotifier = context.read<SearchNotifier>();
    connectionError = !connect;
    if (connect) {
      if (pageSrc == PageSrc.selfProfile) {
        final sp = context.read<SelfProfileNotifier>();
        sp.pageIndex = 2;
        await sp.onScrollListener(context, scrollController, isLoad: true);
        vidData = sp.user.vids;
        isLoadingLoadmore = false;
      }

      if (pageSrc == PageSrc.otherProfile) {
        final op = context.read<OtherProfileNotifier>();
        op.pageIndex = 2;
        await op.onScrollListener(context, scrollController, isLoad: true);
        vidData = op.user.vids;
        isLoadingLoadmore = false;
      }

      final searchNotifier = context.read<SearchNotifier>();

      if (pageSrc == PageSrc.searchData) {
        final data = await searchNotifier.getDetailContents(context, key, HyppeType.HyppeVid, TypeApiSearch.normal, 12, skip: searchNotifier.searchVid?.length ?? 0);
        searchNotifier.searchVid?.addAll(data);
        vidData = searchNotifier.searchVid;
        isLoadingLoadmore = false;
      }

      if (pageSrc == PageSrc.hashtag) {
        final data = await searchNotifier.getDetailContents(context, key, HyppeType.HyppeVid, TypeApiSearch.detailHashTag, 12, skip: searchNotifier.mapDetailHashtag[key]?.vid?.length ?? 0);
        searchNotifier.mapDetailHashtag[key]?.vid?.addAll(data);
        vidData = searchNotifier.mapDetailHashtag[key]?.vid;
        isLoadingLoadmore = false;
      }

      if (pageSrc == PageSrc.interest) {
        final data = await searchNotifier.getDetailContents(context, key, HyppeType.HyppeVid, TypeApiSearch.detailInterest, 12, skip: searchNotifier.interestContents[key]?.vid?.length ?? 0);
        searchNotifier.interestContents[key]?.vid?.addAll(data);
        vidData = searchNotifier.interestContents[key]?.vid;
        isLoadingLoadmore = false;
      }
    } else {
      isLoadingLoadmore = false;
      final language = context.read<TranslateNotifierV2>().translate;
      context.showErrorConnection(language);
    }
  }

  Future reload(BuildContext context, PageSrc pageSrc, {String key = ""}) async {
    bool connect = await System().checkConnections();
    final searchNotifier = context.read<SearchNotifier>();
    connectionError = !connect;
    if (connect) {
      if (pageSrc == PageSrc.selfProfile) {
        final sp = context.read<SelfProfileNotifier>();
        sp.pageIndex = 2;
        await sp.getDataPerPgage(context, isReload: true);
        vidData = sp.user.vids;
        isLoadingLoadmore = false;
      }

      if (pageSrc == PageSrc.otherProfile) {
        final op = context.read<OtherProfileNotifier>();
        op.pageIndex = 2;
        await op.getDataPerPgage(context);
        vidData = op.user.vids;
        isLoadingLoadmore = false;
      }



      if (pageSrc == PageSrc.searchData) {
        final data = await searchNotifier.getDetailContents(context, key, HyppeType.HyppeVid, TypeApiSearch.normal, 12);
        searchNotifier.searchVid = data;
        vidData = searchNotifier.searchVid;
        isLoadingLoadmore = false;
      }

      if (pageSrc == PageSrc.hashtag) {
        final data = await searchNotifier.getDetailContents(context, key, HyppeType.HyppeVid, TypeApiSearch.detailHashTag, 12);
        searchNotifier.mapDetailHashtag[key]?.vid = data;
        vidData = searchNotifier.mapDetailHashtag[key]?.vid;
        isLoadingLoadmore = false;
      }

      if (pageSrc == PageSrc.interest) {
        final data = await searchNotifier.getDetailContents(context, key, HyppeType.HyppeVid, TypeApiSearch.detailInterest, 12);
        searchNotifier.interestContents[key]?.vid = data;
        vidData = searchNotifier.interestContents[key]?.vid;
        isLoadingLoadmore = false;
      }
    } else {
      isLoadingLoadmore = false;
      final language = context.read<TranslateNotifierV2>().translate;
      context.showErrorConnection(language);
    }
  }

  void setAliPlayer(int index, FlutterAliplayer player) {
    vidData?[index].fAliplayer = player;
    notifyListeners();
  }
}
