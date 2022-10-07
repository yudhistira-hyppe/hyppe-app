import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:hyppe/core/config/url_constants.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/core/bloc/repos/repos.dart';
import 'package:hyppe/core/bloc/posts_v2/state.dart';
import 'package:hyppe/core/constants/status_code.dart';
import 'package:hyppe/core/response/generic_response.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:native_device_orientation/native_device_orientation.dart';

import '../../models/collection/posts/content_v2/content_data.dart';

class PostsBloc {
  final _repos = Repos();

  PostsFetch _postsFetch = PostsFetch(PostsState.init);
  PostsFetch get postsFetch => _postsFetch;
  setPostsFetch(PostsFetch val) => _postsFetch = val;

  Future getContentsBlocV2(
    BuildContext context, {
    int pageRows = 5,
    String searchText = "",
    String? postID,
    required int pageNumber,
    required FeatureType type,
    String? visibility,
    bool onlyMyData = false,
    bool myContent = false,
    bool otherContent = false,
  }) async {
    final formData = FormData();
    final email = SharedPreference().readStorage(SpKeys.email);
    String url = '';

    if (onlyMyData) {
      if (myContent != true) {
        formData.fields.add(MapEntry('search', email));
      }
      formData.fields.add(const MapEntry('withExp', 'true'));
      formData.fields.add(const MapEntry('withActive', 'true'));
      formData.fields.add(const MapEntry('withDetail', 'true'));
      formData.fields.add(const MapEntry('withInsight', 'true'));

      formData.fields.add(MapEntry('postType', System().validatePostTypeV2(type)));
      if (type == FeatureType.story) {
        formData.fields.add(const MapEntry('visibility', 'PRIVATE'));
      }
    } else {
      if (type == FeatureType.story) {
        if (postID == null) formData.fields.add(MapEntry('exclude', email));
        formData.fields.add(const MapEntry('withExp', 'true'));
      }
      if (postID != null) {
        formData.fields.add(MapEntry('postID', postID));
      }

      if (searchText == '') {
        formData.fields.add(MapEntry('visibility', '$visibility'));
      }

      // if (type == FeatureType.diary && postID != null) {
      //   // _objTable.removeWhere((key, value) => key == "propertyName");
      //   formData.fields.removeWhere((element) => element.key == 'visibility');
      // }

      if (myContent != true) {
        formData.fields.add(MapEntry('search', searchText));
      }
      formData.fields.add(const MapEntry('withActive', 'true'));
      formData.fields.add(const MapEntry('withDetail', 'true'));
      formData.fields.add(const MapEntry('withInsight', 'true'));
      formData.fields.add(MapEntry('pageRow', '$pageRows'));
      formData.fields.add(MapEntry('pageNumber', '$pageNumber'));
      formData.fields.add(MapEntry('postType', System().validatePostTypeV2(type)));
    }
    url = UrlConstants.getuserposts;
    if (otherContent) {
      formData.fields.add(MapEntry('email', searchText));
      url = UrlConstants.getOtherUserPosts;
    }

    if (myContent) {
      url = UrlConstants.getMyUserPosts;
    }

    print('hahahahahahahaha');
    print(myContent);
    print(onlyMyData);
    print(postID);
    print(formData.fields.map((e) => e).join(','));
    setPostsFetch(PostsFetch(PostsState.loading));
    await _repos.reposPost(
      context,
      (onResult) {
        print(onResult);
        if (onResult.statusCode! > HTTP_CODE) {
          setPostsFetch(PostsFetch(PostsState.getContentsError));
        } else {
          setPostsFetch(PostsFetch(PostsState.getContentsSuccess, version: onResult.data['version'], data: GenericResponse.fromJson(onResult.data).responseData));
        }
      },
      (errorData) {
        setPostsFetch(PostsFetch(PostsState.getContentsError));
      },
      data: formData,
      headers: {
        'x-auth-user': email,
      },
      host: url,
      withAlertMessage: false,
      withCheckConnection: false,
      methodType: MethodType.post,
      errorServiceType: System().getErrorTypeV2(type),
    );
  }

