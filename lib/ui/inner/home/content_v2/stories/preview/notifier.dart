import 'package:hyppe/core/bloc/posts_v2/state.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/inner/upload/make_content/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/arguments/contents/story_detail_screen_argument.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/query_request/contents_data_query.dart';
import 'package:hyppe/core/extension/custom_extension.dart';

import '../../../../../../core/bloc/posts_v2/bloc.dart';
import '../../../../../../core/models/hive_box/boxes.dart';
import '../../../../../../core/services/check_version.dart';
import '../../../notifier_v2.dart';

class PreviewStoriesNotifier with ChangeNotifier {
  final _routing = Routing();
  ScrollController scrollController = ScrollController();

  ContentsDataQuery peopleContentsQuery = ContentsDataQuery()
    ..limit = 10
    ..featureType = FeatureType.story;

  ContentsDataQuery myContentsQuery = ContentsDataQuery()
    ..onlyMyData = true
    ..featureType = FeatureType.story;

  List<ContentData>? _peopleStoriesData;

  List<ContentData>? _myStoriesData;

  int _totalViews = 0;

  List<ContentData>? get peopleStoriesData => _peopleStoriesData;

  List<ContentData>? get myStoriesData => _myStoriesData;

  int get totalViews => _totalViews;

  changeBorderColor(ContentData contentData) {
    contentData.isViewed = true;
    notifyListeners();
  }

  set peopleStoriesData(List<ContentData>? val) {
    _peopleStoriesData = val;
    notifyListeners();
  }

  set myStoriesData(List<ContentData>? val) {
    _myStoriesData = val;
    notifyListeners();
  }

  set totalViews(int val) {
    _totalViews = val;
    notifyListeners();
  }

  int peopleItemCount(dynamic error) => _peopleStoriesData == null && error == null
      ? 10
      : peopleContentsQuery.hasNext
          ? (_peopleStoriesData?.length ?? 0) + 1
          : (_peopleStoriesData?.length ?? 0) + 1;

  bool get hasNext => peopleContentsQuery.hasNext;

  Future initialStories(BuildContext context, {List<ContentData>? list = null}) async {
    initialMyStories(context);
    print('hariyanto3');
    initialPeopleStories(context, reload: true, list: list);
  }

  Future<void> initialMyStories(BuildContext context) async {
    Future<List<ContentData>> _resFuture;

    try {
      print('reload contentsQuery : 13');
      _resFuture = myContentsQuery.reload(context);
      final res = await _resFuture;
      myStoriesData = res;
      if (myStoriesData != null) {
        totalViews = 0;
        for (var element in myStoriesData!) {
          totalViews += (element.insight?.views ?? 0);
        }
      }
    } catch (e) {
      'load my story list: ERROR: $e'.logger();
    }
  }

  Future<void> initialAllPeopleStories(BuildContext context, bool isStart) async {}


  Future<void> initialPeopleStories(
    BuildContext context, {
    bool reload = false,
        List<ContentData>? list = null
  }) async {
    List<ContentData> res = [];

    try {
      if (list != null) {
        res.addAll(list);
      } else {
        if(reload){
          res = await peopleContentsQuery.reload(context);
        }else{
          res = await peopleContentsQuery.loadNext(context);
        }

      }

      if (reload) {
        peopleStoriesData = res;
        scrollController.animateTo(
          scrollController.initialScrollOffset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      } else {
        peopleStoriesData = [...(peopleStoriesData ?? [] as List<ContentData>)] + res;
      }

      if (peopleStoriesData != null) {
        peopleStoriesData?.removeDuplicates(by: (item) => item.email);
      }
    } catch (e) {
      'load people story list: ERROR: $e'.logger();
    }
  }

  void scrollListener(BuildContext context) {
    if (scrollController.offset >= scrollController.position.maxScrollExtent && !scrollController.position.outOfRange && !peopleContentsQuery.loading && hasNext) {
      print('hariyanto2');
      initialPeopleStories(context);
    }
  }

  void onTapHandler(BuildContext context) {
    if (myStoriesData != null && (myStoriesData?.isNotEmpty ?? false)) {
      _routing.move(
        Routes.storyDetail,
        argument: StoryDetailScreenArgument(
          storyData: myStoriesData,
        ),
      );
    } else {
      // System().actionReqiredIdCard(context, action: () => uploadStories(context));
      uploadStories(context);
    }
  }

  void uploadStories(BuildContext context) {
    final notifier = Provider.of<MakeContentNotifier>(context, listen: false);
    notifier.thumbnailLocalMedia();
    notifier.featureType = FeatureType.story;
    notifier.selectedDuration = 15;
    Routing().move(Routes.makeContent);
  }

  void navigateToShortVideoPlayer(BuildContext context, int index) {
    _routing.move(
      Routes.storyDetail,
      argument: StoryDetailScreenArgument(
        storyData: peopleStoriesData,
        index: index.toDouble(),
      ),
    );
  }
}
