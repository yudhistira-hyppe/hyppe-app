import 'package:hyppe/core/models/collection/bookmark/bookmark_data.dart';

class Bookmark {
  int? count;
  int? statusCode;
  String? message;
  String? postID;
  String? playlistID;
  String? featureType;
  String? contentID;
  List<BookmarkData> data = [];

  Bookmark(
      {this.statusCode,
        this.message,
        this.count,
        this.postID,
        this.playlistID,
        this.featureType,
        this.contentID,
        this.data = const []});

  Bookmark.fromJson(Map<String, dynamic> json) {
    statusCode = json["statusCode"];
    message = json["message"];
    count = json["count"];

    if (json["data"] == null && json["data"].isEmpty) {
      data = [];
    } else {
      json["data"].forEach((v) {
        data.add(BookmarkData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json["playlistID"] = playlistID;
    json["contentID"] = contentID;
    json["contentType"] = featureType;
    return json;
  }
}