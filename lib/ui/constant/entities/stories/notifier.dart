import 'package:hyppe/core/bloc/story/bloc.dart';
import 'package:hyppe/core/bloc/story/state.dart';
import 'package:hyppe/core/models/collection/stories/viewer_stories.dart';
import 'package:hyppe/core/models/collection/stories/viewer_stories_data.dart';
import 'package:hyppe/ui/constant/entities/loading/notifier.dart';
import 'package:flutter/material.dart';

class ViewerStoriesNotifier extends LoadingNotifier with ChangeNotifier {
  int _pageNo = 0;
  int? viewers;
  ViewerStories? _viewerStories;

  int get pageNo => _pageNo;
  ViewerStories? get viewerStories => _viewerStories;

  set viewerStories(ViewerStories? val) {
    _viewerStories = val;
    notifyListeners();
  }

  set pageNo(int val) {
    _pageNo = val;
    notifyListeners();
  }

  final String onGoingKey = 'onGoingKey';

  Future getViewers(BuildContext context, {required String storyID}) async {
    _viewerStories = null;
    final notifier = StoryBloc();
    await notifier.getViewerStoriesBloc(context, storyID: storyID, pageNo: 0);
    final fetch = notifier.storiesFetch;
    if (fetch.storyState == StoryState.getViewerStoriesSuccess) {
      ViewerStories _result = fetch.data;
      if (_result.storyViews.isNotEmpty) {
        _viewerStories = _result;
        _pageNo = 1;
      }
    }
    setLoading(false);
  }

  void onScrollGetViewers(BuildContext context, String storyID, ScrollController scrollController) async {
    if (scrollController.offset >= scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange &&
        !loadingForObject(onGoingKey)) {
      final notifier = StoryBloc();

      if (_viewerStories != null) {
        _viewerStories!.storyViews.removeWhere((element) => element.isLoading != null);
        _viewerStories!.storyViews.insert(_viewerStories!.storyViews.length, StoryViewsData.setLoading());
        notifyListeners();
      }

      setLoading(true, loadingObject: onGoingKey);
      await notifier.getViewerStoriesBloc(context, storyID: storyID, pageNo: pageNo);

      if (_viewerStories != null) {
        _viewerStories!.storyViews.removeWhere((element) => element.isLoading != null);
        notifyListeners();
      }

      final fetch = notifier.storiesFetch;
      if (fetch.storyState == StoryState.getViewerStoriesSuccess) {
        ViewerStories _result = fetch.data;
        if (_result.storyViews.isNotEmpty) {
          _viewerStories?.storyViews.addAll(_result.storyViews);
          _pageNo = pageNo++;
        } else {
          print("Data dah mentok");
        }
      }
      setLoading(false, loadingObject: onGoingKey);
    }
  }

  @override
  void setLoading(bool val, {bool setState = true, Object? loadingObject}) {
    super.setLoading(val, loadingObject: loadingObject);
    if (setState) notifyListeners();
  }
}
