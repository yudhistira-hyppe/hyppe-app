import 'package:hyppe/core/constants/enum.dart';

import 'package:hyppe/core/bloc/posts_v2/bloc.dart';

import 'package:flutter/material.dart' show BuildContext;

import 'package:hyppe/core/extension/log_extension.dart';

import 'package:hyppe/core/interface/pagination_query_interface.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/inner/home/notifier_v2.dart';
import 'package:provider/provider.dart';

class ContentsDataQuery extends PaginationQueryInterface {
  FeatureType? featureType;

  String searchText = "";

  bool onlyMyData = false;

  String? postID;

  ContentsDataQuery();

  @override
  Future<List<ContentData>> loadNext(BuildContext context, {bool myContent = false, bool otherContent = false, bool isLandingPage = false}) async {
    print('loadnext : $page');
    print('loadnext : $limit');
    print('loadnext : $hasNext');
    print('skip limit : $hasNext');
    if (featureType == null) throw Exception('Feature Type must be provided');
    if (loading) throw Exception('Query operation is in progress');
    // if (!hasNext) return [];

    final notifierMain = Provider.of<HomeNotifier>(context, listen: false);

    loading = true;

    List<ContentData>? res;

    if (!isLandingPage) {
      try {
        final notifier = PostsBloc();
        await notifier.getContentsBlocV2(
          context,
          pageRows: limit,
          pageNumber: page,
          type: featureType ?? FeatureType.other,
          searchText: searchText,
          onlyMyData: onlyMyData,
          visibility: notifierMain.visibilty,
          myContent: myContent,
          otherContent: otherContent,
        );
        final fetch = notifier.postsFetch;

        res = (fetch.data as List<dynamic>?)?.map((e) => ContentData.fromJson(e as Map<String, dynamic>)).toList();

        hasNext = res?.length == limit;
        if (res?.length != null) page++;
      } catch (e) {
        'error loadNext : $e'.logger();
        rethrow;
      } finally {
        loading = false;
      }
    } else {
      try {
        final notifier = PostsBloc();
        await notifier.getAllContentsBlocV2(
          context,
          pageRows: limit,
          pageNumber: page,
          visibility: notifierMain.visibilty,
          myContent: myContent,
          otherContent: otherContent,
          postType: System().validatePostTypeV2(featureType),
        );
        final fetch = notifier.postsFetch;
        final resAll = AllContents.fromJson(fetch.data);
        if (featureType == FeatureType.story) {
          res = resAll.story;
        } else if (featureType == FeatureType.vid) {
          res = resAll.video;
        } else if (featureType == FeatureType.diary) {
          res = resAll.diary;
        } else if (featureType == FeatureType.pic) {
          res = resAll.pict;
        }

        hasNext = res?.length == limit;
        if (res?.length != null) page++;
        print('pageNumber check 1 : $page');
      } catch (e) {
        'error loadNext : $e'.logger();
        rethrow;
      } finally {
        loading = false;
      }
    }

    return res ?? [];
  }

  @override
  Future<List<ContentData>> reload(BuildContext context, {bool myContent = false, bool otherContent = false, String? visibility, int? indexContent}) async {
    print('reload');

    List<ContentData>? res;
    try {
      if (featureType == null) throw Exception('Feature Type must be provided');
      if (loading) throw Exception('Query operation is in progress');
      // pending error 1

      hasNext = true;

      loading = true;

      page = 1;

      // final box = Boxes.boxDataContents;

      // page = 0;

      print("post id contedata -- $postID");
      final notifierMain = Provider.of<HomeNotifier>(context, listen: false);
      final notifier = PostsBloc();
      await notifier.getContentsBlocV2(context,
          postID: postID,
          pageRows: limit,
          pageNumber: page,
          type: featureType ?? FeatureType.other,
          searchText: searchText,
          onlyMyData: onlyMyData,
          visibility: visibility ?? notifierMain.visibilty,
          myContent: myContent,
          otherContent: otherContent,
          indexContent: indexContent);
      final fetch = notifier.postsFetch;

      res = (fetch.data as List<dynamic>?)?.map((e) => ContentData.fromJson(e as Map<String, dynamic>)).toList();

      if (featureType == FeatureType.vid) {
        // CheckVersion().check(context, fetch.version);
      }
      hasNext = res?.length == limit;
      if (res != null) page++;
    } catch (e) {
      '$e'.logger();
      // rethrow;
    } finally {
      loading = false;
    }
    return res ?? [];
  }
}
