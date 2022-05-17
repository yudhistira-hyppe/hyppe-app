import 'package:flutter/material.dart';
import 'package:hyppe/core/arguments/referral_argument.dart';
import 'package:hyppe/core/bloc/referral/state.dart';
import 'package:hyppe/core/bloc/repos/repos.dart';
import 'package:hyppe/core/config/url_constants.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/status_code.dart';
import 'package:hyppe/core/response/generic_response.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ux/routing.dart';

class ReferralBloc {
  ReferralFetch _referralFetch = ReferralFetch(ReferralState.init);
  ReferralFetch get referralFetch => _referralFetch;
  setReferralFetch(ReferralFetch val) => _referralFetch = val;

  Future referralUserBloc(
    BuildContext context, {
    bool withAlertConnection = true,
    required ReferralUserArgument data,
  }) async {
    setReferralFetch(ReferralFetch(ReferralState.loading));
    await Repos().reposPost(
      context,
      (onResult) {
        if (onResult.statusCode! > HTTP_CODE) {
          setReferralFetch(ReferralFetch(ReferralState.referralUserError));
        } else {
          setReferralFetch(ReferralFetch(ReferralState.referralUserSuccess,
              data: GenericResponse.fromJson(onResult.data).responseData));
        }
      },
      (errorData) {
        ShowBottomSheet.onInternalServerError(context,
            tryAgainButton: () => Routing().moveBack());
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
