import 'package:hyppe/core/arguments/sign_up_argument.dart';
import 'package:hyppe/core/bloc/repos/repos.dart';
import 'package:hyppe/core/config/url_constants.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/status_code.dart';
import 'package:hyppe/core/models/collection/user_v2/profile/user_profile_model.dart';
import 'package:hyppe/core/response/generic_response.dart';
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

  Future recoverPasswordBloc(BuildContext context, {required String email}) async {
    setUserFetch(UserFetch(UserState.loading));
    await Repos().reposPost(
      context,
      (onResult) {
        if (onResult.statusCode! > HTTP_CODE) {
          setUserFetch(UserFetch(UserState.RecoverError, data: GenericResponse.fromJson(onResult.data).responseData));
        } else {
          setUserFetch(UserFetch(UserState.RecoverSuccess, data: GenericResponse.fromJson(onResult.data).responseData));
        }
      },
      (errorData) {
        ShowBottomSheet.onInternalServerError(context, tryAgainButton: () => Routing().moveBack());
        setUserFetch(UserFetch(UserState.RecoverError));
        Dio().close(force: true);
      },
      onNoInternet: () {
        Routing().moveBack();
      },
      data: {
        "email": email,
        "event": "RECOVER_PASS",
        "status": "INITIAL",
        "deviceId": SharedPreference().readStorage(SpKeys.fcmToken),
      },
      withAlertMessage: true,
      withCheckConnection: true,
      host: UrlConstants.recoverPassword,
      methodType: MethodType.post,
    );
  }

  Future recoverPasswordOTPBloc(BuildContext context, {required String email, required String otp}) async {
    setUserFetch(UserFetch(UserState.loading));
    await Repos().reposPost(
      context,
      (onResult) {
        if (onResult.statusCode! > HTTP_CODE) {
          setUserFetch(UserFetch(UserState.RecoverError, data: GenericResponse.fromJson(onResult.data).responseData));
        } else {
          setUserFetch(UserFetch(UserState.RecoverSuccess, data: GenericResponse.fromJson(onResult.data).responseData));
        }
      },
      (errorData) {
        ShowBottomSheet.onInternalServerError(context, tryAgainButton: () => Routing().moveBack());
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
      },
      withAlertMessage: true,
      withCheckConnection: true,
      host: UrlConstants.recoverPassword,
      methodType: MethodType.post,
    );
  }

  Future signInBlocV2(BuildContext context, {required Function() function, required String email, required String password}) async {
    setUserFetch(UserFetch(UserState.loading));
    String? deviceID = SharedPreference().readStorage(SpKeys.fcmToken);

    await Repos().reposPost(
      context,
      (onResult) {
        if (onResult.statusCode! > HTTP_CODE) {
          setUserFetch(UserFetch(UserState.LoginError, data: GenericResponse.fromJson(onResult.data).responseData));
        } else {
          setUserFetch(UserFetch(UserState.LoginSuccess, data: GenericResponse.fromJson(onResult.data).responseData));
        }
      },
      (errorData) {
        ShowBottomSheet.onInternalServerError(context, tryAgainButton: () {
          Routing().moveBack();
          function();
        });
        setUserFetch(UserFetch(UserState.LoginError));
      },
      methodType: MethodType.post,
      withCheckConnection: false,
      withAlertMessage: true,
      host: UrlConstants.login,
      data: {
        'email': email.toLowerCase(),
        "password": password,
        "deviceId": deviceID,
        "location": {
          "longitude": "${double.parse("0.0")}",
          "latitude": "${double.parse("0.0")}",
        },
      },
    );
  }

  Future signUpBlocV2(BuildContext context, {required SignUpDataArgument data}) async {
    setUserFetch(UserFetch(UserState.loading));
    await Repos().reposPost(
      context,
      (onResult) {
        if (onResult.statusCode! > HTTP_CODE) {
          setUserFetch(UserFetch(UserState.signUpError, data: GenericResponse.fromJson(onResult.data).responseData));
        } else {
          setUserFetch(UserFetch(UserState.signUpSuccess, data: GenericResponse.fromJson(onResult.data).responseData));
        }
      },
      (errorData) {
        ShowBottomSheet.onInternalServerError(context, tryAgainButton: () => Routing().moveBack());
        setUserFetch(UserFetch(UserState.signUpError));
        Dio().close(force: true);
      },
      host: UrlConstants.signUp,
      data: data.toJson(),
      methodType: MethodType.post,
      withAlertMessage: true,
      withCheckConnection: false,
    );
  }

  Future updateProfileBlocV2(BuildContext context, {required Map<String, dynamic> data}) async {
    setUserFetch(UserFetch(UserState.loading));
    await Repos().reposPost(
      context,
      (onResult) {
        if (onResult.statusCode! > HTTP_CODE) {
          setUserFetch(UserFetch(UserState.completeProfileError));
        } else {
          setUserFetch(UserFetch(UserState.completeProfileSuccess, data: GenericResponse.fromJson(onResult.data).responseData));
        }
      },
      (errorData) {
        ShowBottomSheet.onInternalServerError(context, tryAgainButton: () => Routing().moveBack());
        setUserFetch(UserFetch(UserState.completeProfileError));
        Dio().close(force: true);
      },
      data: data,
      headers: {
        "x-auth-user": "${data["email"]}",
      },
      host: UrlConstants.updateProfile,
      methodType: MethodType.post,
      withAlertMessage: true,
      withCheckConnection: false,
    );
  }

  Future updateInterestBloc(BuildContext context, {required Map<String, dynamic> data}) async {
    setUserFetch(UserFetch(UserState.loading));
    await Repos().reposPost(
      context,
      (onResult) {
        if (onResult.statusCode! > HTTP_CODE) {
          setUserFetch(UserFetch(UserState.updateInterestError));
        } else {
          setUserFetch(UserFetch(UserState.updateInterestSuccess, data: GenericResponse.fromJson(onResult.data).responseData));
        }
      },
      (errorData) {
        ShowBottomSheet.onInternalServerError(context, tryAgainButton: () => Routing().moveBack());
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

  // Future postBioBlocV2(BuildContext context, {required UpdateBioArgument argument}) async {
  //   setUserFetch(UserFetch(UserState.loading));
  //   await Repos().reposPost(
  //     context,
  //     (onResult) {
  //       if (onResult.statusCode != HTTP_OK) {
  //         setUserFetch(UserFetch(UserState.postBioError));
  //       } else {
  //         setUserFetch(UserFetch(UserState.postBioSuccess));
  //       }
  //     },
  //     (errorData) {
  //       ShowBottomSheet.onInternalServerError(context, tryAgainButton: () => Routing().moveBack());
  //       setUserFetch(UserFetch(UserState.postBioError));
  //     },
  //     host: APIs.bio,
  //     data: argument.toJson(),
  //     headers: {
  //       "x-auth-user": "${argument.email}",
  //     },
  //     withAlertMessage: false,
  //     methodType: MethodType.post,
  //     withCheckConnection: false,
  //   );
  // }

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
        if (onResult.statusCode! > HTTP_CODE) {
          setUserFetch(UserFetch(UserState.uploadProfilePictureError));
        } else {
          setUserFetch(UserFetch(UserState.uploadProfilePictureSuccess, data: onResult));
        }
      },
      (errorData) {
        if (errorData.type == DioErrorType.cancel) {
          print("You canceled change picture photo");
        } else {
          ShowBottomSheet.onInternalServerError(context, tryAgainButton: () => Routing().moveBack());
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
    );
  }

  Future changePasswordBloc(BuildContext context, {required String oldPass, required String newPass}) async {
    setUserFetch(UserFetch(UserState.loading));
    await Repos().reposPost(
      context,
      (onResult) {
        if (onResult.statusCode! > HTTP_CODE) {
          setUserFetch(UserFetch(UserState.changePasswordError, data: GenericResponse.fromJson(onResult.data).responseData));
        } else {
          setUserFetch(UserFetch(UserState.changePasswordSuccess, data: GenericResponse.fromJson(onResult.data).responseData));
        }
      },
      (errorData) {
        ShowBottomSheet.onInternalServerError(context, tryAgainButton: () => Routing().moveBack());
        setUserFetch(UserFetch(UserState.changePasswordError));
        Dio().close(force: true);
      },
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
      },
    );
  }

  Future getUserProfilesBloc(
    BuildContext context, {
    String? search,
    required bool withAlertMessage,
  }) async {
    setUserFetch(UserFetch(UserState.loading));
    var formData = FormData();
    formData.fields.add(MapEntry('search', search ?? SharedPreference().readStorage(SpKeys.email)));
    await Repos().reposPost(
      context,
      (onResult) {
        if (onResult.statusCode != 202) {
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
      host: UrlConstants.getuserprofile,
      withCheckConnection: false,
      methodType: MethodType.post,
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
        if (onResult.statusCode! > HTTP_CODE) {
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

    await Repos().reposPost(
      context,
      (onResult) {
        if (onResult.statusCode! > HTTP_CODE) {
          setUserFetch(UserFetch(UserState.verifyAccountError, data: GenericResponse.fromJson(onResult.data).responseData));
        } else {
          setUserFetch(UserFetch(UserState.verifyAccountSuccess, data: GenericResponse.fromJson(onResult.data).responseData));
        }
      },
      (errorData) {
        ShowBottomSheet.onInternalServerError(context, tryAgainButton: () {
          Routing().moveBack();
        });
        setUserFetch(UserFetch(UserState.verifyAccountError));
        Dio().close(force: true);
      },
      data: {
        "otp": otp,
        'email': email,
        "status": "REPLY",
        "event": "VERIFY_OTP",
        "deviceId": "$deviceId",
      },
      host: UrlConstants.verifyAccount,
      methodType: MethodType.post,
      withAlertMessage: true,
      withCheckConnection: false,
    );
  }

  Future resendOTPBloc(BuildContext context, {required Function function, required String username}) async {
    setUserFetch(UserFetch(UserState.loading));
    await Repos().reposPost(
      context,
      (onResult) {
        if (onResult.data['status'] != null) {
          if (onResult.data['status'] > HTTP_CODE) {
            setUserFetch(UserFetch(UserState.resendOTPError, data: GenericResponse.fromJson(onResult.data).responseData));
          } else {
            setUserFetch(UserFetch(UserState.resendOTPSuccess, data: GenericResponse.fromJson(onResult.data).responseData));
          }
        } else {
          if (onResult.statusCode! > HTTP_CODE) {
            setUserFetch(UserFetch(UserState.resendOTPError, data: GenericResponse.fromJson(onResult.data).responseData));
          } else {
            setUserFetch(UserFetch(UserState.resendOTPSuccess, data: GenericResponse.fromJson(onResult.data).responseData));
          }
        }
      },
      (errorData) {
        ShowBottomSheet.onInternalServerError(context, tryAgainButton: () {
          Routing().moveBack();
          function();
        });
        setUserFetch(UserFetch(UserState.resendOTPError));
        Dio().close(force: true);
      },
      data: {
        'username': username,
      },
      host: UrlConstants.resendOTP,
      methodType: MethodType.post,
      withAlertMessage: true,
      withCheckConnection: false,
    );
  }

  Future signInWithGoogleBloc(BuildContext context, {required GoogleSignInAccount? userAccount}) async {
    setUserFetch(UserFetch(UserState.loading));
    await Repos().reposPost(
      context,
      (onResult) {
        if (onResult.statusCode != HTTP_OK) {
          setUserFetch(UserFetch(UserState.LoginGoogleError, data: onResult.data));
        } else {
          setUserFetch(UserFetch(UserState.LoginGoogleSuccess, data: onResult));
        }
      },
      (errorData) {
        ShowBottomSheet.onInternalServerError(context, tryAgainButton: () => Routing().moveBack());
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
      },
    );
  }
}
