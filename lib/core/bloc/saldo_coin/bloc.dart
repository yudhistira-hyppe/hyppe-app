import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/bloc/repos/repos.dart';
import 'package:hyppe/core/config/url_constants.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/status_code.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';

import 'state.dart';

class SaldoCoinDataBloc {
  SaldoCoinDataFetch _dataFetch = SaldoCoinDataFetch(SaldoCoinState.init);
  SaldoCoinDataFetch get dataFetch => _dataFetch;
  setSaldoCoinFetch(SaldoCoinDataFetch val) => _dataFetch = val;

  Future getSaldoCoin(BuildContext context) async {
    setSaldoCoinFetch(SaldoCoinDataFetch(SaldoCoinState.loading));
    try {
      
      String email = SharedPreference().readStorage(SpKeys.email);
      await Repos().reposPost(
        context,
        (onResult) {
          if ((onResult.statusCode ?? 300) > HTTP_CODE) {
            setSaldoCoinFetch(
                SaldoCoinDataFetch(SaldoCoinState.getBlocError));
          } else {
            setSaldoCoinFetch(
              SaldoCoinDataFetch(SaldoCoinState.getBlocSuccess,
                  data: onResult.data['balance'] ?? 0),
            );
          }
        },
        (errorData) {
          ShowBottomSheet.onInternalServerError(context, statusCode: errorData.response?.statusCode);
          setSaldoCoinFetch(
              SaldoCoinDataFetch(SaldoCoinState.getBlocError));
          Dio().close(force: true);
        },
        headers: {
          'x-auth-user': email,
        },
        host: UrlConstants.saldocoin,
        methodType: MethodType.get,
        withAlertMessage: false,
        withCheckConnection: true,
      );
    } on SocketException catch (_) {
      setSaldoCoinFetch(
          SaldoCoinDataFetch(SaldoCoinState.getBlocError));
      Dio().close(force: true);
    } catch (_) {
      setSaldoCoinFetch(
          SaldoCoinDataFetch(SaldoCoinState.getBlocError));
      Dio().close(force: true);
    }
  }
}
