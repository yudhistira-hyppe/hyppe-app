import 'package:hive/hive.dart';
import 'package:hyppe/core/config/env.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/models/collection/comment_v2/comment_data_v2.dart';
import 'package:hyppe/core/models/collection/user_v2/profile/user_profile_avatar_model.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data_insight.dart';

import '../../music/music.dart';

part 'content_data.g.dart';

@HiveType(typeId: 0)
class AllContents extends HiveObject {
  @HiveField(0)
  List<ContentData>? story;

  @HiveField(1)
  List<ContentData>? video;

  @HiveField(2)
  List<ContentData>? diary;

  @HiveField(3)
  List<ContentData>? pict;

  AllContents({this.story, this.video, this.diary, this.pict});

  AllContents.fromJson(Map<String, dynamic> json) {
    if (json['story'] != null) {
      story = [];
      if(json['story'].isNotEmpty){
        json['story'].forEach((v) => story?.add(ContentData.fromJson(v)));
      }
    }

    if (json['diary'] != null) {
      diary = [];
      if(json['diary'].isNotEmpty){
        json['diary'].forEach((v) => diary?.add(ContentData.fromJson(v)));
      }
    }

    if (json['video'] != null) {
      video = [];
      if(json['video'].isNotEmpty){
        json['video'].forEach((v) => video?.add(ContentData.fromJson(v)));
      }

    }

    if (json['pict'] != null) {
      pict = [];
      if(json['pict'].isNotEmpty){
        json['pict'].forEach((v) => pict?.add(ContentData.fromJson(v)));
      }
    }
  }

  Map<String, dynamic> toJson() {
    final result = <String, dynamic>{};

    result['story'] = List<dynamic>.from(story??[].map((x) => x.toJson()));
    result['diary'] = List<dynamic>.from(diary??[].map((x) => x.toJson()));
    result['video'] = List<dynamic>.from(video??[].map((x) => x.toJson()));
    result['pict'] = List<dynamic>.from(pict??[].map((x) => x.toJson()));

    return result;
  }
}

@HiveType(typeId: 1)
class ContentData extends HiveObject {
  @HiveField(0)
  Metadata? metadata;

  @HiveField(1)
  String? mediaBasePath;

  @HiveField(2)
  String? postType;

  @HiveField(3)
  String? mediaUri;

  @HiveField(4)
  bool? isLiked;

  @HiveField(5)
  String? description;

  @HiveField(6)
  bool? active;

  @HiveField(7)
  Privacy? privacy;

  @HiveField(8)
  String? mediaType;

  @HiveField(9)
  String? mediaThumbEndPoint;

  @HiveField(10)
  String? postID;

  @HiveField(11)
  String? title;

  @HiveField(12)
  bool? isViewed;

  @HiveField(13)
  List<String>? tags;

  @HiveField(14)
  bool? allowComments;

  @HiveField(15)
  bool? certified;

  @HiveField(16)
  String? createdAt;

  @HiveField(17)
  ContentDataInsight? insight;

  @HiveField(18)
  String? mediaThumbUri;

  @HiveField(19)
  String? mediaEndpoint;

  @HiveField(20)
  String? email;

  @HiveField(21)
  String? updatedAt;

  @HiveField(22)
  String? username;

  @HiveField(23)
  String? fullThumbPath;

  @HiveField(24)
  String? fullContentPath;

  @HiveField(25)
  UserProfileAvatarModel? avatar;

  @HiveField(26)
  String? visibility;

  @HiveField(27)
  String? location;

  @HiveField(28)
  List<Cats>? cats;

  @HiveField(29)
  List<TagPeople>? tagPeople;

  @HiveField(30)
  int? likes;

  @HiveField(31)
  num? saleAmount;

  @HiveField(32)
  bool? saleView;

  @HiveField(33)
  bool? saleLike;

  @HiveField(34)
  bool? isApsara;

  @HiveField(35)
  String? apsaraId;

  Music? music;

