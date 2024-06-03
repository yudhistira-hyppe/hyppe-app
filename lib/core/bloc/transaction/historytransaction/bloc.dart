import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/bloc/repos/repos.dart';
import 'package:hyppe/core/config/url_constants.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/status_code.dart';
import 'package:hyppe/core/models/collection/coins/history_transaction.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';

import 'state.dart';

class HistoryTransactionDataBloc {
  HistoryTransactionDataFetch _dataFetch = HistoryTransactionDataFetch(HistoryTransactionState.init);
  HistoryTransactionDataFetch get dataFetch => _dataFetch;
  setHistoryTransactionFetch(HistoryTransactionDataFetch val) => _dataFetch = val;

  Future getHistoryTransaction(BuildContext context,
      {Map? data}) async {
    setHistoryTransactionFetch(HistoryTransactionDataFetch(HistoryTransactionState.loading));
    try {
      String email = SharedPreference().readStorage(SpKeys.email);
      await Repos().reposPost(
        context,
        (onResult) {
          if ((onResult.statusCode ?? 300) > HTTP_CODE) {
            setHistoryTransactionFetch(
                HistoryTransactionDataFetch(HistoryTransactionState.getBlocError));
          } else {
            setHistoryTransactionFetch(
              HistoryTransactionDataFetch(HistoryTransactionState.getBlocSuccess,
                  data: onResult.data['data'] != null
                      ? List.from(onResult.data['data'])
                          .map((e) => TransactionHistoryCoinModel.fromJson(e))
                          .toList()
                      : null),
            );
          }
        },
        (errorData) {
          ShowBottomSheet.onInternalServerError(context, statusCode: errorData.response?.statusCode);
          setHistoryTransactionFetch(
              HistoryTransactionDataFetch(HistoryTransactionState.getBlocError));
          Dio().close(force: true);
        },
        headers: {
          'x-auth-user': email,
        },
        data: data,
        host: UrlConstants.historytransactioncoin,
        methodType: MethodType.post,
        withAlertMessage: false,
        withCheckConnection: true,
      );
    } on SocketException catch (_) {
      setHistoryTransactionFetch(
          HistoryTransactionDataFetch(HistoryTransactionState.getBlocError));
      Dio().close(force: true);
    } catch (_) {
      setHistoryTransactionFetch(
          HistoryTransactionDataFetch(HistoryTransactionState.getBlocError));
      Dio().close(force: true);
    }
  }
}
