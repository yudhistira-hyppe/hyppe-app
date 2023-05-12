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
  final String? version;
  final String? versionIos;
  PostsFetch(this.postsState, {this.data, this.version, this.versionIos});
}
