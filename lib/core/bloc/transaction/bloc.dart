import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
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
        if ((onResult.statusCode ?? 300) > HTTP_CODE) {
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
        if ((onResult.statusCode ?? 300) > HTTP_CODE) {
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
        if ((onResult.statusCode ?? 300) > HTTP_CODE) {
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
        if ((onResult.statusCode ?? 300) > HTTP_CODE) {
          setTransactionFetch(TransactionFetch(TransactionState.getHistoryError, message: onResult.data['message'], data: onResult.data));
        } else {
          // setTransactionFetch(TransactionFetch(TransactionState.getHistorySuccess, data: GenericResponse.fromJson(onResult.data).responseData));
          setTransactionFetch(TransactionFetch(TransactionState.getHistorySuccess, data: onResult.data));
        }
      },
      (errorData) {
        if (errorData.type == DioErrorType.cancel) {
          setTransactionFetch(TransactionFetch(TransactionState.getHistoryError));
        } else {
          ShowBottomSheet.onInternalServerError(context, statusCode: errorData.response?.statusCode);
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

  Future getDetailHistoryTransaction(BuildContext context, {required Map? params, bool isReward = false}) async {
    var type = FeatureType.other;
    setTransactionFetch(TransactionFetch(TransactionState.loading));

    await _repos.reposPost(
      context,
      (onResult) {
        if ((onResult.statusCode ?? 300) > HTTP_CODE) {
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
      host: isReward ? UrlConstants.detailRewards : UrlConstants.detailTransactionHistorys,
      methodType: MethodType.post,
      errorServiceType: System().getErrorTypeV2(type),
    );
  }

  Future getAccountBalance(BuildContext context, {required Map? params}) async {
    bool? isGuest = SharedPreference().readStorage(SpKeys.isGuest);

    if (!(isGuest ?? true)) {
      var type = FeatureType.other;
      setTransactionFetch(TransactionFetch(TransactionState.loading));

      await _repos.reposPost(
        context,
        (onResult) {
          if ((onResult.statusCode ?? 300) > HTTP_CODE) {
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
  }

  Future sendVerificationPin(BuildContext context, {required Map? params}) async {
    // var type = FeatureType.other;
    setTransactionFetch(TransactionFetch(TransactionState.loading));

    await _repos.reposPost(
      context,
      (onResult) {
        if ((onResult.statusCode ?? 300) > HTTP_CODE) {
          setTransactionFetch(TransactionFetch(TransactionState.sendVerificationError, message: onResult.data['message'], data: onResult.data));
        } else {
          setTransactionFetch(TransactionFetch(TransactionState.sendVerificationSuccess, version: onResult.data['version'], data: onResult.data));
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
      errorServiceType: ErrorType.otpVerifyAccount,
    );
  }

  Future summaryWithdrawal(BuildContext context, {required Map? params}) async {
    var type = FeatureType.other;
    setTransactionFetch(TransactionFetch(TransactionState.loading));
    await _repos.reposPost(
      context,
      (onResult) {
        if ((onResult.statusCode ?? 300) > HTTP_CODE) {
          setTransactionFetch(TransactionFetch(TransactionState.summaryWithdrawalError, message: onResult.data['message'], data: onResult.data));
        } else {
          setTransactionFetch(TransactionFetch(TransactionState.summaryWithdrawalSuccess, data: GenericResponse.fromJson(onResult.data).responseData));
        }
      },
      (errorData) {
        setTransactionFetch(TransactionFetch(TransactionState.summaryWithdrawalError, data: errorData.error));
      },
      data: params,
      headers: {
        "x-auth-token": SharedPreference().readStorage(SpKeys.userToken),
        "x-auth-user": SharedPreference().readStorage(SpKeys.email),
      },
      withAlertMessage: true,
      withCheckConnection: false,
      host: UrlConstants.detailWithdrawal,
      methodType: MethodType.post,
      errorServiceType: System().getErrorTypeV2(type),
    );
  }

  Future createWithdraw(BuildContext context, {required Map? params}) async {
    var type = FeatureType.other;
    setTransactionFetch(TransactionFetch(TransactionState.loading));
    await _repos.reposPost(
      context,
      (onResult) {
        if ((onResult.statusCode ?? 300) > HTTP_CODE) {
          setTransactionFetch(TransactionFetch(TransactionState.createWithdrawalError, message: onResult.data, data: onResult.data));
        } else {
          setTransactionFetch(TransactionFetch(TransactionState.createWithdrawalSuccess, data: GenericResponse.fromJson(onResult.data).responseData));
        }
      },
      (errorData) {
        setTransactionFetch(TransactionFetch(TransactionState.createWithdrawalError, data: errorData.error));
      },
      data: params,
      headers: {
        "x-auth-token": SharedPreference().readStorage(SpKeys.userToken),
        "x-auth-user": SharedPreference().readStorage(SpKeys.email),
      },
      withAlertMessage: false,
      withCheckConnection: false,
      host: UrlConstants.withdraw,
      methodType: MethodType.post,
      errorServiceType: System().getErrorTypeV2(type),
    );
  }

  Future transPanding(BuildContext context) async {
    var type = FeatureType.other;
    setTransactionFetch(TransactionFetch(TransactionState.loading));
    await _repos.reposPost(
      context,
      (onResult) {
        if ((onResult.statusCode ?? 300) > HTTP_CODE) {
          setTransactionFetch(TransactionFetch(TransactionState.checkPandingError, message: onResult.data, data: onResult.data));
        } else {
          setTransactionFetch(TransactionFetch(TransactionState.checkPandingSuccess, data: onResult.data));
        }
      },
      (errorData) {
        setTransactionFetch(TransactionFetch(TransactionState.checkPandingError, data: errorData.error));
      },
      headers: {
        "x-auth-token": SharedPreference().readStorage(SpKeys.userToken),
        "x-auth-user": SharedPreference().readStorage(SpKeys.email),
      },
      withAlertMessage: false,
      withCheckConnection: false,
      host: UrlConstants.pandingTransaction,
      methodType: MethodType.get,
      errorServiceType: System().getErrorTypeV2(type),
    );
  }

  Future postAppealBloc(
    BuildContext context, {
    String? noRek,
    String? email,
    String? bankcode,
    String? nama,
    String? language,
    required List<File>? docFiles,
  }) async {
    var type = FeatureType.other;

    FormData formData = FormData.fromMap({
      "noRek": noRek,
      "email": email,
      "bankcode": bankcode,
      "nama": nama,
      "language": language,
    });

    if (docFiles != null) {
      for (File docFile in docFiles) {
        formData.files.add(MapEntry(
            "supportFile",
            await MultipartFile.fromFile(docFile.path,
                filename: System().basenameFiles(docFile.path),
                contentType: MediaType(
                  System().lookupContentMimeType(docFile.path)?.split('/')[0] ?? '',
                  System().extensionFiles(docFile.path)?.replaceAll(".", "") ?? "",
                ))));
      }
    }

    print(formData.fields.map((e) => e).join(','));

    setTransactionFetch(TransactionFetch(TransactionState.loading));
    if (context.mounted) {
      await _repos.reposPost(
        context,
        (onResult) {
          if ((onResult.statusCode ?? 300) > HTTP_CODE) {
            setTransactionFetch(TransactionFetch(TransactionState.checkPandingError, message: onResult.data, data: onResult.data));
          } else {
            setTransactionFetch(TransactionFetch(TransactionState.checkPandingSuccess, data: onResult.data));
          }
        },
        (errorData) {
          setTransactionFetch(TransactionFetch(TransactionState.checkPandingError, data: errorData.error));
        },
        headers: {
          "x-auth-token": SharedPreference().readStorage(SpKeys.userToken),
          "x-auth-user": SharedPreference().readStorage(SpKeys.email),
        },
        data: formData,
        withAlertMessage: false,
        withCheckConnection: false,
        host: UrlConstants.appealBank,
        methodType: MethodType.post,
        errorServiceType: System().getErrorTypeV2(type),
      );
    }
  }
}
