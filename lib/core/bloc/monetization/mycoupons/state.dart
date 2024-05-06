enum MyCouponsState {
  init,
  loading,
  getMyCouponsBlocSuccess,
  getMyCouponsBlocError,
  getNotInternet,
}

class MyCouponsDataFetch {
  final data;
  final MyCouponsState dataState;
  MyCouponsDataFetch(this.dataState, {this.data});
}