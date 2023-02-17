enum GoogleMapPlaceState {
  init,
  loading,
  getGoogleMapPlaceBlocSuccess,
  getGoogleMapPlaceBlocError,
}

class GoogleMapPlaceFetch {
  final data;
  final GoogleMapPlaceState googleMapPlaceState;
  GoogleMapPlaceFetch(this.googleMapPlaceState, {this.data});
}
