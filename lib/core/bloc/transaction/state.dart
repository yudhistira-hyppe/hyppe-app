enum TransactionState {
  init,
  loading,
  getBankAccontSuccess,
  getBankAccontError,
  addBankAccontError,
  addBankAccontSuccess,
  getHistorySuccess,
  getHistoryError,
  getDetailHistorySuccess,
  getDetailHistoryError,
  deleteBankAccontError,
  deleteBankAccontSuccess,
  getAccountBalanceSuccess,
  getAccountBalanceError,
  sendVerificationError,
  sendVerificationSuccess,
  summaryWithdrawalSuccess,
  summaryWithdrawalError,
  createWithdrawalSuccess,
  createWithdrawalError,
  checkPandingSuccess,
  checkPandingError,
}

class TransactionFetch {
  final data;
  final message;
  final TransactionState postsState;
  final version;
  TransactionFetch(this.postsState, {this.data, this.message, this.version});
}
