import 'package:hyppe/core/config/url_constants.dart';
import 'package:hyppe/core/extension/log_extension.dart';

import '../../../config/env.dart';
import '../../../constants/shared_preference_keys.dart';
import '../../../response/generic_response.dart';
import '../../../services/shared_preference.dart';

class AdsVideo {
  int? responseCode;
  AdsData? data;
  Messages? messages;

  AdsVideo({this.responseCode, this.data, this.messages});

  AdsVideo.fromJson(Map<String, dynamic> json) {
    responseCode = json['response_code'] ?? 0;
    data = AdsData.fromJson(json['data']);
    messages = Messages.fromJson(json['messages']);
  }
}

class AdsData {
  String? adsId;
  String? adsUrlLink;
  String? adsDescription;
  String? useradsId;
  String? idUser;
  String? fullName;
  String? email;
  AdsAvatar? avatar;
  String? adsPlace;
  String? adsType;
  int? adsSkip;
  String? mediaType;
  String? videoId;
  double? duration;
  bool? isReport;

  AdsData({
    this.adsId,
    this.adsUrlLink,
    this.adsDescription,
    this.useradsId,
    this.idUser,
    this.fullName,
    this.email,
    this.avatar,
    this.adsPlace,
    this.adsType,
    this.adsSkip,
    this.mediaType,
    this.videoId,
    this.duration,
    this.isReport,
  });

  AdsData.fromJson(Map<String, dynamic> json) {
    adsId = json['adsId'] ?? '';
    adsUrlLink = json['adsUrlLink'] ?? '';
    adsDescription = json['adsDescription'] ?? '';
    useradsId = json['useradsId'] ?? '';
    idUser = json['idUser'] ?? '';
    fullName = json['fullName'] ?? '';
    email = json['email'] ?? '';
    avatar = json['avartar'] != null ? AdsAvatar.fromJson(json['avartar']) : AdsAvatar();
    adsPlace = json['adsPlace'];
    adsType = json['adsType'];
    adsSkip = json['adsSkip'];
    mediaType = json['mediaType'];
    videoId = json['videoId'];
    isReport = json['isReport'] ?? false;
    final value = json['duration'];
    try {
      if (value is int) {
        duration = value.toDouble();
      } else {
        duration = value;
      }
    } catch (e) {
      print('$e');
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['adsId'] = adsId ?? '';
    data['adsUrlLink'] = adsUrlLink ?? '';
    data['adsDescription'] = adsDescription ?? '';
    data['useradsId'] = useradsId ?? '';
    data['idUser'] = idUser ?? '';
    data['fullName'] = fullName ?? '';
    data['email'] = email ?? '';
    data['avartar'] = avatar?.toJson();
    data['adsPlace'] = adsPlace ?? '';
    data['adsSkip'] = adsSkip ?? '';
    data['mediaType'] = mediaType ?? '';
    data['videoId'] = videoId ?? '';
    data['duration'] = duration ?? 0.0;
    return data;
  }
}

class AdsAvatar {
  String? mediaBasePath;
  String? mediaUri;
  String? mediaType;
  String? mediaEndpoint;
  String? fullLinkURL;

  AdsAvatar({this.mediaBasePath, this.mediaUri, this.mediaType, this.mediaEndpoint});

  AdsAvatar.fromJson(Map<String, dynamic> json) {
    mediaBasePath = json['mediaBasePath'] ?? '';
    mediaUri = json['mediaUri'] ?? '';
    mediaType = json['mediaType'] ?? '';
    mediaEndpoint = json['mediaEndpoint'] ?? '';
    fullLinkURL = concatThumbUri();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['mediaBasePath'] = mediaBasePath;
    data['mediaUri'] = mediaUri;
    data['mediaType'] = mediaType;
    data['mediaEndpoint'] = mediaEndpoint;
    return data;
  }

  String? concatThumbUri() {
    if (mediaEndpoint != null) {
      if (mediaEndpoint!.isNotEmpty) {
        return '${Env.data.baseUrl}${Env.data.versionApi}$mediaEndpoint?x-auth-token=${SharedPreference().readStorage(SpKeys.userToken)}&x-auth-user=${SharedPreference().readStorage(SpKeys.email)}';
      } else {
        return '';
      }
    } else {
      return '';
    }
  }
}
