class UserProfileInsightModel {
  String? sId;
  bool? active;
  String? email;
  double? followers;
  double? followings;
  double? unfollows;
  double? likes;
  double? views;
  double? comments;
  double? posts;
  double? shares;
  double? reactions;

  UserProfileInsightModel(
      {this.sId,
      this.active,
      this.email,
      this.followers,
      this.followings,
      this.unfollows,
      this.likes,
      this.views,
      this.comments,
      this.posts,
      this.shares,
      this.reactions});

  UserProfileInsightModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    active = json['active'];
    email = json['email'];
    followers = json['followers'];
    followings = json['followings'];
    unfollows = json['unfollows'];
    likes = json['likes'];
    views = json['views'];
    comments = json['comments'];
    posts = json['posts'];
    shares = json['shares'];
    reactions = json['reactions'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['active'] = active;
    data['email'] = email;
    data['followers'] = followers;
    data['followings'] = followings;
    data['unfollows'] = unfollows;
    data['likes'] = likes;
    data['views'] = views;
    data['comments'] = comments;
    data['posts'] = posts;
    data['shares'] = shares;
    data['reactions'] = reactions;
    return data;
  }
}
