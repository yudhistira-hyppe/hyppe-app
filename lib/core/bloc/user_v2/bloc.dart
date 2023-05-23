import 'dart:io';

import 'package:hyppe/core/arguments/sign_up_argument.dart';
import 'package:hyppe/core/bloc/repos/repos.dart';
import 'package:hyppe/core/config/url_constants.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/status_code.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/models/collection/user_v2/profile/user_profile_model.dart';
import 'package:hyppe/core/response/generic_response.dart';
import 'package:hyppe/core/services/dynamic_link_service.dart';
import 'package:hyppe/core/services/error_service.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http_parser/http_parser.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:hyppe/core/bloc/user_v2/state.dart';

class UserBloc {
  UserFetch _userFetch = UserFetch(UserState.init);
  UserFetch get userFetch => _userFetch;
  setUserFetch(UserFetch val) => _userFetch = val;

  String? deviceID = "";
  String realDeviceId = "";
  String referralEmail = "";
  String platForm = "";

  Future recoverPasswordBloc(BuildContext context, {required String email, String? event, String? status, String newPassword = ''}) async {
    final lang = SharedPreference().readStorage(SpKeys.isoCode);
    setUserFetch(UserFetch(UserState.loading));
    Map data = {
      "email": email,
      "event": event,
      "status": status,
      "deviceId": SharedPreference().readStorage(SpKeys.fcmToken),
      "lang": lang ?? 'id',
    };
    if (newPassword != '') {
      data['new_password'] = newPassword;
    }
    await Repos().reposPost(
      context,
      (onResult) {
        if ((onResult.statusCode ?? 300) > HTTP_CODE) {
          setUserFetch(UserFetch(UserState.RecoverError, data: onResult.data));
        } else {
          setUserFetch(UserFetch(UserState.RecoverSuccess, data: GenericResponse.fromJson(onResult.data).responseData));
        }
      },
      (errorData) {
        ShowBottomSheet.onInternalServerError(context);
        setUserFetch(UserFetch(UserState.RecoverError));
        Dio().close(force: true);
      },
      onNoInternet: () {
        Routing().moveBack();
      },
      data: data,
      withAlertMessage: false,
      withCheckConnection: true,
      host: UrlConstants.recoverPassword,
      methodType: MethodType.post,
    );
  }

  Future recoverPasswordOTPBloc(BuildContext context, {required String email, required String otp}) async {
    setUserFetch(UserFetch(UserState.loading));
    final lang = SharedPreference().readStorage(SpKeys.isoCode);
    deviceID = SharedPreference().readStorage(SpKeys.fcmToken);
    realDeviceId = await System().getDeviceIdentifier();
    await Repos().reposPost(
      context,
      (onResult) {
        if ((onResult.statusCode ?? 300) > HTTP_CODE) {
          setUserFetch(UserFetch(UserState.RecoverError, data: onResult.data));
        } else {
          setUserFetch(UserFetch(UserState.RecoverSuccess, data: GenericResponse.fromJson(onResult.data).responseData));
        }
      },
      (errorData) {
        ShowBottomSheet.onInternalServerError(context);
        setUserFetch(UserFetch(UserState.RecoverError));
        Dio().close(force: true);
      },
      onNoInternet: () {
        Routing().moveBack();
      },
      data: {
        "otp": otp,
        "email": email,
        "event": "VERIFY_OTP",
        "status": "REPLY",
        "deviceId": SharedPreference().readStorage(SpKeys.fcmToken),
        "lang": lang ?? 'id',
      },
      withAlertMessage: false,
      withCheckConnection: true,
      host: UrlConstants.recoverPassword,
      methodType: MethodType.post,
    );
  }

