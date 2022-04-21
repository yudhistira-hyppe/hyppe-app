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

  int peopleItemCount(dynamic error) =>
      _peopleStoriesData == null && error == null
          ? 10
          : peopleContentsQuery.hasNext
              ? (_peopleStoriesData?.length ?? 0) + 1
              : (_peopleStoriesData?.length ?? 0) + 1;

  bool get hasNext => peopleContentsQuery.hasNext;

  Future initialStories(BuildContext context) async {
    initialMyStories(context);
    initialPeopleStories(context, reload: true);
  }

  Future<void> initialMyStories(BuildContext context) async {
    Future<List<ContentData>> _resFuture;

    try {
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

  Future<void> initialPeopleStories(
    BuildContext context, {
    bool reload = false,
  }) async {
    Future<List<ContentData>> _resFuture;

    try {
      if (reload) {
        _resFuture = peopleContentsQuery.reload(context);
      } else {
        _resFuture = peopleContentsQuery.loadNext(context);
      }

      final res = await _resFuture;
      if (reload) {
        peopleStoriesData = res;
        scrollController.animateTo(
          scrollController.initialScrollOffset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      } else {
        peopleStoriesData =
            [...(peopleStoriesData ?? [] as List<ContentData>)] + res;
      }

      if (peopleStoriesData != null) {
        peopleStoriesData!.removeDuplicates(by: (item) => item.email);
      }
    } catch (e) {
      'load people story list: ERROR: $e'.logger();
    }
  }

  void scrollListener(BuildContext context) {
    if (scrollController.offset >= scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange &&
        !peopleContentsQuery.loading &&
        hasNext) {
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
