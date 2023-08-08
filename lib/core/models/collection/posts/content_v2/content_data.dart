import 'dart:typed_data';

import 'package:flutter_aliplayer/flutter_aliplayer.dart';
import 'package:hyppe/core/config/env.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/models/collection/comment_v2/comment_data_v2.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/boosted.dart';
import 'package:hyppe/core/models/collection/transaction/bank_account/transaction_history_model.dart';
import 'package:hyppe/core/models/collection/user_v2/profile/user_profile_avatar_model.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data_insight.dart';

import '../../music/music.dart';

class StoriesGroup {
  List<ContentData>? story;
  String? email;
  String? username;

  StoriesGroup({this.story, this.email, this.username});

  StoriesGroup.fromJson(Map<String, dynamic> json) {
    if (json['story'] != null) {
      story = [];
      if (json['story'].isNotEmpty) {
        json['story'].forEach((v) => story?.add(ContentData.fromJson(v)));
      }
    }
    email = json['email'];
    username = json['username'];
  }
}

class AllContents {
  List<ContentData>? story;

  List<ContentData>? video;

  List<ContentData>? diary;

  List<ContentData>? pict;

  AllContents({this.story, this.video, this.diary, this.pict});

  AllContents.fromJson(Map<String, dynamic> json) {
    if (json['story'] != null) {
      story = [];
      if (json['story'].isNotEmpty) {
        json['story'].forEach((v) => story?.add(ContentData.fromJson(v)));
      }
    } else {
      story = [];
    }

    if (json['diary'] != null) {
      diary = [];
      if (json['diary'].isNotEmpty) {
        json['diary'].forEach((v) => diary?.add(ContentData.fromJson(v)));
      }
    } else {
      diary = [];
    }

    if (json['video'] != null) {
      video = [];
      if (json['video'].isNotEmpty) {
        json['video'].forEach((v) => video?.add(ContentData.fromJson(v)));
      }
    }

    if (json['pict'] != null) {
      pict = [];
      if (json['pict'].isNotEmpty) {
        json['pict'].forEach((v) => pict?.add(ContentData.fromJson(v)));
      }
    }
  }

