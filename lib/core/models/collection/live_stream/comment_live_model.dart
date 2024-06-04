import 'package:hyppe/core/models/collection/message_v2/message_data_v2.dart';

class CommentLiveModel {
  String? sId;
  String? email;
  String? fullName;
  String? userAuth;
  String? username;
  Avatar? avatar;
  String? idStream;
  String? messages;
  String? idComment;
  bool? pinned;
  String? commentType;
  String? idGift;
  String? urlGiftThum;
  String? urlGift;

  CommentLiveModel({
    this.sId,
    this.email,
    this.fullName,
    this.userAuth,
    this.username,
    this.avatar,
    this.idStream,
    this.messages,
    this.idComment,
    this.commentType,
    this.idGift,
    this.urlGiftThum,
    this.urlGift,
    this.pinned,
  });

  CommentLiveModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    email = json['email'];
    fullName = json['fullName'];
    userAuth = json['userAuth'];
    username = json['username'];
    avatar = json['avatar'] != null ? Avatar.fromJson(json['avatar']) : null;
    idStream = json['idStream'];
    messages = json['messages'];
    idComment = json['idComment'];
    commentType = json['commentType'];
    idGift = json['idGift'];
    urlGiftThum = json['urlGiftThum'];
    urlGift = json['urlGift'];
    pinned = json['pinned'] ?? false;
  }
}

class CountLikeLiveModel {
  String? idStream;
  int? likeCount;
  String? userId;
  int? likeCountTotal;

  CountLikeLiveModel({this.idStream, this.likeCount, this.userId, this.likeCountTotal});

  CountLikeLiveModel.fromJson(Map<String, dynamic> json) {
    idStream = json['idStream'];
    likeCount = json['likeCount'];
    userId = json['userId'];
    likeCountTotal = json['likeCountTotal'];
  }
}

class CountViewLiveModel {
  String? idStream;
  int? viewCount;

  CountViewLiveModel({this.idStream, this.viewCount});

  CountViewLiveModel.fromJson(Map<String, dynamic> json) {
    idStream = json['idStream'];
    viewCount = json['viewCount'];
  }
}

class StatusStreamLiveModel {
  String? idStream;
  bool? pause;
  bool? status;
  int? totalViews;
  String? datePelanggaran;

  StatusStreamLiveModel({this.idStream, this.pause, this.status, this.totalViews, this.datePelanggaran});

  StatusStreamLiveModel.fromJson(Map<String, dynamic> json) {
    idStream = json['idStream'];
    pause = json['pause'];
    status = json['status'];
    datePelanggaran = json['datePelanggaran'];
    totalViews = json['totalViews'] ?? 0;
  }
}

class StatusCommentLiveModel {
  String? idStream;
  bool? comment;

  StatusCommentLiveModel({this.idStream, this.comment});

  StatusCommentLiveModel.fromJson(Map<String, dynamic> json) {
    idStream = json['idStream'];
    comment = json['comment'];
  }
}
