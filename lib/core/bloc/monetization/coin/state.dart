enum CoinState {
  init,
  loading,
  getCoinBlocSuccess,
  getCoinBlocError,
  getNotInternet,
}

class CoinDataFetch {
  final data;
  final CoinState dataState;
  CoinDataFetch(this.dataState, {this.data});
}