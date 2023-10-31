import 'package:hyppe/core/bloc/google_map_place/state.dart';
import 'package:hyppe/core/bloc/repos/repos.dart';
import 'package:hyppe/core/config/url_constants.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/status_code.dart';
import 'package:hyppe/core/constants/utils.dart';
import 'package:hyppe/core/models/collection/google_map_place/google_geocoding_model.dart';
import 'package:hyppe/core/models/collection/google_map_place/model_google_map_place.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:flutter/material.dart';

class GoogleMapPlaceBloc {
  GoogleMapPlaceFetch _googleMapPlaceFetch = GoogleMapPlaceFetch(GoogleMapPlaceState.init);
  GoogleMapPlaceFetch get googleMapPlaceFetch => _googleMapPlaceFetch;
  setGoogleMapPlaceFetch(GoogleMapPlaceFetch val) => _googleMapPlaceFetch = val;

  Future getGoogleMapPlaceBloc(BuildContext context, {required String keyword, String? language, String? sessiontoken}) async {
    setGoogleMapPlaceFetch(GoogleMapPlaceFetch(GoogleMapPlaceState.loading));
    await Repos().reposPost(
      context,
      (onResult) {
        if ((onResult.statusCode ?? 300) != HTTP_OK) {
          setGoogleMapPlaceFetch(GoogleMapPlaceFetch(GoogleMapPlaceState.getGoogleMapPlaceBlocError));
        } else {
          final ModelGoogleMapPlace _result = ModelGoogleMapPlace.fromJson(onResult.data);
          setGoogleMapPlaceFetch(GoogleMapPlaceFetch(GoogleMapPlaceState.getGoogleMapPlaceBlocSuccess, data: _result.toJson()));
        }
      },
      (errorData) {
        setGoogleMapPlaceFetch(GoogleMapPlaceFetch(GoogleMapPlaceState.getGoogleMapPlaceBlocError));
      },
      host: "${UrlConstants.getGoogleMapApis}?input=$keyword&language=$language&key=$googleMapApiKey&sessiontoken=$sessiontoken",
      withAlertMessage: false,
      methodType: MethodType.get,
      withCheckConnection: false,
    );
  }
  
  Future getGoogleMapGeocodingBloc(BuildContext context, {required double latitude, required double longitude}) async {
    setGoogleMapPlaceFetch(GoogleMapPlaceFetch(GoogleMapPlaceState.loading));
    await Repos().reposPost(
      context,
      (onResult) {
        if ((onResult.statusCode ?? 300) != HTTP_OK) {
          setGoogleMapPlaceFetch(GoogleMapPlaceFetch(GoogleMapPlaceState.getGoogleMapPlaceBlocError));
        } else {
          final GoogleGeocodingModel _result = GoogleGeocodingModel.fromJson(onResult.data);
          setGoogleMapPlaceFetch(GoogleMapPlaceFetch(GoogleMapPlaceState.getGoogleMapPlaceBlocSuccess, data: _result.toJson()));
        }
      },
      (errorData) {
        setGoogleMapPlaceFetch(GoogleMapPlaceFetch(GoogleMapPlaceState.getGoogleMapPlaceBlocError));
      },
      host: "${UrlConstants.getGoogleGeocodingApis}?latlng=$latitude,$longitude&language=ID&key=$googleMapApiKey",
      withAlertMessage: false,
      methodType: MethodType.get,
      withCheckConnection: false,
    );
  }
}
