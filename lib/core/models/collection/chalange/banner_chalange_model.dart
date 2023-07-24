class BannerChalangeModel {
  String? sId;
  String? nameChallenge;
  String? createdAt;
  String? startChallenge;
  String? endChallenge;
  String? statusChallenge;
  String? bannerLandingpage;

  BannerChalangeModel({this.sId, this.nameChallenge, this.createdAt, this.startChallenge, this.endChallenge, this.statusChallenge, this.bannerLandingpage});

  BannerChalangeModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    nameChallenge = json['nameChallenge'];
    createdAt = json['createdAt'];
    startChallenge = json['startChallenge'];
    endChallenge = json['endChallenge'];
    statusChallenge = json['statusChallenge'];
    bannerLandingpage = json['bannerLandingpage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['nameChallenge'] = nameChallenge;
    data['createdAt'] = createdAt;
    data['startChallenge'] = startChallenge;
    data['endChallenge'] = endChallenge;
    data['statusChallenge'] = statusChallenge;
    data['bannerLandingpage'] = bannerLandingpage;
    return data;
  }
}
