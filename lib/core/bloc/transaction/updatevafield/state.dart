enum UpdateVaFieldState {
  init,
  loading,
  getUpdateVaBlocSuccess,
  getUpdateVaBlocError,
  getNotInternet,
}

class UpdateVaFieldDataFetch {
  final data;
  final UpdateVaFieldState dataState;
  UpdateVaFieldDataFetch(this.dataState, {this.data});
}