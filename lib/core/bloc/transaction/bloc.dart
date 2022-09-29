import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:hyppe/core/bloc/transaction/state.dart';
import 'package:hyppe/core/config/url_constants.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/core/bloc/repos/repos.dart';
import 'package:hyppe/core/constants/status_code.dart';
import 'package:hyppe/core/response/generic_response.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ux/routing.dart';

class TransactionBloc {
  final _repos = Repos();

  TransactionFetch _transactionFetch = TransactionFetch(TransactionState.init);
  TransactionFetch get transactionFetch => _transactionFetch;
  setTransactionFetch(TransactionFetch val) => _transactionFetch = val;

  Future createBankAccount(BuildContext context, {required Map? params}) async {
    var type = FeatureType.other;
    setTransactionFetch(TransactionFetch(TransactionState.loading));
    await _repos.reposPost(
      context,
      (onResult) {
        print(onResult.statusCode);
        if (onResult.statusCode! > HTTP_CODE) {
          setTransactionFetch(TransactionFetch(TransactionState.addBankAccontError, message: onResult.data['message'], data: onResult.data));
        } else {
          setTransactionFetch(TransactionFetch(TransactionState.addBankAccontSuccess, message: onResult.data['message'], data: GenericResponse.fromJson(onResult.data).responseData));
        }
      },
      (errorData) {
        setTransactionFetch(TransactionFetch(TransactionState.addBankAccontError, data: errorData.error));
      },
      data: params,
      withAlertMessage: true,
      withCheckConnection: false,
      host: UrlConstants.userBankAccounts,
      methodType: MethodType.post,
      errorServiceType: System().getErrorTypeV2(type),
    );
  }

  Future deleteBankAccount(BuildContext context, {required Map? params}) async {
    var type = FeatureType.other;
    setTransactionFetch(TransactionFetch(TransactionState.loading));
    await _repos.reposPost(
      context,
      (onResult) {
        if (onResult.statusCode! > HTTP_CODE) {
          setTransactionFetch(TransactionFetch(TransactionState.deleteBankAccontError, message: onResult.data['message'], data: onResult.data));
        } else {
          setTransactionFetch(TransactionFetch(TransactionState.deleteBankAccontSuccess, data: GenericResponse.fromJson(onResult.data).responseData));
        }
      },
      (errorData) {
        setTransactionFetch(TransactionFetch(TransactionState.deleteBankAccontError, data: errorData.error));
      },
      data: params,
      withAlertMessage: true,
      withCheckConnection: false,
      host: UrlConstants.deleteUserBankAccounts,
      methodType: MethodType.post,
      errorServiceType: System().getErrorTypeV2(type),
    );
  }

  Future getMyBankAccount(BuildContext context) async {
    var type = FeatureType.other;
    setTransactionFetch(TransactionFetch(TransactionState.loading));
    final email = SharedPreference().readStorage(SpKeys.email);

    await _repos.reposPost(
      context,
      (onResult) {
        if (onResult.statusCode! > HTTP_CODE) {
          setTransactionFetch(TransactionFetch(TransactionState.getBankAccontError, message: onResult.data['message'], data: onResult.data));
        } else {
          setTransactionFetch(TransactionFetch(TransactionState.getBankAccontSuccess, version: onResult.data['version'], data: GenericResponse.fromJson(onResult.data).responseData));
        }
      },
      (errorData) {
        setTransactionFetch(TransactionFetch(TransactionState.getBankAccontError, data: errorData.error));
      },
      data: {"email": email},
      withAlertMessage: true,
      withCheckConnection: false,
      host: UrlConstants.myUserBankAccounts,
      methodType: MethodType.post,
      errorServiceType: System().getErrorTypeV2(type),
    );
  }

