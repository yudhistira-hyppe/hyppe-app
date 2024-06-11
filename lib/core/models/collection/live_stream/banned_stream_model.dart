class BannedStreamModel {
  String? streamId;
  String? streamBannedDate;
  int? streamBannedMax;
  String? dateStream;
  String? statusApprove;
  String? statusBanned;
  bool? statusAppeal;
  bool? statusBannedStreaming;

  BannedStreamModel({
    this.streamId,
    this.streamBannedDate,
    this.streamBannedMax,
    this.dateStream,
    this.statusApprove,
    this.statusBanned,
    this.statusAppeal,
    this.statusBannedStreaming,
  });

  BannedStreamModel.fromJson(Map<String, dynamic> json) {
    streamId = json['streamId'];
    streamBannedDate = json['streamBannedDate'];
    streamBannedMax = json['streamBannedMax'];
    dateStream = json['dateStream'];
    statusApprove = json['statusApprove'];
    statusBanned = json['statusBanned'];
    statusAppeal = json['statusAppeal'];
  }
}
