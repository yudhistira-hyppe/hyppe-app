import 'package:hyppe/core/constants/enum.dart';

import 'package:hyppe/core/bloc/follow/bloc.dart';

import 'package:flutter/material.dart' show BuildContext;

import 'package:hyppe/core/extension/log_extension.dart';

import 'package:hyppe/core/arguments/get_follower_users_argument.dart';

import 'package:hyppe/core/interface/pagination_query_interface.dart';
import 'package:hyppe/core/models/collection/follow/interactive_follow.dart';

class UsersDataQuery extends PaginationQueryInterface {
  String searchText = "";

  InteractiveEventType? eventType;

  String senderOrReceiver = '';

  List<InteractiveEvent>? withEvents;

  UsersDataQuery();

  @override
  Future<List<InteractiveFollow>> loadNext(BuildContext context) async {
    if (eventType == null) throw Exception('Event Type must be provided');
    if (loading) throw Exception('Query operation is in progress');
    if (!hasNext) return [];

    loading = true;

    List<InteractiveFollow>? res;

    try {
      final notifier = FollowBloc();
      final param = GetFollowerUsersArgument(
        pageRow: limit,
        pageNumber: page,
        eventType: eventType ?? InteractiveEventType.none,
      )
        ..withEvents = withEvents
        ..searchText = searchText
        ..senderOrReceiver = senderOrReceiver;

      await notifier.getFollowersUsersBloc(context, data: param);

      final fetch = notifier.followFetch;

      res = (fetch.data as List<dynamic>?)?.map((e) => InteractiveFollow.fromJson(e as Map<String, dynamic>)).toList();

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
  Future<List<InteractiveFollow>> reload(BuildContext context) async {
    if (eventType == null) throw Exception('Event Type must be provided');
    if (loading) throw Exception('Query operation is in progress');

    hasNext = true;

    loading = true;

    page = 0;

    List<InteractiveFollow>? res;

    try {
      final notifier = FollowBloc();
      final param = GetFollowerUsersArgument(
        pageRow: 200,
        pageNumber: page,
        eventType: eventType ?? InteractiveEventType.none,
      )
        ..withEvents = withEvents
        ..searchText = searchText
        ..senderOrReceiver = senderOrReceiver;

      await notifier.getFollowersUsersBloc(context, data: param);

      final fetch = notifier.followFetch;

      res = (fetch.data as List<dynamic>?)?.map((e) => InteractiveFollow.fromJson(e as Map<String, dynamic>)).toList();

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
