import 'package:flutter/material.dart';
import 'package:hyppe/core/bloc/delete_comment/state.dart';
import 'package:hyppe/core/bloc/repos/repos.dart';
import 'package:hyppe/core/config/url_constants.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/status_code.dart';
import 'package:hyppe/core/response/generic_response.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ux/routing.dart';

class DeleteCommentBloc {
  DeleteCommentPost _deleteCommentPost =
      DeleteCommentPost(DeleteCommentState.init);
  DeleteCommentPost get deletCommentFetch => _deleteCommentPost;
  setDeleteCommentFetch(DeleteCommentPost val) => _deleteCommentPost = val;

  Future postDeleteCommentBloc(
    BuildContext context, {
    bool withAlertConnection = true,
    required String lineID,
  }) async {
    setDeleteCommentFetch(DeleteCommentPost(DeleteCommentState.loading));
    await Repos().reposPost(
      context,
      (onResult) {
        if ((onResult.statusCode ?? 0) > HTTP_CODE) {
          setDeleteCommentFetch(
              DeleteCommentPost(DeleteCommentState.deleteCommentError));
        } else {
          setDeleteCommentFetch(DeleteCommentPost(
              DeleteCommentState.deleteCommentSuccess,
              data: GenericResponse.fromJson(onResult.data).responseData));
        }
      },
      (errorData) {
        ShowBottomSheet.onInternalServerError(context,
            tryAgainButton: () => Routing().moveBack());
        setDeleteCommentFetch(
            DeleteCommentPost(DeleteCommentState.deleteCommentError));
      },
      headers: {
        "x-auth-user": SharedPreference().readStorage(SpKeys.email),
      },
      data: {"disqusLogID": lineID},
      host: UrlConstants.removeComment,
      withCheckConnection: true,
      methodType: MethodType.post,
      withAlertMessage: withAlertConnection,
    );
  }
}
