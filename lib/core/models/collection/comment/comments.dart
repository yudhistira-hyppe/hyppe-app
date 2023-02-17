import 'package:hyppe/core/models/collection/comment/comment_commentor.dart';

class Comments {
  String? postID;
  String? userID;
  dynamic media;
  String? comment;
  String? commentUserID;
  String? cts;
  int? subCommentCount;
  String? commentType;
  dynamic commentTag;
  CommentCommentor? commentor;
  String? commentID;
  int? count;
  List<String?>? reactions = [];
  bool? isReacted;

  Comments(
      {this.postID,
      this.userID,
      this.comment,
      this.media,
      this.commentUserID,
      this.cts,
      this.subCommentCount,
      this.count,
      this.isReacted,
      this.commentType,
      this.commentTag,
      this.commentor,
      this.commentID,
      this.reactions});

  Comments.fromJson(Map<String, dynamic> json) {
    postID = json["postID"] as String?;
    comment = json["comment"] as String?;
    media = json["media"];
    commentUserID = json["commentUserID"] as String?;
    cts = json["cts"] as String?;
    subCommentCount = json["subCommentCount"] as int?;
    count = json["count"] as int?;
    commentType = json["commentType"] as String?;
    commentTag = json["commentTag"];
    isReacted = json['isReacted'];
    if (json["commentor"] != null) commentor = CommentCommentor.fromJson(json["commentor"]);
    commentID = json["commentID"] as String?;
    if (json["reactions"].isNotEmpty) {
      json["reactions"].forEach((v) {
        reactions?.add(v);
      });
    }
  }

  Map toMap() {
    var _result = <String, dynamic>{};
    _result["postID"] = postID;
    _result["userID"] = userID;
    _result["commentUserID"] = commentUserID;
    _result["comment"] = comment;
    _result["commentType"] = commentType;

    return _result;
  }
}