  Future googleSignInBlocV2(BuildContext context, {required Function() function, required String email, latitude, longtitude, uuid}) async {
    setUserFetch(UserFetch(UserState.loading));
    deviceID = SharedPreference().readStorage(SpKeys.fcmToken);
    realDeviceId = await System().getDeviceIdentifier();
    referralEmail = DynamicLinkService.getPendingReferralEmailDynamicLinks();
    platForm = Platform.isAndroid ? "android" : "ios";
    final lang = SharedPreference().readStorage(SpKeys.isoCode);
    dynamic payload = {
      'email': email.toLowerCase(),
      "socmedSource": "GMAIL",
      "deviceId": deviceID,
      "langIso": "en",
      "referral": referralEmail,
      "imei": realDeviceId != "" ? realDeviceId : deviceID,
      "regSrc": platForm,
      "location": {
        "longitude": latitude ?? "${double.parse("0.0")}",
        "latitude": longtitude ?? "${double.parse("0.0")}",
      },
      "devicetype": platForm,
      "lang": lang ?? 'id',
      "uuid": uuid,
    };
    'Payload in social login referralPayload $payload'.logger();

    await Repos().reposPost(
      context,
      (onResult) {
        if ((onResult.statusCode ?? 300) > HTTP_CODE) {
          setUserFetch(UserFetch(UserState.LoginError, data: GenericResponse.fromJson(onResult.data).responseData));
        } else {
          print("/////// ${onResult.data['version_ios']}");
          setUserFetch(UserFetch(UserState.LoginSuccess, version: onResult.data['version'], versionIos: onResult.data['version_ios'], data: GenericResponse.fromJson(onResult.data).responseData));
          SharedPreference().removeValue(SpKeys.referralFrom);
        }
      },
      (errorData) {
        ShowBottomSheet.onInternalServerError(context);
        setUserFetch(UserFetch(UserState.LoginError));
      },
      methodType: MethodType.post,
      withCheckConnection: false,
      withAlertMessage: true,
      host: UrlConstants.loginGoogle,
      data: payload,
      errorServiceType: ErrorType.login,
    );
  }

  Future appleSignInBlocV2(BuildContext context, {required Function() function, required String email, latitude, longtitude}) async {
    setUserFetch(UserFetch(UserState.loading));
    deviceID = SharedPreference().readStorage(SpKeys.fcmToken);
    realDeviceId = await System().getDeviceIdentifier();
    referralEmail = DynamicLinkService.getPendingReferralEmailDynamicLinks();
    platForm = Platform.isAndroid ? "android" : "ios";
    final lang = SharedPreference().readStorage(SpKeys.isoCode);
    dynamic payload = {
      'email': email.toLowerCase(),
      "socmedSource": "APPLE",
      "deviceId": deviceID,
      "langIso": "en",
      "referral": referralEmail,
      "imei": realDeviceId != "" ? realDeviceId : deviceID,
      "regSrc": platForm,
      "location": {
        "longitude": latitude ?? "${double.parse("0.0")}",
        "latitude": longtitude ?? "${double.parse("0.0")}",
      },
      "devicetype": platForm,
      "lang": lang ?? 'id',
    };
    'Payload in social login referralPayload $payload'.logger();

    await Repos().reposPost(
      context,
      (onResult) {
        if ((onResult.statusCode ?? 300) > HTTP_CODE) {
          setUserFetch(UserFetch(UserState.LoginError, data: GenericResponse.fromJson(onResult.data).responseData));
        } else {
          setUserFetch(UserFetch(UserState.LoginSuccess, version: onResult.data['version'], versionIos: onResult.data['version_ios'], data: GenericResponse.fromJson(onResult.data).responseData));
          SharedPreference().removeValue(SpKeys.referralFrom);
        }
      },
      (errorData) {
        ShowBottomSheet.onInternalServerError(context);
        setUserFetch(UserFetch(UserState.LoginError));
      },
      methodType: MethodType.post,
      withCheckConnection: false,
      withAlertMessage: true,
      host: UrlConstants.loginGoogle,
      data: payload,
    );
  }

