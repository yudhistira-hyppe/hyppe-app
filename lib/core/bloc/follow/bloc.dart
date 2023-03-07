import 'package:dio/dio.dart';
import 'package:hyppe/core/arguments/follow_user_argument.dart';
import 'package:hyppe/core/arguments/get_follower_users_argument.dart';
import 'package:hyppe/core/bloc/follow/state.dart';
import 'package:hyppe/core/bloc/repos/repos.dart';
import 'package:hyppe/core/config/url_constants.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/status_code.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/models/collection/follow/follow.dart';
import 'package:hyppe/core/models/collection/follow/is_following.dart';
import 'package:hyppe/core/response/generic_response.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';

class FollowBloc {
  FollowFetch _followFetch = FollowFetch(FollowState.init);
  FollowFetch get followFetch => _followFetch;
  setFollowFetch(FollowFetch val) => _followFetch = val;

  Future checkFollowingToUserBloc(BuildContext context, {required String? userID}) async {
    setFollowFetch(FollowFetch(FollowState.loading));
    await Repos().reposPost(
      context,
      (onResult) {
        if ((onResult.statusCode ?? 300) != HTTP_OK) {
          setFollowFetch(FollowFetch(FollowState.checkFollowingToUserError));
        } else {
          IsFollowing _result = IsFollowing.fromJson(onResult.data);
          setFollowFetch(FollowFetch(FollowState.checkFollowingToUserSuccess, data: _result));
        }
      },
      (errorData) {
        setFollowFetch(FollowFetch(FollowState.checkFollowingToUserError));
      },
      errorServiceType: ErrorType.checkFollow,
      host: UrlConstants.isFollowing + "?userID=$userID",
      withAlertMessage: false,
      methodType: MethodType.get,
      withCheckConnection: false,
    );
  }

  Future followUserBloc(BuildContext context, {required FollowUser data}) async {
    setFollowFetch(FollowFetch(FollowState.loading));
    await Repos().reposPost(
      context,
      (onResult) {
        if ((onResult.statusCode ?? 300) != HTTP_OK) {
          setFollowFetch(FollowFetch(FollowState.followUserError));
        } else {
          setFollowFetch(FollowFetch(FollowState.followUserSuccess, data: onResult.data));
        }
      },
      (errorData) {
        ShowBottomSheet.onInternalServerError(context);
        setFollowFetch(FollowFetch(FollowState.followUserError));
      },
      data: data.toMap(),
      host: UrlConstants.followUser,
      withAlertMessage: false,
      methodType: MethodType.post,
      withCheckConnection: false,
    );
  }

  Future followUserBlocV2(
    BuildContext context, {
    bool withAlertConnection = true,
    required FollowUserArgument data,
  }) async {
    setFollowFetch(FollowFetch(FollowState.loading));
    await Repos().reposPost(
      context,
      (onResult) {
        if ((onResult.statusCode ?? 300) > HTTP_CODE) {
          setFollowFetch(FollowFetch(FollowState.followUserError));
        } else {
          setFollowFetch(FollowFetch(FollowState.followUserSuccess, data: GenericResponse.fromJson(onResult.data).responseData));
        }
      },
      (errorData) {
        ShowBottomSheet.onInternalServerError(context);
        setFollowFetch(FollowFetch(FollowState.followUserError));
      },
      headers: {
        "x-auth-user": SharedPreference().readStorage(SpKeys.email),
      },
      data: data.toJson(),
      host: UrlConstants.interactive,
      withCheckConnection: true,
      methodType: MethodType.post,
      withAlertMessage: withAlertConnection,
    );
  }

  Future getFollowersUsersBloc(
    BuildContext context, {
    required GetFollowerUsersArgument data,
  }) async {
    setFollowFetch(FollowFetch(FollowState.loading));

    data.withEvents?.map((e) => System().convertEventToString(e)).join(",").logger();

    final formData = FormData();
    formData.fields.add(MapEntry('eventType', System().convertEventTypeToString(data.eventType)));
    formData.fields.add(MapEntry('withDetail', '${data.withDetail}'));
    formData.fields.add(MapEntry('withEvents', '${data.withEvents?.map((e) => System().convertEventToString(e)).join(",")}'));
    formData.fields.add(MapEntry('postID', data.postID));
    formData.fields.add(MapEntry('pageRow', '${data.pageRow}'));
    formData.fields.add(MapEntry('pageNumber', '${data.pageNumber}'));
    formData.fields.add(MapEntry('senderOrReceiver', data.senderOrReceiver));
    formData.fields.add(MapEntry('search', data.searchText));
    print('ini getinteractive');
    print(formData.fields);
    await Repos().reposPost(
      context,
      (onResult) {
        if ((onResult.statusCode ?? 300) > HTTP_CODE) {
          setFollowFetch(FollowFetch(FollowState.getFollowersUsersError));
        } else {
          setFollowFetch(FollowFetch(FollowState.getFollowersUsersSuccess, data: GenericResponse.fromJson(onResult.data).responseData));
        }
      },
      (errorData) {
        setFollowFetch(FollowFetch(FollowState.getFollowersUsersError));
      },
      data: formData,
      headers: {
        'x-auth-user': SharedPreference().readStorage(SpKeys.email),
        'x-auth-token': SharedPreference().readStorage(SpKeys.userToken),
      },
      withAlertMessage: false,
      withCheckConnection: false,
      host: UrlConstants.getInnteractives,
      methodType: MethodType.post,
    );
  }

  Future deleteTagUsersBloc(BuildContext context, {String? postId}) async {
    print('asdasd');
    final _repos = Repos();

    print(postId);
    final email = SharedPreference().readStorage(SpKeys.email);
    print(email);

    await _repos.reposPost(
      context,
      (onResult) {
        if ((onResult.statusCode ?? 300) > HTTP_CODE) {
          setFollowFetch(FollowFetch(FollowState.deleteUserTagError));
        } else {
          setFollowFetch(FollowFetch(FollowState.deleteUserTagSuccess));
        }
      },
      (errorData) {
        setFollowFetch(FollowFetch(FollowState.deleteUserTagError));
      },
      data: {'postID': postId, 'email': email},
      headers: {
        'x-auth-token': SharedPreference().readStorage(SpKeys.userToken),
      },
      withAlertMessage: true,
      withCheckConnection: false,
      host: UrlConstants.deletTagUser,
      methodType: MethodType.post,
    );
  }
}
