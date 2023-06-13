import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/other_profile/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/notifier.dart';
import 'package:hyppe/ui/inner/search_v2/notifier.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/services/system.dart';
import '../../../../../../initial/hyppe/translate_v2.dart';

class ScrollPicNotifier with ChangeNotifier {
  bool _isLoadingLoadmore = false;
  bool get isLoadingLoadmore => _isLoadingLoadmore;
  set isLoadingLoadmore(bool state){
    _isLoadingLoadmore = state;
    notifyListeners();
  }

  bool _connectionError = false;
  bool get connectionError => _connectionError;
  set connectionError (bool state){
    _connectionError = state;
    notifyListeners();
  }

  Future checkConnection() async {
    bool connect = await System().checkConnections();
    connectionError = !connect;
  }

  List<ContentData>? pics = [];

  Future loadMore(BuildContext context, ScrollController scrollController, PageSrc pageSrc, String key) async {
    isLoadingLoadmore = true;
    bool connect = await System().checkConnections();
    connectionError = !connect;
    final searchNotifier = context.read<SearchNotifier>();
    if(connect){
      if (pageSrc == PageSrc.selfProfile) {
        final sp = context.read<SelfProfileNotifier>();
        sp.pageIndex = 0;
        await sp.onScrollListener(context, scrollController, isLoad: true);
        pics = sp.user.pics;
        isLoadingLoadmore = false;
      }

      if (pageSrc == PageSrc.otherProfile) {
        final op = context.read<OtherProfileNotifier>();
        op.pageIndex = 0;
        await op.onScrollListener(context, scrollController, isLoad: true);
        pics = op.user.pics;
        isLoadingLoadmore = false;
      }



      if(pageSrc == PageSrc.searchData){
        final data = await searchNotifier.getDetailContents(context, key, HyppeType.HyppePic, TypeApiSearch.normal, 12, skip: searchNotifier.searchPic?.length ?? 0);
        if(data.isNotEmpty){
          searchNotifier.searchPic?.addAll(data);
          pics = searchNotifier.searchPic;

        }
        isLoadingLoadmore = false;
      }

      if(pageSrc == PageSrc.hashtag){
        final data = await searchNotifier.getDetailContents(context, key, HyppeType.HyppePic, TypeApiSearch.detailHashTag, 12, skip: searchNotifier.mapDetailHashtag[key]?.pict?.length ?? 0);
        if(data.isNotEmpty){
          searchNotifier.mapDetailHashtag[key]?.pict?.addAll(data);
          pics = searchNotifier.mapDetailHashtag[key]?.pict;

        }
        isLoadingLoadmore = false;
      }

      if(pageSrc == PageSrc.interest){
        final data = await searchNotifier.getDetailContents(context, key, HyppeType.HyppePic, TypeApiSearch.detailInterest, 12, skip: searchNotifier.interestContents[key]?.pict?.length ?? 0);
        if(data.isNotEmpty){
          searchNotifier.interestContents[key]?.pict?.addAll(data);
          pics = searchNotifier.interestContents[key]?.pict;

        }
        isLoadingLoadmore = false;
      }
    }else{
      if(pageSrc == PageSrc.interest){
        pics = searchNotifier.interestContents[key]?.pict;
      }
      if(pageSrc == PageSrc.hashtag){
        pics = searchNotifier.mapDetailHashtag[key]?.pict;
      }
      if(pageSrc == PageSrc.searchData){
        pics = searchNotifier.searchPic;
      }
      if (pageSrc == PageSrc.selfProfile) {
        final sp = context.read<SelfProfileNotifier>();
        pics = sp.user.pics;
      }
      if (pageSrc == PageSrc.otherProfile) {
        final op = context.read<OtherProfileNotifier>();
        pics = op.user.pics;
      }
      connectionError = true;
      isLoadingLoadmore = false;
      final language = context.read<TranslateNotifierV2>().translate;
      context.showErrorConnection(language);
    }

  }

  Future reload(BuildContext context, PageSrc pageSrc, {String key = ""}) async {
    bool connect = await System().checkConnections();
    final searchNotifier = context.read<SearchNotifier>();
    connectionError = !connect;
    if(connect){
      if (pageSrc == PageSrc.selfProfile) {
        final sp = context.read<SelfProfileNotifier>();
        sp.pageIndex = 0;
        await sp.getDataPerPgage(context, isReload: true);
        pics = sp.user.pics;
        isLoadingLoadmore = false;
      }

      if (pageSrc == PageSrc.otherProfile) {
        final op = context.read<OtherProfileNotifier>();
        op.pageIndex = 0;
        await op.initialOtherProfile(context, refresh: true);
        pics = op.user.pics;
        isLoadingLoadmore = false;
      }


      if(pageSrc == PageSrc.searchData){
        final data = await searchNotifier.getDetailContents(context, key, HyppeType.HyppePic, TypeApiSearch.normal, 12);
        searchNotifier.searchPic = data;
        pics = searchNotifier.searchPic;
        isLoadingLoadmore = false;
      }

      if(pageSrc == PageSrc.hashtag){
        final data = await searchNotifier.getDetailContents(context, key, HyppeType.HyppePic, TypeApiSearch.detailHashTag, 12);
        searchNotifier.mapDetailHashtag[key]?.pict = data;
        pics = searchNotifier.mapDetailHashtag[key]?.pict;
        isLoadingLoadmore = false;
      }

      if(pageSrc == PageSrc.interest){
        final data = await searchNotifier.getDetailContents(context, key, HyppeType.HyppePic, TypeApiSearch.detailInterest, 12);
        searchNotifier.interestContents[key]?.pict = data;
        pics = searchNotifier.interestContents[key]?.pict;
        isLoadingLoadmore = false;
      }
    }else{
      if(pageSrc == PageSrc.interest){
        pics = searchNotifier.interestContents[key]?.pict;
      }
      if(pageSrc == PageSrc.hashtag){
        pics = searchNotifier.mapDetailHashtag[key]?.pict;
      }
      if(pageSrc == PageSrc.searchData){
        pics = searchNotifier.searchPic;
      }
      if (pageSrc == PageSrc.selfProfile) {
        final sp = context.read<SelfProfileNotifier>();
        pics = sp.user.pics;
      }
      if (pageSrc == PageSrc.otherProfile) {
        final op = context.read<OtherProfileNotifier>();
        pics = op.user.pics;
      }
      connectionError = true;
      isLoadingLoadmore = false;
      final language = context.read<TranslateNotifierV2>().translate;
      context.showErrorConnection(language);
    }

  }
}
