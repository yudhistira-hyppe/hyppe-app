import 'dart:convert';

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

  Future likePostUserBloc(
    BuildContext context, {
    required String postId,
    required String emailOwner,
    required bool isLike,
    required List userView,
    required List userLike,
    required num saleAmount,
    required String createdAt,
    required List mediaSource,
    required String description,
    required bool active,
  }) async {
    final email = SharedPreference().readStorage(SpKeys.email);

    final Map<String, dynamic> _data = {"eventType": !isLike ? "LIKE" : "UNLIKE", "postID": postId, "receiverParty": emailOwner, "userView": userView, "userLike": userLike, "saleAmount": saleAmount, "createdAt": createdAt, "mediaSource": mediaSource, "description": description, "active": active};

    String challangedata = SharedPreference().readStorage(SpKeys.challangeData) ?? '';
    print("====== $challangedata");
    if (challangedata != '') {
      var dataListChallange = jsonDecode(challangedata);
      _data['listchallenge'] = dataListChallange;
    }

    await _repos.reposPost(
      context,
      (onResult) {
        if ((onResult.statusCode ?? 300) > HTTP_CODE) {
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
