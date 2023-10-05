class UserBadgeModel {
  String? id;
  String? idUserBadge;
  String? badgeProfile;
  String? badgeOther;
  String? endDatetime;
  bool? isActive;
  String? startDatetime;
  String? createdAt;

  UserBadgeModel({
    this.id,
    this.idUserBadge,
    this.badgeProfile,
    this.badgeOther,
    this.endDatetime,
    this.isActive,
    this.startDatetime,
    this.createdAt,
  });

  UserBadgeModel.fromJson(Map<String, dynamic> json) {
    // id = json['id'];
    idUserBadge = json['idUserBadge'];
    badgeProfile = json['badgeProfile'];
    badgeOther = json['badgeOther'];
    endDatetime = json['endDatetime'];
    isActive = json['isActive'];
    startDatetime = json['startDatetime'];
    createdAt = json['createdAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    // data['id'] = id;
    data['idUserBadge'] = idUserBadge;
    data['badgeProfile'] = badgeProfile;
    data['badgeOther'] = badgeOther;
    data['endDatetime'] = endDatetime;
    data['isActive'] = isActive;
    data['startDatetime'] = startDatetime;
    data['createdAt'] = createdAt;
    return data;
  }
}
