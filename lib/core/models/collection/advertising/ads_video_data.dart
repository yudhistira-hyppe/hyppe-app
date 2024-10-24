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
  String? username;
  String? fullName;
  String? email;
  AdsAvatar? avatar;
  String? adsPlace;
  String? adsType;
  int? adsSkip;
  String? mediaType;
  String? videoId;
  double? duration;
  String? mediaBasePath;
  String? mediaUri;
  String? mediaThumBasePath;
  String? mediaThumUri;
  String? ctaButton;
  int? width;
  int? height;
  bool? isReport;
  String? apsaraAuth;
  bool isLoading = false;
  String? mediaPortraitUri;
  String? mediaPortraitThumUri;
  String? mediaLandscapeUri;
  String? mediaLandscapeThumUri;
  String? videoIdPortrait;
  String? videoIdLandscape;
  int? widthPortrait;
  int? heightPortrait;
  int? widthLandscape;
  int? heightLandscape;

  AdsData({
    this.adsId,
    this.adsUrlLink,
    this.adsDescription,
    this.useradsId,
    this.idUser,
    this.username,
    this.fullName,
    this.email,
    this.avatar,
    this.adsPlace,
    this.adsType,
    this.adsSkip,
    this.mediaType,
    this.videoId,
    this.duration,
    this.mediaBasePath,
    this.mediaUri,
    this.mediaThumBasePath,
    this.mediaThumUri,
    this.ctaButton,
    this.width,
    this.height,
    this.isReport,
    this.apsaraAuth,
    this.isLoading = false,
    this.mediaPortraitUri,
    this.mediaPortraitThumUri,
    this.mediaLandscapeUri,
    this.mediaLandscapeThumUri,
    this.widthPortrait,
    this.heightPortrait,
    this.videoIdPortrait,
    this.videoIdLandscape,
    this.widthLandscape,
    this.heightLandscape,
  });

  AdsData.fromJson(Map<String, dynamic> json) {
    adsId = json['adsId'] ?? '';
    adsUrlLink = json['adsUrlLink'] ?? '';
    adsDescription = json['adsDescription'] ?? '';
    useradsId = json['useradsId'] ?? '';
    idUser = json['idUser'] ?? '';
    username = json['username'] ?? '';
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
    mediaBasePath = json['mediaBasePath'];
    mediaUri = json['mediaUri'];
    mediaThumBasePath = json['mediaThumBasePath'];
    mediaThumUri = json['mediaThumUri'];
    ctaButton = json['ctaButton'];
    width = json['width'];
    height = json['height'];
    mediaPortraitUri = json['mediaPortraitUri'];
    mediaPortraitThumUri = json['mediaPortraitThumUri'];
    mediaLandscapeUri = json['mediaLandscapeUri'];
    mediaLandscapeThumUri = json['mediaLandscapeThumUri'];
    widthPortrait = json['widthPortrait'];
    heightPortrait = json['heightPortrait'];

    videoIdPortrait = json['videoIdPortrait'];
    videoIdLandscape = json['videoIdLandscape'];
    widthLandscape = json['widthLandscape'];
    heightLandscape = json['heightLandscape'];

    apsaraAuth = '';
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
    data['username'] = username ?? '';
    data['idUser'] = idUser ?? '';
    data['fullName'] = fullName ?? '';
    data['email'] = email ?? '';
    data['avartar'] = avatar?.toJson();
    data['adsPlace'] = adsPlace ?? '';
    data['adsSkip'] = adsSkip ?? '';
    data['mediaType'] = mediaType ?? '';
    data['videoId'] = videoId ?? '';
    data['duration'] = duration ?? 0.0;
    data['mediaBasePath'] = mediaBasePath;
    data['mediaUri'] = mediaUri;
    data['mediaThumBasePath'] = mediaThumBasePath;
    data['mediaThumUri'] = mediaThumUri;
    data['ctaButton'] = ctaButton;
    data['width'] = width;
    data['height'] = height;
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
