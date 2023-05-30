import 'package:flutter/material.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/notifier.dart';
import 'package:provider/provider.dart';

class ScrollDiaryNotifier with ChangeNotifier {
  List<ContentData>? diaryData = [];

  Future loadMore(BuildContext context, ScrollController scrollController) async {
    final sp = context.read<SelfProfileNotifier>();
    sp.pageIndex = 1;
    await sp.onScrollListener(context, scrollController, isLoad: true);
    diaryData = sp.user.diaries;
    notifyListeners();
  }
}
