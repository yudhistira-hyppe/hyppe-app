import 'package:flutter/cupertino.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/services/shared_preference.dart';

class UserProfileAvatarModel {
  String? createdAt;

  String? mediaBasePath;

  String? mediaUri;

  bool? active;

  String? mediaType;

  String? mediaEndpoint;

  String? updatedAt;

  String? imageKey; //untuk key image cache

  UserProfileAvatarModel({this.createdAt, this.mediaBasePath, this.mediaUri, this.active, this.mediaType, this.mediaEndpoint, this.updatedAt, this.imageKey});

  UserProfileAvatarModel.fromJson(Map<String, dynamic> json) {
    createdAt = json['createdAt'];
    mediaBasePath = json['mediaBasePath'];
    mediaUri = json['mediaUri'];
    active = json['active'];
    mediaType = json['mediaType'];
    mediaEndpoint = json['mediaEndpoint'];
    updatedAt = json['updatedAt'];
    imageKey = '';
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
