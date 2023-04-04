

import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';

import 'package:hyppe/core/bloc/repos/repos.dart';
import 'package:hyppe/core/bloc/reaction/state.dart';

import 'package:hyppe/core/arguments/post_reaction_argument.dart';

import 'package:hyppe/core/config/url_constants.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/status_code.dart';

import 'package:hyppe/core/models/collection/utils/reaction/post_reaction.dart';
import 'package:hyppe/core/models/collection/comment/update_comment_reaction.dart';

import 'package:hyppe/core/response/generic_response.dart';

import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';

class ReactionBloc {
  ReactionFetch _reactionFetch = ReactionFetch(ReactionState.init);
  ReactionFetch get reactionFetch => _reactionFetch;
  setReactionFetch(ReactionFetch val) => _reactionFetch = val;

  Future addPostReactionBloc(BuildContext context, {required Future<dynamic> Function() function, required PostReaction data}) async {
    setReactionFetch(ReactionFetch(ReactionState.loading));
    await Repos().reposPost(
      context,
      (onResult) {
        if ((onResult.statusCode ?? 300) != HTTP_OK) {
          setReactionFetch(ReactionFetch(ReactionState.addPostReactionBlocError));
        } else {
          setReactionFetch(ReactionFetch(ReactionState.addPostReactionBlocSuccess, data: onResult.data));
        }
      },
      (errorData) {
        ShowBottomSheet.onInternalServerError(context);
        setReactionFetch(ReactionFetch(ReactionState.addPostReactionBlocError));
      },
      host: UrlConstants.addPostReaction,
      data: data.toMap(),
      withAlertMessage: false,
      methodType: MethodType.post,
      withCheckConnection: true,
      onNoInternet: () {
        Routing().moveBack();
        function();
      },
    );
  }

  addPostReactionBlocV2(
    BuildContext context, {
    required PostReactionArgument argument,
  }) {
    setReactionFetch(ReactionFetch(ReactionState.loading));
    final email = SharedPreference().readStorage(SpKeys.email);

    Repos().reposPost(
      context,
      (onResult) {
        if ((onResult.statusCode ?? 300) > HTTP_CODE) {
          setReactionFetch(ReactionFetch(ReactionState.addPostReactionBlocErrorV2));
        } else {
          final _response = GenericResponse.fromJson(onResult.data).responseData;
          setReactionFetch(ReactionFetch(ReactionState.addPostReactionBlocSuccessV2, data: _response));
        }
      },
      (errorData) {
        ShowBottomSheet.onInternalServerError(context);
        setReactionFetch(ReactionFetch(ReactionState.addPostReactionBlocErrorV2));
      },
      headers: {
        'x-auth-user': email,
      },
      host: UrlConstants.interactive,
      data: argument.toJson(),
      withAlertMessage: false,
      withCheckConnection: false,
      methodType: MethodType.post,
    );
  }

  Future addReactOnCommentBloc(BuildContext context, {required Future<dynamic> Function() function, required PostReaction data}) async {
    setReactionFetch(ReactionFetch(ReactionState.loading));
    await Repos().reposPost(
      context,
      (onResult) {
        if ((onResult.statusCode ?? 300) != HTTP_OK) {
          setReactionFetch(ReactionFetch(ReactionState.addReactOnCommentBlocError));
        } else {
          setReactionFetch(ReactionFetch(ReactionState.addReactOnCommentBlocSuccess));
        }
      },
      (errorData) {
        ShowBottomSheet.onInternalServerError(context);
        setReactionFetch(ReactionFetch(ReactionState.addReactOnCommentBlocError));
      },
      host: UrlConstants.addReactOnComment,
      data: data.toMapReactOnComment(),
      withAlertMessage: false,
      methodType: MethodType.post,
      withCheckConnection: true,
      onNoInternet: () {
        Routing().moveBack();
        function();
      },
    );
  }

  Future getCommentReactionsBloc(BuildContext context, {required String? postID, required String? commentID}) async {
    setReactionFetch(ReactionFetch(ReactionState.loading));
    await Repos().reposPost(
      context,
      (onResult) {
        if ((onResult.statusCode ?? 300) != HTTP_OK) {
          setReactionFetch(ReactionFetch(ReactionState.getCommentReactionsBlocError));
        } else {
          UpdateCommentReaction _result = UpdateCommentReaction.fromJson(onResult.data);
          setReactionFetch(ReactionFetch(ReactionState.getCommentReactionsBlocSuccess, data: _result));
        }
      },
      (errorData) {
        ShowBottomSheet.onInternalServerError(context);
        setReactionFetch(ReactionFetch(ReactionState.getCommentReactionsBlocSuccess));
      },
      host: UrlConstants.getCommentReactions + "?postID=$postID&commentID=$commentID",
      withAlertMessage: false,
      methodType: MethodType.get,
      withCheckConnection: false,
    );
  }
}
