enum TransactionCoinDetailState {
  init,
  loading,
  getcBlocSuccess,
  getBlocError,
  getNotInternet,
}

class TransactionCoinDetailFetch {
  final data;
  final TransactionCoinDetailState dataState;
  TransactionCoinDetailFetch(this.dataState, {this.data});
}