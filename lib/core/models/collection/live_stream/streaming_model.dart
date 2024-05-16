import 'package:hyppe/core/models/collection/comment_v2/comment_data_v2.dart';
import 'package:hyppe/core/models/collection/live_stream/comment_live_model.dart';

class StreamingModel {
  String? sId;
  String? title;
  String? userId;
  int? expireTime;
  String? startLive;
  bool? status;
  String? urlStream;
  String? urlIngest;
  String? createAt;
  String? endLive;
  bool? pause;
  bool? commentDisabled;
  int? viewCountActive;
  String? url;
  String? textUrl;
  List<CommentLiveModel>? comment;
  List<String>? reportRemark;
  User? user;

  StreamingModel({
    this.sId,
    this.title,
    this.userId,
    this.expireTime,
    this.startLive,
    this.status,
    this.urlStream,
    this.urlIngest,
    this.createAt,
    this.endLive,
    this.pause,
    this.commentDisabled,
    this.viewCountActive,
    this.url,
    this.comment,
    this.textUrl,
    this.reportRemark,
    this.user,
  });

  StreamingModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    title = json['title'];
    userId = json['userId'];
    expireTime = json['expireTime'];
    startLive = json['startLive'];
    status = json['status'];
    urlStream = json['urlStream'];
    urlIngest = json['urlIngest'];
    createAt = json['createAt'];
    endLive = json['endLive'];
    pause = json['pause'];
    commentDisabled = json['commentDisabled'];
    viewCountActive = json['viewCountActive'] ?? 0;
    url = json['url'];
    textUrl = json['textUrl'];
    if (json['comment'] != null) {
      comment = <CommentLiveModel>[];
      json['comment'].forEach((v) {
        comment!.add(CommentLiveModel.fromJson(v));
      });
    }
    if (json['reportRemark'] != null) {
      reportRemark = json['reportRemark'].cast<String>();
    }
    user = json['user'] != null ? User.fromJson(json['user']) : null;
  }
}

class User {
  String? sId;
  String? email;
  String? fullName;
  String? username;
  Avatar? avatar;

  User({this.sId, this.email, this.fullName, this.username, this.avatar});

  User.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    email = json['email'];
    fullName = json['fullName'];
    username = json['username'];
    avatar = json['avatar'] != null ? Avatar.fromJson(json['avatar']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['email'] = email;
    data['fullName'] = fullName;
    data['username'] = username;
    if (avatar != null) {
      data['avatar'] = avatar!.toJson();
    }
    return data;
  }
}
