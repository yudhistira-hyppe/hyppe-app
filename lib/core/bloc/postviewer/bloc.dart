import 'package:flutter/material.dart';
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
        if ((onResult.statusCode ?? 300) > HTTP_CODE) {
          setPostViewerFetch(PostViewerFetch(PostViewerState.postViewerUserError));
        } else {
          setPostViewerFetch(PostViewerFetch(PostViewerState.postViewerUserSuccess, data: GenericResponse.fromJson(onResult.data).responseData));
        }
      },
      (errorData) {
        ShowBottomSheet.onInternalServerError(context, tryAgainButton: () => Routing().moveBack());
        setPostViewerFetch(PostViewerFetch(PostViewerState.postViewerUserError));
      },
      headers: {
        "x-auth-user": SharedPreference().readStorage(SpKeys.email),
      },
      data: {"postID": postID},
      host: UrlConstants.postViewer,
      withCheckConnection: true,
      methodType: MethodType.post,
      withAlertMessage: withAlertConnection,
    );
  }

  Future likeViewContentBloc(
    BuildContext context, {
    bool withAlertConnection = true,
    String? eventType,
    int? skip,
    int? limit,
    required String postID,
  }) async {
    print('hahaha status code2');
    setPostViewerFetch(PostViewerFetch(PostViewerState.loading));
    await Repos().reposPost(
      context,
      (onResult) {
        print('hahaha status code');
        print(onResult.statusCode);
        if ((onResult.statusCode ?? 300) > HTTP_CODE) {
          setPostViewerFetch(PostViewerFetch(PostViewerState.likeViewError));
        } else {
          // print(onResult.data['data']);
          setPostViewerFetch(PostViewerFetch(PostViewerState.likeViewSuccess, data: onResult.data['data']));
        }
      },
      (errorData) {
        print('asasas');
        print(errorData);
        ShowBottomSheet.onInternalServerError(context, tryAgainButton: () => Routing().moveBack());
        setPostViewerFetch(PostViewerFetch(PostViewerState.likeViewError));
      },
      headers: {
        "x-auth-user": SharedPreference().readStorage(SpKeys.email),
      },
      data: {
        "postID": postID,
        "eventType": eventType,
        "skip": skip,
        "limit": limit,
      },
      host: UrlConstants.viewLike,
      withCheckConnection: true,
      methodType: MethodType.post,
      withAlertMessage: withAlertConnection,
    );
  }
}
