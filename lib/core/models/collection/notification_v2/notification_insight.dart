class NotificationInsightModel {
  int? follower;
  int? following;

  NotificationInsightModel({this.follower, this.following});

  NotificationInsightModel.fromJson(Map<String, dynamic> json) {
    follower = json['follower'];
    following = json['following'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['follower'] = follower;
    data['following'] = following;
    return data;
  }
}