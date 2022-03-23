import 'package:hyppe/core/constants/enum.dart';

import 'package:flutter/material.dart' show BuildContext;

import 'package:hyppe/core/extension/log_extension.dart';

import 'package:hyppe/core/bloc/notifications_v2/bloc.dart';

import 'package:hyppe/core/interface/pagination_query_interface.dart';
import 'package:hyppe/core/models/collection/notification_v2/notification.dart';

import 'package:hyppe/core/arguments/get_user_notifications.dart';

class NotificationsDataQuery extends PaginationQueryInterface {
  String senderOrReceiver = '';

  String postID = '';

  NotificationCategory? eventType;

  NotificationsDataQuery();

  @override
  Future<List<NotificationModel>> loadNext(BuildContext context) async {
    if (loading) throw Exception('Query operation is in progress');
    if (!hasNext) return [];

    loading = true;

    List<NotificationModel>? res;

    try {
      final notifier = NotificationBloc();
      await notifier.getUserNotification(
        context,
        argument: GetUserNotificationArgument(
          pageRow: limit,
          pageNumber: page,
        )
          ..postID = postID
          ..eventType = eventType
          ..senderOrReceiver = senderOrReceiver,
      );

      final fetch = notifier.notificationFetch;

      res = (fetch.data as List<dynamic>?)?.map((e) => NotificationModel.fromJson(e as Map<String, dynamic>)).toList();

      hasNext = res?.length == limit;
      if (res?.length != null) page++;
    } catch (e) {
      '$e'.logger();
      rethrow;
    } finally {
      loading = false;
    }

    return res ?? [];
  }

  @override
  Future<List<NotificationModel>> reload(BuildContext context) async {
    if (loading) throw Exception('Query operation is in progress');

    hasNext = true;

    loading = true;

    page = 0;

    List<NotificationModel>? res;

    try {
      final notifier = NotificationBloc();
      await notifier.getUserNotification(
        context,
        argument: GetUserNotificationArgument(
          pageRow: limit,
          pageNumber: page,
        )
          ..postID = postID
          ..eventType = eventType
          ..senderOrReceiver = senderOrReceiver,
      );

      final fetch = notifier.notificationFetch;

      res = (fetch.data as List<dynamic>?)?.map((e) => NotificationModel.fromJson(e as Map<String, dynamic>)).toList();

      hasNext = res?.length == limit;
      if (res != null) page++;
    } catch (e) {
      '$e'.logger();
      rethrow;
    } finally {
      loading = false;
    }

    return res ?? [];
  }
}
