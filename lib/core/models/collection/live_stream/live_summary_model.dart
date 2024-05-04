class LiveSummaryModel {
  int? totalViews;
  int? totalShare;
  int? totalFollower;
  int? totalGifter;
  int? totalGift;
  int? totalComment;
  int? totalLike;
  int? totalCoin;

  LiveSummaryModel({this.totalViews, this.totalShare, this.totalFollower, this.totalComment, this.totalLike});

  LiveSummaryModel.fromJson(Map<String, dynamic> json) {
    totalViews = json['totalViews'];
    totalShare = json['totalShare'];
    totalFollower = json['totalFollower'];
    totalComment = json['totalComment'];
    totalLike = json['totalLike'];
    totalGift = json['totalGift'];
    totalGifter = json['totalGifter'];
    totalCoin = json['totalCoin'];
  }
}