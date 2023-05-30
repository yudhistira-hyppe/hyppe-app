import 'package:flutter/material.dart';
import 'package:flutter_aliplayer/flutter_aliplayer.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/notifier.dart';
import 'package:provider/provider.dart';

class ScrollVidNotifier with ChangeNotifier {
  List<ContentData>? vidData = [];

  Future loadMore(BuildContext context, ScrollController scrollController) async {
    final sp = context.read<SelfProfileNotifier>();
    sp.pageIndex = 2;
    await sp.onScrollListener(context, scrollController, isLoad: true);
    vidData = sp.user.vids;
    notifyListeners();
  }

  void setAliPlayer(int index, FlutterAliplayer player) {
    vidData?[index].fAliplayer = player;
    notifyListeners();
  }
}
