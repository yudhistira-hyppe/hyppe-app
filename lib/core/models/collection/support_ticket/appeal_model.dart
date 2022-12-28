import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/models/collection/comment_v2/comment_data_v2.dart';

class AppealModel{
  String? id;
  String? mediaType;
  String? mediaThumbEndPoint;
  String? mediaEndPoint;
  String? idMedia;
  String? createdAt;
  String? updatedAt;
  String? postID;
  String? email;
  String? fullName;
  String? username;
  String? postType;
  String? description;
  bool? active;
  bool? contentModeration;
  String? contentModerationResponse;
  String? reportedStatus;
  int? reportedUserCount;
  List<ReportedUser>? reportedUser;
  List<ReportedUserHandle>? reportedUserHandle;
  String? reportReasonIdLast;
  String? reasonLast;
  String? createdAtReportLast;
  String? createdAtAppealLast;
  String? reportStatusLast;
  String? reasonLastAppeal;
  String? apsaraId;
  bool? isApsara;
  Avatar? avatar;
  Media? media;
  AppealStatus? status;

  AppealModel.fromJson(Map<String,dynamic> map){
    id = map['_id'];
    mediaType = map['mediaType'];
    mediaThumbEndPoint = map['mediaThumbEndpoint'];
    mediaEndPoint = map['mediaEndpoint'];
    idMedia = map['idmedia'];
    createdAt = map['createdAt'];
    updatedAt = map['updatedAt'];
    postID = map['postID'];
    email = map['email'];
    fullName = map['fullName'];
    username = map['username'];
    postType = map['postType'];
    description = map['description'];
    active = map['active'];
    contentModeration = map['contentModeration'];
    contentModerationResponse = map['contentModerationResponse'];
    reportedStatus = map['reportedStatus'];
    reportedUserCount = map['reportedUserCount'];
    if(map['reportedUser'] != null){
      reportedUser = [];
      if(map['reportedUser'].isNotEmpty){
        map['reportedUser'].forEach((v) => reportedUser?.add(ReportedUser.fromJson(v)));
      }
    }
    if(map['reportedUserHandle'] != null){
      reportedUserHandle = [];
      if(map['reportedUserHandle'].isNotEmpty){
        map['reportedUserHandle'].forEach((v) => reportedUserHandle?.add(ReportedUserHandle.fromJson(v)));
      }
    }
    reportReasonIdLast = map['reportReasonIdLast'];
    reasonLast = map['reasonLast'];
    createdAtReportLast = map['createdAtReportLast'];
    createdAtAppealLast = map['createdAtAppealLast'];
    reportStatusLast = map['reportStatusLast'];
    reasonLastAppeal = map['reasonLastAppeal'];
    apsaraId = map['apsaraId'];
    isApsara = map['apsara'];
    avatar = Avatar.fromJson(map['avatar']);
    media = Media.fromJson(map['media']);
    status = getAppealStatus(reportStatusLast);
  }

  AppealModel({
    this.id,
    this.mediaType,
    this.mediaEndPoint,
    this.mediaThumbEndPoint,
    this.idMedia,
    this.createdAt,
    this.updatedAt,
    this.postID,
    this.email,
    this.fullName,
    this.username,
    this.postType,
    this.description,
    this.active,
    this.contentModeration,
    this.contentModerationResponse,
    this.reportedStatus,
    this.reportedUserCount,
    this.reportedUser,
    this.reportedUserHandle,
    this.reportReasonIdLast,
    this.reasonLast,
    this.createdAtReportLast,
    this.createdAtAppealLast,
    this.reportStatusLast,
    this.reasonLastAppeal,
    this.apsaraId,
    this.isApsara,
    this.avatar,
    this.media,
    this.status
  });


  AppealStatus getAppealStatus(String? status){
    if(status == 'BARU'){
      return AppealStatus.newest;
    }else if(status == 'FLAGING'){
      return AppealStatus.flaging;
    }else if(status == 'TIDAK DITANGGUHKAN'){
      return AppealStatus.notSuspended;
    }else if(status == 'DITANGGUHKAN'){
      return AppealStatus.suspend;
    }else{
      return AppealStatus.removed;
    }
  }

}

class ReportedUser{
  String? userID;
  String? email;
  String? reportReasonId;
  String? createdAt;
  String? updatedAt;
  bool? active;
  String? description;

  ReportedUser({
    this.userID,
    this.email,
    this.reportReasonId,
    this.createdAt,
    this.updatedAt,
    this.active,
    this.description
  });

  ReportedUser.fromJson(Map<String,dynamic> map){
    userID = map['userID'];
    email = map['email'];
    reportReasonId = map['reportReasonId'];
    createdAt = map['createdAt'];
    updatedAt = map['updatedAt'];
    active = map['active'];
    description = map['description'];
  }
}

