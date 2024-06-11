import 'package:hyppe/core/config/env.dart';
import 'package:hyppe/core/models/collection/common/user_badge_model.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/models/collection/notification_v2/notification_sender_or_receiver.dart';

class NotificationModel {
  bool? active;
  bool? flowIsDone;
  String? actionButtons; //
  String? eventType;
  String? title;
  String? titleEN;
  String? titleId;
  String? body;
  String? bodyId;
  // List<Content> content = [];
  Content? content;
  String? createdAt;
  NotificationSenderOrReceiverInfoModel? senderOrReceiverInfo;
  String? mate;
  String? notificationID;
  String? event;
  String? email;
  String? updatedAt;
  bool? isRead;
  String? postID;
  String? postType;
  UserBadgeModel? urluserBadge;
  bool? winner;
  int? index;
  int? challengeSession;
  String? contentEventID; // untuk challeng masuk ke tab isinya 1 atau 0
  String? streamId;
  List<DataBanned>? dataBanned;

  NotificationModel({
    this.active,
    this.flowIsDone,
    this.actionButtons,
    this.eventType,
    this.title,
    this.titleEN,
    this.titleId,
    this.body,
    this.bodyId,
    // this.content = const [],
    this.content,
    this.createdAt,
    this.senderOrReceiverInfo,
    this.mate,
    this.notificationID,
    this.event,
    this.email,
    this.updatedAt,
    this.isRead,
    this.postID,
    this.postType,
    this.urluserBadge,
    this.contentEventID,
    this.streamId,
    this.dataBanned,
  });