  Map<String, dynamic> toJson() {
    final result = <String, dynamic>{};

    result['story'] = List<dynamic>.from(story ?? [].map((x) => x.toJson()));
    result['diary'] = List<dynamic>.from(diary ?? [].map((x) => x.toJson()));
    result['video'] = List<dynamic>.from(video ?? [].map((x) => x.toJson()));
    result['pict'] = List<dynamic>.from(pict ?? [].map((x) => x.toJson()));

    return result;
  }
}

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

  bool? isIdVerified;

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

  String? fullContent;

  UserProfileAvatarModel? avatar;

  String? visibility;

  String? location;

  List<Cats>? cats;

  List<TagPeople>? tagPeople;

  int? likes;

  num? saleAmount;

  bool? saleView;

  bool? saleLike;

  bool? isApsara;

  String? apsaraId;

  String? apsaraThumbId;

  Music? music;

  bool? isReport;

  Uint8List? blob;

  List<Boosted> boosted = [];
  int? boostCount;
  int? isBoost;
  int? boostJangkauan;
  String? statusBoost;
  String? reportedStatus;
  String? reportedStatus2;
  int? reportedUserCount;
  MediaModel? media;
  bool? apsara;
  bool? isShared;
  bool? following;
  List<Comment>? comment;
  bool? isDiaryPlay;
  int? comments;
  bool? isNewFollowing;
  bool isLoading = false;
  FlutterAliplayer? fAliplayer;
  FlutterAliplayer? fAliplayerAds;

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
      this.isIdVerified,
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
      this.apsaraThumbId,
      this.isReport,
      this.boosted = const [],
      this.boostCount,
      this.isBoost,
      this.boostJangkauan,
      this.statusBoost,
      this.reportedStatus,
      this.reportedStatus2,
      this.music,
      this.reportedUserCount,
      this.media,
      this.apsara,
      this.isShared,
      this.following,
      this.comment,
      this.isDiaryPlay,
      this.comments,
      this.isNewFollowing,
      this.isLoading = false,
      this.fullContent});

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
    isIdVerified = json['isIdVerified'];
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
    fullContent = concatFullContent();
    fullContentPath = concatContentUri();

    avatar = json['avatar'] != null ? UserProfileAvatarModel.fromJson(json['avatar']) : null;
    location = json['location'] ?? '';
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
    if (json['isApsara'] != null) {
      isApsara = json['isApsara'] ?? false;
    } else {
      isApsara = json['apsara'] ?? false;
    }

    apsaraId = json['apsaraId'] ?? '';
    apsaraThumbId = json['apsaraThumbId'];
    music = json['music'] != null && json['music'].isNotEmpty ? Music.fromJson(json['music']) : null;
    isReport = json['isReport'] ?? false;
    if (json['boosted'] != null) {
      boosted = [];
      json['boosted'].forEach((v) => boosted.add(Boosted.fromJson(v)));
    }
    boostCount = json['boostCount'] ?? 0;
    isBoost = json['isBoost'];
    boostJangkauan = json['boostJangkauan'] ?? 0;
    statusBoost = json['statusBoost'] ?? '';
    reportedStatus = json['reportedStatus'] ?? 'ALL';
    reportedStatus2 = json['reportedStatus'] ?? 'ALL';
    reportedUserCount = json['reportedUserCount'] ?? 0;
    apsara = json['apsara'] ?? false;
    isShared = json['isShared'] ?? true;
    media = json['media'] == null
        ? null
        : json['media'] is List
            ? null
            : MediaModel.fromJSON(json['media']);
    following = json['following'] ?? false;
    if (json['comment'] != null && json['comment'].length > 0) {
      print("json length ${json['postID']} ${json['comment'].length}");
      comment = <Comment>[];
      json['comment'].forEach((v) {
        comment!.add(Comment.fromJson(v));
      });
    } else {
      comment = [];
    }
    isDiaryPlay = false;
    comments = json['comments'] ?? 0;
    isNewFollowing = following ?? false ? false : true;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (metadata != null) {
      data['metadata'] = metadata?.toJson();
    }

    data['mediaBasePath'] = mediaBasePath;
    data['postType'] = postType;
    data['mediaUri'] = mediaUri;
    data['isLiked'] = isLiked ?? false;
    data['description'] = description;
    data['active'] = active;
    if (privacy != null) {
      data['privacy'] = privacy?.toJson();
    }
    data['mediaType'] = mediaType;
    data['mediaThumbEndpoint'] = mediaThumbEndPoint;
    data['postID'] = postID;
    data['isIdVerified'] = isIdVerified;
    data['title'] = title;
    data['isViewed'] = isViewed;
    data['tags'] = tags;
    data['allowComments'] = allowComments;
    data['certified'] = certified ?? false;
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
    if (data['isApsara'] != null) {
      data['isApsara'] = isApsara;
    } else {
      data['apsara'] = isApsara;
    }

    data['apsaraId'] = apsaraId;
    data['apsaraThumbId'] = apsaraThumbId;
    if (music != null) {
      data['music'] = music!.toJson();
    }

    data['isLoading'] = isLoading;

    return data;
  }

  String? concatThumbUri() {
    final fixMedia = mediaThumbEndPoint ?? mediaEndpoint ?? '';
    if (fixMedia.isNotEmpty) {
      return Env.data.baseUrl + "${Env.data.versionApi}" + fixMedia + '?x-auth-token=${SharedPreference().readStorage(SpKeys.userToken)}&x-auth-user=${SharedPreference().readStorage(SpKeys.email)}';
    } else {
      return fixMedia;
    }
  }

  String? concatFullContent() {
    final fixMedia = mediaEndpoint ?? '';
    if (fixMedia.isNotEmpty) {
      return Env.data.baseUrl + "${Env.data.versionApi}" + fixMedia + '?x-auth-token=${SharedPreference().readStorage(SpKeys.userToken)}&x-auth-user=${SharedPreference().readStorage(SpKeys.email)}';
    } else {
      return fixMedia;
    }
  }

  String? concatContentUri() {
    final fixMedia = mediaEndpoint ?? '';
    if (fixMedia.isNotEmpty) {
      return Env.data.baseUrl + "${Env.data.versionApi}" + (mediaEndpoint ?? '');
    } else {
      return '';
    }
  }

  // Future getBlob()async{
  //   final _postID = postID;
  //   if(_postID != null && !(apsara ?? true)){
  //     final data =  await globalDB.getThumbnail(_postID);
  //     if(data != null){
  //       blob = data.thumbnail;
  //     }
  //   }
  // }
}

class Metadata {
  int? duration;

  int? postRoll;

  int? preRoll;

  int? midRoll;

  String? postID;

  String? email;

  int? width;

  int? height;

