import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/bloc/monetization/maxmin/state.dart';
import 'package:hyppe/core/bloc/repos/repos.dart';
import 'package:hyppe/core/config/url_constants.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/status_code.dart';
import 'package:hyppe/core/response/generic_response.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';


class MaxminDataBloc {
  MaxminCoinDataFetch _dataFetch = MaxminCoinDataFetch(MaxminCoinState.init);
  MaxminCoinDataFetch get dataFetch => _dataFetch;
  setCoinFetch(MaxminCoinDataFetch val) => _dataFetch = val;

  Future getMaxmin(BuildContext context,
      {Map? data}) async {
    setCoinFetch(MaxminCoinDataFetch(MaxminCoinState.loading));
    try {
      
      String email = SharedPreference().readStorage(SpKeys.email);
      await Repos().reposPost(
        context,
        (onResult) {
          if ((onResult.statusCode ?? 300) > HTTP_CODE) {
            setCoinFetch(
                MaxminCoinDataFetch(MaxminCoinState.getBlocError));
          } else {
            setCoinFetch(
              MaxminCoinDataFetch(MaxminCoinState.getBlocSuccess,
                  data: GenericResponse.fromJson(onResult.data).responseData),
            );
          }
        },
        (errorData) {
          ShowBottomSheet.onInternalServerError(context, statusCode: errorData.response?.statusCode);
          setCoinFetch(
              MaxminCoinDataFetch(MaxminCoinState.getBlocError));
          Dio().close(force: true);
        },
        headers: {
          'x-auth-user': email,
        },
        data: data,
        host: UrlConstants.maxmincoin,
        methodType: MethodType.post,
        withAlertMessage: false,
        withCheckConnection: true,
      );
    } on SocketException catch (_) {
      setCoinFetch(
          MaxminCoinDataFetch(MaxminCoinState.getBlocError));
      Dio().close(force: true);
    } catch (_) {
      setCoinFetch(
          MaxminCoinDataFetch(MaxminCoinState.getBlocError));
      Dio().close(force: true);
    }
  }
}