  Future signInBlocV2(BuildContext context, {required Function() function, required String email, required String password, latitude, longtitude}) async {
    setUserFetch(UserFetch(UserState.loading));
    final lang = SharedPreference().readStorage(SpKeys.isoCode);
    deviceID = SharedPreference().readStorage(SpKeys.fcmToken);
    realDeviceId = await System().getDeviceIdentifier();
    platForm = Platform.isAndroid ? "android" : "ios";
    referralEmail = DynamicLinkService.getPendingReferralEmailDynamicLinks();
    // print('ini plat $platForm');
    dynamic payload = {
      'email': email.toLowerCase(),
      "password": password,
      "deviceId": deviceID,
      "referral": referralEmail,
      "imei": realDeviceId != "" ? realDeviceId : deviceID,
      "regSrc": platForm,
      "location": {
        "longitude": latitude ?? "${double.parse("0.0")}",
        "latitude": longtitude ?? "${double.parse("0.0")}",
      },
      "lang": lang ?? 'id',
    };
    'Login payload => $payload'.logger();
    print('payload');
    print(payload);

    await Repos().reposPost(
      context,
      (onResult) {
        if ((onResult.statusCode ?? 300) > HTTP_CODE) {
          print('salah 1');
          setUserFetch(UserFetch(UserState.LoginError, data: GenericResponse.fromJson(onResult.data).responseData));
        } else {
          setUserFetch(UserFetch(UserState.LoginSuccess, version: onResult.data['version'], versionIos: onResult.data['version_ios'], data: GenericResponse.fromJson(onResult.data).responseData));
          SharedPreference().removeValue(SpKeys.referralFrom);
        }
      },
      (errorData) {
        ShowBottomSheet.onInternalServerError(context);
        setUserFetch(UserFetch(UserState.LoginError));
      },
      errorServiceType: ErrorType.login,
      methodType: MethodType.post,
      withCheckConnection: false,
      withAlertMessage: true,
      host: UrlConstants.login,
      // host: 'item/test/',
      data: payload,
    );
  }

  Future signUpBlocV2(BuildContext context, {required SignUpDataArgument data}) async {
    setUserFetch(UserFetch(UserState.loading));
    await Repos().reposPost(context, (onResult) {
      if ((onResult.statusCode ?? 300) > HTTP_CODE) {
        setUserFetch(UserFetch(UserState.signUpError, data: GenericResponse.fromJson(onResult.data).responseData));
      } else {
        setUserFetch(UserFetch(UserState.signUpSuccess, data: GenericResponse.fromJson(onResult.data).responseData));
      }
    }, (errorData) {
      ShowBottomSheet.onInternalServerError(context);
      setUserFetch(UserFetch(UserState.signUpError));
      Dio().close(force: true);
    }, host: UrlConstants.signUp, data: data.toJson(), methodType: MethodType.post, withAlertMessage: true, withCheckConnection: false, errorServiceType: ErrorType.register, verbose: true);
  }

  Future updateProfileBlocV2(BuildContext context, {required Map<String, dynamic> data}) async {
    setUserFetch(UserFetch(UserState.loading));
    await Repos().reposPost(
      context,
      (onResult) {
        if ((onResult.statusCode ?? 300) > HTTP_CODE) {
          print("ini print data ${onResult.data}");
          setUserFetch(UserFetch(UserState.completeProfileError, data: onResult.data));
        } else {
          setUserFetch(UserFetch(UserState.completeProfileSuccess, data: GenericResponse.fromJson(onResult.data).responseData));
        }
      },
      (errorData) {
        ShowBottomSheet.onInternalServerError(context);
        setUserFetch(UserFetch(UserState.completeProfileError));
        Dio().close(force: true);
      },
      data: data,
      headers: {
        "x-auth-user": "${data["email"]}",
      },
      host: UrlConstants.updateProfile,
      methodType: MethodType.post,
      withAlertMessage: false,
      withCheckConnection: false,
    );
  }

  Future updateInterestBloc(BuildContext context, {required Map<String, dynamic> data}) async {
    setUserFetch(UserFetch(UserState.loading));
    await Repos().reposPost(
      context,
      (onResult) {
        if ((onResult.statusCode ?? 300) > HTTP_CODE) {
          setUserFetch(UserFetch(UserState.updateInterestError));
        } else {
          setUserFetch(UserFetch(UserState.updateInterestSuccess, data: GenericResponse.fromJson(onResult.data).responseData));
        }
      },
      (errorData) {
        ShowBottomSheet.onInternalServerError(context);
        setUserFetch(UserFetch(UserState.updateInterestError));
        Dio().close(force: true);
      },
      data: data,
      headers: {
        "x-auth-user": "${data["email"]}",
      },
      host: UrlConstants.updateInterest,
      methodType: MethodType.post,
      withAlertMessage: true,
      withCheckConnection: false,
    );
  }