  Metadata({this.duration, this.postRoll, this.preRoll, this.midRoll, this.postID, this.email, this.width, this.height});

  Metadata.fromJson(Map<String, dynamic> json) {
    duration = json['duration'];
    postRoll = json['postRoll'];
    preRoll = json['preRoll'];
    midRoll = json['midRoll'];
    postID = json['postID'];
    email = json['email'];
    width = json['width'];
    height = json['height'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['duration'] = duration;
    data['postRoll'] = postRoll;
    data['preRoll'] = preRoll;
    data['midRoll'] = midRoll;
    data['postID'] = postID;
    data['email'] = email;
    data['width'] = width;
    data['height'] = height;
    return data;
  }
}

class Privacy {
  bool? isPostPrivate;

  bool? isCelebrity;

  bool? isPrivate;

  bool? isIdVerified;

  Privacy({
    this.isPrivate,
    this.isCelebrity,
    this.isPostPrivate,
    this.isIdVerified,
  });

  Privacy.fromJson(Map<String, dynamic> json) {
    isPostPrivate = json['isPostPrivate'];
    isCelebrity = json['isCelebrity'];
    isPrivate = json['isPrivate'];
    isIdVerified = json['isIdVerified'] ?? false;
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

class TagPeople {
  String? email;

  String? username;

  String? status;

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

class Comment {
  String? sId;
  String? disqusID;
  int? sequenceNumber;
  String? sender;
  String? receiver;
  bool? active;
  String? postType;
  String? txtMessages;
  String? postID;
  String? createdAt;
  String? updatedAt;
  List<Medias>? medias;
  String? sClass;
  int? iV;
  UserComment? userComment;

  Comment(
      {this.sId,
      this.disqusID,
      this.sequenceNumber,
      this.sender,
      this.receiver,
      this.active,
      this.postType,
      this.txtMessages,
      this.postID,
      this.createdAt,
      this.updatedAt,
      this.medias,
      this.sClass,
      this.iV,
      this.userComment});

  Comment.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    disqusID = json['disqusID'];
    sequenceNumber = json['sequenceNumber'];
    sender = json['sender'];
    receiver = json['receiver'];
    active = json['active'];
    postType = json['postType'];
    txtMessages = json['txtMessages'];
    postID = json['postID'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    if (json['medias'] != null) {
      medias = <Medias>[];
      json['medias'].forEach((v) {
        medias!.add(Medias.fromJson(v));
      });
    }

    sClass = json['_class'];
    iV = json['__v'];
    userComment = json['userComment'] != null ? new UserComment.fromJson(json['userComment']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['disqusID'] = disqusID;
    data['sequenceNumber'] = sequenceNumber;
    data['sender'] = sender;
    data['receiver'] = receiver;
    data['active'] = active;
    data['postType'] = postType;
    data['txtMessages'] = txtMessages;
    data['postID'] = postID;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    if (medias != null) {
      data['medias'] = medias!.map((v) => v.toJson()).toList();
    }
    data['_class'] = sClass;
    data['__v'] = iV;
    if (userComment != null) {
      data['userComment'] = userComment!.toJson();
    }
    return data;
  }
}

class Medias {
  String? createdAt;
  String? postType;
  String? description;
  bool? active;
  String? mediaType;
  String? mediaThumbEndpoint;
  String? postID;
  bool? apsara;
  String? apsaraId;

  Medias({this.createdAt, this.postType, this.description, this.active, this.mediaType, this.mediaThumbEndpoint, this.postID, this.apsara, this.apsaraId});

  Medias.fromJson(Map<String, dynamic> json) {
    createdAt = json['createdAt'];
    postType = json['postType'];
    description = json['description'];
    active = json['active'];
    mediaType = json['mediaType'];
    mediaThumbEndpoint = json['mediaThumbEndpoint'];
    postID = json['postID'];
    apsara = json['apsara'];
    apsaraId = json['apsaraId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['createdAt'] = createdAt;
    data['postType'] = postType;
    data['description'] = description;
    data['active'] = active;
    data['mediaType'] = mediaType;
    data['mediaThumbEndpoint'] = mediaThumbEndpoint;
    data['postID'] = postID;
    data['apsara'] = apsara;
    data['apsaraId'] = apsaraId;
    return data;
  }
}

class UserComment {
  String? sId;
  String? username;

  UserComment({this.sId, this.username});

  UserComment.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    username = json['username'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['username'] = username;
    return data;
  }
}
