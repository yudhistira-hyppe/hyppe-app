import 'package:hyppe/core/constants/enum.dart';

import 'package:hyppe/core/bloc/posts_v2/bloc.dart';

import 'package:flutter/material.dart' show BuildContext;

import 'package:hyppe/core/extension/log_extension.dart';

import 'package:hyppe/core/interface/pagination_query_interface.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/services/check_version.dart';

class ContentsDataQuery extends PaginationQueryInterface {
  FeatureType? featureType;

  String searchText = "";

  bool onlyMyData = false;

  String? postID;

  ContentsDataQuery();

  @override
  Future<List<ContentData>> loadNext(BuildContext context) async {
    if (featureType == null) throw Exception('Feature Type must be provided');
    if (loading) throw Exception('Query operation is in progress');
    if (!hasNext) return [];

    loading = true;

    List<ContentData>? res;

    try {
      final notifier = PostsBloc();
      await notifier.getContentsBlocV2(
        context,
        pageRows: limit,
        pageNumber: page,
        type: featureType!,
        searchText: searchText,
        onlyMyData: onlyMyData,
      );
      final fetch = notifier.postsFetch;

      res = (fetch.data as List<dynamic>?)?.map((e) => ContentData.fromJson(e as Map<String, dynamic>)).toList();

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
  Future<List<ContentData>> reload(BuildContext context) async {
    if (featureType == null) throw Exception('Feature Type must be provided');
    if (loading) throw Exception('Query operation is in progress');

    hasNext = true;

    loading = true;

    page = 0;

    List<ContentData>? res;

    try {
      final notifier = PostsBloc();
      await notifier.getContentsBlocV2(
        context,
        postID: postID,
        pageRows: limit,
        pageNumber: page,
        type: featureType!,
        searchText: searchText,
        onlyMyData: onlyMyData,
      );
      final fetch = notifier.postsFetch;

      res = (fetch.data as List<dynamic>?)?.map((e) => ContentData.fromJson(e as Map<String, dynamic>)).toList();

      if (featureType == FeatureType.vid) {
        CheckVersion().check(context, fetch.version);
      }
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
