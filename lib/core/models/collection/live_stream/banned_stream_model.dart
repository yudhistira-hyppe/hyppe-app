class BannedStreamModel {
  String? streamId;
  String? streamBannedDate;
  int? streamBannedMax;
  String? dateStream;
  bool? statusAppeal;
  bool? statusBanned;

  BannedStreamModel({this.streamId, this.streamBannedDate, this.streamBannedMax, this.dateStream, this.statusAppeal, this.statusBanned});

  BannedStreamModel.fromJson(Map<String, dynamic> json) {
    streamId = json['streamId'];
    streamBannedDate = json['streamBannedDate'];
    streamBannedMax = json['streamBannedMax'];
    dateStream = json['dateStream'];
    statusAppeal = json['statusAppeal'];
    statusBanned = json['statusBanned'];
  }
}
