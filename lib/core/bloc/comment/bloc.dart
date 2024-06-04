import 'package:dio/dio.dart';
import 'package:hyppe/core/arguments/comment_argument.dart';
import 'package:hyppe/core/bloc/comment/state.dart';
import 'package:hyppe/core/bloc/repos/repos.dart';
import 'package:hyppe/core/config/url_constants.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/status_code.dart';
import 'package:hyppe/core/response/generic_response.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:flutter/material.dart';

class CommentBloc {
  final _system = System();

  CommentFetch _commentFetch = CommentFetch(CommentState.init);
  CommentFetch get commentFetch => _commentFetch;
  setCommentFetch(CommentFetch val) => _commentFetch = val;

  Future commentsBlocV2(
    BuildContext context, {
    required CommentArgument argument,
  }) async {
    setCommentFetch(CommentFetch(CommentState.loading));
    final formData = FormData();
    final email = SharedPreference().readStorage(SpKeys.email);

    if (argument.isQuery) {
      // formData.fields.add(MapEntry('email', argument.email));
      formData.fields.add(MapEntry('postID', argument.postID));
      // formData.fields.add(MapEntry('parentID', argument.parentID));
      formData.fields.add(MapEntry('isQuery', argument.isQuery.toString()));
      formData.fields.add(MapEntry('pageRow', argument.pageRow.toString()));
      formData.fields.add(MapEntry('pageNumber', argument.pageNumber.toString()));
      formData.fields.add(MapEntry('postType', _system.validatePostTypeV2(argument.postType)));
      formData.fields.add(MapEntry('eventType', _system.convertMessageEventTypeToString(argument.discussEventType)));
    } else {
      formData.fields.add(MapEntry('postID', argument.postID));
      formData.fields.add(MapEntry('parentID', argument.parentID));
      formData.fields.add(MapEntry('txtMessages', argument.txtMessages));

      if (argument.giftID != '') formData.fields.add(MapEntry('giftID', argument.giftID));
      
      formData.fields.add(MapEntry('isQuery', argument.isQuery.toString()));
      formData.fields.add(MapEntry('postType', _system.validatePostTypeV2(argument.postType)));
      formData.fields.add(MapEntry('eventType', _system.convertMessageEventTypeToString(argument.discussEventType)));
      formData.fields.add(MapEntry('tagComment', argument.tagComment.join(',')));
    }
    print('hasil form');
    formData.fields.map((e) {
      print(e);
    }).toList();

    await Repos().reposPost(
      context,
      (onResult) {
        if ((onResult.statusCode ?? 300) > HTTP_CODE) {
          setCommentFetch(CommentFetch(CommentState.commentsBlocError));
        } else {
          final _response = GenericResponse.fromJson(onResult.data).responseData;
          setCommentFetch(CommentFetch(CommentState.commentsBlocSuccess, data: _response));
        }
      },
      (errorData) {
        ShowBottomSheet.onInternalServerError(context, statusCode: errorData.response?.statusCode);
        setCommentFetch(CommentFetch(CommentState.commentsBlocError));
      },
      data: formData,
      host: UrlConstants.discuss,
      withAlertMessage: false,
      withCheckConnection: false,
      methodType: MethodType.post,
      headers: {'x-auth-user': email},
    );
  }
}
