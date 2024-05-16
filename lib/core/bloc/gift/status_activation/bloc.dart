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

class GiftDataBloc {
  GiftDataFetch _dataFetch = GiftDataFetch(GiftState.init);
  GiftDataFetch get dataFetch => _dataFetch;
  setGiftFetch(GiftDataFetch val) => _dataFetch = val;

  Future getGift(BuildContext context) async {
    setGiftFetch(GiftDataFetch(GiftState.loading));
    try {
      String email = SharedPreference().readStorage(SpKeys.email);
      await Repos().reposPost(
        context,
        (onResult) {
          if ((onResult.statusCode ?? 300) > HTTP_CODE) {
            setGiftFetch(
                GiftDataFetch(GiftState.getBlocError));
          } else {
            bool result = onResult.data['result'] as bool;
            setGiftFetch(
              GiftDataFetch(GiftState.getBlocSuccess,
                  data: result),
            );
          }
        },
        (errorData) {
          ShowBottomSheet.onInternalServerError(context, statusCode: errorData.response?.statusCode);
          setGiftFetch(
              GiftDataFetch(GiftState.getBlocError));
          Dio().close(force: true);
        },
        headers: {
          'x-auth-user': email,
        },
        host: UrlConstants.checkposting,
        methodType: MethodType.get,
        withAlertMessage: false,
        withCheckConnection: true,
      );
    } on SocketException catch (_) {
      setGiftFetch(
          GiftDataFetch(GiftState.getBlocError));
      Dio().close(force: true);
    } catch (_) {
      setGiftFetch(
          GiftDataFetch(GiftState.getBlocError));
      Dio().close(force: true);
    }
  }
}
