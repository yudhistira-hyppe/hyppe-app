enum HistoryTransactionState {
  init,
  loading,
  getBlocSuccess,
  getBlocError,
  getNotInternet,
}

class HistoryTransactionDataFetch {
  final data;
  final HistoryTransactionState dataState;
  HistoryTransactionDataFetch(this.dataState, {this.data});
}