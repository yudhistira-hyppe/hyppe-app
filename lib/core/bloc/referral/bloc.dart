import 'package:flutter/material.dart';
import 'package:hyppe/core/arguments/referral_argument.dart';
import 'package:hyppe/core/arguments/register_referral_argument.dart';
import 'package:hyppe/core/bloc/referral/state.dart';
import 'package:hyppe/core/bloc/repos/repos.dart';
import 'package:hyppe/core/config/url_constants.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/status_code.dart';
import 'package:hyppe/core/response/generic_response.dart';
import 'package:hyppe/core/services/error_service.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class ReferralBloc {
  ReferralFetch _referralFetch = ReferralFetch(ReferralState.init);
  ReferralFetch get referralFetch => _referralFetch;
  setReferralFetch(ReferralFetch val) => _referralFetch = val;

  Future getReferralCount(BuildContext context) async {
    setReferralFetch(ReferralFetch(ReferralState.loading));
    await Repos().reposPost(
      context,
      (onResult) {
        if (onResult.statusCode != 202) {
          setReferralFetch(ReferralFetch(ReferralState.getReferralUserError));
        } else {
          setReferralFetch(ReferralFetch(ReferralState.getReferralUserSuccess, data: onResult.data));
        }
      },
      (errorData) {
        context.read<ErrorService>().addErrorObject(ErrorType.unknown, errorData.message);
        setReferralFetch(ReferralFetch(ReferralState.getReferralUserError));
      },
      data: null,
      headers: {
        "x-auth-user": SharedPreference().readStorage(SpKeys.email),
      },
      host: UrlConstants.referralCount,
      withCheckConnection: false,
      methodType: MethodType.post,
      withAlertMessage: false,
    );
  }

  Future referralUserBloc(
    BuildContext context, {
    bool withAlertConnection = true,
    required ReferralUserArgument data,
  }) async {
    print('ini email sapa ${data.email} ${data.imei}');
    setReferralFetch(ReferralFetch(ReferralState.loading));
    await Repos().reposPost(
      context,
      (onResult) {
        if (onResult.statusCode! > HTTP_CODE) {
          setReferralFetch(ReferralFetch(ReferralState.referralUserError));
        } else {
          setReferralFetch(ReferralFetch(ReferralState.referralUserSuccess, data: GenericResponse.fromJson(onResult.data).responseData));
        }
      },
      (errorData) {
        ShowBottomSheet.onInternalServerError(context, tryAgainButton: () => Routing().moveBack());
        setReferralFetch(ReferralFetch(ReferralState.referralUserError));
      },
      headers: {
        "x-auth-user": SharedPreference().readStorage(SpKeys.email),
      },
      data: data.toJson(),
      host: UrlConstants.referral,
      withCheckConnection: true,
      methodType: MethodType.post,
      withAlertMessage: withAlertConnection,
    );
  }

  Future registerReferral(
    BuildContext context, {
    bool withAlertConnection = true,
    required RegisterReferralArgument data,
  }) async {
    setReferralFetch(ReferralFetch(ReferralState.loading));
    await Repos().reposPost(
      context,
      (onResult) {
        if (onResult.statusCode! == 406 || onResult.statusCode! > HTTP_CODE) {
          setReferralFetch(ReferralFetch(ReferralState.referralUserError));
        } else if (onResult.statusCode! == 200) {
          setReferralFetch(ReferralFetch(ReferralState.referralUserError, data: (onResult.data)));
        } else {
          setReferralFetch(ReferralFetch(ReferralState.referralUserSuccess, data: GenericResponse.fromJson(onResult.data).responseData));
        }
      },
      (errorData) {
        ShowBottomSheet.onInternalServerError(context, tryAgainButton: () => Routing().moveBack());
        setReferralFetch(ReferralFetch(ReferralState.referralUserError));
      },
      headers: {
        "x-auth-user": SharedPreference().readStorage(SpKeys.email),
      },
      data: data.toJson(),
      host: UrlConstants.referral,
      withCheckConnection: true,
      methodType: MethodType.post,
      withAlertMessage: withAlertConnection,
    );
  }
}
