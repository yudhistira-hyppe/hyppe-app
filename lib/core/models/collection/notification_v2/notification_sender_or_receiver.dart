import 'package:hyppe/core/models/collection/notification_v2/notification_avatar.dart';

class NotificationSenderOrReceiverInfoModel {
  String? fullName;
  NotificationAvatarModel? avatar;
  String? email;
  String? username;

  NotificationSenderOrReceiverInfoModel({
    this.fullName,
    this.avatar,
    this.email,
    this.username,
  });

  NotificationSenderOrReceiverInfoModel.fromJson(Map<String, dynamic> json) {
    fullName = json['fullName'];
    avatar = json['avatar'] != null ? NotificationAvatarModel.fromJson(json['avatar']) : null;
    email = json['email'];
    username = json['username'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['fullName'] = fullName;
    if (avatar != null) data['avatar'] = avatar?.toJson();
    data['email'] = email;
    data['username'] = username;
    return data;
  }
}
