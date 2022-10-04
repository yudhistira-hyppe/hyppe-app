enum AdsDataState {
  init,
  loading,
  getAdsVideoBlocSuccess,
  getAdsVideoBlocError,
}

class AdsDataFetch {
  // ignore: prefer_typing_uninitialized_variables
  final data;
  final AdsDataState adsDataState;
  AdsDataFetch(this.adsDataState, {this.data});
}