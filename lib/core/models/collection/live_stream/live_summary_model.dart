class LiveSummaryModel {
  int? totalViews;
  int? totalShare;
  int? totalFollower;
  int? totalUserGift;
  int? totalGift;
  int? totalComment;
  int? totalLike;
  int? totalIncome;
  int? totalCoin;

  LiveSummaryModel({
    this.totalViews,
    this.totalShare,
    this.totalFollower,
    this.totalComment,
    this.totalLike,
    this.totalIncome,
  });

  LiveSummaryModel.fromJson(Map<String, dynamic> json) {
    totalViews = json['totalViews'];
    totalShare = json['totalShare'];
    totalFollower = json['totalFollower'];
    totalComment = json['totalComment'];
    totalLike = json['totalLike'];
    totalIncome = json['totalIncome'];
    totalGift = json['totalGift'];
    totalUserGift = json['totalUserGift'];
    totalCoin = json['totalCoin'];
  }
}
