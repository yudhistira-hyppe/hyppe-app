import 'package:hyppe/core/models/collection/common/user_badge_model.dart';

class ViewContent {
  List<User>? user;
  int? guest;

  ViewContent({this.user, this.guest});

  ViewContent.fromJson(Map<String, dynamic> json) {
    if (json['user'] != null) {
      user = <User>[];
      json['user'].forEach((v) {
        user!.add(User.fromJson(v));
      });
    }
    guest = json['guest'];
  }
}

class User {
  String? sId;
  String? email;
  String? fullName;
  String? username;
  UserBadgeModel? urluserBadge;
  Avatar? avatar;
  bool? following;
  bool? guest;
  bool? isloadingFollow;

  User({this.sId, this.email, this.fullName, this.username, this.urluserBadge, this.avatar, this.following, this.guest, this.isloadingFollow});

  User.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    email = json['email'];
    fullName = json['fullName'];
    username = json['username'];

    if (json['urluserBadge'] != null && json['urluserBadge'].isNotEmpty) {
      if (json['urluserBadge'] is List) {
        urluserBadge = UserBadgeModel.fromJson(json['urluserBadge'].first);
      } else {
        urluserBadge = UserBadgeModel.fromJson(json['urluserBadge']);
      }
    }

    avatar = json['avatar'] != null ? Avatar.fromJson(json['avatar']) : null;
    following = json['following'];
    guest = json['guest'];
  }
}

class Avatar {
  String? mediaBasePath;
  String? mediaUri;
  String? mediaType;
  String? mediaEndpoint;

  Avatar({this.mediaBasePath, this.mediaUri, this.mediaType, this.mediaEndpoint});

  Avatar.fromJson(Map<String, dynamic> json) {
    mediaBasePath = json['mediaBasePath'];
    mediaUri = json['mediaUri'];
    mediaType = json['mediaType'];
    mediaEndpoint = json['mediaEndpoint'];
  }
}
