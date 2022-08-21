enum BuyState {
  init,
  loading,
  getContentsSuccess,
  getContentsError,
  postContentsSuccess,
  postContentsError
}

class BuyFetch {
  final data;
  final BuyState postsState;
  final version;
  BuyFetch(this.postsState, {this.data, this.version});
}
