enum WithdrawalTransactionDetailState {
  init,
  loading,
  getcBlocSuccess,
  getBlocError,
  getNotInternet,
}

class WithdrawalTransactionDetailFetch {
  final data;
  final WithdrawalTransactionDetailState dataState;
  WithdrawalTransactionDetailFetch(this.dataState, {this.data});
}