// To parse this JSON data, do
//
//     final ViewContent = ViewContentFromJson(jsonString);

import 'dart:convert';

import 'package:hyppe/core/models/collection/comment_v2/comment_data_v2.dart';

List<ViewContent> viewContentFromJson(String str) => List<ViewContent>.from(json.decode(str).map((x) => ViewContent.fromJson(x)));

String viewContentToJson(List<ViewContent> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ViewContent {
  ViewContent({
    this.fullName,
    this.email,
    this.username,
    this.avatar,
  });

  String? fullName;
  String? email;
  String? username;
  Avatar? avatar;

  factory ViewContent.fromJson(Map<String, dynamic> json) => ViewContent(
        fullName: json["fullName"],
        email: json["email"],
        username: json["username"],
        avatar: Avatar.fromJson(json["avatar"]),
      );

  Map<String, dynamic> toJson() => {
        "fullName": fullName,
        "email": email,
        "username": username,
        "avatar": avatar?.toJson(),
      };
}
