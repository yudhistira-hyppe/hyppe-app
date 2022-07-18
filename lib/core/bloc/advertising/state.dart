enum AdvertisingState {
  init,
  loading,
  getAdvertisingBlocSuccess,
  getAdvertisingBlocError,
}

class AdvertisingFetch {
  final data;
  final AdvertisingState advertisingState;
  AdvertisingFetch(this.advertisingState, {this.data});
}
