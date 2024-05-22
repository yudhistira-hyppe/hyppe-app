enum SaldoCoinState {
  init,
  loading,
  getBlocSuccess,
  getBlocError,
  getInternet,
}

class SaldoCoinDataFetch {
  final data;
  final SaldoCoinState dataState;
  SaldoCoinDataFetch(this.dataState, {this.data});
}