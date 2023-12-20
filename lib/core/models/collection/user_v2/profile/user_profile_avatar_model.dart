class UserProfileAvatarModel {
  String? createdAt;

  String? mediaBasePath;

  String? mediaUri;

  bool? active;

  String? mediaType;

  String? mediaEndpoint;

  String? updatedAt;

  String? imageKey; //untuk key image cache

  String? fsSourceUri;

  String? fsTargetUri;

  UserProfileAvatarModel({this.createdAt, this.mediaBasePath, this.mediaUri, this.active, this.mediaType, this.mediaEndpoint, this.updatedAt, this.imageKey, this.fsSourceUri, this.fsTargetUri});

  UserProfileAvatarModel.fromJson(Map<String, dynamic> json) {
    createdAt = json['createdAt'];
    mediaBasePath = json['mediaBasePath'];
    mediaUri = json['mediaUri'];
    active = json['active'];
    mediaType = json['mediaType'];
    mediaEndpoint = json['mediaEndpoint'];
    updatedAt = json['updatedAt'];
    imageKey = '';
    fsSourceUri = json['fsSourceUri'];
    fsTargetUri = json['fsTargetUri'];
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
    data['fsSourceUri'] = fsSourceUri;
    data['fsTargetUri'] = fsTargetUri;
    return data;
  }
}
