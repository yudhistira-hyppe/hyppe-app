enum TransactionCoinState {
  init,
  loading,
  getcBlocSuccess,
  getBlocError,
  getNotInternet,
}

class TransactionCoinFetch {
  final data;
  final TransactionCoinState dataState;
  TransactionCoinFetch(this.dataState, {this.data});
}