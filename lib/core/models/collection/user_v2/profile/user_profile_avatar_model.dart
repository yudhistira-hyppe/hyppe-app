import 'package:hive/hive.dart';

part 'user_profile_avatar_model.g.dart';

@HiveType(typeId: 6)
class UserProfileAvatarModel extends HiveObject {
  @HiveField(0)
  String? createdAt;

  @HiveField(1)
  String? mediaBasePath;

  @HiveField(2)
  String? mediaUri;

  @HiveField(3)
  bool? active;

  @HiveField(4)
  String? mediaType;

  @HiveField(5)
  String? mediaEndpoint;

  @HiveField(6)
  String? updatedAt;

  UserProfileAvatarModel({this.createdAt, this.mediaBasePath, this.mediaUri, this.active, this.mediaType, this.mediaEndpoint, this.updatedAt});

  UserProfileAvatarModel.fromJson(Map<String, dynamic> json) {
    createdAt = json['createdAt'];
    mediaBasePath = json['mediaBasePath'];
    mediaUri = json['mediaUri'];
    active = json['active'];
    mediaType = json['mediaType'];
    mediaEndpoint = json['mediaEndpoint'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['createdAt'] = createdAt;
    data['mediaBasePath'] = mediaBasePath;
    data['mediaUri'] = mediaUri;
    data['active'] = active;
    data['mediaType'] = mediaType;
    data['mediaEndpoint'] = mediaEndpoint;
    data['updatedAt'] = updatedAt;
    return data;
  }
}
