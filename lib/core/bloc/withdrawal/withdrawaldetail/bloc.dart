import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/bloc/repos/repos.dart';
import 'package:hyppe/core/config/url_constants.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/status_code.dart';
import 'package:hyppe/core/models/collection/withdrawal/withdrawaldetail.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';

import 'state.dart';

class WithdrawalDetailBloc {
  WithdrawalDetailFetch _dataFetch = WithdrawalDetailFetch(WithdrawalDetailState.init);
  WithdrawalDetailFetch get dataFetch => _dataFetch;
  setDiscFetch(WithdrawalDetailFetch val) => _dataFetch = val;

  Future getWithdrawalDetail(BuildContext context,
      {Map? data}) async {
    setDiscFetch(WithdrawalDetailFetch(WithdrawalDetailState.loading));
    try {
      String email = SharedPreference().readStorage(SpKeys.email);
      await Repos().reposPost(
        context,
        (onResult) {
          if ((onResult.statusCode ?? 300) > HTTP_CODE) {
            setDiscFetch(
                WithdrawalDetailFetch(WithdrawalDetailState.getBlocError, data: onResult.data));
          } else {
            setDiscFetch(
              WithdrawalDetailFetch(WithdrawalDetailState.getcBlocSuccess,
                  data: DetailWithdrawalModel.fromJson(onResult.data['data'])),
            );
          }
        },
        (errorData) {
          ShowBottomSheet.onInternalServerError(context, statusCode: errorData.response?.statusCode);
          setDiscFetch(
              WithdrawalDetailFetch(WithdrawalDetailState.getBlocError, data: errorData));
          Dio().close(force: true);
        },
        headers: {
          'x-auth-user': email,
        },
        data: data,
        host: UrlConstants.withdrawaldetail,
        methodType: MethodType.post,
        withAlertMessage: false,
        withCheckConnection: true,
      );
    } on SocketException catch (_) {
      setDiscFetch(
          WithdrawalDetailFetch(WithdrawalDetailState.getBlocError));
      Dio().close(force: true);
    } catch (_) {
      setDiscFetch(
          WithdrawalDetailFetch(WithdrawalDetailState.getBlocError));
      Dio().close(force: true);
    }
  }
}