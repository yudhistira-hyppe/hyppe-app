import 'package:flutter/material.dart';
import 'package:hyppe/core/bloc/device/state.dart';
import 'package:hyppe/core/bloc/repos/repos.dart';
import 'package:hyppe/core/config/url_constants.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/status_code.dart';
import 'package:hyppe/core/response/generic_response.dart';
import 'package:hyppe/core/services/shared_preference.dart';

class DeviceBloc {
  DeviceFetch _deviceFetch = DeviceFetch(DeviceState.init);
  DeviceFetch get deviceFetch => _deviceFetch;
  setDeviceFetch(DeviceFetch val) => _deviceFetch = val;

  Future activityAwake(BuildContext context) async {
    setDeviceFetch(DeviceFetch(DeviceState.loading));

    final _sharedPreference = SharedPreference();
    String? email = _sharedPreference.readStorage(SpKeys.email);
    String? deviceID = _sharedPreference.readStorage(SpKeys.fcmToken);

    await Repos().reposPost(
      context,
      (onResult) {
        if ((onResult.statusCode ?? 300) > HTTP_CODE) {
          setDeviceFetch(DeviceFetch(DeviceState.activityAwakeError, version: onResult.data['version'], data: GenericResponse.fromJson(onResult.data).responseData));
        } else {
          setDeviceFetch(
            DeviceFetch(DeviceState.activityAwakeSuccess, version: onResult.data['version'], versionIos: onResult.data['version_ios'], data: GenericResponse.fromJson(onResult.data).responseData),
          );
        }
      },
      (errorData) {
        setDeviceFetch(DeviceFetch(DeviceState.activityAwakeError));
      },
      methodType: MethodType.post,
      withCheckConnection: false,
      withAlertMessage: false,
      host: UrlConstants.deviceactivity,
      headers: {
        "x-auth-user": "$email",
      },
      data: {
        "email": "$email",
        "deviceId": "$deviceID",
        "event": "AWAKE",
        "status": "INITIAL",
      },
    );
  }

  Future activitySleep(BuildContext context) async {
    setDeviceFetch(DeviceFetch(DeviceState.loading));

    final _sharedPreference = SharedPreference();
    String? email = _sharedPreference.readStorage(SpKeys.email);
    String? deviceID = _sharedPreference.readStorage(SpKeys.fcmToken);

    await Repos().reposPost(
      context,
      (onResult) {
        if ((onResult.statusCode ?? 300) > HTTP_CODE) {
          setDeviceFetch(DeviceFetch(DeviceState.activityAwakeSuccess, data: GenericResponse.fromJson(onResult.data).responseData));
        } else {
          setDeviceFetch(DeviceFetch(DeviceState.activityAwakeError, data: GenericResponse.fromJson(onResult.data).responseData));
        }
      },
      (errorData) {
        setDeviceFetch(DeviceFetch(DeviceState.activityAwakeError));
      },
      methodType: MethodType.post,
      withCheckConnection: false,
      withAlertMessage: false,
      host: UrlConstants.deviceactivity,
      headers: {
        "x-auth-user": "$email",
      },
      data: {
        "email": "$email",
        "deviceId": "$deviceID",
        "event": "SLEEP",
        "status": "ACTIVE",
      },
    );
  }
}
