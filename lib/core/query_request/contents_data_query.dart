import 'package:hyppe/core/constants/enum.dart';

import 'package:hyppe/core/bloc/posts_v2/bloc.dart';

import 'package:flutter/material.dart' show BuildContext;
import 'package:hyppe/core/constants/utils.dart';

import 'package:hyppe/core/extension/log_extension.dart';

import 'package:hyppe/core/interface/pagination_query_interface.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/models/hive_box/boxes.dart';
import 'package:hyppe/core/services/check_version.dart';
import 'package:hyppe/ui/inner/home/notifier_v2.dart';
import 'package:provider/provider.dart';

class ContentsDataQuery extends PaginationQueryInterface {
  FeatureType? featureType;

  String searchText = "";

  bool onlyMyData = false;

  String? postID;

  ContentsDataQuery();

  @override
  Future<List<ContentData>> loadNext(BuildContext context, {bool myContent = false, bool otherContent = false}) async {
    if (featureType == null) throw Exception('Feature Type must be provided');
    if (loading) throw Exception('Query operation is in progress');
    if (!hasNext) return [];
    final box = Boxes.boxDataContents;

    final notifierMain = Provider.of<HomeNotifier>(context, listen: false);

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
        visibility: notifierMain.visibilty,
        myContent: myContent,
        otherContent: otherContent,
      );
      final fetch = notifier.postsFetch;

      res = (fetch.data as List<dynamic>?)?.map((e) => ContentData.fromJson(e as Map<String, dynamic>)).toList();

      if(featureType == FeatureType.story){
        box.get(notifierMain.visibilty)!.story!.addAll(res ?? []);
      }else if(featureType == FeatureType.vid){
        box.get(notifierMain.visibilty)!.video!.addAll(res ?? []);
      }else if(featureType == FeatureType.diary){
        box.get(notifierMain.visibilty)!.diary!.addAll(res ?? []);
      }else if(featureType == FeatureType.pic){
        box.get(notifierMain.visibilty)!.pict!.addAll(res ?? []);
      }
      await box.get(notifierMain.visibilty)!.save();

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
  Future<List<ContentData>> reload(BuildContext context, {bool myContent = false, bool otherContent = false, bool isCache = false }) async {
    if (featureType == null) throw Exception('Feature Type must be provided');
    if (loading) throw Exception('Query operation is in progress');
    final notifierMain = Provider.of<HomeNotifier>(context, listen: false);
    hasNext = true;

    loading = true;

    final box = Boxes.boxDataContents;

    page = 0;
    List<ContentData>? res;
    if(!isCache){
      try {
        final notifier = PostsBloc();
        await notifier.getContentsBlocV2(context,
            postID: postID,
            pageRows: limit,
            pageNumber: page,
            type: featureType!,
            searchText: searchText,
            onlyMyData: onlyMyData,
            visibility: notifierMain.visibilty,
            myContent: myContent,
            otherContent: otherContent);
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
    }else{
      try{
        final data = box.get(notifierMain.visibilty);
        if(featureType == FeatureType.story){
          res = data?.story ?? [];
        }else if(featureType == FeatureType.vid){
          res = data?.video ?? [];
        }else if(featureType == FeatureType.diary){
          res = data?.diary ?? [];
        }else if(featureType == FeatureType.pic){
          res = data?.pict ?? [];
        }else{
          res = [];
        }

        hasNext = res.length == limit;
        if (res != null) page++;
      }catch (e) {
        '$e'.logger();
        rethrow;
      } finally {
        loading = false;
      }

      return res;
    }

  }



}
