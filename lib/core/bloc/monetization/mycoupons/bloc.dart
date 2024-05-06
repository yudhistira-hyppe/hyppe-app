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

class MyCouponsDataBloc {
  MyCouponsDataFetch _dataFetch = MyCouponsDataFetch(MyCouponsState.init);
  MyCouponsDataFetch get dataFetch => _dataFetch;
  setMyCouponsFetch(MyCouponsDataFetch val) => _dataFetch = val;

  Future getMyCoupons(BuildContext context,
      {int? page, int? limit, bool? desc}) async {
    setMyCouponsFetch(MyCouponsDataFetch(MyCouponsState.loading));
    try {
      Map<String, dynamic> data = {
        'page': page ?? 0,
        'limit': limit ?? 10,
        'descending': desc ?? true,
        'type': 'DISCOUNT'
      };
      String email = SharedPreference().readStorage(SpKeys.email);
      await System().checkConnections().then((value) async {
        if (value){
            await Repos().reposPost(
            context,
            (onResult) {
              if ((onResult.statusCode ?? 300) > HTTP_CODE) {
                setMyCouponsFetch(
                    MyCouponsDataFetch(MyCouponsState.getMyCouponsBlocError));
              } else {
                setMyCouponsFetch(
                  MyCouponsDataFetch(MyCouponsState.getMyCouponsBlocSuccess,
                      data: onResult.data['data'] != null
                          ? List.from(onResult.data['data'])
                              .map((e) => DiscountModel.fromJson(e))
                              .toList()
                          : null),
                );
              }
            },
            (errorData) {
              setMyCouponsFetch(
                  MyCouponsDataFetch(MyCouponsState.getMyCouponsBlocError));
              Dio().close(force: true);
            },
            headers: {
              'x-auth-user': email,
            },
            data: data,
            host: UrlConstants.listmonetization,
            methodType: MethodType.post,
            withAlertMessage: false,
            withCheckConnection: true,
          );
        }else{
          setMyCouponsFetch(
                MyCouponsDataFetch(MyCouponsState.getNotInternet));
          Dio().close(force: true);
        }
      });
      
    } on SocketException catch (_) {
      setMyCouponsFetch(
          MyCouponsDataFetch(MyCouponsState.getMyCouponsBlocError));
      Dio().close(force: true);
    } catch (_) {
      setMyCouponsFetch(
          MyCouponsDataFetch(MyCouponsState.getMyCouponsBlocError));
      Dio().close(force: true);
    }
  }
}
