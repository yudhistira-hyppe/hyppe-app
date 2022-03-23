import 'package:flutter/material.dart';

import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';

import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';

import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/query_request/contents_data_query.dart';
import 'package:hyppe/core/arguments/contents/diary_detail_screen_argument.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';

class DiarySeeAllNotifier extends ChangeNotifier {
  final _system = System();
  final _routing = Routing();

  ContentsDataQuery contentsQuery = ContentsDataQuery()
    ..limit = 15
    ..featureType = FeatureType.diary;

  ScrollController scrollController = ScrollController();

  List<ContentData>? _diaryData;

  List<ContentData>? get diaryData => _diaryData;

  set diaryData(List<ContentData>? val) {
    _diaryData = val;
    notifyListeners();
  }

  int get itemCount => _diaryData == null
      ? 10
      : contentsQuery.hasNext
          ? (_diaryData?.length ?? 0) + 1
          : (_diaryData?.length ?? 0);

  bool get hasNext => contentsQuery.hasNext;

  void initState(BuildContext context) {
    initialDiary(context, reload: true);
    scrollController.addListener(() => scrollListener(context));
  }

  Future<void> initialDiary(
    BuildContext context, {
    bool reload = false,
  }) async {
    Future<List<ContentData>> _resFuture;

    try {
      if (reload) {
        _resFuture = contentsQuery.reload(context);
      } else {
        _resFuture = contentsQuery.loadNext(context);
      }

      final res = await _resFuture;
      if (reload) {
        diaryData = res;
      } else {
        diaryData = [...(diaryData ?? [] as List<ContentData>)] + res;
      }
    } catch (e) {
      'load diary list: ERROR: $e'.logger();
    }
  }

  void scrollListener(BuildContext context) {
    if (scrollController.offset >= scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange &&
        !contentsQuery.loading &&
        hasNext) {
      initialDiary(context);
    }
  }

  void navigateToShortVideoPlayer(BuildContext context, int index, {List<ContentData>? data}) async {
    final connect = await _system.checkConnections();
    if (connect) {
      _routing.move(
        Routes.diaryDetail,
        argument: DiaryDetailScreenArgument(
          diaryData: diaryData,
          index: index.toDouble(),
        ),
      );
    } else {
      ShowBottomSheet.onNoInternetConnection(context);
    }
  }
}
