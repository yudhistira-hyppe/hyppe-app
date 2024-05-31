enum WithdrawalTransactionState {
  init,
  loading,
  getcBlocSuccess,
  getBlocError,
  getNotInternet,
}

class WithdrawalTransactionFetch {
  final data;
  final WithdrawalTransactionState dataState;
  WithdrawalTransactionFetch(this.dataState, {this.data});
}