import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/other_profile/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/notifier.dart';
import 'package:provider/provider.dart';

class ScrollDiaryNotifier with ChangeNotifier {
  List<ContentData>? diaryData = [];

  Future loadMore(BuildContext context, ScrollController scrollController, PageSrc pageSrc) async {
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
  }
}
