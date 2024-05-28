import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/bloc/repos/repos.dart';
import 'package:hyppe/core/config/url_constants.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/status_code.dart';
import 'package:hyppe/core/models/collection/transaction/coinpurchasedetail.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';

import 'state.dart';

class CoinPurchaseDetailDataBloc {
  CoinPurchaseDetailDataFetch _dataFetch = CoinPurchaseDetailDataFetch(CoinPurchaseDetailState.init);
  CoinPurchaseDetailDataFetch get dataFetch => _dataFetch;
  setCoinFetch(CoinPurchaseDetailDataFetch val) => _dataFetch = val;

  Future getCoinPurchaseDetail(BuildContext context,
      {Map? data}) async {
    setCoinFetch(CoinPurchaseDetailDataFetch(CoinPurchaseDetailState.loading));
    try {
      
      String email = SharedPreference().readStorage(SpKeys.email);
      await Repos().reposPost(
        context,
        (onResult) {
          if ((onResult.statusCode ?? 300) > HTTP_CODE) {
            setCoinFetch(
                CoinPurchaseDetailDataFetch(CoinPurchaseDetailState.getCoinPurchaseDetailBlocError));
          } else {
            setCoinFetch(
              CoinPurchaseDetailDataFetch(CoinPurchaseDetailState.getCoinPurchaseDetailBlocSuccess,
                  data: onResult.data['data'] != null
                      ? CointPurchaseDetailModel.fromJson(onResult.data['data'])
                      : null),
            );
          }
        },
        (errorData) {
          ShowBottomSheet.onInternalServerError(context, statusCode: errorData.response?.statusCode);
          setCoinFetch(
              CoinPurchaseDetailDataFetch(CoinPurchaseDetailState.getCoinPurchaseDetailBlocError));
          Dio().close(force: true);
        },
        headers: {
          'x-auth-user': email,
        },
        data: data,
        host: UrlConstants.coinpurchasedetail,
        methodType: MethodType.post,
        withAlertMessage: false,
        withCheckConnection: true,
      );
    } on SocketException catch (_) {
      setCoinFetch(
          CoinPurchaseDetailDataFetch(CoinPurchaseDetailState.getCoinPurchaseDetailBlocError));
      Dio().close(force: true);
    } catch (_) {
      setCoinFetch(
          CoinPurchaseDetailDataFetch(CoinPurchaseDetailState.getCoinPurchaseDetailBlocError));
      Dio().close(force: true);
    }
  }
}