  Future uploadProfilePictureBlocV2(
    BuildContext context, {
    required String file,
    required String email,
    required bool verifyID,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
  }) async {
    setUserFetch(UserFetch(UserState.loading));

    var formData = FormData();
    formData.fields.add(MapEntry('email', email));
    if (verifyID) {
      formData.files.add(
        MapEntry(
          "proofPict",
          await MultipartFile.fromFile(
            file,
            filename: System().basenameFiles(file),
            contentType: MediaType(
              System().lookupContentMimeType(file)?.split('/')[0] ?? '',
              System().extensionFiles(file)?.replaceAll(".", "") ?? '',
            ),
          ),
        ),
      );
      formData.fields.add(MapEntry('verifyID', "$verifyID"));
    } else {
      formData.files.add(
        MapEntry(
          "profilePict",
          await MultipartFile.fromFile(
            file,
            filename: System().basenameFiles(file),
            contentType: MediaType(
              System().lookupContentMimeType(file)?.split('/')[0] ?? '',
              System().extensionFiles(file)?.replaceAll(".", "") ?? '',
            ),
          ),
        ),
      );
    }

    await Repos().reposPost(
      context,
      (onResult) {
        if ((onResult.statusCode ?? 300) > HTTP_CODE) {
          setUserFetch(UserFetch(UserState.uploadProfilePictureError));
        } else {
          setUserFetch(UserFetch(UserState.uploadProfilePictureSuccess, data: onResult));
        }
      },
      (errorData) {
        if (errorData.type == DioErrorType.cancel) {
          print("You canceled change picture photo");
        } else {
          ShowBottomSheet.onInternalServerError(context);
        }
      },
      data: formData,
      withAlertMessage: true,
      withCheckConnection: false,
      headers: {
        "x-auth-user": email,
      },
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      host: UrlConstants.uploadProfilePictureV2,
      methodType: MethodType.postUploadProfile,
      errorServiceType: ErrorType.updateProfile,
    );
  }

  Future changePasswordBloc(BuildContext context, {required String oldPass, required String newPass}) async {
    setUserFetch(UserFetch(UserState.loading));
    final lang = SharedPreference().readStorage(SpKeys.isoCode);
    await Repos().reposPost(
      context,
      (onResult) {
        if ((onResult.statusCode ?? 300) > HTTP_CODE) {
          setUserFetch(UserFetch(UserState.changePasswordError, data: GenericResponse.fromJson(onResult.data).responseData));
        } else {
          setUserFetch(UserFetch(UserState.changePasswordSuccess, data: GenericResponse.fromJson(onResult.data).responseData));
        }
      },
      (errorData) {
        ShowBottomSheet.onInternalServerError(context);
        setUserFetch(UserFetch(UserState.changePasswordError));
        Dio().close(force: true);
      },
      errorServiceType: ErrorType.login,
      host: UrlConstants.changePassword,
      withAlertMessage: true,
      methodType: MethodType.post,
      withCheckConnection: false,
      headers: {
        "x-auth-user": SharedPreference().readStorage(SpKeys.email),
      },
      data: {
        "email": SharedPreference().readStorage(SpKeys.email),
        "oldPass": oldPass,
        "newPass": newPass,
        "lang": lang ?? 'id',
      },
    );
  }

  Future getUserProfilesBloc(BuildContext context, {String? search, required bool withAlertMessage, bool isByUsername = false}) async {
    setUserFetch(UserFetch(UserState.loading));
    var formData = FormData();
    formData.fields.add(MapEntry('search', search ?? (SharedPreference().readStorage(SpKeys.email) ?? '')));
    print('formData.fields');
    print(formData.fields);
    await Repos().reposPost(
      context,
      (onResult) {
        if ((onResult.statusCode ?? 300) != 202) {
          setUserFetch(UserFetch(UserState.getUserProfilesError));
        } else {
          UserProfileModel _result = UserProfileModel.fromJson(onResult.data["data"][0]);
          setUserFetch(UserFetch(UserState.getUserProfilesSuccess, data: _result));
        }
      },
      (errorData) {
        context.read<ErrorService>().addErrorObject(ErrorType.gGetUserDetail, errorData.message);
        setUserFetch(UserFetch(UserState.getUserProfilesError));
      },
      data: formData,
      headers: {
        "x-auth-user": SharedPreference().readStorage(SpKeys.email),
      },
      host: isByUsername ? UrlConstants.getProfileByUser : UrlConstants.getuserprofile,
      withCheckConnection: false,
      methodType: MethodType.post,
      withAlertMessage: withAlertMessage,
    );
  }

