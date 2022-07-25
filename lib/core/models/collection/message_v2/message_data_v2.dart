import 'package:hyppe/core/config/env.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';

class MessageDataV2 {
  bool? active;
  String? fullName;
  String? eventType;
  Avatar? avatar;
  String? disqusID;
  String? room;
  String? createdAt;
  SenderOrReceiverInfo? senderOrReceiverInfo;
  Mate? mate;
  List<DisqusLogs> disqusLogs = [];
  String? email;
  String? updatedAt;
  String? lastestMessage;
  String? username;

  MessageDataV2({
    this.createdAt,
    this.mate,
    this.disqusLogs = const [],
    this.active,
    this.fullName,
    this.eventType,
    this.disqusID,
    this.email,
    this.room,
    this.updatedAt,
    this.username,
    this.senderOrReceiverInfo,
    this.lastestMessage,
    this.avatar,
  });

  MessageDataV2.fromJson(Map<String, dynamic> json) {
    createdAt = json['createdAt'];
    mate = json['mate'] != null ? Mate.fromJson(json['mate']) : null;
    if (json['disqusLogs'] != null) {
      json['disqusLogs'].forEach((v) {
        disqusLogs.add(DisqusLogs.fromJson(v));
      });
    }
    active = json['active'];
    fullName = json['fullName'];
    eventType = json['eventType'];
    avatar = json['avatar'] != null ? Avatar.fromJson(json['avatar']) : null;
    disqusID = json['disqusID'];
    email = json['email'];
    room = json['room'];
    updatedAt = json['updatedAt'];
    username = json['username'];
    lastestMessage = json["lastestMessage"];
    senderOrReceiverInfo = json['senderOrReceiverInfo'] != null ? SenderOrReceiverInfo.fromJson(json['senderOrReceiverInfo']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['createdAt'] = createdAt;
    if (mate != null) {
      data['mate'] = mate?.toJson();
    }
    data['disqusLogs'] = disqusLogs.map((v) => v.toJson()).toList();
    data['active'] = active;
    data['fullName'] = fullName;
    data['eventType'] = eventType;
    if (avatar != null) {
      data['avatar'] = avatar?.toJson();
    }
    data['disqusID'] = disqusID;
    data['email'] = email;
    data['room'] = room;
    data['updatedAt'] = updatedAt;
    data['username'] = username;
    data['lastestMessage'] = lastestMessage;
    if (senderOrReceiverInfo != null) {
      data['senderOrReceiverInfo'] = senderOrReceiverInfo?.toJson();
    }
    return data;
  }
}

class Mate {
  String? fullName;
  Avatar? avatar;
  String? email;
  String? username;

  Mate({
    this.fullName,
    this.avatar,
    this.email,
    this.username,
  });

  Mate.fromJson(Map<String, dynamic> json) {
    fullName = json['fullName'];
    avatar = json['avatar'] != null ? Avatar.fromJson(json['avatar']) : null;
    email = json['email'];
    username = json['username'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['fullName'] = fullName;
    if (avatar != null) {
      data['avatar'] = avatar?.toJson();
    }
    data['email'] = email;
    data['username'] = username;
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

class DisqusLogs {
  String? createdAt;
  String? txtMessages;
  String? receiver;
  String? postType;
  String? sender;
  bool? active;
  String? parentID;
  List<Content> content = [];
  String? updatedAt;
  String? reactionIcon;
  String? lineID;

  DisqusLogs({
    this.createdAt,
    this.txtMessages,
    this.receiver,
    this.postType,
    this.sender,
    this.active,
    this.parentID,
    this.content = const [],
    this.updatedAt,
    this.reactionIcon,
    this.lineID,
  });

  DisqusLogs.fromJson(Map<String, dynamic> json) {
    createdAt = json['createdAt'];
    txtMessages = json['txtMessages'];
    receiver = json['receiver'];
    postType = json['postType'];
    sender = json['sender'];
    active = json['active'];
    parentID = json['parentID'];
    if (json['content'] != null) {
      json['content'].forEach((v) {
        content.add(Content.fromJson(v));
      });
    }
    updatedAt = json['updatedAt'];
    reactionIcon = json['reaction_icon'];
    lineID = json['lineID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['createdAt'] = createdAt;
    data['txtMessages'] = txtMessages;
    data['receiver'] = receiver;
    data['postType'] = postType;
    data['sender'] = sender;
    data['active'] = active;
    data['parentID'] = parentID;
    data['content'] = content.map((v) => v.toJson()).toList();
    data['updatedAt'] = updatedAt;
    data['reaction_icon'] = reactionIcon;
    data['lineID'] = lineID;
    return data;
  }

  void removeWhere(bool Function(dynamic item) param0) {}
}

class Content {
  String? createdAt;
  String? mediaBasePath;
  String? postType;
  String? mediaUri;
  String? description;
  bool? active;
  String? mediaType;
  String? postID;
  String? mediaEndpoint;
  String? fullThumbPath;
  String? mediaThumbUri;
  String? mediaThumbEndpoint;

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
    return Env.data.baseUrl +
        (mediaThumbEndpoint ?? mediaEndpoint ?? '') +
        '?x-auth-token=${SharedPreference().readStorage(SpKeys.userToken)}&x-auth-user=${SharedPreference().readStorage(SpKeys.email)}';
  }
}

class SenderOrReceiverInfo {
  String? fullName;
  Avatar? avatar;
  String? email;
  String? username;

  SenderOrReceiverInfo({
    this.fullName,
    this.avatar,
    this.email,
    this.username,
  });

  SenderOrReceiverInfo.fromJson(Map<String, dynamic> json) {
    fullName = json['fullName'];
    avatar = json['avatar'] != null ? Avatar.fromJson(json['avatar']) : null;
    email = json['email'];
    username = json['username'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['fullName'] = fullName;
    if (avatar != null) {
      data['avatar'] = avatar?.toJson();
    }
    data['email'] = email;
    data['username'] = username;
    return data;
  }
}
