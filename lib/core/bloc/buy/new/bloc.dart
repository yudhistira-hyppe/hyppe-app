import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/bloc/repos/repos.dart';
import 'package:hyppe/core/config/url_constants.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/status_code.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/buy/buy_data_new.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';

import 'state.dart';

class BuyDataNewBloc {
  BuyDataNewFetch _dataFetch = BuyDataNewFetch(BuyDataNewState.init);
  BuyDataNewFetch get dataFetch => _dataFetch;
  setBuyDataNewFetch(BuyDataNewFetch val) => _dataFetch = val;

  Future getBuyDataNew(BuildContext context, {Map? data}) async {
    setBuyDataNewFetch(BuyDataNewFetch(BuyDataNewState.loading));
    try {
      
      String email = SharedPreference().readStorage(SpKeys.email);
      await Repos().reposPost(
        context,
        (onResult) {
          if ((onResult.statusCode ?? 300) > HTTP_CODE) {
            setBuyDataNewFetch(
                BuyDataNewFetch(BuyDataNewState.getBlocError));
          } else {
            setBuyDataNewFetch(
              BuyDataNewFetch(BuyDataNewState.getBlocSuccess,
                  data: onResult.data['data'] != null
                      ? BuyDataNew.fromJson(onResult.data['data'])
                      : null),
            );
          }
        },
        (errorData) {
          ShowBottomSheet.onInternalServerError(context, statusCode: errorData.response?.statusCode);
          setBuyDataNewFetch(
              BuyDataNewFetch(BuyDataNewState.getBlocError));
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
      setBuyDataNewFetch(
          BuyDataNewFetch(BuyDataNewState.getBlocError));
      Dio().close(force: true);
    } catch (_) {
      setBuyDataNewFetch(
          BuyDataNewFetch(BuyDataNewState.getBlocError));
      Dio().close(force: true);
    }
  }
}
