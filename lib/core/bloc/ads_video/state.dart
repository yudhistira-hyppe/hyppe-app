enum AdsVideoState {
  init,
  loading,
  getAdsVideoBlocSuccess,
  getAdsVideoBlocError,
}

class AdsVideoFetch {
  // ignore: prefer_typing_uninitialized_variables
  final data;
  final AdsVideoState adsVideoState;
  AdsVideoFetch(this.adsVideoState, {this.data});
}