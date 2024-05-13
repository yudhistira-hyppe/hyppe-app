import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/bloc/repos/repos.dart';
import 'package:hyppe/core/config/url_constants.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/status_code.dart';
import 'package:hyppe/core/models/collection/transaction/transactioncoin.dart';
import 'package:hyppe/core/response/generic_response.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/services/system.dart';

import 'state.dart';

class TransactionCoinBloc {
  TransactionCoinFetch _dataFetch = TransactionCoinFetch(TransactionCoinState.init);
  TransactionCoinFetch get dataFetch => _dataFetch;
  setDiscFetch(TransactionCoinFetch val) => _dataFetch = val;

  Future postPayNow(BuildContext context,
      {CoinTransModel? coin, String? discId, String? bankcode, String? type, String? paymentmethod, String? productCode}) async {
    setDiscFetch(TransactionCoinFetch(TransactionCoinState.loading));
    try {
      
      Map<String, dynamic> data={};
      if (discId == ''){
        data = {
          "postid": [coin!.toJson()],
          // "idDiscount":discId,
          "bankcode": bankcode,
          "type": type,
          "paymentmethod": paymentmethod,
          "productCode": productCode,
          "platform":"APP"
        };
      }else{
        data = {
        "postid": [coin!.toJson()],
        "idDiscount":discId,
        "bankcode": bankcode,
        "type": type,
        "paymentmethod": paymentmethod,
        "productCode": productCode,
        "platform":"APP"
      };
      }
      String email = SharedPreference().readStorage(SpKeys.email);
      await System().checkConnections().then((value) async {
        if (value){
            await Repos().reposPost(
            context,
            (onResult) {
              if ((onResult.statusCode ?? 300) > HTTP_CODE) {
                setDiscFetch(
                    TransactionCoinFetch(TransactionCoinState.getBlocError, data: onResult));
              } else {
                setDiscFetch(
                  TransactionCoinFetch(TransactionCoinState.getcBlocSuccess,
                      data: onResult.data['data'] != null
                          ? TransactionCoinModel.fromJson(onResult.data['data'])
                          : null),
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
