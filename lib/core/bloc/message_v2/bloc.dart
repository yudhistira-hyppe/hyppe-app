import 'package:dio/dio.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';

import 'package:hyppe/core/bloc/repos/repos.dart';

import 'package:hyppe/core/bloc/message_v2/state.dart';

import 'package:hyppe/core/config/url_constants.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/status_code.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';

import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/core/services/shared_preference.dart';

import 'package:hyppe/core/response/generic_response.dart';

import 'package:hyppe/core/arguments/discuss_argument.dart';

class MessageBlocV2 {
  final _system = System();
  MessageFetch _messageFetch = MessageFetch(MessageState.init);
  MessageFetch get messageFetch => _messageFetch;
  setMessageFetch(MessageFetch val) => _messageFetch = val;

  Future getDiscussionBloc(
    BuildContext context, {
    required DiscussArgument disqusArgument, String? disqusID
  }) async {
    setMessageFetch(MessageFetch(MessageState.loading));
    final formData = FormData();
    final email = SharedPreference().readStorage(SpKeys.email);

    formData.fields.add(MapEntry('email', disqusArgument.email));
    formData.fields.add(MapEntry('postId', disqusArgument.postID));
    formData.fields.add(MapEntry('txtMessages', disqusArgument.txtMessages));
    formData.fields.add(MapEntry('reactionUri', disqusArgument.reactionUri));
    formData.fields.add(MapEntry('isQuery', disqusArgument.isQuery.toString()));
    formData.fields.add(MapEntry('pageRow', disqusArgument.pageRow.toString()));
    formData.fields.add(MapEntry('receiverParty', disqusArgument.receiverParty));
    formData.fields.add(MapEntry('withDetail', disqusArgument.withDetail.toString()));
    formData.fields.add(MapEntry('detailOnly', disqusArgument.detailOnly.toString()));
    formData.fields.add(MapEntry('pageNumber', disqusArgument.pageNumber.toString()));
    formData.fields.add(MapEntry('postType', _system.validatePostTypeV2(disqusArgument.postType)));
    formData.fields.add(MapEntry('eventType', _system.convertMessageEventTypeToString(disqusArgument.discussEventType)));

    if(disqusID != null){
      formData.fields.add(MapEntry('disqusID', disqusID));
    }

    print('formData.fields');
    print(formData.fields);

    await Repos().reposPost(
      context,
      (onResult) {
        if ((onResult.statusCode ?? 300) > HTTP_CODE) {
          setMessageFetch(MessageFetch(MessageState.getDiscussionBlocError));
        } else {
          final _response = GenericResponse.fromJson(onResult.data).responseData;
          setMessageFetch(MessageFetch(MessageState.getDiscussionBlocSuccess, data: _response));
        }
      },
      (errorData) {
        setMessageFetch(MessageFetch(MessageState.getDiscussionBlocError));
      },
      headers: {
        'x-auth-user': email,
      },
      data: formData,
      host: UrlConstants.discuss,
      withAlertMessage: false,
      withCheckConnection: true,
      methodType: MethodType.post,
      errorServiceType: ErrorType.message,
      onNoInternet: () => Routing().moveBack(),
    );
  }

  Future createDiscussionBloc(
    BuildContext context, {
    required DiscussArgument disqusArgument,
  }) async {
    setMessageFetch(MessageFetch(MessageState.loading));
    final _system = System();
    final formData = FormData();
    final email = SharedPreference().readStorage(SpKeys.email);

    if (disqusArgument.postID.isNotEmpty) {
      formData.fields.add(MapEntry('postId', disqusArgument.postID));
    }
    if (disqusArgument.txtMessages.isNotEmpty) {
      formData.fields.add(MapEntry('txtMessages', disqusArgument.txtMessages));
    }
    if (disqusArgument.reactionUri.isNotEmpty) {
      formData.fields.add(MapEntry('reactionUri', disqusArgument.reactionUri));
    }

    formData.fields.add(MapEntry('email', disqusArgument.email));
    formData.fields.add(MapEntry('isQuery', disqusArgument.isQuery.toString()));
    formData.fields.add(MapEntry('receiverParty', disqusArgument.receiverParty));
    formData.fields.add(MapEntry('postType', _system.validatePostTypeV2(disqusArgument.postType)));
    formData.fields.add(MapEntry('eventType', _system.convertMessageEventTypeToString(disqusArgument.discussEventType)));
    print('create dm');
    print(formData.fields);

    await Repos().reposPost(
      context,
      (onResult) {
        if ((onResult.statusCode ?? 300) > HTTP_CODE) {
          setMessageFetch(MessageFetch(MessageState.createDiscussionBlocError));
        } else {
          final _response = GenericResponse.fromJson(onResult.data).responseData;
          setMessageFetch(MessageFetch(MessageState.createDiscussionBlocSuccess, data: _response));
        }
      },
      (errorData) {
        setMessageFetch(MessageFetch(MessageState.createDiscussionBlocError));
      },
      headers: {
        'x-auth-user': email,
      },
      data: formData,
      host: UrlConstants.discuss,
      withAlertMessage: true,
      withCheckConnection: true,
      methodType: MethodType.post,
      onNoInternet: () => Routing().moveBack(),
      errorServiceType: ErrorType.createMessage,
    );
  }

  Future deleteDiscussionBloc(
    BuildContext context, {
    required String postEmail,
    required String postId,
  }) async {
    setMessageFetch(MessageFetch(MessageState.loading));
    String? token = SharedPreference().readStorage(SpKeys.userToken);
    String? email = SharedPreference().readStorage(SpKeys.email);
    Map data = {};

    postEmail != '' ? data = {"_id": postId, "email": postEmail} : data = {"_id": postId};
    await Repos().reposPost(
      context,
      (onResult) {
        if ((onResult.statusCode ?? 300) > HTTP_CODE) {
          setMessageFetch(MessageFetch(MessageState.deleteDiscussionBlocError));
        } else {
          final _response = GenericResponse.fromJson(onResult.data).responseData;
          setMessageFetch(MessageFetch(MessageState.deleteDiscussionBlocSuccess, data: _response));
        }
      },
      (errorData) {
        setMessageFetch(MessageFetch(MessageState.deleteDiscussionBlocError));
      },
      headers: {
        'x-auth-user': email,
        'x-auth-token': token,
      },
      data: data,
      host: postEmail != '' ? UrlConstants.deleteDiscuss : UrlConstants.deleteChat,
      withAlertMessage: false,
      withCheckConnection: true,
      methodType: MethodType.post,
      errorServiceType: ErrorType.message,
      onNoInternet: () => Routing().moveBack(),
    );
  }
}
