enum DiscState {
  init,
  loading,
  getDiscBlocSuccess,
  getDiscBlocError,
  getNotInternet,
}

class DiscDataFetch {
  final data;
  final DiscState dataState;
  DiscDataFetch(this.dataState, {this.data});
}