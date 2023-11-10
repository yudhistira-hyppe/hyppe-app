import 'package:hyppe/core/bloc/effect/state.dart';
import 'package:hyppe/core/bloc/repos/repos.dart';
import 'package:hyppe/core/config/url_constants.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/status_code.dart';
import 'package:hyppe/core/response/generic_response.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/enum.dart';

class EffectBloc {
  static final _repos = Repos();

  EffectFetch _effectFetch = EffectFetch(EffectState.init);
  EffectFetch get effectFetch => _effectFetch;
  setEffectFetch(EffectFetch val) => _effectFetch = val;

  Future getEffects(BuildContext context) async {
    setEffectFetch(EffectFetch(EffectState.loading));
    
    final email = SharedPreference().readStorage(SpKeys.email);
    final token = SharedPreference().readStorage(SpKeys.userToken);
    await _repos.reposPost(
      context,
      (onResult) {
        if ((onResult.statusCode ?? 300) > HTTP_CODE) {
          setEffectFetch(EffectFetch(EffectState.getEffectError));
        } else {
          setEffectFetch(EffectFetch(EffectState.getEffectSuccess, data: GenericResponse.fromJson(onResult.data).responseData));
        }
      },
      (errorData) {
        ShowBottomSheet.onInternalServerError(context, statusCode: errorData.response?.statusCode);
        setEffectFetch(EffectFetch(EffectState.getEffectError));
      },
      errorServiceType: ErrorType.getEffect,
      host: UrlConstants.getEffects,
      withAlertMessage: false,
      methodType: MethodType.get,
      withCheckConnection: false,
      headers: {
        'x-auth-user': email,
        'x-auth-token': token,
      }
    );
  }

  Future downloadEffect({required BuildContext context, required String? effectID, required String savePath, required VoidCallback whenComplete}) async {
    setEffectFetch(EffectFetch(EffectState.loading));
    
    final email = SharedPreference().readStorage(SpKeys.email);
    final token = SharedPreference().readStorage(SpKeys.userToken);
    await _repos.reposPost(
      context,
      (onResult) {},
      (errorData) {},
      errorServiceType: ErrorType.downloadEffect,
      host: "${UrlConstants.downloadEffect}/$effectID?x-auth-user=$email&x-auth-token=$token",
      savePath: savePath,
      withAlertMessage: false,
      methodType: MethodType.download,
      withCheckConnection: false,
      whenComplete: () {
        whenComplete();
      }
    );
  }
}
