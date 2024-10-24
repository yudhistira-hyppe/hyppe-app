import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/models/collection/common/user_badge_model.dart';
import 'package:hyppe/core/services/system.dart';

class InteractiveFollow {
  String? createdAt;
  ProfileInsight? profileInsight;
  String? fullName;
  bool? flowIsDone;
  InteractiveEventType? eventType;
  Avatar? avatar;
  InteractiveEvent? event;
  SenderOrReceiverInfo? senderOrReceiverInfo;
  String? senderOrReceiver;
  String? email;
  String? username;
  UserBadgeModel? urluserBadge;

  InteractiveFollow({
    this.createdAt,
    this.profileInsight,
    this.fullName,
    this.flowIsDone,
    this.eventType,
    this.avatar,
    this.event,
    this.senderOrReceiverInfo,
    this.senderOrReceiver,
    this.email,
    this.username,
    this.urluserBadge,
  });

  InteractiveFollow.fromJson(Map<String, dynamic> json) {
    createdAt = json['createdAt'];
    profileInsight = json['profileInsight'] != null ? ProfileInsight.fromJson(json['profileInsight']) : null;
    fullName = json['fullName'];
    flowIsDone = json['flowIsDone'];
    eventType = System().convertEventType(json['eventType']);
    avatar = json['avatar'] != null ? Avatar.fromJson(json['avatar']) : null;
    event = System().convertEvent(json['event']);
    senderOrReceiverInfo = json['senderOrReceiverInfo'] != null ? SenderOrReceiverInfo.fromJson(json['senderOrReceiverInfo']) : null;
    senderOrReceiver = json['senderOrReceiver'];
    email = json['email'];
    username = json['username'];
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
    data['createdAt'] = createdAt;
    if (profileInsight != null) {
      data['profileInsight'] = profileInsight?.toJson();
    }
    data['fullName'] = fullName;
    data['flowIsDone'] = flowIsDone;
    data['eventType'] = System().convertEventTypeToString(eventType);
    if (avatar != null) {
      data['avatar'] = avatar?.toJson();
    }
    data['event'] = System().convertEventToString(event);
    if (senderOrReceiverInfo != null) {
      data['senderOrReceiverInfo'] = senderOrReceiverInfo?.toJson();
    }
    data['senderOrReceiver'] = senderOrReceiver;
    data['email'] = email;
    data['username'] = username;
    if (urluserBadge != null) {
      data['urluserBadge'] = urluserBadge?.toJson();
    }
    return data;
  }

  InteractiveFollow copyWith({
    String? createdAt,
    ProfileInsight? profileInsight,
    String? fullName,
    bool? flowIsDone,
    InteractiveEventType? eventType,
    Avatar? avatar,
    InteractiveEvent? event,
    SenderOrReceiverInfo? senderOrReceiver,
    String? email,
    String? username,
  }) {
    return InteractiveFollow(
      createdAt: createdAt ?? this.createdAt,
      profileInsight: profileInsight ?? this.profileInsight,
      fullName: fullName ?? this.fullName,
      flowIsDone: flowIsDone ?? this.flowIsDone,
      eventType: eventType ?? this.eventType,
      avatar: avatar ?? this.avatar,
      event: event ?? this.event,
      senderOrReceiverInfo: senderOrReceiver ?? senderOrReceiverInfo,
      email: email ?? this.email,
      username: username ?? this.username,
    );
  }
}

class ProfileInsight {
  int? follower;
  int? following;

  ProfileInsight({
    this.follower,
    this.following,
  });

  ProfileInsight.fromJson(Map<String, dynamic> json) {
    follower = json['follower'];
    following = json['following'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['follower'] = follower;
    data['following'] = following;
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

class SenderOrReceiverInfo {
  String? fullName;
  String? username;
  String? email;
  Avatar? avatar;
  UserBadgeModel? urluserBadge;

  SenderOrReceiverInfo({
    this.email,
    this.avatar,
    this.fullName,
    this.username,
    this.urluserBadge,
  });

  SenderOrReceiverInfo.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    fullName = json['fullName'];
    username = json['username'];
    avatar = json['avatar'] != null ? Avatar.fromJson(json['avatar']) : null;
    urluserBadge =
        json['urluserBadge'] != null && json['urluserBadge'].isNotEmpty
            ? UserBadgeModel.fromJson(json['urluserBadge'])
            : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['email'] = email;
    data['fullName'] = fullName;
    data['username'] = username;
    if (avatar != null) {
      data['avatar'] = avatar?.toJson();
    }
    if (urluserBadge != null) {
      data['urluserBadge'] = urluserBadge?.toJson();
    }
    return data;
  }
}
