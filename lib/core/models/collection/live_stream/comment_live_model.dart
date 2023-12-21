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

  CommentLiveModel({this.sId, this.email, this.fullName, this.userAuth, this.username, this.avatar, this.idStream, this.messages});

  CommentLiveModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    email = json['email'];
    fullName = json['fullName'];
    userAuth = json['userAuth'];
    username = json['username'];
    avatar = json['avatar'] != null ? Avatar.fromJson(json['avatar']) : null;
    idStream = json['idStream'];
    messages = json['messages'];
  }
}

class CountLikeLiveModel {
  String? idStream;
  int? likeCount;

  CountLikeLiveModel({this.idStream, this.likeCount});

  CountLikeLiveModel.fromJson(Map<String, dynamic> json) {
    idStream = json['idStream'];
    likeCount = json['likeCount'];
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

  StatusStreamLiveModel({this.idStream, this.pause});

  StatusStreamLiveModel.fromJson(Map<String, dynamic> json) {
    idStream = json['idStream'];
    pause = json['pause'];
  }
}
