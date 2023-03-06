import 'dart:convert';

import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';

SearchContentModel searchContentFromJson(String str) =>
    SearchContentModel.fromJson(json.decode(str));

// String searchContentToJson(SearchContentModel data) => json.encode(data.toJson());

class SearchContentModel {
  SearchContentModel({
    this.users,
    this.tags,
    this.vid,
    this.diary,
    this.pict,
  });

  List<DataUser>? users;
  List<Tags>? tags;
  List<ContentData>? vid;
  List<ContentData>? diary;
  List<ContentData>? pict;

  factory SearchContentModel.fromJson(Map<String, dynamic> json) =>
      SearchContentModel(
        tags: List<Tags>.from(json['tags'].map((x) => Tags.fromJson(x))),
        users:
            List<DataUser>.from(json["user"].map((x) => DataUser.fromJson(x))),
        vid: List<ContentData>.from(
            json["vid"].map((x) => ContentData.fromJson(x))),
        diary: List<ContentData>.from(
            json["diary"].map((x) => ContentData.fromJson(x))),
        pict: List<ContentData>.from(
            json["picts"].map((x) => ContentData.fromJson(x))),
      );
}

class Diary {
  Diary({
    this.data,
    this.totalFilter,
    this.skip,
    this.limit,
  });

  List<ContentData>? data;
  int? totalFilter;
  int? skip;
  int? limit;

  factory Diary.fromJson(Map<String, dynamic> json) => Diary(
        data: List<ContentData>.from(
            json["data"].map((x) => ContentData.fromJson(x))),
        totalFilter: json["totalFilter"],
        skip: json["skip"],
        limit: json["limit"],
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from((data ?? []).map((x) => x.toJson())),
        "totalFilter": totalFilter,
        "skip": skip,
        "limit": limit,
      };
}

class Tags {
  String? id;
  String? tag;
  int? total;
  Tags({
    this.id,
    this.tag,
    this.total,
  });

  factory Tags.fromJson(Map<String, dynamic> json) => Tags(
        id: json['_id'],
        tag: json["tag"] ?? json['nama'],
        total: json["total"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "tag": tag,
        "total": total,
      };
}

class Interest{
  String? id;
  String? interestName;
  String? langIso;
  String? icon;
  String? createdAt;
  String? updatedAt;
  String? interestNameId;
  String? thumbnail;
  int? total;

  Interest({
    this.id,
    this.interestName,
    this.langIso,
    this.icon,
    this.createdAt,
    this.updatedAt,
    this.interestNameId,
    this.thumbnail,
    this.total
  });

  Interest.fromJson(Map<String, dynamic> map){
    id = map['_id'];
    interestName = map['interestName'];
    langIso = map['langIso'];
    icon = map['icon'];
    createdAt = map['createAt'];
    updatedAt = map['updatedAt'];
    interestNameId = map['interestNameId'];
    thumbnail = map['thumbnail'];
    total = map['total'];
  }

  Map<String, dynamic> toJson(){
    final result = <String, dynamic>{};
    result['id'] = id;
    result['interestName'] = interestName;
    result['langIso'] = langIso;
    result['icon'] = icon;
    result['createdAt'] = createdAt;
    result['updatedAt'] = updatedAt;
    result['interestNameId'] = interestNameId;
    result['thumbnail'] = thumbnail;
    result['total'] = total;
    return result;
  }

}

class Users {
  Users({
    this.data,
  });

  List<DataUser>? data;

  factory Users.fromJson(Map<String, dynamic> json) => Users(
        data:
            List<DataUser>.from(json["data"].map((x) => DataUser.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data ?? [].map((x) => x.toJson())),
      };
}

class DataUser {
  DataUser({
    this.id,
    this.avatar,
    this.idUserAuth,
    this.username,
    this.fullName,
    this.email,
    this.statusEN,
    this.statusID
  });

  String? id;
  List<Avatar>? avatar;
  String? idUserAuth;
  String? username;
  String? fullName;
  String? email;
  String? statusEN;
  String? statusID;

  factory DataUser.fromJson(Map<String, dynamic> json) => DataUser(
        id: json["_id"],
        avatar: json['avatar'] != null
            ? List<Avatar>.from(json["avatar"].map((x) => Avatar.fromJson(x)))
            : null,
        idUserAuth: json["idUserAuth"],
        username: json["username"],
        fullName: json["fullName"],
        email: json["email"],
        statusEN: json['statusEN'],
        statusID: json['statusID']
      );

  // Map<String, dynamic> toJson() => {
  //       "_id": id,
  //       "avatar": avatar?.toJson(),
  //       "idUserAuth": idUserAuth,
  //       "username": username,
  //       "fullName": fullName,
  //       "email": email,
  //     };
}

class Avatar {
  Avatar({
    this.mediaBasePath,
    this.mediaUri,
    this.mediaType,
    this.mediaEndpoint,
  });

  String? mediaBasePath;
  String? mediaUri;
  String? mediaType;
  String? mediaEndpoint;

  factory Avatar.fromJson(Map<String, dynamic> json) => Avatar(
        mediaBasePath:
            json["mediaBasePath"] == null ? null : json["mediaBasePath"],
        mediaUri: json["mediaUri"] == null ? null : json["mediaUri"],
        mediaType: json["mediaType"] == null ? null : json["mediaType"],
        mediaEndpoint:
            json["mediaEndpoint"] == null ? null : json["mediaEndpoint"],
      );

  Map<String, dynamic> toJson() => {
        "mediaBasePath": mediaBasePath == null ? null : mediaBasePath,
        "mediaUri": mediaUri == null ? null : mediaUri,
        "mediaType": mediaType == null ? null : mediaType,
        "mediaEndpoint": mediaEndpoint == null ? null : mediaEndpoint,
      };
}
