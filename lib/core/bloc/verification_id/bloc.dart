import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:hyppe/core/bloc/verification_id/state.dart';
import 'package:hyppe/core/config/url_constants.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/response/generic_response.dart';
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
    String? jenisKelamin,
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
      "idcardnumber": idcardnumber,
      "nama": nama,
      "tempatLahir": tempatLahir,
      "alamat": alamat,
      "agama": agama,
      "statusPerkawinan": statusPerkawinan,
      "pekerjaan": pekerjaan,
      "kewarganegaraan": kewarganegaraan,
      "jenisKelamin": jenisKelamin,
    });

    setVerificationIDFetch(VerificationIDFetch(VerificationIDState.loading));
    await _repos.reposPost(
      context,
      (onResult) {
        if (onResult.statusCode! > HTTP_CODE) {
          setVerificationIDFetch(VerificationIDFetch(
              VerificationIDState.postVerificationIDError,
              data: GenericResponse.fromJson(onResult.data).responseData));
        } else {
          setVerificationIDFetch(VerificationIDFetch(
              VerificationIDState.postVerificationIDSuccess,
              data: onResult));
        }
      },
      (errorData) {
        setVerificationIDFetch(VerificationIDFetch(
            VerificationIDState.postVerificationIDError,
            data: errorData));
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

  Future postVerificationIDSupportDocsBloc(
    BuildContext context, {
    required String id,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    required List<File>? docFiles,
  }) async {
    FormData formData = FormData.fromMap({"_id": id});

    if (docFiles != null) {
      for (File docFile in docFiles) {
        formData.files.add(MapEntry(
            "supportFile",
            await MultipartFile.fromFile(docFile.path,
                filename: System().basenameFiles(docFile.path),
                contentType: MediaType(
                  System().lookupContentMimeType(docFile.path)?.split('/')[0] ??
                      '',
                  System().extensionFiles(docFile.path)?.replaceAll(".", "") ??
                      "",
                ))));
      }
    }

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
      host: UrlConstants.verificationIDSupportingDocs,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
      methodType: MethodType.postUploadContent,
      errorServiceType: System().getErrorTypeV2(FeatureType.other),
    );
  }

  Future postVerificationIDWithSupportDocsBloc(
    BuildContext context, {
    required String idcardnumber,
    required String nama,
    required String tempatLahir,
    required String idCardFile,
    required String selfieFile,
    String? alamat,
    String? agama,
    String? statusPerkawinan,
    String? pekerjaan,
    String? kewarganegaraan,
    String? jenisKelamin,
    List<File>? docFiles,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
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
      "idcardnumber": idcardnumber,
      "nama": nama,
      "tempatLahir": tempatLahir,
      "alamat": alamat,
      "agama": agama,
      "statusPerkawinan": statusPerkawinan,
      "pekerjaan": pekerjaan,
      "kewarganegaraan": kewarganegaraan,
      "jenisKelamin": jenisKelamin,
    });

    if (docFiles != null) {
      for (File docFile in docFiles) {
        formData.files.add(MapEntry(
            "supportFile",
            await MultipartFile.fromFile(docFile.path,
                filename: System().basenameFiles(docFile.path),
                contentType: MediaType(
                  System().lookupContentMimeType(docFile.path)?.split('/')[0] ??
                      '',
                  System().extensionFiles(docFile.path)?.replaceAll(".", "") ??
                      "",
                ))));
      }
    }

    setVerificationIDFetch(VerificationIDFetch(VerificationIDState.loading));
    await _repos.reposPost(
      context,
      (onResult) {
        if (onResult.statusCode! > HTTP_CODE) {
          setVerificationIDFetch(VerificationIDFetch(
              VerificationIDState.postVerificationIDError,
              data: GenericResponse.fromJson(onResult.data).responseData));
        } else {
          setVerificationIDFetch(VerificationIDFetch(
              VerificationIDState.postVerificationIDSuccess,
              data: onResult));
        }
      },
      (errorData) {
        setVerificationIDFetch(VerificationIDFetch(
            VerificationIDState.postVerificationIDError,
            data: errorData));
      },
      data: formData,
      headers: {
        'x-auth-user': SharedPreference().readStorage(SpKeys.email),
        'x-auth-token': SharedPreference().readStorage(SpKeys.userToken),
      },
      withAlertMessage: true,
      withCheckConnection: true,
      host: UrlConstants.verificationIDWithSupportDocs,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
      methodType: MethodType.postUploadContent,
      errorServiceType: System().getErrorTypeV2(FeatureType.other),
    );
  }
}
