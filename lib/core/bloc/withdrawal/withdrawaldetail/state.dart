enum WithdrawalDetailState {
  init,
  loading,
  getcBlocSuccess,
  getBlocError,
  getNotInternet,
}

class WithdrawalDetailFetch {
  final data;
  final WithdrawalDetailState dataState;
  WithdrawalDetailFetch(this.dataState, {this.data});
}