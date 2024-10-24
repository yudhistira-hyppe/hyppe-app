import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:hyppe/core/config/url_constants.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/models/collection/discount/discountmodel.dart';
import 'package:hyppe/core/models/collection/sticker/sticker_model.dart';
import 'package:hyppe/core/models/collection/transaction/coinpurchasedetail.dart';
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
    String? visibility,
    bool onlyMyData = false,
    bool myContent = false,
    bool otherContent = false,
    int? indexContent,
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
      print('ZT $pageRows, $pageNumber, $visibility, ${System().validatePostTypeV2(type)}');
      formData.fields.add(MapEntry('pageNumber', '$pageNumber'));
      formData.fields.add(MapEntry('postType', System().validatePostTypeV2(type)));
    }
    url = UrlConstants.getuserposts;
    if (otherContent) {
      formData.fields.add(MapEntry('email', searchText));
      url = UrlConstants.getOtherUserPosts;
    }

    if (myContent) {
      formData.fields.add(MapEntry('email', email));
      // url = UrlConstants.getMyUserPostsV2;
      url = UrlConstants.getMyUserPosts;
    }

    if (indexContent != null) {
      formData.fields.add(MapEntry('index', '$indexContent'));
      url = UrlConstants.getuserposts;
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
        if ((onResult.statusCode ?? 300) > HTTP_CODE) {
          setPostsFetch(PostsFetch(PostsState.getContentsError));
        } else {
          setPostsFetch(
              PostsFetch(PostsState.getContentsSuccess, version: onResult.data['version'], versionIos: onResult.data['version_ios'], data: GenericResponse.fromJson(onResult.data).responseData));
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

  Future getStoriesGroup(BuildContext context, int page, int limit) async {
    final email = SharedPreference().readStorage(SpKeys.email);
    setPostsFetch(PostsFetch(PostsState.loading));
    await _repos.reposPost(
      context,
      (onResult) {
        if ((onResult.statusCode ?? 300) > HTTP_CODE) {
          setPostsFetch(PostsFetch(PostsState.getAllContentsError));
        } else {
          setPostsFetch(PostsFetch(PostsState.getAllContentsSuccess, data: GenericResponse.fromJson(onResult.data).responseData));
        }
      },
      (errorData) {
        setPostsFetch(PostsFetch(PostsState.getAllContentsError));
      },
      data: {'email': email, 'page': page, 'limit': limit},
      host: UrlConstants.getStoriesLandingPage,
      withAlertMessage: false,
      methodType: MethodType.post,
      withCheckConnection: false,
    );
  }

  Future getAllContentsBlocV2(
    BuildContext context, {
    int pageRows = 5,
    bool myContent = false,
    bool otherContent = false,
    String? postType,
    required String visibility,
    required int pageNumber,
  }) async {
    final formData = FormData();
    final email = SharedPreference().readStorage(SpKeys.email);
    final fcmToken = SharedPreference().readStorage(SpKeys.fcmToken);
    print('my fcm token : $fcmToken');
    // final currentDate = context.getCurrentDate();

    formData.fields.add(const MapEntry('withActive', 'true'));
    formData.fields.add(const MapEntry('withDetail', 'true'));
    formData.fields.add(const MapEntry('withInsight', 'true'));
    if (postType != null) {
      formData.fields.add(MapEntry('postType', postType));
      if (postType == 'story') {
        formData.fields.add(const MapEntry('withExp', 'true'));
      }
    }
    formData.fields.add(MapEntry('visibility', visibility));
    // formData.fields.add(MapEntry('endDate', currentDate));
    formData.fields.add(MapEntry('pageRow', '$pageRows'));
    formData.fields.add(MapEntry('pageNumber', '$pageNumber'));

    print('getAllContentsBlocV2 paging : ${formData.fields.map((e) => e).join(',')}');
    setPostsFetch(PostsFetch(PostsState.loading));
    await _repos.reposPost(
      context,
      (onResult) {
        print("test $onResult");
        if ((onResult.statusCode ?? 300) > HTTP_CODE) {
          setPostsFetch(PostsFetch(PostsState.getAllContentsError));
        } else {
          setPostsFetch(
            PostsFetch(PostsState.getAllContentsSuccess, version: onResult.data['version'], versionIos: onResult.data['version_ios'], data: GenericResponse.fromJson(onResult.data).responseData),
          );
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

  Future getNewContentsBlocV2(
    BuildContext context, {
    Map? data,
  }) async {
    print('getAllContentsBlocV2 paging : $data');
    setPostsFetch(PostsFetch(PostsState.loading));
    await _repos.reposPost(
      context,
      (onResult) {
        print("test $onResult");
        if ((onResult.statusCode ?? 300) > HTTP_CODE) {
          setPostsFetch(PostsFetch(PostsState.getAllContentsError));
        } else {
          print("test2 ${GenericResponse.fromJson(onResult.data).responseData}");
          setPostsFetch(
            PostsFetch(PostsState.getAllContentsSuccess, version: onResult.data['version'], versionIos: onResult.data['version_ios'], data: onResult.data),
          );
        }
      },
      (errorData) {
        setPostsFetch(PostsFetch(PostsState.getAllContentsError));
      },
      data: data,
      host: UrlConstants.getNewLandingPage,
      withAlertMessage: false,
      withCheckConnection: false,
      methodType: MethodType.post,
    );
  }

  Future postContentsBlocV2(
    BuildContext context, {
    List<String>? tags,
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
    bool? saleView,
    bool? isShared,
    String? idMusic,
    int? width,
    int? height,
    String? urlLink,
    String? judulLink,
    DiscountModel? discount,
    CointPurchaseDetailModel? cointPurchaseDetail,
    List<StickerModel>? stickers,
  }) async {
    final formData = FormData();
    final email = SharedPreference().readStorage(SpKeys.email);

    File x = File(fileContents[0] ?? '');
    if (Platform.isIOS && type == FeatureType.pic) {
      x = await System().rotateAndCompressAndSaveImage(File(fileContents[0] ?? ''));
    }

    formData.files.add(MapEntry(
        "postContent",
        await MultipartFile.fromFile(x.path,
            filename: "${System().basenameFiles(x.path)}.${System().extensionFiles(x.path)?.replaceAll(".", "")}",
            contentType: MediaType(
              System().lookupContentMimeType(x.path)?.split('/')[0] ?? '',
              System().extensionFiles(x.path)?.replaceAll(".", "") ?? "",
            ))));
    formData.fields.add(MapEntry('email', email));
    formData.fields.add(MapEntry('postType', System().validatePostTypeV2(type)));
    formData.fields.add(MapEntry('description', description));
    formData.fields.add(MapEntry('tags', tags?.join(',') ?? ''));
    formData.fields.add(MapEntry('cats', cats != null ? cats.map((item) => item).toList().join(",") : ""));
    formData.fields.add(MapEntry('tagPeople', tagPeople != null ? tagPeople.map((item) => item).toList().join(",") : ""));
    formData.fields.add(MapEntry('visibility', visibility));
    formData.fields.add(MapEntry('allowComments', allowComment.toString()));
    formData.fields.add(MapEntry('certified', certified.toString()));
    formData.fields.add(MapEntry('urlLink', urlLink.toString()));
    formData.fields.add(MapEntry('judulLink', judulLink.toString()));
    if (certified == true){
      formData.fields.add(MapEntry('transaction_fee', (cointPurchaseDetail?.total_before_discount??0).toString() ));
      print('========== post disctont ${discount != null}');
      if (discount != null){
        formData.fields.add(MapEntry('discount_id', discount.id.toString()));
        formData.fields.add(MapEntry('discount_fee', discount.nominal_discount.toString()));
      }
    }

    if (idMusic != null) {
      formData.fields.add(MapEntry('musicId', idMusic));
    }

    if (width != null) {
      formData.fields.add(MapEntry('width', width.toString()));
    }
    if (height != null) {
      formData.fields.add(MapEntry('height', height.toString()));
    }

    formData.fields.add(MapEntry('location', location ?? ''));
    formData.fields.add(MapEntry('tagDescription', tagDescription?.join(',') ?? ''));
    // formData.fields.add(MapEntry('tagDescription', jsonEncode(tagDescription)));

    formData.fields.add(MapEntry('rotate', '${System().convertOrientation(rotate)}'));
    formData.fields.add(MapEntry('saleAmount', saleAmount != null ? saleAmount.toString() : "0"));
    formData.fields.add(MapEntry('saleLike', saleLike != null ? saleLike.toString() : "false"));
    formData.fields.add(MapEntry('saleView', saleView != null ? saleView.toString() : "false"));
    if (isShared != null) {
      formData.fields.add(MapEntry('isShared', isShared.toString()));
    } else {
      formData.fields.add(MapEntry('isShared', 'false'));
    }
    if (stickers != null && stickers.isNotEmpty) {
      var ids = stickers.asMap().entries.map((e) => e.value.id).join(',');
      var images = stickers.asMap().entries.map((e) => e.value.image).join(',');
      var types = stickers.asMap().entries.map((e) => e.value.type).join(',');
      var positions = stickers.asMap().entries.map((e) => e.value.matrix?.storage.asMap().entries.map((f) => f.value).join(',')).join('#');
      formData.fields.add(MapEntry('stiker', ids));
      formData.fields.add(MapEntry('image', images));
      formData.fields.add(MapEntry('type', types));
      formData.fields.add(MapEntry('position', positions));
    }

    String challangedata = SharedPreference().readStorage(SpKeys.challangeData) ?? '';
    if (challangedata != '') {
      formData.fields.add(MapEntry('listchallenge', challangedata));
    }

    debugPrint("FORM_POST => " + allowComment.toString());
    debugPrint(formData.fields.join(" - "));

    print('createPost : ');
    print("name file ${"${System().basenameFiles(File(fileContents[0] ?? '').path)}.${System().extensionFiles(File(fileContents[0] ?? '').path)?.replaceAll(".", "")}"}");
    print(formData.fields.map((e) => e).join(','));
    print('file upload: ${formData.files.toString()}');

    print(System().basenameFiles(File(fileContents[0] ?? '').path));
    print(System().extensionFiles(File(fileContents[0] ?? '').path)?.replaceAll(".", ""));

    setPostsFetch(PostsFetch(PostsState.loading));
    await _repos.reposPost(
      context,
      (onResult) {
        print('Error Create Post ${onResult.statusCode}');
        if ((onResult.statusCode ?? 300) > HTTP_CODE) {
          setPostsFetch(PostsFetch(PostsState.postContentsError));
        } else {
          setPostsFetch(PostsFetch(PostsState.postContentsSuccess, data: onResult));
        }
      },
      (errorData) {
        print('Error Create Post $errorData');
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

    print("delet content");
    print(formData.fields.map((e) => e).join(','));
    setPostsFetch(PostsFetch(PostsState.loading));
    await _repos.reposPost(
      context,
      (onResult) {
        if ((onResult.statusCode ?? 300) > HTTP_CODE) {
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
      bool? isShared,
      String? urlLink,
      String? judulLink,
      DiscountModel? discount,
      CointPurchaseDetailModel? cointPurchaseDetail,
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
    formData.fields.add(MapEntry('location', location ?? ''));
    formData.fields.add(MapEntry('saleAmount', saleAmount != null ? saleAmount.toString() : "0"));
    formData.fields.add(MapEntry('saleLike', saleLike != null ? saleLike.toString() : "false"));
    formData.fields.add(MapEntry('saleView', saleView != null ? saleView.toString() : "false"));
    formData.fields.add(MapEntry('isShared', isShared.toString()));
    formData.fields.add(MapEntry('urlLink', urlLink.toString()));
    formData.fields.add(MapEntry('judulLink', judulLink.toString()));
    if (cointPurchaseDetail != null){
      formData.fields.add(MapEntry('transaction_fee', (cointPurchaseDetail.total_before_discount??0).toString()));
      if (discount != null){
        formData.fields.add(MapEntry('discount_id', discount.id.toString()));
        formData.fields.add(MapEntry('discount_fee', discount.nominal_discount.toString()));
      }
    } 

    print('hahahahahahahaha');
    print(type);
    print(formData.fields.map((e) => e).join(','));

    setPostsFetch(PostsFetch(PostsState.loading));
    await _repos.reposPost(
      context,
      (onResult) {
        if ((onResult.statusCode ?? 300) > HTTP_CODE) {
          setPostsFetch(PostsFetch(PostsState.updateContentsError, data: onResult));
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
      withAlertMessage: false,
      withCheckConnection: true,
      host: UrlConstants.updatepost,
      methodType: MethodType.post,
      errorServiceType: System().getErrorTypeV2(type),
    );
  }

  Future getVideoApsaraBlocV2(
    BuildContext context, {
    required String apsaraId,
    SpeedInternet? speedInternet,
  }) async {
    final email = SharedPreference().readStorage(SpKeys.email);
    final token = SharedPreference().readStorage(SpKeys.userToken);
    setPostsFetch(PostsFetch(PostsState.loading));
    String speed = 'SD';

    await _repos.reposPost(
      context,
      (onResult) {
        if ((onResult.statusCode ?? 300) > HTTP_CODE) {
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
      data: {"apsaraId": apsaraId, "definition": speed},
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

  Future getAuthApsara(BuildContext context, {required String apsaraId, bool check = true}) async {
    final email = SharedPreference().readStorage(SpKeys.email);

    setPostsFetch(PostsFetch(PostsState.loading));
    var url = UrlConstants.apsaraauth + apsaraId;

    await _repos.reposPost(
      context,
      (onResult) {
        if ((onResult.statusCode ?? 300) > HTTP_CODE) {
          setPostsFetch(PostsFetch(PostsState.videoApsaraError));
        } else {
          setPostsFetch(PostsFetch(PostsState.videoApsaraSuccess, data: onResult));
        }
      },
      (errorData) {
        setPostsFetch(PostsFetch(PostsState.videoApsaraError));
      },
      headers: {
        'x-auth-user': email,
      },
      withAlertMessage: false,
      withCheckConnection: check,
      host: url,
      methodType: MethodType.get,
    );
  }

  Future getOldVideo(BuildContext context, {required String apsaraId, bool check = true}) async {
    setPostsFetch(PostsFetch(PostsState.loading));
    var url = UrlConstants.oldVideo + apsaraId;

    await _repos.reposPost(
      context,
      (onResult) {
        if ((onResult.statusCode ?? 300) > HTTP_CODE) {
          setPostsFetch(PostsFetch(PostsState.videoApsaraError));
        } else {
          setPostsFetch(PostsFetch(PostsState.videoApsaraSuccess, data: onResult));
        }
      },
      (errorData) {
        setPostsFetch(PostsFetch(PostsState.videoApsaraError));
      },
      withAlertMessage: false,
      withCheckConnection: check,
      host: url,
      methodType: MethodType.get,
    );
  }

  Future getSTS(BuildContext context) async {
    setPostsFetch(PostsFetch(PostsState.loading));
    var url = "https://alivc-demo.aliyuncs.com/player/getVideoSts";

    await _repos.reposPost(
      context,
      (onResult) {
        if ((onResult.statusCode ?? 300) > HTTP_CODE) {
          setPostsFetch(PostsFetch(PostsState.videoApsaraError));
        } else {
          setPostsFetch(PostsFetch(PostsState.videoApsaraSuccess, data: onResult));
        }
      },
      (errorData) {
        setPostsFetch(PostsFetch(PostsState.videoApsaraError));
      },
      withAlertMessage: false,
      withCheckConnection: false,
      host: url,
      methodType: MethodType.get,
    );
  }

  Future getMusic(BuildContext context, {required String apsaraId, bool check = true}) async {
    final email = SharedPreference().readStorage(SpKeys.email);

    setPostsFetch(PostsFetch(PostsState.loading));
    var url = UrlConstants.getMusicsPath + apsaraId;

    await _repos.reposPost(
      context,
      (onResult) {
        if ((onResult.statusCode ?? 300) > HTTP_CODE) {
          setPostsFetch(PostsFetch(PostsState.videoApsaraError));
        } else {
          setPostsFetch(PostsFetch(PostsState.videoApsaraSuccess, data: onResult));
        }
      },
      (errorData) {
        setPostsFetch(PostsFetch(PostsState.videoApsaraError));
      },
      headers: {
        'x-auth-user': email,
      },
      withAlertMessage: false,
      withCheckConnection: check,
      host: url,
      methodType: MethodType.get,
    );
  }
}