  Future getMyUserProfilesBloc(
    BuildContext context, {
    String? search,
    required bool withAlertMessage,
  }) async {
    setUserFetch(UserFetch(UserState.loading));
    var formData = FormData();
    // formData.fields.add(MapEntry('search', search ?? SharedPreference().readStorage(SpKeys.email)));
    await Repos().reposPost(
      context,
      (onResult) {
        if ((onResult.statusCode ?? 300) != 202) {
          setUserFetch(UserFetch(UserState.getUserProfilesError));
        } else {
          UserProfileModel _result = UserProfileModel.fromJson(onResult.data["data"][0]);
          setUserFetch(UserFetch(UserState.getUserProfilesSuccess, data: _result));
        }
      },
      (errorData) {
        context.read<ErrorService>().addErrorObject(ErrorType.gGetUserDetail, errorData.message);
        setUserFetch(UserFetch(UserState.getUserProfilesError));
      },
      data: formData,
      headers: {
        "x-auth-user": SharedPreference().readStorage(SpKeys.email),
      },
      host: UrlConstants.getMyUserPosts,
      withCheckConnection: false,
      methodType: MethodType.get,
      withAlertMessage: withAlertMessage,
    );
  }

  Future logOut(
    BuildContext context, {
    bool withAlertMessage = false,
  }) async {
    setUserFetch(UserFetch(UserState.loading));
    String? deviceID = SharedPreference().readStorage(SpKeys.fcmToken);
    String? email = SharedPreference().readStorage(SpKeys.email);

    await Repos().reposPost(
      context,
      (onResult) {
        if ((onResult.statusCode ?? 300) > HTTP_CODE) {
          setUserFetch(UserFetch(UserState.logoutError));
        } else {
          setUserFetch(UserFetch(UserState.logoutSuccess, data: onResult));
        }
      },
      (errorData) {
        setUserFetch(UserFetch(UserState.logoutError));
      },
      host: UrlConstants.logout,
      data: {
        "email": email,
        "deviceId": deviceID,
      },
      headers: {
        "x-auth-user": email,
      },
      withCheckConnection: false,
      methodType: MethodType.post,
      withAlertMessage: withAlertMessage,
    );
  }

  Future verifyAccountBlocV2(BuildContext context, {required String email, required String otp}) async {
    setUserFetch(UserFetch(UserState.loading));
    String? deviceId = SharedPreference().readStorage(SpKeys.fcmToken);
    deviceID = SharedPreference().readStorage(SpKeys.fcmToken);
    realDeviceId = await System().getDeviceIdentifier();
    referralEmail = SharedPreference().readStorage(SpKeys.referralFrom) ?? '';
    final lang = SharedPreference().readStorage(SpKeys.isoCode);

    await Repos().reposPost(
      context,
      (onResult) {
        if ((onResult.statusCode ?? 300) > HTTP_CODE) {
          setUserFetch(UserFetch(UserState.verifyAccountError, data: GenericResponse.fromJson(onResult.data).responseData));
        } else {
          setUserFetch(UserFetch(UserState.verifyAccountSuccess, data: GenericResponse.fromJson(onResult.data).responseData));
        }
      },
      (errorData) {
        ShowBottomSheet.onInternalServerError(context);
        setUserFetch(UserFetch(UserState.verifyAccountError));
        Dio().close(force: true);
      },
      data: {
        "otp": otp,
        'email': email,
        "status": "REPLY",
        "event": "VERIFY_OTP",
        "deviceId": "$deviceId",
        "referral": referralEmail,
        "imei": realDeviceId != "" ? realDeviceId : deviceID,
        "lang": lang ?? 'id',
      },
      host: UrlConstants.verifyAccount,
      methodType: MethodType.post,
      withAlertMessage: true,
      withCheckConnection: false,
      errorServiceType: ErrorType.otpVerifyAccount,
    );
  }