  NotificationModel.fromJson(Map<String, dynamic> json) {
    active = json['active'];
    flowIsDone = json['flowIsDone'];
    actionButtons = json['actionButtons'];
    eventType = json['eventType'];
    titleEN = json['titleEN'];
    titleId = json['titleId'];
    title = json['title'];
    body = json['body'];
    bodyId = json['bodyId'];
    if (json['content'] != null) {
      content = Content.fromJson(json['content']);
      // json['content'].forEach((v) {
      //   content.add(Content.fromJson(v));
      // });
    }
    createdAt = json['createdAt'];
    senderOrReceiverInfo = json['senderOrReceiverInfo'] != null ? NotificationSenderOrReceiverInfoModel.fromJson(json['senderOrReceiverInfo']) : null;
    mate = json['mate'];
    notificationID = json['notificationID'];
    event = json['event'];
    email = json['email'];
    updatedAt = json['updatedAt'];
    postID = json['postID'];
    isRead = json['isRead'] ?? false;
    postType = json['postType'];
    streamId = json['streamId'];
    if (json['urluserBadge'] != null && json['urluserBadge'].isNotEmpty) {
      if (json['urluserBadge'] is List) {
        urluserBadge = UserBadgeModel.fromJson(json['urluserBadge'].first);
      } else {
        urluserBadge = UserBadgeModel.fromJson(json['urluserBadge']);
      }
    }
    contentEventID = json["contentEventID"];
    if (json['data'] != null) {
      dataBanned = <DataBanned>[];
      json['data'].forEach((v) {
        dataBanned!.add(DataBanned.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['active'] = active;
    data['flowIsDone'] = flowIsDone;
    data['actionButtons'] = actionButtons;
    data['eventType'] = eventType;
    data['title'] = title;
    data['titleEN'] = titleEN;
    data['body'] = body;
    data['bodyId'] = bodyId;
    data['content'] = content?.toJson();
    data['createdAt'] = createdAt;
    if (senderOrReceiverInfo != null) {
      data['senderOrReceiverInfo'] = senderOrReceiverInfo?.toJson();
    }
    data['mate'] = mate;
    data['notificationID'] = notificationID;
    data['event'] = event;
    data['email'] = email;
    data['updatedAt'] = updatedAt;
    data['isRead'] = isRead;
    if (urluserBadge != null) {
      data['urluserBadge'] = urluserBadge?.toJson();
    }
    return data;
  }

  NotificationModel copyWith({
    bool? active,
    bool? flowIsDone,
    String? actionButtons,
    String? eventType,
    String? title,
    String? body,
    String? bodyId,
    // List<Content>? content,
    Content? content,
    String? createdAt,
    NotificationSenderOrReceiverInfoModel? senderOrReceiverInfo,
    String? mate,
    String? notificationID,
    String? event,
    String? email,
    String? updatedAt,
    bool? isRead,
  }) {
    return NotificationModel(
      active: active ?? this.active,
      flowIsDone: flowIsDone ?? this.flowIsDone,
      actionButtons: actionButtons ?? this.actionButtons,
      eventType: eventType ?? this.eventType,
      title: title ?? this.title,
      body: body ?? this.body,
      bodyId: bodyId ?? this.bodyId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      senderOrReceiverInfo: senderOrReceiverInfo ?? this.senderOrReceiverInfo,
      mate: mate ?? this.mate,
      notificationID: notificationID ?? this.notificationID,
      event: event ?? this.event,
      email: email ?? this.email,
      updatedAt: updatedAt ?? this.updatedAt,
      isRead: isRead ?? this.isRead,
    );
  }
}

class Content {
  String? createdAt;
  String? mediaBasePath;
  String? postType;
  String? mediaUri;
  String? mediaThumbUri;
  String? description;
  bool? active;
  String? mediaType;
  String? mediaThumbEndpoint;
  String? postID;
  String? mediaEndpoint;
  String? fullThumbPath;
  bool? isApsara;

  Content({
    this.createdAt,
    this.mediaBasePath,
    this.postType,
    this.mediaUri,
    this.mediaThumbUri,
    this.description,
    this.active,
    this.mediaType,
    this.mediaThumbEndpoint,
    this.postID,
    this.mediaEndpoint,
    this.isApsara,
  });

  Content.fromJson(Map<String, dynamic> json) {
    createdAt = json['createdAt'];
    mediaBasePath = json['mediaBasePath'];
    postType = json['postType'];
    mediaUri = json['mediaUri'];
    mediaThumbUri = json['mediaThumbUri'];
    description = json['description'];
    active = json['active'];
    mediaType = json['mediaType'];
    mediaThumbEndpoint = json['mediaThumbEndpoint'];
    postID = json['postID'];
    mediaEndpoint = json['mediaEndpoint'];
    isApsara = json['isApsara'] ?? false;
    fullThumbPath = concatThumbUri();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['createdAt'] = createdAt;
    data['mediaBasePath'] = mediaBasePath;
    data['postType'] = postType;
    data['mediaUri'] = mediaUri;
    data['mediaThumbUri'] = mediaThumbUri;
    data['description'] = description;
    data['active'] = active;
    data['mediaType'] = mediaType;
    data['mediaThumbEndpoint'] = mediaThumbEndpoint;
    data['postID'] = postID;
    data['mediaEndpoint'] = mediaEndpoint;
    return data;
  }

  String? concatThumbUri() {
    final fixMedia = mediaThumbEndpoint ?? mediaEndpoint ?? '';
    if (fixMedia.isNotEmpty) {
      return Env.data.baseUrl +
          Env.data.versionApi +
          (mediaThumbEndpoint ?? mediaEndpoint ?? '') +
          '?x-auth-token=${SharedPreference().readStorage(SpKeys.userToken)}&x-auth-user=${SharedPreference().readStorage(SpKeys.email)}';
    } else {
      return fixMedia;
    }
  }
}

class DataBanned {
  String? idBanned;
  String? bannedDate;
  int? userWarningCount;

  DataBanned({this.idBanned, this.bannedDate, this.userWarningCount});

  DataBanned.fromJson(Map<String, dynamic> json) {
    idBanned = json['idBanned'];
    bannedDate = json['bannedDate'];
    userWarningCount = json['userWarningCount'];
  }
}
