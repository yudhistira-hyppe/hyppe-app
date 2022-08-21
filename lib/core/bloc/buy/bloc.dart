import 'package:flutter/material.dart';
import 'package:hyppe/core/bloc/buy/state.dart';
import 'package:hyppe/core/config/url_constants.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/buy_request.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/core/bloc/repos/repos.dart';
import 'package:hyppe/core/constants/status_code.dart';
import 'package:hyppe/core/response/generic_response.dart';

class BuyBloc {
  final _repos = Repos();

  BuyFetch _buyFetch = BuyFetch(BuyState.init);
  BuyFetch get buyFetch => _buyFetch;
  setBuyFetch(BuyFetch val) => _buyFetch = val;

  Future getBuyContent(BuildContext context, {required String? postId}) async {
    var type = FeatureType.other;
    setBuyFetch(BuyFetch(BuyState.loading));
    await _repos.reposPost(
      context,
      (onResult) {
        if (onResult.statusCode! > HTTP_CODE) {
          setBuyFetch(BuyFetch(BuyState.getContentsError, data: onResult.data));
        } else {
          setBuyFetch(BuyFetch(BuyState.getContentsSuccess,
              version: onResult.data['version'],
              data: GenericResponse.fromJson(onResult.data).responseData));
        }
      },
      (errorData) {
        setBuyFetch(BuyFetch(BuyState.getContentsError, data: errorData.error));
      },
      data: {'postID': postId},
      host: UrlConstants.getBuyContent,
      withAlertMessage: false,
      withCheckConnection: false,
      methodType: MethodType.post,
      errorServiceType: System().getErrorTypeV2(type),
    );
  }

  Future getBank(BuildContext context) async {
    var type = FeatureType.other;
    setBuyFetch(BuyFetch(BuyState.loading));
    await _repos.reposPost(
      context,
      (onResult) {
        if (onResult.statusCode! > HTTP_CODE) {
          setBuyFetch(BuyFetch(BuyState.getContentsError, data: onResult.data));
        } else {
          setBuyFetch(BuyFetch(BuyState.getContentsSuccess,
              version: onResult.data['version'],
              data: GenericResponse.fromJson(onResult.data).responseData));
        }
      },
      (errorData) {
        setBuyFetch(BuyFetch(BuyState.getContentsError, data: errorData.error));
      },
      host: UrlConstants.getAllBank,
      withAlertMessage: false,
      withCheckConnection: false,
      methodType: MethodType.get,
      errorServiceType: System().getErrorTypeV2(type),
    );
  }

  Future getBankByCode(BuildContext context,
      {required String? codeBank}) async {
    var type = FeatureType.other;
    setBuyFetch(BuyFetch(BuyState.loading));
    await _repos.reposPost(
      context,
      (onResult) {
        if (onResult.statusCode! > HTTP_CODE) {
          setBuyFetch(BuyFetch(BuyState.getContentsError, data: onResult.data));
        } else {
          setBuyFetch(BuyFetch(BuyState.getContentsSuccess,
              version: onResult.data['version'],
              data: GenericResponse.fromJson(onResult.data).responseData));
        }
      },
      (errorData) {
        setBuyFetch(BuyFetch(BuyState.getContentsError, data: errorData.error));
      },
      data: {'bankcode': codeBank},
      host: UrlConstants.getBankByCode,
      withAlertMessage: false,
      withCheckConnection: false,
      methodType: MethodType.post,
      errorServiceType: System().getErrorTypeV2(type),
    );
  }

  Future postContentBuy(BuildContext context,
      {required BuyRequest? params}) async {
    var type = FeatureType.other;
    setBuyFetch(BuyFetch(BuyState.loading));
    await _repos.reposPost(
      context,
      (onResult) {
        if (onResult.statusCode! > HTTP_CODE) {
          setBuyFetch(
              BuyFetch(BuyState.postContentsError, data: onResult.data));
        } else {
          setBuyFetch(BuyFetch(BuyState.postContentsSuccess,
              version: onResult.data['version'],
              data: GenericResponse.fromJson(onResult.data).responseData));
        }
      },
      (errorData) {
        setBuyFetch(
            BuyFetch(BuyState.postContentsError, data: errorData.error));
      },
      data: params,
      withAlertMessage: true,
      withCheckConnection: true,
      host: UrlConstants.postBuyContent,
      methodType: MethodType.post,
      errorServiceType: System().getErrorTypeV2(type),
    );
  }
}