  Future getAllContentsBlocV2(
    BuildContext context, {
    int pageRows = 12,
    bool isStartAgain = false,
    bool myContent = false,
    bool otherContent = false,
    required String visibility,
    required int pageNumber,
  }) async {
    final formData = FormData();
    final email = SharedPreference().readStorage(SpKeys.email);
    final lastHit = SharedPreference().readStorage(SpKeys.lastHitPost);
    final currentDate = context.getCurrentDate();
    print('test sini');
    print(isStartAgain);
    print(lastHit);
    formData.fields.add(const MapEntry('withExp', 'true'));
    formData.fields.add(const MapEntry('withActive', 'true'));
    formData.fields.add(const MapEntry('withDetail', 'true'));
    formData.fields.add(const MapEntry('withInsight', 'true'));
    formData.fields.add(MapEntry('visibility', visibility));
    // formData.fields.add(MapEntry('startDate', isStartAgain ? '' : lastHit));
    // formData.fields.add(MapEntry('endDate', currentDate));
    formData.fields.add(MapEntry('pageRow', '$pageRows'));
    formData.fields.add(MapEntry('pageNumber', '$pageNumber'));
    SharedPreference().writeStorage(SpKeys.lastHitPost, currentDate);

    print(formData.fields.map((e) => e).join(','));
    setPostsFetch(PostsFetch(PostsState.loading));
    await _repos.reposPost(
      context,
      (onResult) {
        print("test $onResult");
        if (onResult.statusCode! > HTTP_CODE) {
          setPostsFetch(PostsFetch(PostsState.getAllContentsError));
        } else {
          setPostsFetch(PostsFetch(PostsState.getAllContentsSuccess, data: GenericResponse.fromJson(onResult.data).responseData));
        }
      },
      (errorData) {
        setPostsFetch(PostsFetch(PostsState.getAllContentsError));
      },
      data: formData,
      headers: {
        'x-auth-user': email,
      },
      host: UrlConstants.getUserPostsLandingPage,
      withAlertMessage: false,
      withCheckConnection: false,
      methodType: MethodType.post,
    );
  }

  Future postContentsBlocV2(BuildContext context,
      {List<String>? tags,
      List<String>? cats,
      List<String>? tagPeople,
      required FeatureType type,
      required bool allowComment,
      required bool certified,
      required String description,
      required String visibility,
      String? location,
      ProgressCallback? onSendProgress,
      ProgressCallback? onReceiveProgress,
      required List<String?> fileContents,
      required NativeDeviceOrientation rotate,
      List<String>? tagDescription,
      String? saleAmount,
      bool? saleLike,
      bool? saleView}) async {
    final formData = FormData();
    final email = SharedPreference().readStorage(SpKeys.email);

    formData.files.add(MapEntry(
        "postContent",
        await MultipartFile.fromFile(File(fileContents[0]!).path,
            filename: System().basenameFiles(File(fileContents[0]!).path),
            contentType: MediaType(
              System().lookupContentMimeType(File(fileContents[0]!).path)?.split('/')[0] ?? '',
              System().extensionFiles(File(fileContents[0]!).path)?.replaceAll(".", "") ?? "",
            ))));
    formData.fields.add(MapEntry('email', email));
    formData.fields.add(MapEntry('postType', System().validatePostTypeV2(type)));
    formData.fields.add(MapEntry('description', description));
    formData.fields.add(MapEntry('tags', tags!.join(',')));
    formData.fields.add(MapEntry('cats', cats != null ? cats.map((item) => item).toList().join(",") : ""));
    formData.fields.add(MapEntry('tagPeople', tagPeople != null ? tagPeople.map((item) => item).toList().join(",") : ""));
    formData.fields.add(MapEntry('visibility', visibility));
    formData.fields.add(MapEntry('allowComments', allowComment.toString()));
    formData.fields.add(MapEntry('certified', certified.toString()));

    formData.fields.add(MapEntry('location', location!));
    formData.fields.add(MapEntry('tagDescription', tagDescription!.join(',')));
    // formData.fields.add(MapEntry('tagDescription', jsonEncode(tagDescription)));

    formData.fields.add(MapEntry('rotate', '${System().convertOrientation(rotate)}'));
    formData.fields.add(MapEntry('saleAmount', saleAmount != null ? saleAmount.toString() : "0"));
    formData.fields.add(MapEntry('saleLike', saleLike != null ? saleLike.toString() : "false"));
    formData.fields.add(MapEntry('saleView', saleView != null ? saleView.toString() : "false"));

    debugPrint("FORM_POST => " + allowComment.toString());
    debugPrint(formData.fields.join(" - "));

    setPostsFetch(PostsFetch(PostsState.loading));
    await _repos.reposPost(
      context,
      (onResult) {
        if (onResult.statusCode! > HTTP_CODE) {
          setPostsFetch(PostsFetch(PostsState.postContentsError));
        } else {
          setPostsFetch(PostsFetch(PostsState.postContentsSuccess, data: onResult));
        }
      },
      (errorData) {
        setPostsFetch(PostsFetch(PostsState.postContentsError));
      },
      data: formData,
      headers: {
        'x-auth-user': email,
      },
      withAlertMessage: true,
      withCheckConnection: true,
      host: UrlConstants.createuserposts,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
      methodType: MethodType.postUploadContent,
      errorServiceType: System().getErrorTypeV2(type),
    );

    return _postsFetch.data;
  }

