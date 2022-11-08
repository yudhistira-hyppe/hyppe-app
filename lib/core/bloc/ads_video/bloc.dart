import 'package:flutter/cupertino.dart';
import 'package:hyppe/core/bloc/ads_video/state.dart';
import 'package:hyppe/core/bloc/repos/repos.dart';
import 'package:hyppe/core/config/url_constants.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/models/collection/advertising/ads_video_data.dart';
import 'package:hyppe/core/models/collection/advertising/view_ads_request.dart';
import 'package:hyppe/core/response/generic_response.dart';
import 'package:hyppe/core/services/shared_preference.dart';

import '../../constants/status_code.dart';

class AdsDataBloc {
  AdsDataFetch _adsDataFetch = AdsDataFetch(AdsDataState.init);
  AdsDataFetch get adsDataFetch => _adsDataFetch;
  setCommentFetch(AdsDataFetch val) => _adsDataFetch = val;

  Future adsVideoBloc(BuildContext context, bool isContent) async {
    setCommentFetch(AdsDataFetch(AdsDataState.loading));
    final email = SharedPreference().readStorage(SpKeys.email);
    final token = SharedPreference().readStorage(SpKeys.userToken);
    await Repos().reposPost(context, (onResult) {
      if ((onResult.statusCode ?? 300)  > HTTP_CODE) {
        setCommentFetch(AdsDataFetch(AdsDataState.getAdsVideoBlocError));
      } else {
        print('data: ${onResult.data}');
        final response = AdsVideo.fromJson(onResult.data);
        setCommentFetch(AdsDataFetch(AdsDataState.getAdsVideoBlocSuccess,
            data: response));
      }
    },
        (errorData) =>
            setCommentFetch(AdsDataFetch(AdsDataState.getAdsVideoBlocError)),
        host: isContent ? UrlConstants.getAdsVideo : UrlConstants.getSponsoredAds,
        withAlertMessage: false,
        withCheckConnection: false,
        methodType: MethodType.get,
        headers: {
          'x-auth-user': email,
          'x-auth-token': token,
        });
  }
  
  Future appAdsBloc(BuildContext context) async{
    setCommentFetch(AdsDataFetch(AdsDataState.loading));
    final email = SharedPreference().readStorage(SpKeys.email);
    final token = SharedPreference().readStorage(SpKeys.userToken);
    await Repos().reposPost(context, (onResult) {
      if ((onResult.statusCode ?? 300) > HTTP_CODE) {
        setCommentFetch(AdsDataFetch(AdsDataState.getAdsVideoBlocError));
      } else {
        print('data: ${onResult.data}');
        final response = AdsVideo.fromJson(onResult.data);
        setCommentFetch(AdsDataFetch(AdsDataState.getAdsVideoBlocSuccess,
            data: response));
      }
    },
            (errorData) =>
            setCommentFetch(AdsDataFetch(AdsDataState.getAdsVideoBlocError)),
        host: UrlConstants.getInAppAds,
        withAlertMessage: false,
        withCheckConnection: false,
        methodType: MethodType.get,
        headers: {
          'x-auth-user': email,
          'x-auth-token': token,
        });
  }

  Future viewAdsBloc(BuildContext context, ViewAdsRequest request, {bool isClick = false}) async {
    setCommentFetch(AdsDataFetch(AdsDataState.loading));
    final email = SharedPreference().readStorage(SpKeys.email);
    final token = SharedPreference().readStorage(SpKeys.userToken);
    await Repos().reposPost(context, (onResult) {
      if ((onResult.statusCode ?? 300) > HTTP_CODE) {
        setCommentFetch(AdsDataFetch(AdsDataState.getAdsVideoBlocError));
      } else {
        print('data: ${onResult.data}');
        final response = GenericResponse.fromJson(onResult.data);
        setCommentFetch(AdsDataFetch(AdsDataState.getAdsVideoBlocSuccess,
            data: response));
      }
    },
        (errorData) =>
            setCommentFetch(AdsDataFetch(AdsDataState.getAdsVideoBlocError)),
        host: isClick ? UrlConstants.clickAds : UrlConstants.viewAds,
        withAlertMessage: false,
        data: request.toJson(),
        methodType: MethodType.post,
        withCheckConnection: false,
        headers: {
          'x-auth-user': email,
          'x-auth-token': token,
        });
  }
}
