enum PostViewerState {
  init,
  loading,
  postViewerUserSuccess,
  postViewerUserError
}

class PostViewerFetch {
  final data;
  final PostViewerState postViewerState;
  PostViewerFetch(this.postViewerState, {this.data});
}
