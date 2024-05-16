enum ActivationGiftState {
  init,
  loading,
  getBlocSuccess,
  getBlocError,
  getNotInternet,
}

class ActivationGiftDataFetch {
  final data;
  final ActivationGiftState dataState;
  ActivationGiftDataFetch(this.dataState, {this.data});
}