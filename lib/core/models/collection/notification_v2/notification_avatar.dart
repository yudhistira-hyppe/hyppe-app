class NotificationAvatarModel {
  String? mediaBasePath;
  String? mediaUri;
  String? mediaType;
  String? mediaEndpoint;

  NotificationAvatarModel({this.mediaBasePath, this.mediaUri, this.mediaType, this.mediaEndpoint});

  NotificationAvatarModel.fromJson(Map<String, dynamic> json) {
    mediaBasePath = json['mediaBasePath'];
    mediaUri = json['mediaUri'];
    mediaType = json['mediaType'];
    mediaEndpoint = json['mediaEndpoint'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['mediaBasePath'] = mediaBasePath;
    data['mediaUri'] = mediaUri;
    data['mediaType'] = mediaType;
    data['mediaEndpoint'] = mediaEndpoint;
    return data;
  }
}
