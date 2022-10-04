enum PostsState {
  init,
  loading,
  getAllContentsSuccess,
  getAllContentsError,
  getContentsSuccess,
  getContentsError,
  postContentsSuccess,
  postContentsError,
  deleteContentsSuccess,
  deleteContentsError,
  updateContentsSuccess,
  updateContentsError,
  videoApsaraSuccess,
  videoApsaraError,
}

class PostsFetch {
  final data;
  final PostsState postsState;
  final version;
  PostsFetch(this.postsState, {this.data, this.version});
}
