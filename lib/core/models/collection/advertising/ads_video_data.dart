import '../../../response/generic_response.dart';

class AdsVideo{
  int? responseCode;
  AdsData? data;
  Messages? messages;

  AdsVideo({
    this.responseCode,
    this.data,
    this.messages
  });

  AdsVideo.fromJson(Map<String, dynamic> json){
    responseCode = json['response_code'] ?? 0;
    data = AdsData.fromJson(json['data']);
    messages = Messages.fromJson(json['messages']);
  }
}

class AdsData{
  String? adsId;
  String? useradsId;
  String? idUser;
  String? fullName;
  String? email;
  AdsAvatar? avatar;
  String? adsPlace;
  String? adsType;
  int? adsSkip;
  String? videoId;

  AdsData({
    this.adsId,
    this.useradsId,
    this.idUser,
    this.fullName,
    this.email,
    this.avatar,
    this.adsPlace,
    this.adsType,
    this.adsSkip,
    this.videoId
  });

  AdsData.fromJson(Map<String, dynamic> json){
    adsId = json['adsId'] ?? '';
    useradsId = json['useradsId'] ?? '';
    idUser = json['idUser'] ?? '';
    fullName = json['fullName'] ?? '';
    email = json['email'] ?? '';
    avatar = json['avartar'] != null ? AdsAvatar.fromJson(json['avartar']) : AdsAvatar();
    adsPlace = json['adsPlace'];
    adsType = json['adsType'];
    adsSkip = json['adsSkip'];
    videoId = json['videoId'];
  }

  Map<String, dynamic> toJson(){
    final Map<String, dynamic> data = <String, dynamic>{};
    data['adsId'] = adsId ?? '';
    data['useradsId'] = useradsId ?? '';
    data['idUser'] = idUser ?? '';
    data['fullName'] = fullName ?? '';
    data['email'] = email ?? '';
    data['avartar'] = avatar?.toJson();
    data['adsPlace'] = adsPlace ?? '';
    data['adsSkip'] = adsSkip ?? '';
    data['videoId'] = videoId ?? '';
    return data;
  }

}

class AdsAvatar{
  String? mediaBasePath;
  String? mediaUri;
  String? mediaType;
  String? mediaEndpoint;

  AdsAvatar({
    this.mediaBasePath,
    this.mediaUri,
    this.mediaType,
    this.mediaEndpoint
  });

  AdsAvatar.fromJson(Map<String, dynamic> json){
    mediaBasePath = json['mediaBasePath'] ?? '';
    mediaUri = json['mediaUri'] ?? '';
    mediaType = json['mediaType'] ?? '';
    mediaEndpoint = json['mediaEndpoint'] ?? '';
  }

  Map<String, dynamic> toJson(){
    final Map<String, dynamic> data = <String, dynamic>{};
    data['mediaBasePath'] = mediaBasePath;
    data['mediaUri'] = mediaUri;
    data['mediaType'] = mediaType;
    data['mediaEndpoint'] = mediaEndpoint;
    return data;
  }
}