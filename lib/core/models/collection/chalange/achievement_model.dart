class AcievementModel {
  String? sId;
  String? subChallengeId;
  String? userId;
  String? idBadge;
  int? session;
  String? startDatetime;
  String? endDatetime;
  String? createdAt;
  bool? isActive;
  List<BadgeData>? badgeData;
  List<SubChallengeData>? subChallengeData;
  Avatar? avatar;

  AcievementModel(
      {this.sId,
      this.subChallengeId,
      this.userId,
      this.idBadge,
      this.session,
      this.startDatetime,
      this.endDatetime,
      this.createdAt,
      this.isActive,
      this.badgeData,
      this.subChallengeData,
      this.avatar});

  AcievementModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    subChallengeId = json['SubChallengeId'];
    userId = json['userId'];
    idBadge = json['idBadge'];
    session = json['session'];
    startDatetime = json['startDatetime'];
    endDatetime = json['endDatetime'];
    createdAt = json['createdAt'];
    isActive = json['isActive'];
    if (json['badge_data'] != null) {
      badgeData = <BadgeData>[];
      json['badge_data'].forEach((v) {
        badgeData!.add(new BadgeData.fromJson(v));
      });
    }
    if (json['subChallenge_data'] != null) {
      subChallengeData = <SubChallengeData>[];
      json['subChallenge_data'].forEach((v) {
        subChallengeData!.add(new SubChallengeData.fromJson(v));
      });
    }
    avatar = json['avatar'] != null ? new Avatar.fromJson(json['avatar']) : null;
  }
}

class BadgeData {
  String? sId;
  String? name;
  String? type;
  String? badgeProfile;
  String? badgeOther;
  String? createdAt;
  int? iV;

  BadgeData({this.sId, this.name, this.type, this.badgeProfile, this.badgeOther, this.createdAt, this.iV});

  BadgeData.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    type = json['type'];
    badgeProfile = json['badgeProfile'];
    badgeOther = json['badgeOther'];
    createdAt = json['createdAt'];
    iV = json['__v'];
  }
}

class SubChallengeData {
  String? sId;
  String? challengeId;
  String? startDatetime;
  String? endDatetime;
  bool? isActive;
  int? session;
  String? nameChallenge;

  SubChallengeData({this.sId, this.challengeId, this.startDatetime, this.endDatetime, this.isActive, this.session, this.nameChallenge});

  SubChallengeData.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    challengeId = json['challengeId'];
    startDatetime = json['startDatetime'];
    endDatetime = json['endDatetime'];
    isActive = json['isActive'];
    session = json['session'];
    nameChallenge = json['nameChallenge'];
  }
}

class Avatar {
  String? mediaEndpoint;

  Avatar({this.mediaEndpoint});

  Avatar.fromJson(Map<String, dynamic> json) {
    mediaEndpoint = json['mediaEndpoint'];
  }
}
