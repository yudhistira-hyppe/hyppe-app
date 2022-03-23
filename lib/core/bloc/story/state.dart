enum StoryState {
  init,
  loading,
  getViewerStoriesSuccess,
  getViewerStoriesError,
}

class StoryFetch {
  final dynamic data;
  final StoryState storyState;
  StoryFetch(this.storyState, {this.data});
}
