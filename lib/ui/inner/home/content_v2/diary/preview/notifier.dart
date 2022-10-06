import 'package:flutter/material.dart';

import 'package:hyppe/core/constants/enum.dart';

import 'package:hyppe/core/extension/log_extension.dart';

import 'package:hyppe/core/query_request/contents_data_query.dart';

import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';

import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/inner/search_v2/notifier.dart';

import 'package:hyppe/ux/path.dart';

import 'package:hyppe/ux/routing.dart';

import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';

import 'package:hyppe/core/arguments/contents/diary_detail_screen_argument.dart';

import 'package:provider/provider.dart';

class PreviewDiaryNotifier with ChangeNotifier {
  final _system = System();
  final _routing = Routing();
  ScrollController scrollController = ScrollController();

  ContentsDataQuery contentsQuery = ContentsDataQuery()..featureType = FeatureType.diary;

  List<ContentData>? _diaryData;

  List<ContentData>? get diaryData => _diaryData;

  set diaryData(List<ContentData>? val) {
    _diaryData = val;
    notifyListeners();
  }

  int get itemCount => _diaryData == null ? 3 : (_diaryData?.length ?? 0);

  bool get hasNext => contentsQuery.hasNext;

  double _heightVid = 0.0;
  double _heightTitleFeature = 0.0;

  double get heightVid => _heightVid;
  double get heightTitleFeature => _heightTitleFeature;

  set heightVid(double val) {
    _heightVid = val;
    notifyListeners();
  }

  set heightTitleFeature(double val) {
    _heightTitleFeature = val;
    notifyListeners();
  }

  double scaleDiary(BuildContext context) {
    final _size = MediaQuery.of(context).size;
    const _appBar = 50;
    const _story = 72;
    final _vid = (211 + _heightTitleFeature);
    // final _pic = 115;
    const _bottomBar = 56;
    const _spacer = 48;
    final _sum = (_appBar + _bottomBar + _story + _vid + _spacer);
    double _result = _size.height - _sum;

    return _result;
  }

  Future<void> initialDiary(
    BuildContext context, {
    bool reload = false,
  }) async {
    Future<List<ContentData>> _resFuture;

    try {
      if (reload) {

        print('test2');
        _resFuture = contentsQuery.reload(context, isCache: true);
      } else {
        _resFuture = contentsQuery.loadNext(context);
      }

      final res = await _resFuture;

      if (reload) {
        diaryData = res;

        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.initialScrollOffset,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeIn,
          );
        }
      } else {
        diaryData = [...(diaryData ?? [] as List<ContentData>)] + res;
      }
      final _searchData = context.read<SearchNotifier>();
      if (_searchData.allContents!.diaries == null) {
        _searchData.diaryContentsQuery.featureType = FeatureType.diary;
        _searchData.allContents?.diaries = diaryData;
      }
    } catch (e) {
      'load diary list: ERROR: $e'.logger();
    }
  }

  void scrollListener(BuildContext context) {
    if (scrollController.offset >= scrollController.position.maxScrollExtent && !scrollController.position.outOfRange && !contentsQuery.loading && hasNext) {
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

  void navigateToSeeAll(BuildContext context) async {
    final connect = await _system.checkConnections();
    if (connect) {
      _routing.move(Routes.diarySeeAllScreen);
    } else {
      ShowBottomSheet.onNoInternetConnection(context);
    }
  }
}