  Future getHistoryTransaction(BuildContext context, {required Map? params}) async {
    var type = FeatureType.other;
    setTransactionFetch(TransactionFetch(TransactionState.loading));

    await _repos.reposPost(
      context,
      (onResult) {
        if (onResult.statusCode! > HTTP_CODE) {
          setTransactionFetch(TransactionFetch(TransactionState.getHistoryError, message: onResult.data['message'], data: onResult.data));
        } else {
          // setTransactionFetch(TransactionFetch(TransactionState.getHistorySuccess, data: GenericResponse.fromJson(onResult.data).responseData));
          setTransactionFetch(TransactionFetch(TransactionState.getHistorySuccess, data: onResult.data));
        }
      },
      (errorData) {
        if (errorData.type == DioErrorType.cancel) {
          setTransactionFetch(TransactionFetch(TransactionState.getHistorySuccess));
        } else {
          ShowBottomSheet.onInternalServerError(context, tryAgainButton: () => Routing().moveBack());
          setTransactionFetch(TransactionFetch(TransactionState.getHistoryError, data: errorData.error));
        }
      },
      data: params,
      withAlertMessage: true,
      withCheckConnection: false,
      host: UrlConstants.transactionHistorys,
      methodType: MethodType.post,
      errorServiceType: System().getErrorTypeV2(type),
    );
  }

  Future getDetailHistoryTransaction(BuildContext context, {required Map? params}) async {
    var type = FeatureType.other;
    setTransactionFetch(TransactionFetch(TransactionState.loading));

    await _repos.reposPost(
      context,
      (onResult) {
        if (onResult.statusCode! > HTTP_CODE) {
          setTransactionFetch(TransactionFetch(TransactionState.getDetailHistoryError, message: onResult.data['message'], data: onResult.data));
        } else {
          setTransactionFetch(TransactionFetch(TransactionState.getDetailHistorySuccess, version: onResult.data['version'], data: GenericResponse.fromJson(onResult.data).responseData));
        }
      },
      (errorData) {
        setTransactionFetch(TransactionFetch(TransactionState.getDetailHistoryError, data: errorData.error));
      },
      data: params,
      withAlertMessage: true,
      withCheckConnection: false,
      host: UrlConstants.detailTransactionHistorys,
      methodType: MethodType.post,
      errorServiceType: System().getErrorTypeV2(type),
    );
  }

  Future getAccountBalance(BuildContext context, {required Map? params}) async {
    var type = FeatureType.other;
    setTransactionFetch(TransactionFetch(TransactionState.loading));

    await _repos.reposPost(
      context,
      (onResult) {
        if (onResult.statusCode! > HTTP_CODE) {
          setTransactionFetch(TransactionFetch(TransactionState.getAccountBalanceError, message: onResult.data['message'], data: onResult.data));
        } else {
          setTransactionFetch(TransactionFetch(TransactionState.getAccountBalanceSuccess, version: onResult.data['version'], data: GenericResponse.fromJson(onResult.data).responseData));
        }
      },
      (errorData) {
        setTransactionFetch(TransactionFetch(TransactionState.getAccountBalanceError, data: errorData.error));
      },
      data: params,
      withAlertMessage: true,
      headers: {"x-auth-token": SharedPreference().readStorage(SpKeys.userToken)},
      withCheckConnection: false,
      host: UrlConstants.accountBalances,
      methodType: MethodType.post,
      errorServiceType: System().getErrorTypeV2(type),
    );
  }

  Future sendVerificationPin(BuildContext context, {required Map? params}) async {
    var type = FeatureType.other;
    setTransactionFetch(TransactionFetch(TransactionState.loading));

    await _repos.reposPost(
      context,
      (onResult) {
        if (onResult.statusCode! > HTTP_CODE) {
          setTransactionFetch(TransactionFetch(TransactionState.sendVerificationError, message: onResult.data['message'], data: onResult.data));
        } else {
          setTransactionFetch(TransactionFetch(TransactionState.sendVerificationSuccess, version: onResult.data['version'], data: GenericResponse.fromJson(onResult.data).responseData));
        }
      },
      (errorData) {
        setTransactionFetch(TransactionFetch(TransactionState.sendVerificationError, data: errorData.error));
      },
      data: params,
      headers: {
        "x-auth-token": SharedPreference().readStorage(SpKeys.userToken),
        "x-auth-user": SharedPreference().readStorage(SpKeys.email),
      },
      withAlertMessage: true,
      withCheckConnection: false,
      host: UrlConstants.userPin,
      methodType: MethodType.post,
      errorServiceType: System().getErrorTypeV2(type),
    );
  }
}
