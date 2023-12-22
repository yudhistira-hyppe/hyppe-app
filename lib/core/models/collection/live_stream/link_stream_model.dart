import '../user_v2/profile/user_profile_avatar_model.dart';

class LinkStreamModel {
  bool? status;
  String? userId;
  int? expireTime;
  String? startLive;
  String? urlStream;
  String? urlIngest;
  String? createAt;
  String? sId;
  UserProfileAvatarModel? avatar;
  int? interest;
  int? totalView;
  int? totalLike;
  int? totalFollower;
  String? username;
  String? fullName;
  String? title;
  String? email;

  LinkStreamModel({
    this.status,
    this.userId,
    this.expireTime,
    this.startLive,
    this.urlStream,
    this.urlIngest,
    this.createAt,
    this.sId,
    this.avatar,
    this.interest,
    this.totalView,
    this.totalLike,
    this.totalFollower,
    this.username,
    this.fullName,
    this.title,
    this.email,
  });

  LinkStreamModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    userId = json['userId'];
    expireTime = json['expireTime'];
    startLive = json['startLive'];
    urlStream = json['urlStream'];
    urlIngest = json['urlIngest'];
    createAt = json['createAt'];
    sId = json['_id'];
    avatar = json['avatar'] != null ? UserProfileAvatarModel.fromJson(json['avatar']) : null;

    interest = json['interest'];
    totalView = json['totalView'];
    totalLike = json['totalLike'];
    totalFollower = json['totalFollower'];
    username = json['username'];
    fullName = json['fullName'];
    title = json['title'];
    email = json['email'];
  }
}
