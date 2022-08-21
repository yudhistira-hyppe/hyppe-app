import 'package:flutter/material.dart';
import 'package:hyppe/core/bloc/like/state.dart';
import 'package:hyppe/core/bloc/repos/repos.dart';
import 'package:hyppe/core/config/url_constants.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/status_code.dart';
import 'package:hyppe/core/response/generic_response.dart';
import 'package:hyppe/core/services/shared_preference.dart';

class LikeBloc {
  LikeFetch _likeFetch = LikeFetch(LikeState.init);
  LikeFetch get likeFetch => _likeFetch;
  setLikeFetch(LikeFetch val) => _likeFetch = val;

  final _repos = Repos();

  Future likePostUserBloc(BuildContext context, {required String postId, required String emailOwner, required bool isLike}) async {
    final email = SharedPreference().readStorage(SpKeys.email);

    final Map<String, String> _data = {"eventType": isLike ? "LIKE" : "UNLIKE", "postID": postId, "receiverParty": emailOwner};

    await _repos.reposPost(
      context,
      (onResult) {
        if (onResult.statusCode! > HTTP_CODE) {
          setLikeFetch(LikeFetch(LikeState.likeUserPostFailed));
        } else {
          setLikeFetch(LikeFetch(LikeState.likeUserPostSuccess, data: GenericResponse.fromJson(onResult.data).responseData));
        }
      },
      (errorData) {
        setLikeFetch(LikeFetch(LikeState.likeUserPostFailed));
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
