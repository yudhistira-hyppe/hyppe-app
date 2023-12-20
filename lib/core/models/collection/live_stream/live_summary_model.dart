class LiveSummaryModel {
  int? totalViews;
  int? totalShare;
  int? totalFollower;
  int? totalComment;
  int? totalLike;

  LiveSummaryModel({this.totalViews, this.totalShare, this.totalFollower, this.totalComment, this.totalLike});

  LiveSummaryModel.fromJson(Map<String, dynamic> json) {
    totalViews = json['totalViews'];
    totalShare = json['totalShare'];
    totalFollower = json['totalFollower'];
    totalComment = json['totalComment'];
    totalLike = json['totalLike'];
  }
}
