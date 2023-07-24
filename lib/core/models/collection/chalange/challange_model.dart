class ChallangeModel {
  String? sId;
  String? nameChallenge;
  String? jenisChallenge;
  String? description;
  String? createdAt;
  String? updatedAt;
  int? durasi;
  bool? tampilStatusPengguna;
  String? objectChallenge;
  String? statusChallenge;
  String? endChallenge;
  String? endTime;
  String? startChallenge;
  String? startTime;
  String? searchBanner;
  String? bannerLeaderboard;
  String? statusJoined;
  String? statusFormalChallenge;
  bool? onGoing;
  int? totalDays;

  ChallangeModel({
    this.sId,
    this.nameChallenge,
    this.jenisChallenge,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.durasi,
    this.tampilStatusPengguna,
    this.objectChallenge,
    this.statusChallenge,
    this.endChallenge,
    this.endTime,
    this.startChallenge,
    this.startTime,
    this.searchBanner,
    this.bannerLeaderboard,
    this.statusJoined,
    this.statusFormalChallenge,
    this.onGoing,
    this.totalDays,
  });

  ChallangeModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    nameChallenge = json['nameChallenge'];
    jenisChallenge = json['jenisChallenge'];
    description = json['description'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    durasi = json['durasi'];
    tampilStatusPengguna = json['tampilStatusPengguna'];
    objectChallenge = json['objectChallenge'];
    statusChallenge = json['statusChallenge'];
    endChallenge = json['endChallenge'];
    endTime = json['endTime'];
    startChallenge = json['startChallenge'];
    startTime = json['startTime'];
    searchBanner = json['searchBanner'];
    bannerLeaderboard = json['bannerLeaderboard'];
    statusJoined = json['statusJoined'];
    statusFormalChallenge = json['statusFormalChallenge'];
    onGoing = json['onGoing'];
    totalDays = json['totalDays'];
  }
}
