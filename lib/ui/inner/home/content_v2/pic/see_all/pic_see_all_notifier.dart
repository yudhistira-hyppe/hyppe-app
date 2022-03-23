import 'package:flutter/material.dart';

import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';

import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';

import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/query_request/contents_data_query.dart';
import 'package:hyppe/core/arguments/contents/pic_detail_screen_argument.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';

class PicSeeAllNotifier extends ChangeNotifier {
  final _system = System();
  final _routing = Routing();

  ContentsDataQuery contentsQuery = ContentsDataQuery()
    ..limit = 10
    ..featureType = FeatureType.pic;

  ScrollController scrollController = ScrollController();

  List<ContentData>? _picData;

  List<ContentData>? get picData => _picData;

  set picData(List<ContentData>? val) {
    _picData = val;
    notifyListeners();
  }

  int get itemCount => _picData == null
      ? 10
      : contentsQuery.hasNext
          ? (_picData?.length ?? 0) + 1
          : (_picData?.length ?? 0);

  bool get hasNext => contentsQuery.hasNext;

  void initState(BuildContext context) {
    initialPic(context, reload: true);
    scrollController.addListener(() => scrollListener(context));
  }

  Future<void> initialPic(
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
        picData = res;
      } else {
        picData = [...(picData ?? [] as List<ContentData>)] + res;
      }
    } catch (e) {
      'load pic list: ERROR: $e'.logger();
    }
  }

  void scrollListener(BuildContext context) {
    if (scrollController.offset >= scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange &&
        !contentsQuery.loading &&
        hasNext) {
      initialPic(context);
    }
  }

  void navigateToHyppePicDetail(BuildContext context, ContentData? data) async {
    final connect = await _system.checkConnections();
    if (connect) {
      _routing.move(Routes.picDetail, argument: PicDetailScreenArgument(picData: data));
    } else {
      ShowBottomSheet.onNoInternetConnection(context);
    }
  }
}
