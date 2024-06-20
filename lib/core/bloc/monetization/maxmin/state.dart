enum MaxminCoinState {
  init,
  loading,
  getBlocSuccess,
  getBlocError,
  getNotInternet,
}

class MaxminCoinDataFetch {
  final data;
  final MaxminCoinState dataState;
  MaxminCoinDataFetch(this.dataState, {this.data});
}