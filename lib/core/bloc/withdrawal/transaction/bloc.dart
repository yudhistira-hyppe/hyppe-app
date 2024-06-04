import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/bloc/repos/repos.dart';
import 'package:hyppe/core/config/url_constants.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/status_code.dart';
import 'package:hyppe/core/models/collection/withdrawal/withdrawaltransaction.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';

import 'state.dart';

class WithdrawalTransactionBloc {
  WithdrawalTransactionFetch _dataFetch = WithdrawalTransactionFetch(WithdrawalTransactionState.init);
  WithdrawalTransactionFetch get dataFetch => _dataFetch;
  setDiscFetch(WithdrawalTransactionFetch val) => _dataFetch = val;

  Future postWithdrawalTransaction(BuildContext context,
      {Map? data}) async {
    setDiscFetch(WithdrawalTransactionFetch(WithdrawalTransactionState.loading));
    try {
      String email = SharedPreference().readStorage(SpKeys.email);
      await Repos().reposPost(
        context,
        (onResult) {
          if ((onResult.statusCode ?? 300) > HTTP_CODE) {
            setDiscFetch(
                WithdrawalTransactionFetch(WithdrawalTransactionState.getBlocError, data: onResult.data));
          } else {
            setDiscFetch(
              WithdrawalTransactionFetch(WithdrawalTransactionState.getcBlocSuccess,
                  data: WithdrawalTransactionModel.fromJson(onResult.data['data'])),
            );
          }
        },
        (errorData) {
          ShowBottomSheet.onInternalServerError(context, statusCode: errorData.response?.statusCode);
          setDiscFetch(
              WithdrawalTransactionFetch(WithdrawalTransactionState.getBlocError, data: errorData));
          Dio().close(force: true);
        },
        headers: {
          'x-auth-user': email,
        },
        data: data,
        host: UrlConstants.withdrawcoin,
        methodType: MethodType.post,
        withAlertMessage: false,
        withCheckConnection: true,
      );
    } on SocketException catch (_) {
      setDiscFetch(
          WithdrawalTransactionFetch(WithdrawalTransactionState.getBlocError));
      Dio().close(force: true);
    } catch (_) {
      setDiscFetch(
          WithdrawalTransactionFetch(WithdrawalTransactionState.getBlocError));
      Dio().close(force: true);
    }
  }
}
