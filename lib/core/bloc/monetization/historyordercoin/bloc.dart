import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/bloc/repos/repos.dart';
import 'package:hyppe/core/config/url_constants.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/status_code.dart';
import 'package:hyppe/core/models/collection/coins/history_order_coin.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';

import 'state.dart';

class HistoryOrderCoinDataBloc {
  HistoryOrderCoinDataFetch _dataFetch = HistoryOrderCoinDataFetch(HistoryOrderCoinState.init);
  HistoryOrderCoinDataFetch get dataFetch => _dataFetch;
  setHistoryOrderCoinFetch(HistoryOrderCoinDataFetch val) => _dataFetch = val;

  Future getHistoryOrderCoin(BuildContext context,
      {int? page, int? limit, String? startdate, String? enddate}) async {
    setHistoryOrderCoinFetch(HistoryOrderCoinDataFetch(HistoryOrderCoinState.loading));
    try {
      Map<String, dynamic> data;
      if (startdate == null || enddate == null){
        data = {
          'page': page ?? 0,
          'limit': limit ?? 5
        };
      }else{
        data = {
          'page': page ?? 0,
          'limit': limit ?? 5,
          'startdate': startdate,
          'enddate': enddate,
        };
      }
      String email = SharedPreference().readStorage(SpKeys.email);
      await Repos().reposPost(
        context,
        (onResult) {
          if ((onResult.statusCode ?? 300) > HTTP_CODE) {
            setHistoryOrderCoinFetch(
                HistoryOrderCoinDataFetch(HistoryOrderCoinState.getBlocError));
          } else {
            setHistoryOrderCoinFetch(
              HistoryOrderCoinDataFetch(HistoryOrderCoinState.getBlocSuccess,
                  data: onResult.data['data'] != null
                      ? List.from(onResult.data['data'])
                          .map((e) => HistoryOrderCoinModel.fromJson(e))
                          .toList()
                      : null),
            );
          }
        },
        (errorData) {
          ShowBottomSheet.onInternalServerError(context, statusCode: errorData.response?.statusCode);
          setHistoryOrderCoinFetch(
              HistoryOrderCoinDataFetch(HistoryOrderCoinState.getBlocError));
          Dio().close(force: true);
        },
        headers: {
          'x-auth-user': email,
        },
        data: data,
        host: UrlConstants.historyordercoin,
        methodType: MethodType.post,
        withAlertMessage: false,
        withCheckConnection: true,
      );
    } on SocketException catch (_) {
      setHistoryOrderCoinFetch(
          HistoryOrderCoinDataFetch(HistoryOrderCoinState.getBlocError));
      Dio().close(force: true);
    } catch (_) {
      setHistoryOrderCoinFetch(
          HistoryOrderCoinDataFetch(HistoryOrderCoinState.getBlocError));
      Dio().close(force: true);
    }
  }
}
