import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/show_general_dialog.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/other_profile/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/notifier.dart';
import 'package:hyppe/ui/inner/search_v2/notifier.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../../../../core/services/system.dart';

class ScrollPicNotifier with ChangeNotifier {
  final ItemScrollController itemScrollController = ItemScrollController();
  LocalizationModelV2 language = LocalizationModelV2();
  Offset positionDxDy = const Offset(0, 0);
  bool _isLoadingLoadmore = false;
  bool isConnect = true;
  bool isMute = true;
  int currIndex = 0;
  int get currentIndex => currIndex;
  
  setIsSound(bool val){
    isMute = val;
    notifyListeners();
  }
  
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

  List<ContentData>? _pics;

  List<ContentData>? get pics => _pics;

  set pics(List<ContentData>? val) {
    _pics = val;
    // notifyListeners();
  }

  void onUpdate() => notifyListeners();

  Future loadMore(BuildContext context, ScrollController scrollController, PageSrc pageSrc, String key) async {
    isLoadingLoadmore = true;
    bool connect = await System().checkConnections();
    connectionError = !connect;
    final searchNotifier = context.read<SearchNotifier>();
    if (connect) {
      print("masuk");
      print(pageSrc);
      if (pageSrc == PageSrc.selfProfile) {
        final sp = context.read<SelfProfileNotifier>();
        sp.pageIndex = 0;
        await sp.onScrollListener(context, scrollController: scrollController, isLoad: true);
        if (sp.user.pics == null || (sp.user.pics?.isEmpty ?? [].isEmpty)) {
        } else {
          pics = sp.user.pics;
        }
        isLoadingLoadmore = false;
      }

      if (pageSrc == PageSrc.otherProfile) {
        final op = context.read<OtherProfileNotifier>();
        op.pageIndex = 0;
        await op.onScrollListener(context, scrollController: scrollController, isLoad: true);
        if (op.manyUser.last.pics == null || (op.manyUser.last.pics?.isEmpty ?? [].isEmpty)) {
        } else {
          pics = op.manyUser.last.pics;
        }

        isLoadingLoadmore = false;
      }

      if (pageSrc == PageSrc.searchData) {
        final data = await searchNotifier.getDetailContents(context, key, HyppeType.HyppePic, TypeApiSearch.normal, 12, skip: searchNotifier.searchPic?.length ?? 0);
        if (data.isNotEmpty) {
          searchNotifier.searchPic?.addAll(data);
          pics = searchNotifier.searchPic;
        }
        isLoadingLoadmore = false;
      }

      if (pageSrc == PageSrc.hashtag) {
        final data = await searchNotifier.getDetailContents(context, key, HyppeType.HyppePic, TypeApiSearch.detailHashTag, 12, skip: searchNotifier.mapDetailHashtag[key]?.pict?.length ?? 0);
        if (data.isNotEmpty) {
          searchNotifier.mapDetailHashtag[key]?.pict?.addAll(data);
          pics = searchNotifier.mapDetailHashtag[key]?.pict;
        }
        isLoadingLoadmore = false;
      }

      if (pageSrc == PageSrc.interest) {
        final data = await searchNotifier.getDetailContents(context, key, HyppeType.HyppePic, TypeApiSearch.detailInterest, 12, skip: searchNotifier.interestContents[key]?.pict?.length ?? 0);
        if (data.isNotEmpty) {
          searchNotifier.interestContents[key]?.pict?.addAll(data);
          pics = searchNotifier.interestContents[key]?.pict;
        }
        isLoadingLoadmore = false;
      }
    } else {
      if (pageSrc == PageSrc.interest) {
        pics = searchNotifier.interestContents[key]?.pict;
      }
      if (pageSrc == PageSrc.hashtag) {
        pics = searchNotifier.mapDetailHashtag[key]?.pict;
      }
      if (pageSrc == PageSrc.searchData) {
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
    }
  }

  Future reload(BuildContext context, PageSrc pageSrc, {String key = ""}) async {
    bool connect = await System().checkConnections();
    final searchNotifier = context.read<SearchNotifier>();
    connectionError = !connect;
    if (connect) {
      print("hahahaha======== $pageSrc");
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
        pics = op.manyUser.last.pics;
        isLoadingLoadmore = false;
      }

      if (pageSrc == PageSrc.searchData) {
        final data = await searchNotifier.getDetailContents(context, key, HyppeType.HyppePic, TypeApiSearch.normal, 12);
        searchNotifier.searchPic = data;
        pics = searchNotifier.searchPic;
        isLoadingLoadmore = false;
      }

      if (pageSrc == PageSrc.hashtag) {
        final data = await searchNotifier.getDetailContents(context, key, HyppeType.HyppePic, TypeApiSearch.detailHashTag, 12);
        searchNotifier.mapDetailHashtag[key]?.pict = data;
        pics = searchNotifier.mapDetailHashtag[key]?.pict;
        isLoadingLoadmore = false;
      }

      if (pageSrc == PageSrc.interest) {
        final data = await searchNotifier.getDetailContents(context, key, HyppeType.HyppePic, TypeApiSearch.detailInterest, 12);
        searchNotifier.interestContents[key]?.pict = data;
        pics = searchNotifier.interestContents[key]?.pict;
        isLoadingLoadmore = false;
      }
    } else {
      if (pageSrc == PageSrc.interest) {
        pics = searchNotifier.interestContents[key]?.pict;
      }
      if (pageSrc == PageSrc.hashtag) {
        pics = searchNotifier.mapDetailHashtag[key]?.pict;
      }
      if (pageSrc == PageSrc.searchData) {
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
    }
  }

  void initialPicConnection(BuildContext context) async {
    final connect = await System().checkConnections();
      if (!connect) {
        isConnect = false;
        notifyListeners();
        // ignore: use_build_context_synchronously
        ShowGeneralDialog.showToastAlert(
          context,
          language.internetConnectionLost ?? ' Error',
          () async {},
        );
      } else {
        isConnect = true;
        notifyListeners();
      }
  }
}
