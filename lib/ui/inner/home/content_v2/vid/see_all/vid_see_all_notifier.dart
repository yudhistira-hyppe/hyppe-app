import 'package:flutter/material.dart';

import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';

import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';

import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/query_request/contents_data_query.dart';
import 'package:hyppe/core/arguments/contents/vid_detail_screen_argument.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';

class VidSeeAllNotifier extends ChangeNotifier {
  final _system = System();
  final _routing = Routing();

  ContentsDataQuery contentsQuery = ContentsDataQuery()
    ..limit = 10
    ..featureType = FeatureType.vid;

  ScrollController scrollController = ScrollController();

  List<ContentData>? _vidData;

  List<ContentData>? get vidData => _vidData;

  set vidData(List<ContentData>? val) {
    _vidData = val;
    notifyListeners();
  }

  int get itemCount => _vidData == null
      ? 10
      : contentsQuery.hasNext
          ? (_vidData?.length ?? 0) + 1
          : (_vidData?.length ?? 0);

  bool get hasNext => contentsQuery.hasNext;

  void initState(BuildContext context) {
    initialVid(context, reload: true);
    scrollController.addListener(() => scrollListener(context));
  }

  Future<void> initialVid(
    BuildContext context, {
    bool reload = false,
  }) async {
    Future<List<ContentData>> _resFuture;

    try {
      if (reload) {
        print('test20');
        _resFuture = contentsQuery.reload(context);
      } else {
        _resFuture = contentsQuery.loadNext(context);
      }

      final res = await _resFuture;
      if (reload) {
        vidData = res;
      } else {
        vidData = [...(vidData ?? [] as List<ContentData>)] + res;
      }
    } catch (e) {
      'load vid list: ERROR: $e'.logger();
    }
  }

  void scrollListener(BuildContext context) {
    if (scrollController.offset >= scrollController.position.maxScrollExtent && !scrollController.position.outOfRange && !contentsQuery.loading && hasNext) {
      initialVid(context);
    }
  }

  void navigateToHyppeVidDetail(BuildContext context, ContentData? data) async {
    final connect = await _system.checkConnections();
    if (connect) {
      _routing.move(Routes.vidDetail, argument: VidDetailScreenArgument(vidData: data));
    } else {
      ShowBottomSheet.onNoInternetConnection(context);
    }
  }

  void reportContent(BuildContext context) {
    ShowBottomSheet.onReportContent(context);
  }

  void showUserTag(BuildContext context, index) {
    ShowBottomSheet.onShowUserTag(context, value: _vidData![index].tagPeople!, function: () {}, postId: _vidData![index].postID);
  }
}
