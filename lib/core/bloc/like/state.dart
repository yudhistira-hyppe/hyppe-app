enum LikeState {
  init,
  loading,
  likeUserPostSuccess,
  likeUserPostFailed,
}

class LikeFetch {
  final data;
  final LikeState likeState;
  LikeFetch(this.likeState, {this.data});
}
