import 'package:hyppe/core/models/collection/message_v2/message_data_v2.dart';

class ViewersLiveModel {
  String? sId;
  String? email;
  String? fullName;
  String? userAuth;
  String? username;
  Avatar? avatar;
  bool? following;

  ViewersLiveModel({this.sId, this.email, this.fullName, this.userAuth, this.username, this.avatar, this.following});

  ViewersLiveModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    email = json['email'];
    fullName = json['fullName'];
    userAuth = json['userAuth'];
    username = json['username'];
    following = json['following'];
    avatar = json['avatar'] != null ? Avatar.fromJson(json['avatar']) : null;
  }
}
