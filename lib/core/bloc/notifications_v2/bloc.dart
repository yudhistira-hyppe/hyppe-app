import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:hyppe/core/bloc/repos/repos.dart';
import 'package:hyppe/core/bloc/notifications_v2/state.dart';

import 'package:hyppe/core/config/url_constants.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/status_code.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';

import 'package:hyppe/core/arguments/get_user_notifications.dart';

import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/core/services/shared_preference.dart';

import 'package:hyppe/core/response/generic_response.dart';

class NotificationBloc {
  NotificationFetch _notificationFetch = NotificationFetch(NotificationState.init);
  NotificationFetch get notificationFetch => _notificationFetch;
  setNotificationsFetch(NotificationFetch val) => _notificationFetch = val;

  Future getUserNotification(
    BuildContext context, {
    required GetUserNotificationArgument argument,
  }) async {
    String email = SharedPreference().readStorage(SpKeys.email);
    String eventType = System().postNotificationCategory(argument.eventType ?? NotificationCategory.all);

    final FormData formData = FormData();

    formData.fields.add(MapEntry("senderOrReceiver", argument.senderOrReceiver));
    formData.fields.add(MapEntry("postID", argument.postID));
    formData.fields.add(MapEntry("eventType", eventType));
    formData.fields.add(MapEntry("pageRow", argument.pageRow.toString()));
    formData.fields.add(MapEntry("pageNumber", argument.pageNumber.toString()));

    print('asdasd');
    print(formData.fields);
    print(eventType);
    formData.fields.map(
      (e) => print(e),
    );

    await Repos().reposPost(
      context,
      (onResult) {
        if ((onResult.statusCode ?? 0) > HTTP_CODE) {
          setNotificationsFetch(NotificationFetch(NotificationState.getUsersNotificationBlocError));
        } else {
          setNotificationsFetch(NotificationFetch(
            NotificationState.getUsersNotificationBlocSuccess,
            data: GenericResponse.fromJson(onResult.data).responseData,
          ));
        }
      },
      (errorData) {
        setNotificationsFetch(NotificationFetch(NotificationState.getUsersNotificationBlocError));
      },
      data: formData,
      headers: {
        "x-auth-user": email,
      },
      withAlertMessage: true,
      withCheckConnection: true,
      host: UrlConstants.getNotification,
      methodType: MethodType.post,
    );
  }
}
