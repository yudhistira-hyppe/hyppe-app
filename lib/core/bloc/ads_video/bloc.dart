import 'package:flutter/cupertino.dart';
import 'package:hyppe/core/bloc/ads_video/state.dart';
import 'package:hyppe/core/bloc/repos/repos.dart';
import 'package:hyppe/core/config/url_constants.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/models/collection/advertising/ads_video_data.dart';
import 'package:hyppe/core/services/shared_preference.dart';

import '../../constants/status_code.dart';

class AdsVideoBloc {
  AdsVideoFetch _adsVideoFetch = AdsVideoFetch(AdsVideoState.init);
  AdsVideoFetch get adsVideoFetch => _adsVideoFetch;
  setCommentFetch(AdsVideoFetch val) => _adsVideoFetch = val;

  Future adsVideoBloc(BuildContext context) async {
    setCommentFetch(AdsVideoFetch(AdsVideoState.loading));
    final email = SharedPreference().readStorage(SpKeys.email);

    await Repos().reposPost(context, (onResult) {
      if (onResult.statusCode! > HTTP_CODE) {
        setCommentFetch(AdsVideoFetch(AdsVideoState.getAdsVideoBlocError));
      } else {
        final response = AdsVideo.fromJson(onResult.data);
        setCommentFetch(AdsVideoFetch(AdsVideoState.getAdsVideoBlocSuccess,
            data: response));
      }
    },
        (errorData) =>
            setCommentFetch(AdsVideoFetch(AdsVideoState.getAdsVideoBlocError)),
        host: UrlConstants.getAdsVideo,
        withAlertMessage: false,
        withCheckConnection: false,
        methodType: MethodType.get,
        headers: {
          'x-auth-user': email,
          'x-auth-token': SharedPreference().readStorage(SpKeys.userToken),
        });
  }
}