class ReportedUserHandle{
  String? reason;
  String? remark;
  String? reasonAdmin;
  String? reasonId;
  String? createdAt;
  String? updatedAt;
  String? status;

  ReportedUserHandle({
    this.reason,
    this.remark,
    this.reasonAdmin,
    this.reasonId,
    this.createdAt,
    this.updatedAt,
    this.status
  });

  ReportedUserHandle.fromJson(Map<String, dynamic> map){
    reason = map['reason'];
    remark = map['remark'];
    reasonAdmin = map['reasonAdmin'];
    reasonId = map['reasonId'];
    createdAt = map['createdAt'];
    updatedAt = map['updatedAt'];
    status = map['status'];
  }
}

class Media{
  List<ImageInfo>? imageInfo;
  List<VideoInfo>? videoInfo;

  Media({this.imageInfo, this.videoInfo});

  Media.fromJson(Map<String, dynamic> map){
    try{
      if(map['ImageInfo'] != null){
        imageInfo = [];
        if(map['ImageInfo'].isNotEmpty){
          map['ImageInfo'].forEach((value) => imageInfo?.add(ImageInfo.fromJson(value)));
        }
      }
      if(map['VideoList'] != null){
        videoInfo = [];
        if(map['VideoList'].isNotEmpty){
          map['VideoList'].forEach((value) => videoInfo?.add(VideoInfo.fromJson(value)));
        }
      }
    }catch(e){
      'Error Media: $e'.logger();
      imageInfo = [];
      videoInfo = [];
    }

  }
}

class ImageInfo{
  String? status;
  Mezzanine? mezzanine;
  String? createdAt;
  String? imageId;
  String? title;
  String? regionId;
  String? storageLocation;
  String? url;
  String? imageType;

  ImageInfo({
    this.status,
    this.mezzanine,
    this.createdAt,
    this.imageId,
    this.title,
    this.regionId,
    this.storageLocation,
    this.url,
    this.imageType
  });

  ImageInfo.fromJson(Map<String, dynamic> map){
    status = map['Status'];
    mezzanine = Mezzanine.fromJson(map['Mezzanine']);
    createdAt = map['CreationTime'];
    imageId = map['ImageId'];
    title = map['Title'];
    regionId = map['RegionId'];
    storageLocation = map['StorageLocation'];
    url = map['URL'];
    imageType = map['ImageType'];
  }
}

class Mezzanine{
  String? fileURL;
  String? originalFileName;
  int? height;
  int? width;
  int? fileSize;

  Mezzanine({
    this.fileURL,
    this.originalFileName,
    this.fileSize,
    this.width,
    this.height
  });

  Mezzanine.fromJson(Map<String, dynamic> map){
    fileURL = map['FileURL'];
    originalFileName = map['OriginalFileName'];
    height = map['Height'];
    width = map['Width'];
    fileSize = map['FileSize'];
  }
}

class VideoInfo{
  String? status;
  String? videoId;
  int? size;
  String? downloadSwitch;
  String? title;
  double? duration;
  String? updateAt;
  String? createdAt;
  int? cateId;
  String? cateName;
  String? preProcessStatus;
  String? appId;
  String? coverURL;
  String? regionId;
  String? storageLocation;
  List<String>? snapshots;
  String? templateGroupId;

  VideoInfo({
    this.status,
    this.videoId,
    this.size,
    this.downloadSwitch,
    this.title,
    this.duration,
    this.updateAt,
    this.createdAt,
    this.cateId,
    this.cateName,
    this.preProcessStatus,
    this.appId,
    this.coverURL,
    this.regionId,
    this.storageLocation,
    this.snapshots,
    this.templateGroupId
  });

  VideoInfo.fromJson(Map<String, dynamic> map){
    status = map['Status'];
    videoId = map['VideoId'];
    size = map['Size'];
    downloadSwitch = map['DownloadSwitch'];
    title = map['Title'];
    duration = map['Duration'];
    updateAt = map['ModificationTime'];
    createdAt = map['CreationTime'];
    cateId = map['CateId'];
    cateName = map['CateName'];
    preProcessStatus = map['PreprocessStatus'];
    appId = map['AppId'];
    coverURL = map['CoverURL'];
    regionId = map['RegionId'];
    storageLocation = map['StorageLocation'];
    if(map['Snapshots'] != null){
      snapshots = [];
      if(map['Snapshots'].isNotEmpty){
        map['Snapshots'].forEach((v) => snapshots?.add(v));
      }
    }
    templateGroupId = map['TemplateGroupId'];
  }
}

