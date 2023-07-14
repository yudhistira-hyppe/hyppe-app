import 'package:collection/collection.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/models/collection/common/user_badge_model.dart';

class CommentDataV2 {
  String? createdAt;
  List<CommentsLogs>? disqusLogs;
  bool? active;
  String? fullName;
  String? postID;
  String? eventType;
  Avatar? avatar;
  String? disqusID;
  String? email;
  String? updatedAt;
  String? username;
  bool? isIdVerified;
  int? comment;

  CommentDataV2({
    this.createdAt,
    this.disqusLogs = const [],
    this.active,
    this.fullName,
    this.postID,
    this.eventType,
    this.avatar,
    this.disqusID,
    this.email,
    this.updatedAt,
    this.username,
  });

  CommentDataV2.fromJson(Map<String, dynamic> json) {
    createdAt = json['createdAt'];
    serializeComments(json["disqusLogs"]);
    active = json['active'];
    fullName = json['fullName'];
    postID = json['postID'];
    eventType = json['eventType'];
    avatar = json['avatar'] != null ? Avatar.fromJson(json['avatar']) : null;
    disqusID = json['disqusID'];
    email = json['email'];
    updatedAt = json['updatedAt'];
    username = json['username'];
    isIdVerified = json['isIdVerified'];
    comment = json['comment'];
  }

  CommentDataV2.fromJsonResponse(Map<String, dynamic> json) {
    createdAt = json['createdAt'];
    serializeCommentsResponse(json["disqusLogs"]);
    active = json['active'];
    fullName = json['fullName'];
    postID = json['postID'];
    eventType = json['eventType'];
    avatar = json['avatar'] != null ? Avatar.fromJson(json['avatar']) : null;
    disqusID = json['disqusID'];
    email = json['email'];
    updatedAt = json['updatedAt'];
    username = json['username'];
    isIdVerified = json['isIdVerified'];
    comment = json['comment'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['createdAt'] = createdAt;
    data['active'] = active;
    data['fullName'] = fullName;
    data['postID'] = postID;
    data['eventType'] = eventType;
    if (avatar != null) {
      data['avatar'] = avatar?.toJson();
    }
    data['disqusID'] = disqusID;
    data['email'] = email;
    data['updatedAt'] = updatedAt;
    data['username'] = username;
    data['isIdVerified'] = isIdVerified;
    data['comment'] = comment;
    return data;
  }

  void serializeComments(dynamic datas) {
    try {
      // parse comments
      final _comments = List<List<DisqusLogs>>.from(
        datas.map(
          (x) => List<DisqusLogs>.from(
            x.map((x2) => DisqusLogs.fromJson(x2)),
          ),
        ),
      );

      // convert comments to map
      disqusLogs = List<CommentsLogs>.from(
        _comments.map(
          (x) => CommentsLogs(
            comment: x.firstOrNull,
            replies: x.skip(1).toList(),
          ),
        ),
      );
    } catch (e) {
      'Error $e'.logger();
    }
  }

  void serializeCommentsResponse(dynamic datas) {
    try {
      // parse comments
      final _comments = List<DisqusLogs>.from(
        datas.map((x2) => DisqusLogs.fromJson(x2)),
      );

      // convert comments to map
      disqusLogs = List<CommentsLogs>.from(
        _comments.map(
          (x) => CommentsLogs(comment: x, replies: []),
        ),
      );
    } catch (e) {
      'Error $e'.logger();
    }
  }
}

class CommentsLogs {
  DisqusLogs? comment;
  List<DisqusLogs> replies = [];

  CommentsLogs({
    this.comment,
    required this.replies,
  });
}

class DisqusLogs {
  int? sequenceNumber;
  String? createdAt;
  String? txtMessages;
  SenderInfo? senderInfo;
  String? receiver;
  String? sender;
  String? lineID;
  bool? active;
  String? updatedAt;
  bool? isIdVerified;
  List<DisqusLogs>? detailDisquss;

  DisqusLogs({
    this.sequenceNumber,
    this.createdAt,
    this.txtMessages,
    this.senderInfo,
    this.receiver,
    this.sender,
    this.lineID,
    this.active,
    this.updatedAt,
    this.isIdVerified,
    this.detailDisquss,
  });

  DisqusLogs.fromJson(Map<String, dynamic> json) {
    sequenceNumber = json['sequenceNumber'];
    createdAt = json['createdAt'];
    txtMessages = json['txtMessages'];
    senderInfo = json['senderInfo'] != null ? SenderInfo.fromJson(json['senderInfo']) : null;
    receiver = json['receiver'];
    sender = json['sender'];
    lineID = json['lineID'];
    active = json['active'];
    updatedAt = json['updatedAt'];
    isIdVerified = json['isIdVerified'];
    if(json['detailDisquss'] != null){
      detailDisquss = [];
      detailDisquss = List<DisqusLogs>.from(
        json['detailDisquss'].map((e) => DisqusLogs.fromJson(e)),
      );
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['sequenceNumber'] = sequenceNumber;
    data['createdAt'] = createdAt;
    data['txtMessages'] = txtMessages;
    if (senderInfo != null) {
      data['senderInfo'] = senderInfo?.toJson();
    }
    data['receiver'] = receiver;
    data['sender'] = sender;
    data['lineID'] = lineID;
    data['active'] = active;
    data['updatedAt'] = updatedAt;
    data['isIdVerified'] = isIdVerified;
    return data;
  }
}

class SenderInfo {
  String? fullName;
  Avatar? avatar;
  String? username;
  bool? isIdVerified;
  UserBadgeModel? urluserBadge;

  SenderInfo({
    this.fullName,
    this.avatar,
    this.username,
    this.urluserBadge,
  });

  SenderInfo.fromJson(Map<String, dynamic> json) {
    fullName = json['fullName'];
    avatar = json['avatar'] != null ? Avatar.fromJson(json['avatar']) : null;
    username = json['username'];
    isIdVerified = json['isIdVerified'];
    if (json['urluserBadge'] != null && json['urluserBadge'].isNotEmpty) {
      if (json['urluserBadge'] is List) {
        urluserBadge = UserBadgeModel.fromJson(json['urluserBadge'].first);
      } else {
        urluserBadge = UserBadgeModel.fromJson(json['urluserBadge']);
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['fullName'] = fullName;
    if (avatar != null) {
      data['avatar'] = avatar?.toJson();
    }
    data['username'] = username;
    data['isIdVerified'] = isIdVerified;
    if (urluserBadge != null) {
      data['urluserBadge'] = urluserBadge?.toJson();
    }
    return data;
  }
}

class Avatar {
  String? mediaBasePath;

  String? mediaUri;

  String? mediaType;

  String? mediaEndpoint;

  Avatar({
    this.mediaBasePath,
    this.mediaUri,
    this.mediaType,
    this.mediaEndpoint,
  });

  Avatar.fromJson(Map<String, dynamic> json) {
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
