import 'package:collection/collection.dart';

import 'package:flutter/material.dart' show BuildContext;

import 'package:hyppe/core/bloc/comment/bloc.dart';

import 'package:hyppe/core/extension/log_extension.dart';

import 'package:hyppe/core/models/collection/comment_v2/comment_data_v2.dart';

import 'package:hyppe/core/arguments/comment_argument.dart';

import 'package:hyppe/core/interface/pagination_query_interface.dart';

class CommentDataQuery extends PaginationQueryInterface {
  String postID = '';

  String parentID = '';

  String txtMessages = '';

  CommentDataQuery();

  @override
  Future<List<CommentDataV2>> loadNext(BuildContext context) async {
    if (loading) throw Exception('Query operation is in progress');
    if (postID.isEmpty) throw Exception('Post ID is not set');
    if (!hasNext) return [];

    loading = true;

    List<CommentDataV2>? res;

    try {
      final param = CommentArgument()
        ..isQuery = true
        ..postID = postID
        ..pageRow = limit
        ..pageNumber = page;

      final notifier = CommentBloc();
      await notifier.commentsBlocV2(context, argument: param);

      final fetch = notifier.commentFetch;

      res = (fetch.data as List<dynamic>?)?.map((e) => CommentDataV2.fromJson(e as Map<String, dynamic>)).toList();

      hasNext = res?.firstOrNull?.disqusLogs?.length == limit;
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
  Future<List<CommentDataV2>> reload(BuildContext context) async {
    if (loading) throw Exception('Query operation is in progress');
    if (postID.isEmpty) throw Exception('Post ID is not set');

    hasNext = true;

    loading = true;

    page = 0;

    List<CommentDataV2>? res;

    try {
      final param = CommentArgument()
        ..isQuery = true
        ..postID = postID
        ..pageRow = limit
        ..pageNumber = page;

      final notifier = CommentBloc();
      await notifier.commentsBlocV2(context, argument: param);

      final fetch = notifier.commentFetch;

      res = (fetch.data as List<dynamic>?)?.map((e) => CommentDataV2.fromJson(e as Map<String, dynamic>)).toList();

      hasNext = res?.firstOrNull?.disqusLogs?.length == limit;
      if (res != null) page++;
    } catch (e) {
      '$e'.logger();
      rethrow;
    } finally {
      loading = false;
    }

    return res ?? [];
  }

  Future<CommentsLogs?> addComment(BuildContext context) async {
    if (postID.isEmpty) throw Exception('Post ID is not set');

    try {
      final param = CommentArgument()
        ..isQuery = false
        ..postID = postID
        ..parentID = parentID
        ..txtMessages = txtMessages;

      final notifier = CommentBloc();
      await notifier.commentsBlocV2(context, argument: param);

      final fetch = notifier.commentFetch;

      final res = (fetch.data as List<dynamic>?)?.map((e) => CommentDataV2.fromJsonResponse(e as Map<String, dynamic>)).toList();

      return res?.firstOrNull?.disqusLogs?.firstOrNull;
    } catch (e) {
      '$e'.logger();
      rethrow;
    }
  }
}