  bool? isReport;

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
      this.avatar,
      this.location,
      this.visibility,
      this.cats,
      this.tagPeople,
      this.likes,
      this.saleAmount,
      this.saleView,
      this.saleLike,
      this.isApsara,
      this.apsaraId,
      this.music,
      this.isReport});

  ContentData.fromJson(Map<String, dynamic> json) {
    metadata = json['metadata'] != null ? Metadata.fromJson(json['metadata']) : null;
    mediaBasePath = json['mediaBasePath'];
    postType = json['postType'];
    mediaUri = json['mediaUri'];
    isLiked = json['isLiked'] ?? false;
    description = json['description'] ?? '';
    active = json['active'] ?? false;
    privacy = json['privacy'] != null ? Privacy.fromJson(json['privacy']) : null;
    mediaType = json['mediaType'];
    mediaThumbEndPoint = json['mediaThumbEndpoint'];
    postID = json['postID'];
    title = json['title'];
    isViewed = json['isViewed'] ?? false;
    tags = json['tags'] != null ? json['tags'].cast<String>() : [];
    allowComments = json['allowComments'] ?? false;
    certified = json['saleAmount'] != null
        ? json['saleAmount'] > 0
            ? true
            : json['certified'] ?? false
        : false;
    createdAt = json['createdAt'];
    insight = json['insight'] != null ? ContentDataInsight.fromJson(json['insight'], isLike: isLiked ?? false) : null;
    mediaThumbUri = json['mediaThumbUri'];
    mediaEndpoint = json['mediaEndpoint'];
    email = json['email'];
    updatedAt = json['updatedAt'];
    username = json['username'] ?? '';
    fullThumbPath = concatThumbUri();
    fullContentPath = concatContentUri();

    avatar = json['avatar'] != null ? UserProfileAvatarModel.fromJson(json['avatar']) : null;
    location = json['location'];
    visibility = json['visibility'];
    if (json['cats'] != null) {
      cats = [];
      json['cats'].forEach((v) => cats?.add(Cats.fromJson(v)));
    }
    tagPeople = json['tagPeople'] != null ? List<TagPeople>.from(json["tagPeople"].map((x) => TagPeople.fromJson(x))) : [];
    if (json['likes'] != null) {
      likes = json['likes'];
    }
    // cats = List<Cats>.from(json["cats"].map((x) => Cats.fromJson(x)));

    avatar = json['avatar'] != null ? UserProfileAvatarModel.fromJson(json['avatar']) : null;
    saleAmount = json['saleAmount'] ?? 0;
    saleView = json['saleView'] ?? false;
    saleLike = json['saleLike'] ?? false;
    isApsara = json['isApsara'] ?? false;
    apsaraId = json['apsaraId'] ?? '';
    music = json['music'] != null ? Music.fromJson(json['music']) : null;
    isReport = json['isReport'] ?? false;
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
    data['location'] = location;
    data['visibility'] = visibility;
    data['tagPeople'] = List<dynamic>.from((tagPeople ?? []).map((x) => x.toJson()));
    data['likes'] = likes;
    data['isApsara'] = isApsara;
    data['apsaraId'] = apsaraId;
    if(music != null){
      data['music'] = music!.toJson();
    }

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
}

@HiveType(typeId: 2)
class Metadata {
  @HiveField(0)
  int? duration;

  @HiveField(1)
  int? postRoll;

  @HiveField(2)
  int? preRoll;

  @HiveField(3)
  int? midRoll;

  @HiveField(4)
  String? postID;

  @HiveField(5)
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

@HiveType(typeId: 4)
class Privacy {
  @HiveField(0)
  bool? isPostPrivate;

  @HiveField(1)
  bool? isCelebrity;

  @HiveField(2)
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
@HiveType(typeId: 7)
class Cats extends HiveObject {
  @HiveField(0)
  String? id;

  @HiveField(1)
  String? interestName;

  @HiveField(2)
  String? langIso;

  @HiveField(3)
  String? icon;

  @HiveField(4)
  String? createdAt;

  @HiveField(5)
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

@HiveType(typeId: 8)
class TagPeople extends HiveObject {
  @HiveField(0)
  String? email;

  @HiveField(1)
  String? username;

  @HiveField(2)
  String? status;

  @HiveField(3)
  Avatar? avatar;

  TagPeople({this.email, this.username, this.status, this.avatar});

  TagPeople.fromJson(Map<String, dynamic> json) {
    email = json["email"];
    username = json["username"];
    status = json["status"];
    avatar = json['avatar'] != null ? Avatar.fromJson(json['avatar']) : null;
  }

  Map<String, dynamic> toJson() => {
        "email": email,
        "username": username,
        "status": status,
        "avatar": avatar != null ? avatar?.toJson() : '',
      };
}
