enum HistoryOrderCoinState {
  init,
  loading,
  getBlocSuccess,
  getBlocError,
  getNotInternet,
}

class HistoryOrderCoinDataFetch {
  final data;
  final HistoryOrderCoinState dataState;
  HistoryOrderCoinDataFetch(this.dataState, {this.data});
}