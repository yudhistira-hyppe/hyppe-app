import 'package:dio/dio.dart';
import 'package:hyppe/core/arguments/advertising_argument.dart';
import 'package:hyppe/core/bloc/advertising/state.dart';
import 'package:hyppe/core/bloc/repos/repos.dart';
import 'package:hyppe/core/config/url_constants.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/status_code.dart';
import 'package:hyppe/core/models/collection/advertising/advertising_data.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:flutter/material.dart';

class AdvertisingBloc {
  AdvertisingFetch _advertisingFetch = AdvertisingFetch(AdvertisingState.init);
  AdvertisingFetch get advertisingFetchFetch => _advertisingFetch;
  setCommentFetch(AdvertisingFetch val) => _advertisingFetch = val;

  Future advertisingBlocV2(
    BuildContext context, {
    required AdvertisingArgument argument,
  }) async {
    setCommentFetch(AdvertisingFetch(AdvertisingState.loading));
    final formData = FormData();
    final email = SharedPreference().readStorage(SpKeys.email);

    formData.fields.add(MapEntry('email', argument.email));
    formData.fields.add(MapEntry('postID', argument.postID));

    await Repos().reposPost(
      context,
      (onResult) {
        if ((onResult.statusCode ?? 300) > HTTP_CODE) {
          setCommentFetch(AdvertisingFetch(AdvertisingState.getAdvertisingBlocError));
        } else {
          final _response = AdvertisingData.fromJson(onResult.data, argument.metadata);
          setCommentFetch(AdvertisingFetch(AdvertisingState.getAdvertisingBlocSuccess, data: _response));
        }
      },
      (errorData) {
        setCommentFetch(AdvertisingFetch(AdvertisingState.getAdvertisingBlocError));
      },
      data: formData,
      host: UrlConstants.getAdsRoster,
      withAlertMessage: false,
      withCheckConnection: false,
      methodType: MethodType.post,
      headers: {'x-auth-user': email},
    );
  }
}
