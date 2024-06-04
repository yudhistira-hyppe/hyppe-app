import 'package:hyppe/core/models/collection/comment_v2/comment_data_v2.dart';
import 'package:hyppe/core/models/collection/live_stream/comment_live_model.dart';

class StreamingModel {
  String? sId;
  String? title;
  String? userId;
  int? expireTime;
  String? startLive;
  bool? status;
  bool? pause;
  String? urlStream;
  String? urlIngest;
  String? createAt;
  String? endLive;

  bool? commentDisabled;
  int? viewCountActive;
  String? url;
  String? textUrl;
  String? tokenAgora;
  String? pauseDate;
  List<CommentLiveModel>? comment;
  List<CommentLiveModel>? commentAll;
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
    this.commentAll,
    this.textUrl,
    this.tokenAgora,
    this.pauseDate,
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
    pause = json['pause'];
    urlStream = json['urlStream'];
    urlIngest = json['urlIngest'];
    createAt = json['createAt'];
    endLive = json['endLive'];
    commentDisabled = json['commentDisabled'];
    viewCountActive = json['viewCountActive'] ?? 0;
    url = json['url'];
    textUrl = json['textUrl'];
    tokenAgora = json['tokenAgora'];
    pauseDate = json['pauseDate'];
    if (json['comment'] != null) {
      comment = <CommentLiveModel>[];
      json['comment'].forEach((v) {
        comment!.add(CommentLiveModel.fromJson(v));
      });
    }
    if (json['commentAll'] != null) {
      commentAll = <CommentLiveModel>[];
      json['commentAll'].forEach((v) {
        commentAll!.add(CommentLiveModel.fromJson(v));
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
  bool? giftActivation;
  Avatar? avatar;

  User({
    this.sId,
    this.email,
    this.fullName,
    this.username,
    this.giftActivation,
    this.avatar,
  });

  User.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    email = json['email'];
    fullName = json['fullName'];
    username = json['username'];
    giftActivation = json['GiftActivation'];
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
