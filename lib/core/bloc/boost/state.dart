enum BoostPostContentState {
  init,
  loading,
  getBlocSuccess,
  getBlocError,
  getInternet,
}

class BoostPostContentDataFetch {
  final data;
  final BoostPostContentState dataState;
  BoostPostContentDataFetch(this.dataState, {this.data});
}