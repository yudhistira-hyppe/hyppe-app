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

class ActivationGiftDataBloc {
  ActivationGiftDataFetch _dataFetch = ActivationGiftDataFetch(ActivationGiftState.init);
  ActivationGiftDataFetch get dataFetch => _dataFetch;
  setActivationGiftFetch(ActivationGiftDataFetch val) => _dataFetch = val;

  Future postActivationGift(BuildContext context,{bool? activation}) async {
    setActivationGiftFetch(ActivationGiftDataFetch(ActivationGiftState.loading));
    try {
      Map<String, dynamic> data = {
        'GiftActivation': activation
      };
      String email = SharedPreference().readStorage(SpKeys.email);
      await Repos().reposPost(
        context,
        (onResult) {
          if ((onResult.statusCode ?? 300) > HTTP_CODE) {
            setActivationGiftFetch(
                ActivationGiftDataFetch(ActivationGiftState.getBlocError));
          } else {
            setActivationGiftFetch(
              ActivationGiftDataFetch(ActivationGiftState.getBlocSuccess),
            );
          }
        },
        (errorData) {
          ShowBottomSheet.onInternalServerError(context, statusCode: errorData.response?.statusCode);
          setActivationGiftFetch(
              ActivationGiftDataFetch(ActivationGiftState.getBlocError));
          Dio().close(force: true);
        },
        headers: {
          'x-auth-user': email,
        },
        data: data,
        host: UrlConstants.activationgift,
        methodType: MethodType.post,
        withAlertMessage: false,
        withCheckConnection: true,
      );
    } on SocketException catch (_) {
      setActivationGiftFetch(
          ActivationGiftDataFetch(ActivationGiftState.getBlocError));
      Dio().close(force: true);
    } catch (_) {
      setActivationGiftFetch(
          ActivationGiftDataFetch(ActivationGiftState.getBlocError));
      Dio().close(force: true);
    }
  }
}
