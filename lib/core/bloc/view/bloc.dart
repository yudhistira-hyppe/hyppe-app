import 'package:flutter/material.dart';
import 'package:hyppe/core/bloc/repos/repos.dart';
import 'package:hyppe/core/bloc/view/state.dart';
import 'package:hyppe/core/config/url_constants.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/status_code.dart';
import 'package:hyppe/core/response/generic_response.dart';
import 'package:hyppe/core/services/shared_preference.dart';

class ViewBloc {
  ViewFetch _viewFetch = ViewFetch(ViewState.init);
  ViewFetch get viewFetch => _viewFetch;
  setViewFetch(ViewFetch val) => _viewFetch = val;

  final _repos = Repos();

  Future viewPostUserBloc(BuildContext context, {required String postId, required String emailOwner}) async {
    final email = SharedPreference().readStorage(SpKeys.email);
    final Map<String, String> _data = {
      "eventType" : "VIEW",
      "postID": postId,
      "receiverParty": emailOwner
    };

    await _repos.reposPost(
      context,
      (onResult) {
        if ((onResult.statusCode ?? 300) > HTTP_CODE) {
          setViewFetch(ViewFetch(ViewState.viewUserPostFailed));
        } else {
          setViewFetch(ViewFetch(ViewState.viewUserPostSuccess, data: GenericResponse.fromJson(onResult.data).responseData));
        }
      },
      (errorData) {
        setViewFetch(ViewFetch(ViewState.viewUserPostFailed));
      },
      headers: {
        'x-auth-user': email,
      },
      data: _data,
      host: UrlConstants.interactive,
      methodType: MethodType.post,
      withAlertMessage: false,
      withCheckConnection: true,
    );
  }
}
