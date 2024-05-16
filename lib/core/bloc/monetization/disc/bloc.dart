import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/bloc/repos/repos.dart';
import 'package:hyppe/core/config/url_constants.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/status_code.dart';
import 'package:hyppe/core/models/collection/discount/discountmodel.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/services/system.dart';

import 'state.dart';

class DiscDataBloc {
  DiscDataFetch _dataFetch = DiscDataFetch(DiscState.init);
  DiscDataFetch get dataFetch => _dataFetch;
  setDiscFetch(DiscDataFetch val) => _dataFetch = val;

  Future getDisc(BuildContext context,
      {int? page, int? limit, String? productType}) async {
    setDiscFetch(DiscDataFetch(DiscState.loading));
    try {
      Map<String, dynamic> data;
      if (productType == null || productType == ''){
        data = {
          'page': page ?? 0,
          'limit': limit ?? 10
        };
      }else{
        data = {
          'page': page ?? 0,
          'limit': limit ?? 10,
          'productType': [productType]
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
                    DiscDataFetch(DiscState.getDiscBlocError));
              } else {
                setDiscFetch(
                  DiscDataFetch(DiscState.getDiscBlocSuccess,
                      data: onResult.data['data'] != null
                          ? List.from(onResult.data['data'])
                              .map((e) => DiscountModel.fromJson(e))
                              .toList()
                          : null),
                );
              }
            },
            (errorData) {
              setDiscFetch(
                  DiscDataFetch(DiscState.getDiscBlocError));
              Dio().close(force: true);
            },
            headers: {
              'x-auth-user': email,
            },
            data: data,
            host: UrlConstants.discmonetization,
            methodType: MethodType.post,
            withAlertMessage: false,
            withCheckConnection: true,
          );
        }else{
          setDiscFetch(
                DiscDataFetch(DiscState.getNotInternet));
          Dio().close(force: true);
        }
      });
      
    } on SocketException catch (_) {
      setDiscFetch(
          DiscDataFetch(DiscState.getDiscBlocError));
      Dio().close(force: true);
    } catch (_) {
      setDiscFetch(
          DiscDataFetch(DiscState.getDiscBlocError));
      Dio().close(force: true);
    }
  }
}
