import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/bloc/repos/repos.dart';
import 'package:hyppe/core/config/url_constants.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/status_code.dart';
import 'package:hyppe/core/models/collection/transaction/transactioncoin.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/services/system.dart';

import 'state.dart';

class TransactionCoinBloc {
  TransactionCoinFetch _dataFetch = TransactionCoinFetch(TransactionCoinState.init);
  TransactionCoinFetch get dataFetch => _dataFetch;
  setDiscFetch(TransactionCoinFetch val) => _dataFetch = val;

  Future postPayNow(BuildContext context,
      {Map? data}) async {
    setDiscFetch(TransactionCoinFetch(TransactionCoinState.loading));
    try {
      String email = SharedPreference().readStorage(SpKeys.email);
      await System().checkConnections().then((value) async {
        if (value){
            await Repos().reposPost(
            context,
            (onResult) {
              if ((onResult.statusCode ?? 300) > HTTP_CODE) {
                setDiscFetch(
                    TransactionCoinFetch(TransactionCoinState.getBlocError, data: onResult.data));
              } else {
                setDiscFetch(
                  TransactionCoinFetch(TransactionCoinState.getcBlocSuccess,
                      data: onResult.data['data']),
                );
              }
            },
            (errorData) {
             
              setDiscFetch(
                  TransactionCoinFetch(TransactionCoinState.getBlocError, data: errorData));
              Dio().close(force: true);
            },
            headers: {
              'x-auth-user': email,
            },
            data: data,
            host: UrlConstants.transactioncoin,
            methodType: MethodType.post,
            withAlertMessage: false,
            withCheckConnection: true,
          );
        }else{
          setDiscFetch(
                TransactionCoinFetch(TransactionCoinState.getNotInternet));
          Dio().close(force: true);
        }
      });
      
    } on SocketException catch (_) {
      setDiscFetch(
          TransactionCoinFetch(TransactionCoinState.getBlocError));
      Dio().close(force: true);
    } catch (_) {
      setDiscFetch(
          TransactionCoinFetch(TransactionCoinState.getBlocError));
      Dio().close(force: true);
    }
  }
}
