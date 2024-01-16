// To parse this JSON data, do
//
//     final ViewContent = ViewContentFromJson(jsonString);

import 'dart:convert';

import 'package:hyppe/core/models/collection/comment_v2/comment_data_v2.dart';
import 'package:hyppe/core/models/collection/common/user_badge_model.dart';

List<ViewContent> viewContentFromJson(String str) => List<ViewContent>.from(json.decode(str).map((x) => ViewContent.fromJson(x)));

String viewContentToJson(List<ViewContent> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ViewContent {
  ViewContent({
    this.fullName,
    this.email,
    this.username,
    this.avatar,
    this.urluserBadge,
    this.isFollowing,
  });

  String? fullName;
  String? email;
  String? username;
  Avatar? avatar;
  String? isFollowing;
  UserBadgeModel? urluserBadge;

  factory ViewContent.fromJson(Map<String, dynamic> json) => ViewContent(
        fullName: json["fullName"],
        email: json["email"],
        username: json["username"],
        isFollowing: json["isFollowing"]??'none',
        avatar: json['avatar'] != null ? Avatar.fromJson(json['avatar']) : null,
        urluserBadge:
            json['urluserBadge'] != null && json['urluserBadge'].isNotEmpty
                ? json['urluserBadge'] is List
                    ? UserBadgeModel.fromJson(json['urluserBadge'].first)
                    : UserBadgeModel.fromJson(json['urluserBadge'])
                : null,
      );

  Map<String, dynamic> toJson() => {
        "fullName": fullName,
        "email": email,
        "username": username,
        "isFollowing": isFollowing,
        "avatar": avatar?.toJson(),
        "urluserBadge": urluserBadge?.toJson(),
      };
}
