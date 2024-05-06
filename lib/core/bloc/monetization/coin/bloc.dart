import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/bloc/repos/repos.dart';
import 'package:hyppe/core/config/url_constants.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/status_code.dart';
import 'package:hyppe/core/models/collection/coins/coinmodel.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';

import 'state.dart';

class CoinDataBloc {
  CoinDataFetch _dataFetch = CoinDataFetch(CoinState.init);
  CoinDataFetch get dataFetch => _dataFetch;
  setCoinFetch(CoinDataFetch val) => _dataFetch = val;

  Future getCoin(BuildContext context,
      {int? page, int? limit, bool? desc}) async {
    setCoinFetch(CoinDataFetch(CoinState.loading));
    try {
      Map<String, dynamic> data = {
        'page': page ?? 0,
        'limit': limit ?? 20,
        'descending': desc ?? true,
        'type': 'COIN'
      };
      String email = SharedPreference().readStorage(SpKeys.email);
      await Repos().reposPost(
        context,
        (onResult) {
          if ((onResult.statusCode ?? 300) > HTTP_CODE) {
            setCoinFetch(
                CoinDataFetch(CoinState.getCoinBlocError));
          } else {
            setCoinFetch(
              CoinDataFetch(CoinState.getCoinBlocSuccess,
                  data: onResult.data['data'] != null
                      ? List.from(onResult.data['data'])
                          .map((e) => CointModel.fromJson(e))
                          .toList()
                      : null),
            );
          }
        },
        (errorData) {
          ShowBottomSheet.onInternalServerError(context, statusCode: errorData.response?.statusCode);
          setCoinFetch(
              CoinDataFetch(CoinState.getCoinBlocError));
          Dio().close(force: true);
        },
        headers: {
          'x-auth-user': email,
        },
        data: data,
        host: UrlConstants.listmonetization,
        methodType: MethodType.post,
        withAlertMessage: false,
        withCheckConnection: true,
      );
    } on SocketException catch (_) {
      setCoinFetch(
          CoinDataFetch(CoinState.getCoinBlocError));
      Dio().close(force: true);
    } catch (_) {
      setCoinFetch(
          CoinDataFetch(CoinState.getCoinBlocError));
      Dio().close(force: true);
    }
  }
}
