import 'package:flutter/material.dart';
import 'package:hyppe/core/arguments/referral_argument.dart';
import 'package:hyppe/core/bloc/postviewer/state.dart';
import 'package:hyppe/core/bloc/repos/repos.dart';
import 'package:hyppe/core/config/url_constants.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/status_code.dart';
import 'package:hyppe/core/response/generic_response.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ux/routing.dart';

class PostViewerBloc {
  PostViewerFetch _postViewerFetch = PostViewerFetch(PostViewerState.init);
  PostViewerFetch get postViewerFetch => _postViewerFetch;
  setPostViewerFetch(PostViewerFetch val) => _postViewerFetch = val;

  Future postViewerBloc(
    BuildContext context, {
    bool withAlertConnection = true,
    required String postID,
  }) async {
    setPostViewerFetch(PostViewerFetch(PostViewerState.loading));
    await Repos().reposPost(
      context,
      (onResult) {
        if (onResult.statusCode! > HTTP_CODE) {
          setPostViewerFetch(PostViewerFetch(PostViewerState.postViewerUserError));
        } else {
          setPostViewerFetch(PostViewerFetch(PostViewerState.postViewerUserSuccess,
              data: GenericResponse.fromJson(onResult.data).responseData));
        }
      },
      (errorData) {
        ShowBottomSheet.onInternalServerError(context,
            tryAgainButton: () => Routing().moveBack());
        setPostViewerFetch(PostViewerFetch(PostViewerState.postViewerUserError));
      },
      headers: {
        "x-auth-user": SharedPreference().readStorage(SpKeys.email),
      },
      data: {"postID":postID},
      host: UrlConstants.postViewer,
      withCheckConnection: true,
      methodType: MethodType.post,
      withAlertMessage: withAlertConnection,
    );
  }
}
