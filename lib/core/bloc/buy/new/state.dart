enum BuyDataNewState {
  init,
  loading,
  getBlocSuccess,
  getBlocError,
  getInternet,
}

class BuyDataNewFetch {
  final data;
  final BuyDataNewState dataState;
  BuyDataNewFetch(this.dataState, {this.data});
}