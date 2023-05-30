import 'package:hyppe/core/bloc/repos/repos.dart';
import 'package:hyppe/core/bloc/story/state.dart';
import 'package:hyppe/core/config/url_constants.dart';
import 'package:hyppe/core/constants/status_code.dart';
import 'package:hyppe/core/models/collection/stories/viewer_stories.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/enum.dart';

class StoryBloc {
  static final _repos = Repos();

  StoryFetch _storiesFetch = StoryFetch(StoryState.init);
  StoryFetch get storiesFetch => _storiesFetch;
  setStoriesFetch(StoryFetch val) => _storiesFetch = val;

  Future getViewerStoriesBloc(BuildContext context, {required String storyID, required int pageNo}) async {
    setStoriesFetch(StoryFetch(StoryState.loading));
    await _repos.reposPost(
      context,
      (onResult) {
        if ((onResult.statusCode ?? 300) == HTTP_OK) {
          ViewerStories _result = ViewerStories.fromJson(onResult.data);
          setStoriesFetch(StoryFetch(StoryState.getViewerStoriesSuccess, data: _result));
        } else {
          setStoriesFetch(StoryFetch(StoryState.getViewerStoriesError));
        }
      },
      (errorData) {
        ShowBottomSheet.onInternalServerError(context);
        setStoriesFetch(StoryFetch(StoryState.getViewerStoriesError));
      },
      errorServiceType: ErrorType.getViewerStories,
      host: UrlConstants.views + "?storyID=$storyID&pageNo=$pageNo",
      withAlertMessage: false,
      methodType: MethodType.get,
      withCheckConnection: false,
    );
  }
}
