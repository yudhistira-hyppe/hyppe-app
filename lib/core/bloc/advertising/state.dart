enum AdvertisingState {
  init,
  loading,
  getAdvertisingBlocSuccess,
  getAdvertisingBlocError,
}

class AdvertisingFetch {
  // ignore: prefer_typing_uninitialized_variables
  final data;
  final AdvertisingState advertisingState;
  AdvertisingFetch(this.advertisingState, {this.data});
}
