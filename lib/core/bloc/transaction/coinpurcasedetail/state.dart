enum CoinPurchaseDetailState {
  init,
  loading,
  getCoinPurchaseDetailBlocSuccess,
  getCoinPurchaseDetailBlocError,
  getNotInternet,
}

class CoinPurchaseDetailDataFetch {
  final data;
  final CoinPurchaseDetailState dataState;
  CoinPurchaseDetailDataFetch(this.dataState, {this.data});
}