  Future resendOTPBloc(BuildContext context, {required Function function, required String email}) async {
    setUserFetch(UserFetch(UserState.loading));
    await Repos().reposPost(
      context,
      (onResult) {
        print(onResult);

        if (onResult.data['status'] != null) {
          if (onResult.data['status'] > HTTP_CODE) {
            setUserFetch(UserFetch(UserState.resendOTPError, data: GenericResponse.fromJson(onResult.data).responseData));
          } else {
            setUserFetch(UserFetch(UserState.resendOTPSuccess, data: GenericResponse.fromJson(onResult.data).responseData));
          }
        } else {
          if ((onResult.statusCode ?? 300) > HTTP_CODE) {
            setUserFetch(UserFetch(UserState.resendOTPError, data: GenericResponse.fromJson(onResult.data).responseData));
          } else {
            setUserFetch(UserFetch(UserState.resendOTPSuccess, data: GenericResponse.fromJson(onResult.data).responseData));
          }
        }
      },
      (errorData) {
        print(errorData);
        ShowBottomSheet.onInternalServerError(context);
        setUserFetch(UserFetch(UserState.resendOTPError));
        Dio().close(force: true);
      },
      data: {
        'email': email,
      },
      host: UrlConstants.resendOTP,
      methodType: MethodType.post,
      withAlertMessage: true,
      withCheckConnection: false,
    );
  }

  Future signInWithGoogleBloc(BuildContext context, {required GoogleSignInAccount? userAccount}) async {
    setUserFetch(UserFetch(UserState.loading));
    final lang = SharedPreference().readStorage(SpKeys.isoCode);
    await Repos().reposPost(
      context,
      (onResult) {
        if ((onResult.statusCode ?? 300) != HTTP_OK) {
          setUserFetch(UserFetch(UserState.LoginGoogleError, data: onResult.data));
        } else {
          setUserFetch(UserFetch(UserState.LoginGoogleSuccess, data: onResult));
        }
      },
      (errorData) {
        ShowBottomSheet.onInternalServerError(context);
        setUserFetch(UserFetch(UserState.LoginGoogleError));
      },
      methodType: MethodType.post,
      withCheckConnection: false,
      withAlertMessage: true,
      host: UrlConstants.loginGoogle,
      data: {
        "profile": {
          "email": userAccount?.email,
          "displayName": userAccount?.displayName,
          "photoURL": userAccount?.photoUrl,
          "uid": userAccount?.id,
        },
        "deviceId": SharedPreference().readStorage(SpKeys.fcmToken),
        "location": {
          "longitude": "${double.parse("0.0")}",
          "latitude": "${double.parse("0.0")}",
        },
        "lang": lang ?? 'id',
      },
    );
  }

  Future deleteAccountBlocV2(BuildContext context) async {
    setUserFetch(UserFetch(UserState.loading));
    String? email = SharedPreference().readStorage(SpKeys.email);
    String? token = SharedPreference().readStorage(SpKeys.userToken);

    await Repos().reposPost(
      context,
      (onResult) {
        if ((onResult.statusCode ?? 300) > HTTP_CODE) {
          setUserFetch(UserFetch(UserState.deleteAccountError, data: GenericResponse.fromJson(onResult.data).responseData));
        } else {
          setUserFetch(UserFetch(UserState.deleteAccountSuccess, data: GenericResponse.fromJson(onResult.data).responseData));
        }
      },
      (errorData) {
        ShowBottomSheet.onInternalServerError(context);
        setUserFetch(UserFetch(UserState.deleteAccountError));
        Dio().close(force: true);
      },
      data: {
        "email": email,
      },
      headers: {"x-auth-user": email, "x-auth-token": token},
      host: UrlConstants.deleteAccount,
      methodType: MethodType.post,
      withAlertMessage: true,
      withCheckConnection: false,
    );
  }
}
