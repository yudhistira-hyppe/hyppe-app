import 'package:hyppe/core/bloc/challange/state.dart';
import 'package:hyppe/core/bloc/repos/repos.dart';
import 'package:hyppe/core/config/url_constants.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/status_code.dart';
import 'package:hyppe/core/models/collection/chalange/banner_request.dart';
import 'package:hyppe/core/response/generic_response.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../constants/shared_preference_keys.dart';

class ChallangeBloc {
  ChallangeFetch _challangeFetch = ChallangeFetch(ChallengeState.init);
  ChallangeFetch get userFetch => _challangeFetch;
  setChallangeFetch(ChallangeFetch val) => _challangeFetch = val;

  Future postChallange(
    BuildContext context, {
    required Map data,
    required String url,
  }) async {
    setChallangeFetch(ChallangeFetch(ChallengeState.loading));

    await Repos().reposPost(
      context,
      (onResult) {
        if ((onResult.statusCode ?? 300) > HTTP_CODE) {
          setChallangeFetch(ChallangeFetch(ChallengeState.getPostError, data: onResult.data));
        } else {
          setChallangeFetch(ChallangeFetch(ChallengeState.getPostSuccess, data: GenericResponse.fromJson(onResult.data).responseData));
        }
      },
      (errorData) {
        ShowBottomSheet.onInternalServerError(context);
        setChallangeFetch(ChallangeFetch(ChallengeState.getPostError));
        Dio().close(force: true);
      },
      onNoInternet: () {
        Routing().moveBack();
      },
      data: data,
      withAlertMessage: false,
      withCheckConnection: false,
      host: url,
      methodType: MethodType.post,
    );
  }

  Future getBanners(BuildContext context) async{
    setChallangeFetch(ChallangeFetch(ChallengeState.loading));

    await Repos().reposPost(
      context,
          (onResult) {
        if ((onResult.statusCode ?? 300) > HTTP_CODE) {
          setChallangeFetch(ChallangeFetch(ChallengeState.getPostError, data: onResult.data));
        } else {
          setChallangeFetch(ChallangeFetch(ChallengeState.getPostSuccess, data: GenericResponse.fromJson(onResult.data).responseData));
        }
      },
          (errorData) {
        ShowBottomSheet.onInternalServerError(context);
        setChallangeFetch(ChallangeFetch(ChallengeState.getPostError));
        Dio().close(force: true);
      },
      onNoInternet: () {
        Routing().moveBack();
      },
      data: BannerRequest().toJson(),
      withAlertMessage: false,
      withCheckConnection: false,
      host: UrlConstants.getBanners,
      methodType: MethodType.post,
    );
  }

  Future checkChallengeStatus(BuildContext context) async {
    final userId = SharedPreference().readStorage(SpKeys.userID);
    setChallangeFetch(ChallangeFetch(ChallengeState.loading));
    await Repos().reposPost(context, (onResult){
      if ((onResult.statusCode ?? 300) > HTTP_CODE) {
        setChallangeFetch(ChallangeFetch(ChallengeState.getPostError, data: onResult.data));
      } else {
        setChallangeFetch(ChallangeFetch(ChallengeState.getPostSuccess, data: GenericResponse.fromJson(onResult.data).responseData));
      }
    }, (errorData) {
      ShowBottomSheet.onInternalServerError(context);
      setChallangeFetch(ChallangeFetch(ChallengeState.getPostError));
      Dio().close(force: true);
    }, host: UrlConstants.checkChallengeStatus,
        data: {
          'idUser' : userId
        },
        withAlertMessage: false,
        methodType: MethodType.post,
        withCheckConnection: false);
  }
}
