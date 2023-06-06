import 'package:flutter/material.dart';
import 'package:flutter_aliplayer/flutter_aliplayer.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/other_profile/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/notifier.dart';
import 'package:provider/provider.dart';

class ScrollVidNotifier with ChangeNotifier {
  List<ContentData>? vidData = [];
  bool isLoadingLoadmore = false;

  Future loadMore(BuildContext context, ScrollController scrollController, PageSrc pageSrc) async {
    if (pageSrc == PageSrc.selfProfile) {
      final sp = context.read<SelfProfileNotifier>();
      sp.pageIndex = 2;
      await sp.onScrollListener(context, scrollController, isLoad: true);
      vidData = sp.user.vids;
      notifyListeners();
    }

    if (pageSrc == PageSrc.otherProfile) {
      final op = context.read<OtherProfileNotifier>();
      op.pageIndex = 2;
      await op.onScrollListener(context, scrollController, isLoad: true);
      vidData = op.user.vids;
      notifyListeners();
    }
  }

  Future reload(BuildContext context, PageSrc pageSrc) async {
    if (pageSrc == PageSrc.selfProfile) {
      final sp = context.read<SelfProfileNotifier>();
      sp.pageIndex = 0;
      await sp.getDataPerPgage(context, isReload: true);
      vidData = sp.user.vids;
      isLoadingLoadmore = false;
      notifyListeners();
    }

    if (pageSrc == PageSrc.otherProfile) {
      final op = context.read<OtherProfileNotifier>();
      op.pageIndex = 0;
      await op.initialOtherProfile(context, refresh: true);
      vidData = op.user.vids;
      isLoadingLoadmore = false;
      notifyListeners();
    }
  }

  void setAliPlayer(int index, FlutterAliplayer player) {
    vidData?[index].fAliplayer = player;
    notifyListeners();
  }
}
