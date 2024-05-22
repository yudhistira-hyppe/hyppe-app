import 'package:hyppe/core/models/collection/comment_v2/comment_data_v2.dart';

class ListGiftModel {
  int? count;
  String? sId;
  String? giftId;
  String? name;
  String? thumbnail;
  String? typeGift;
  String? userId;
  String? fullName;
  String? username;
  String? email;
  Avatar? avatar;

  ListGiftModel({
    this.count,
    this.sId,
    this.giftId,
    this.name,
    this.thumbnail,
    this.typeGift,
    this.userId,
    this.fullName,
    this.username,
    this.email,
    this.avatar,
  });

  ListGiftModel.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    sId = json['_id'];
    giftId = json['giftId'];
    name = json['name'];
    thumbnail = json['thumbnail'];
    typeGift = json['typeGift'];
    userId = json['userId'];
    fullName = json['fullName'];
    username = json['username'];
    email = json['email'];
    avatar = json['avatar'] != null ? Avatar.fromJson(json['avatar']) : null;
  }
}
