enum GiftState {
  init,
  loading,
  getBlocSuccess,
  getBlocError,
  getNotInternet,
}

class GiftDataFetch {
  final data;
  final GiftState dataState;
  GiftDataFetch(this.dataState, {this.data});
}