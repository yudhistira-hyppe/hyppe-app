import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:hyppe/core/config/url_constants.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/core/bloc/repos/repos.dart';
import 'package:hyppe/core/bloc/posts_v2/state.dart';
import 'package:hyppe/core/constants/status_code.dart';
import 'package:hyppe/core/response/generic_response.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:native_device_orientation/native_device_orientation.dart';

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
    bool onlyMyData = false,
  }) async {
    final formData = FormData();
    final email = SharedPreference().readStorage(SpKeys.email);

    if (onlyMyData) {
      formData.fields.add(MapEntry('search', email));
      formData.fields.add(const MapEntry('withExp', 'true'));
      formData.fields.add(const MapEntry('withActive', 'true'));
      formData.fields.add(const MapEntry('withDetail', 'true'));
      formData.fields.add(const MapEntry('withInsight', 'true'));
      formData.fields
          .add(MapEntry('postType', System().validatePostTypeV2(type)));
    } else {
      if (type == FeatureType.story) {
        if (postID == null) formData.fields.add(MapEntry('exclude', email));
        formData.fields.add(const MapEntry('withExp', 'true'));
      }
      if (postID != null) {
        formData.fields.add(MapEntry('postID', postID));
      }
      formData.fields.add(MapEntry('search', searchText));
      formData.fields.add(const MapEntry('withActive', 'true'));
      formData.fields.add(const MapEntry('withDetail', 'true'));
      formData.fields.add(const MapEntry('withInsight', 'true'));
      formData.fields.add(MapEntry('pageRow', '$pageRows'));
      formData.fields.add(MapEntry('pageNumber', '$pageNumber'));
      formData.fields
          .add(MapEntry('postType', System().validatePostTypeV2(type)));
    }

    setPostsFetch(PostsFetch(PostsState.loading));
    await _repos.reposPost(
      context,
      (onResult) {
        if (onResult.statusCode! > HTTP_CODE) {
          setPostsFetch(PostsFetch(PostsState.getContentsError));
        } else {
          setPostsFetch(PostsFetch(PostsState.getContentsSuccess,
              data: GenericResponse.fromJson(onResult.data).responseData));
        }
      },
      (errorData) {
        setPostsFetch(PostsFetch(PostsState.getContentsError));
      },
      data: formData,
      headers: {
        'x-auth-user': email,
      },
      host: UrlConstants.getuserposts,
      withAlertMessage: false,
      withCheckConnection: false,
      methodType: MethodType.post,
      errorServiceType: System().getErrorTypeV2(type),
    );
  }

  Future postContentsBlocV2(
    BuildContext context, {
    String? tags,
    required FeatureType type,
    required bool allowComment,
    required String description,
    required String visibility,
    String location = "Indonesia",
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    required List<String?> fileContents,
    required NativeDeviceOrientation rotate,
  }) async {
    final formData = FormData();
    final email = SharedPreference().readStorage(SpKeys.email);

    formData.files.add(MapEntry(
        "postContent",
        await MultipartFile.fromFile(File(fileContents[0]!).path,
            filename: System().basenameFiles(File(fileContents[0]!).path),
            contentType: MediaType(
              System()
                      .lookupContentMimeType(File(fileContents[0]!).path)
                      ?.split('/')[0] ??
                  '',
              System()
                      .extensionFiles(File(fileContents[0]!).path)
                      ?.replaceAll(".", "") ??
                  "",
            ))));
    formData.fields.add(MapEntry('email', email));
    formData.fields
        .add(MapEntry('postType', System().validatePostTypeV2(type)));
    formData.fields.add(MapEntry('description', description));
    formData.fields.add(MapEntry('tags', tags ?? ""));
    formData.fields.add(MapEntry('visibility', visibility));
    formData.fields.add(MapEntry('allowComments', allowComment.toString()));
    formData.fields.add(MapEntry('location', location));
    formData.fields
        .add(MapEntry('rotate', '${System().convertOrientation(rotate)}'));
    debugPrint("FORM_POST => " + allowComment.toString());
    debugPrint(formData.toString());

    setPostsFetch(PostsFetch(PostsState.loading));
    await _repos.reposPost(
      context,
      (onResult) {
        if (onResult.statusCode! > HTTP_CODE) {
          setPostsFetch(PostsFetch(PostsState.postContentsError));
        } else {
          setPostsFetch(
              PostsFetch(PostsState.postContentsSuccess, data: onResult));
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

  Future deleteContentBlocV2(BuildContext context,
      {required String postId, required FeatureType type}) async {
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
          setPostsFetch(
              PostsFetch(PostsState.deleteContentsSuccess, data: onResult));
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

  Future updateContentBlocV2(
    BuildContext context, {
    required String postId,
    required String description,
    String? tags,
    String visibility = "PUBLIC",
    required bool allowComment,
    required FeatureType type,
  }) async {
    final email = SharedPreference().readStorage(SpKeys.email);

    final formData = FormData();
    formData.fields.add(MapEntry('postID', postId));
    formData.fields.add(MapEntry('description', description));
    formData.fields.add(MapEntry('tags', tags ?? ""));
    formData.fields.add(MapEntry('visibility', visibility));
    formData.fields.add(MapEntry('allowComments', allowComment.toString()));
    formData.fields.add(const MapEntry('active', 'true'));
    formData.fields
        .add(MapEntry('postType', System().validatePostTypeV2(type)));

    setPostsFetch(PostsFetch(PostsState.loading));
    await _repos.reposPost(
      context,
      (onResult) {
        if (onResult.statusCode! > HTTP_CODE) {
          setPostsFetch(PostsFetch(PostsState.updateContentsError));
        } else {
          setPostsFetch(
              PostsFetch(PostsState.updateContentsSuccess, data: onResult));
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
}
