import 'package:flutter/material.dart' show BuildContext;

import 'package:hyppe/core/bloc/message_v2/bloc.dart';

import 'package:hyppe/core/constants/shared_preference_keys.dart';

import 'package:hyppe/core/extension/log_extension.dart';

import 'package:hyppe/core/models/collection/message_v2/message_data_v2.dart';

import 'package:hyppe/core/services/shared_preference.dart';

import 'package:hyppe/core/arguments/discuss_argument.dart';

import 'package:hyppe/core/interface/pagination_query_interface.dart';

class DiscussDataQuery extends PaginationQueryInterface {
  static final _sharedPrefs = SharedPreference();

  String receiverParty = '';

  bool withDetail = true;

  DiscussDataQuery();

  @override
  Future<List<MessageDataV2>> loadNext(BuildContext context) async {
    if (loading) throw Exception('Query operation is in progress');
    if (!hasNext) return [];

    loading = true;

    List<MessageDataV2>? res;

    try {
      final param = DiscussArgument(
        receiverParty: receiverParty,
        email: _sharedPrefs.readStorage(SpKeys.email),
      )
        ..isQuery = true
        ..pageRow = limit
        ..pageNumber = page
        ..withDetail = withDetail;

      final notifier = MessageBlocV2();
      await notifier.getDiscussionBloc(context, disqusArgument: param);

      final fetch = notifier.messageFetch;

      res = (fetch.data as List<dynamic>?)?.map((e) => MessageDataV2.fromJson(e as Map<String, dynamic>)).toList();

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
  Future<List<MessageDataV2>> reload(BuildContext context) async {
    if (loading) throw Exception('Query operation is in progress');

    hasNext = true;

    loading = true;

    page = 0;

    List<MessageDataV2>? res;

    try {
      final param = DiscussArgument(
        receiverParty: receiverParty,
        email: _sharedPrefs.readStorage(SpKeys.email),
      )
        ..isQuery = true
        ..pageRow = limit
        ..pageNumber = page
        ..withDetail = withDetail;

      final notifier = MessageBlocV2();
      await notifier.getDiscussionBloc(context, disqusArgument: param);

      final fetch = notifier.messageFetch;

      res = (fetch.data as List<dynamic>?)?.map((e) => MessageDataV2.fromJson(e as Map<String, dynamic>)).toList();

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
