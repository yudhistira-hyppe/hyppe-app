enum PostViewerState {
  init,
  loading,
  postViewerUserSuccess,
  postViewerUserError,
  likeViewError,
  likeViewSuccess,
}

class PostViewerFetch {
  final data;
  final PostViewerState postViewerState;
  PostViewerFetch(this.postViewerState, {this.data});
}
