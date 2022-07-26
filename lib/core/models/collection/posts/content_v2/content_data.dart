import 'package:hyppe/core/config/env.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/privacy.dart';
import 'package:hyppe/core/models/collection/user_v2/profile/user_profile_avatar_model.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data_insight.dart';

class ContentData {
  Metadata? metadata;
  String? mediaBasePath;
  String? postType;
  String? mediaUri;
  bool? isLiked;
  String? description;
  bool? active;
  Privacy? privacy;
  String? mediaType;
  String? mediaThumbEndPoint;
  String? postID;
  String? title;
  bool? isViewed;
  List<String>? tags;
  bool? allowComments;
  bool? certified;
  String? createdAt;
  ContentDataInsight? insight;
  String? mediaThumbUri;
  String? mediaEndpoint;
  String? email;
  String? updatedAt;
  String? username;
  String? fullThumbPath;
  String? fullContentPath;
  ContentType? contentType;
  UserProfileAvatarModel? avatar;
  double? saleAmount;
  bool? saleView;
  bool? saleLike;

  ContentData(
      {this.metadata,
      this.mediaBasePath,
      this.postType,
      this.mediaUri,
      this.isLiked,
      this.description,
      this.active,
      this.privacy,
      this.mediaType,
      this.mediaThumbEndPoint,
      this.postID,
      this.title,
      this.isViewed,
      this.tags = const [],
      this.allowComments,
      this.certified,
      this.createdAt,
      this.insight,
      this.mediaThumbUri,
      this.mediaEndpoint,
      this.email,
      this.updatedAt,
      this.username,
      this.fullThumbPath,
      this.fullContentPath,
      this.contentType,
      this.avatar,
      this.saleAmount,
      this.saleView,
      this.saleLike});

  ContentData.fromJson(Map<String, dynamic> json) {
    metadata =
        json['metadata'] != null ? Metadata.fromJson(json['metadata']) : null;
    mediaBasePath = json['mediaBasePath'];
    postType = json['postType'];
    mediaUri = json['mediaUri'];
    isLiked = json['isLiked'];
    description = json['description'] ?? '';
    active = json['active'];
    privacy =
        json['privacy'] != null ? Privacy.fromJson(json['privacy']) : null;
    mediaType = json['mediaType'];
    mediaThumbEndPoint = json['mediaThumbEndpoint'];
    postID = json['postID'];
    title = json['title'];
    isViewed = json['isViewed'];
    tags = json['tags'] != null ? json['tags'].cast<String>() : [];
    allowComments = json['allowComments'] ?? false;
    certified = json['certified'] ?? false;
    createdAt = json['createdAt'];
    insight = json['insight'] != null
        ? ContentDataInsight.fromJson(json['insight'])
        : null;
    mediaThumbUri = json['mediaThumbUri'];
    mediaEndpoint = json['mediaEndpoint'];
    email = json['email'];
    updatedAt = json['updatedAt'];
    username = json['username'];
    fullThumbPath = concatThumbUri();
    fullContentPath = concatContentUri();
    contentType = _translateType(mediaType);
    avatar = json['avatar'] != null
        ? UserProfileAvatarModel.fromJson(json['avatar'])
        : null;
    saleAmount = json['saleAmount'] ?? 0;
    saleView = json['saleView'] ?? false;
    saleLike = json['saleLike'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (metadata != null) {
      data['metadata'] = metadata?.toJson();
    }
    data['mediaBasePath'] = mediaBasePath;
    data['postType'] = postType;
    data['mediaUri'] = mediaUri;
    data['isLiked'] = isLiked;
    data['description'] = description;
    data['active'] = active;
    if (privacy != null) {
      data['privacy'] = privacy?.toJson();
    }
    data['mediaType'] = mediaType;
    data['mediaThumbEndpoint'] = mediaThumbEndPoint;
    data['postID'] = postID;
    data['title'] = title;
    data['isViewed'] = isViewed;
    data['tags'] = tags;
    data['allowComments'] = allowComments;
    data['certified'] = certified;
    data['createdAt'] = createdAt;
    if (insight != null) {
      data['insight'] = insight?.toJson();
    }
    data['mediaThumbUri'] = mediaThumbUri;
    data['mediaEndpoint'] = mediaEndpoint;
    data['email'] = email;
    data['updatedAt'] = updatedAt;
    data['username'] = username;
    data['saleAmount'] = saleAmount ?? 0;
    data['saleView'] = saleView ?? false;
    data['saleLike'] = saleLike ?? false;
    if (avatar != null) {
      data['avatar'] = avatar?.toJson();
    }
    return data;
  }

  String? concatThumbUri() {
    print(Env.data.baseUrl +
        (mediaThumbEndPoint ?? mediaEndpoint ?? '') +
        '?x-auth-token=${SharedPreference().readStorage(SpKeys.userToken)}&x-auth-user=${SharedPreference().readStorage(SpKeys.email)}');
    return Env.data.baseUrl +
        (mediaThumbEndPoint ?? mediaEndpoint ?? '') +
        '?x-auth-token=${SharedPreference().readStorage(SpKeys.userToken)}&x-auth-user=${SharedPreference().readStorage(SpKeys.email)}';
  }

  String? concatContentUri() {
    return Env.data.baseUrl + (mediaEndpoint ?? '');
  }

  ContentType? _translateType(String? type) {
    if (type == "video") {
      return ContentType.video;
    } else if (type == "image") {
      return ContentType.image;
    }
    return null;
  }
}

class Metadata {
  int? duration;
  int? postRoll;
  int? preRoll;
  int? midRoll;
  String? postID;
  String? email;

  Metadata({
    this.duration,
    this.postRoll,
    this.preRoll,
    this.midRoll,
    this.postID,
    this.email,
  });

  Metadata.fromJson(Map<String, dynamic> json) {
    duration = json['duration'];
    postRoll = json['postRoll'];
    preRoll = json['preRoll'];
    midRoll = json['midRoll'];
    postID = json['postID'];
    email = json['email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['duration'] = duration;
    data['postRoll'] = postRoll;
    data['preRoll'] = preRoll;
    data['midRoll'] = midRoll;
    data['postID'] = postID;
    data['email'] = email;
    return data;
  }
}
