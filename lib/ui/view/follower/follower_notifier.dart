import 'package:flutter/material.dart';

import 'package:hyppe/core/bloc/follow/bloc.dart';
import 'package:hyppe/core/bloc/follow/state.dart';

import 'package:hyppe/core/constants/enum.dart';

import 'package:hyppe/core/extension/log_extension.dart';

import 'package:hyppe/core/arguments/follow_user_argument.dart';

import 'package:hyppe/core/query_request/users_data_query.dart';

import 'package:hyppe/core/models/collection/follow/interactive_follow.dart';
import 'package:hyppe/core/services/system.dart';

class FollowerNotifier extends ChangeNotifier {
  final UsersDataQuery _usersFollowersQuery = UsersDataQuery()
    ..limit = 25
    ..withEvents = [InteractiveEvent.initial, InteractiveEvent.accept, InteractiveEvent.request]
    ..eventType = InteractiveEventType.follower;

  final UsersDataQuery _usersFollowingQuery = UsersDataQuery()
    ..limit = 25
    ..withEvents = [InteractiveEvent.initial, InteractiveEvent.accept, InteractiveEvent.request]
    ..eventType = InteractiveEventType.following;

  final ScrollController listFollowersController = ScrollController();
  final ScrollController listFollowingController = ScrollController();
  final TextEditingController textEditingController = TextEditingController();

  List<InteractiveFollow>? _followersData;

  List<InteractiveFollow>? _followingData;

  List<InteractiveFollow>? get followersData => _followersData;

  List<InteractiveFollow>? get followingData => _followingData;

  set followersData(List<InteractiveFollow>? value) {
    _followersData = value;
    notifyListeners();
  }

  set followingData(List<InteractiveFollow>? value) {
    _followingData = value;
    notifyListeners();
  }

  int get followersItemCount => _followersData == null
      ? 10
      : _usersFollowersQuery.hasNext
          ? (_followersData?.length ?? 0) + 1
          : (_followersData?.length ?? 0);

  int get followingItemCount => _followingData == null
      ? 10
      : _usersFollowingQuery.hasNext
          ? (_followingData?.length ?? 0) + 1
          : (_followingData?.length ?? 0);

  bool get followersHasNext => _usersFollowersQuery.hasNext;

  bool get followingHasNext => _usersFollowingQuery.hasNext;

  void initState(BuildContext context) {
    listFollowersController.addListener(() => _followersScrollListener);
    listFollowingController.addListener(() => _followingScrollListener);
    requestFollowers(context, reload: true);
    requestFollowing(context, reload: true);
  }

  Future followUser(
    BuildContext context, {
    required InteractiveFollow? data,
    required FollowUserArgument argument,
  }) async {
    try {
      // System().actionReqiredIdCard(
      //   context,
      //   action: () async {
          final notifier = FollowBloc();
          await notifier.followUserBlocV2(context, data: argument);
          final fetch = notifier.followFetch;
          if (fetch.followState == FollowState.followUserSuccess) {
            if (data?.eventType == InteractiveEventType.follower) {
              final _followersDataIndex = _followersData?.indexOf(data!);

              _followersData?[_followersDataIndex!] = _followersData![_followersDataIndex].copyWith(
                event: data?.event == InteractiveEvent.request ? InteractiveEvent.accept : InteractiveEvent.none,
              );
            } else if (data?.eventType == InteractiveEventType.following) {
              final _followingDataIndex = _followingData?.indexOf(data!);

              _followingData?[_followingDataIndex!] = _followingData![_followingDataIndex].copyWith(
                event: InteractiveEvent.none,
              );
            }

            notifyListeners();
          }
      //   },
      //   uploadContentAction: false,
      // );
    } catch (e) {
      print(e);
    }
  }

  Future<void> requestFollowers(
    BuildContext context, {
    bool reload = false,
  }) async {
    Future<List<InteractiveFollow>> _resFuture;

    _usersFollowersQuery.searchText = textEditingController.value.text;

    try {
      if (reload) {
        _resFuture = _usersFollowersQuery.reload(context);
      } else {
        _resFuture = _usersFollowersQuery.loadNext(context);
      }

      final res = await _resFuture;
      if (reload) {
        followersData = res;
      } else {
        followersData = [...(followersData ?? [] as List<InteractiveFollow>)] + res;
      }
    } catch (e) {
      'load followers list: ERROR: $e'.logger();
    }
  }

  _followersScrollListener(BuildContext context) {
    if (listFollowersController.offset >= listFollowersController.position.maxScrollExtent &&
        !listFollowersController.position.outOfRange &&
        !_usersFollowersQuery.loading &&
        followersHasNext) {
      requestFollowing(context);
    }
  }

  Future<void> requestFollowing(
    BuildContext context, {
    bool reload = false,
  }) async {
    Future<List<InteractiveFollow>> _resFuture;

    _usersFollowingQuery.searchText = textEditingController.value.text;

    try {
      if (reload) {
        _resFuture = _usersFollowingQuery.reload(context);
      } else {
        _resFuture = _usersFollowingQuery.loadNext(context);
      }

      final res = await _resFuture;
      if (reload) {
        followingData = res;
      } else {
        followingData = [...(followingData ?? [] as List<InteractiveFollow>)] + res;
      }
    } catch (e) {
      'load following list: ERROR: $e'.logger();
    }
  }

  _followingScrollListener(BuildContext context) {
    if (listFollowingController.offset >= listFollowingController.position.maxScrollExtent &&
        !listFollowingController.position.outOfRange &&
        !_usersFollowingQuery.loading &&
        followingHasNext) {
      requestFollowing(context);
    }
  }
}
