import 'package:hyppe/core/config/env.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
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
  String? visibility;
  String? location;
  List<Cats>? cats;
  List<String>? tagPeople;

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
      this.location,
      this.visibility,
      this.cats,
      this.tagPeople});

  ContentData.fromJson(Map<String, dynamic> json) {
    metadata = json['metadata'] != null ? Metadata.fromJson(json['metadata']) : null;
    mediaBasePath = json['mediaBasePath'];
    postType = json['postType'];
    mediaUri = json['mediaUri'];
    isLiked = json['isLiked'];
    description = json['description'] ?? '';
    active = json['active'];
    privacy = json['privacy'] != null ? Privacy.fromJson(json['privacy']) : null;
    mediaType = json['mediaType'];
    mediaThumbEndPoint = json['mediaThumbEndpoint'];
    postID = json['postID'];
    title = json['title'];
    isViewed = json['isViewed'];
    tags = json['tags'] != null ? json['tags'].cast<String>() : [];
    allowComments = json['allowComments'] ?? false;
    certified = json['certified'] ?? false;
    createdAt = json['createdAt'];
    insight = json['insight'] != null ? ContentDataInsight.fromJson(json['insight']) : null;
    mediaThumbUri = json['mediaThumbUri'];
    mediaEndpoint = json['mediaEndpoint'];
    email = json['email'];
    updatedAt = json['updatedAt'];
    username = json['username'];
    fullThumbPath = concatThumbUri();
    fullContentPath = concatContentUri();
    contentType = _translateType(mediaType);
    avatar = json['avatar'] != null ? UserProfileAvatarModel.fromJson(json['avatar']) : null;
    location = json['location'];
    visibility = json['visibility'];
    if (json['cats'] != null) {
      cats = [];
      json['cats'].forEach((v) => cats!.add(Cats.fromJson(v)));
    }
    tagPeople = json['tagPeople'] != null ? json['tagPeople'].cast<String>() : [];
    // cats = List<Cats>.from(json["cats"].map((x) => Cats.fromJson(x)));
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
    if (avatar != null) {
      data['avatar'] = avatar?.toJson();
    }
    data['location'] = location;
    data['visibility'] = visibility;
    data['tagPeople'] = tagPeople;

    return data;
  }

  String? concatThumbUri() {
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

class Privacy {
  bool? isPostPrivate;
  bool? isCelebrity;
  bool? isPrivate;

  Privacy({
    this.isPrivate,
    this.isCelebrity,
    this.isPostPrivate,
  });

  Privacy.fromJson(Map<String, dynamic> json) {
    isPostPrivate = json['isPostPrivate'];
    isCelebrity = json['isCelebrity'];
    isPrivate = json['isPrivate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['isPostPrivate'] = isPostPrivate;
    data['isCelebrity'] = isCelebrity;
    data['isPrivate'] = isPrivate;
    return data;
  }
}

//Category
class Cats {
  String? id;
  String? interestName;
  String? langIso;
  String? icon;
  String? createdAt;
  String? updatedAt;

  Cats({this.id, this.interestName, this.langIso, this.icon, this.createdAt, this.updatedAt});

  Cats.fromJson(Map<String, dynamic> json) {
    id = json["_id"];
    interestName = json["interestName"];
    langIso = json["langIso"];
    icon = json["icon"];
    createdAt = json["createdAt"];
    updatedAt = json["updatedAt"];
  }
}