  Future deleteContentBlocV2(BuildContext context, {required String postId, required FeatureType type}) async {
    final email = SharedPreference().readStorage(SpKeys.email);

    final formData = FormData();
    formData.fields.add(MapEntry('postID', postId));
    formData.fields.add(const MapEntry('active', 'false'));

    setPostsFetch(PostsFetch(PostsState.loading));
    await _repos.reposPost(
      context,
      (onResult) {
        if (onResult.statusCode! > HTTP_CODE) {
          setPostsFetch(PostsFetch(PostsState.deleteContentsError));
        } else {
          setPostsFetch(PostsFetch(PostsState.deleteContentsSuccess, data: onResult));
        }
      },
      (errorData) {
        setPostsFetch(PostsFetch(PostsState.deleteContentsError));
      },
      data: formData,
      headers: {
        'x-auth-user': email,
      },
      withAlertMessage: true,
      withCheckConnection: true,
      host: UrlConstants.updatepost,
      methodType: MethodType.post,
      errorServiceType: System().getErrorTypeV2(type),
    );
  }

  Future updateContentBlocV2(BuildContext context,
      {required String postId,
      required String description,
      String? tags,
      String visibility = "PUBLIC",
      required bool allowComment,
      required bool certified,
      required FeatureType type,
      List<String>? cats,
      List<String>? tagPeople,
      String? location,
      String? saleAmount,
      bool? saleLike,
      bool? saleView}) async {
    final email = SharedPreference().readStorage(SpKeys.email);

    final formData = FormData();
    formData.fields.add(MapEntry('postID', postId));
    formData.fields.add(MapEntry('description', description));
    formData.fields.add(MapEntry('tags', tags ?? ""));
    formData.fields.add(MapEntry('visibility', visibility));
    formData.fields.add(MapEntry('allowComments', allowComment.toString()));
    formData.fields.add(MapEntry('certified', certified.toString()));
    formData.fields.add(const MapEntry('active', 'true'));
    formData.fields.add(MapEntry('postType', System().validatePostTypeV2(type)));
    formData.fields.add(MapEntry('cats', cats != null ? cats.map((item) => item).toList().join(",") : ""));
    formData.fields.add(MapEntry('tagPeople', tagPeople != null ? tagPeople.map((item) => item).toList().join(",") : ""));
    formData.fields.add(MapEntry('location', location!));
    formData.fields.add(MapEntry('saleAmount', saleAmount != null ? saleAmount.toString() : "0"));
    formData.fields.add(MapEntry('saleLike', saleLike != null ? saleLike.toString() : "false"));
    formData.fields.add(MapEntry('saleView', saleView != null ? saleView.toString() : "false"));

    print('hahahahahahahaha');
    print(type);
    print(formData.fields.map((e) => e).join(','));

    setPostsFetch(PostsFetch(PostsState.loading));
    await _repos.reposPost(
      context,
      (onResult) {
        if (onResult.statusCode! > HTTP_CODE) {
          setPostsFetch(PostsFetch(PostsState.updateContentsError));
        } else {
          setPostsFetch(PostsFetch(PostsState.updateContentsSuccess, data: onResult));
        }
      },
      (errorData) {
        setPostsFetch(PostsFetch(PostsState.updateContentsError));
      },
      data: formData,
      headers: {
        'x-auth-user': email,
      },
      withAlertMessage: true,
      withCheckConnection: true,
      host: UrlConstants.updatepost,
      methodType: MethodType.post,
      errorServiceType: System().getErrorTypeV2(type),
    );
  }

  Future getVideoApsaraBlocV2(
    BuildContext context, {
    required String apsaraId,
  }) async {
    final email = SharedPreference().readStorage(SpKeys.email);
    final token = SharedPreference().readStorage(SpKeys.userToken);

    setPostsFetch(PostsFetch(PostsState.loading));
    await _repos.reposPost(
      context,
      (onResult) {
        if (onResult.statusCode! > HTTP_CODE) {
          setPostsFetch(PostsFetch(PostsState.videoApsaraError));
        } else {
          print('onResult');
          print(onResult);
          setPostsFetch(PostsFetch(PostsState.videoApsaraSuccess, data: onResult));
        }
      },
      (errorData) {
        setPostsFetch(PostsFetch(PostsState.videoApsaraError));
      },
      data: {"apsaraId": apsaraId},
      headers: {
        'x-auth-user': email,
        'x-auth-token': token,
      },
      withAlertMessage: false,
      withCheckConnection: true,
      host: UrlConstants.getVideoApsara,
      methodType: MethodType.post,
    );
  }
}
