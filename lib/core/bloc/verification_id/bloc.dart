import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:hyppe/core/bloc/verification_id/state.dart';
import 'package:hyppe/core/config/url_constants.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/core/bloc/repos/repos.dart';
import 'package:hyppe/core/constants/status_code.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';

class VerificationIDBloc {
  final _repos = Repos();

  VerificationIDFetch _verificationIdFetch =
      VerificationIDFetch(VerificationIDState.init);
  VerificationIDFetch get postsFetch => _verificationIdFetch;
  setVerificationIDFetch(VerificationIDFetch val) => _verificationIdFetch = val;

  Future postVerificationIDBloc(
    BuildContext context, {
    required String idcardnumber,
    required String nama,
    required String tempatLahir,
    String? alamat,
    String? agama,
    String? statusPerkawinan,
    String? pekerjaan,
    String? kewarganegaraan,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    required String idCardFile,
    required String selfieFile,
  }) async {
    FormData formData = FormData.fromMap({
      "cardPict": await MultipartFile.fromFile(
        File(idCardFile).path,
        filename: File(idCardFile).path.split('/').last,
        contentType: MediaType("image", "jpeg"),
      ),
      "selfiepict": await MultipartFile.fromFile(
        File(selfieFile).path,
        filename: File(selfieFile).path.split('/').last,
        contentType: MediaType("image", "jpeg"),
      ),
      "idcardnumber": idcardnumber
    });

    setVerificationIDFetch(VerificationIDFetch(VerificationIDState.loading));
    await _repos.reposPost(
      context,
      (onResult) {
        if (onResult.statusCode! > HTTP_CODE) {
          setVerificationIDFetch(
              VerificationIDFetch(VerificationIDState.postVerificationIDError));
        } else {
          setVerificationIDFetch(VerificationIDFetch(
              VerificationIDState.postVerificationIDSuccess,
              data: onResult));
        }
      },
      (errorData) {
        setVerificationIDFetch(
            VerificationIDFetch(VerificationIDState.postVerificationIDError));
      },
      data: formData,
      headers: {
        'x-auth-user': SharedPreference().readStorage(SpKeys.email),
        'x-auth-token': SharedPreference().readStorage(SpKeys.userToken),
      },
      withAlertMessage: true,
      withCheckConnection: true,
      host: UrlConstants.verificationID,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
      methodType: MethodType.postUploadContent,
      errorServiceType: System().getErrorTypeV2(FeatureType.other),
    );
  }
}
