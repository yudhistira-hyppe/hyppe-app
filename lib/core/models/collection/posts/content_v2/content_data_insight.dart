class ContentDataInsight {
  int? shares;

  int? follower;

  int? comments;

  int? following;

  int? reactions;

  int? views;

  int? likes;

  bool isPostLiked = false;

  bool isView = false;

  List<InsightLogs>? insightLogs;
  bool? isloading;
  bool? isloadingFollow;

  ContentDataInsight({
    this.shares,
    this.insightLogs,
    this.follower,
    this.comments,
    this.following,
    this.reactions,
    this.views,
    this.likes,
    this.isloading,
    this.isloadingFollow,
  });

  ContentDataInsight.fromJson(Map<String, dynamic> json, {bool isLike = false}) {
    shares = json['shares'];
    if (json['insightLogs'] != null) {
      insightLogs = [];
      json['insightLogs'].forEach((v) => insightLogs!.add(InsightLogs.fromJson(v)));
    }
    follower = json['follower'];
    comments = json['comments'];
    following = json['following'];
    reactions = json['reactions'];
    views = json['views'];
    likes = json['likes'];
    isPostLiked = isLike;
    isView = (json['isView'] != null) ? json['isView'] : false;
    isloading = false;
    isloadingFollow = false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['shares'] = shares;
    if (insightLogs != null) {
      data['insightLogs'] = insightLogs?.map((v) => v.toJson()).toList();
    }
    data['follower'] = follower;
    data['comments'] = comments;
    data['following'] = following;
    data['reactions'] = reactions;
    data['views'] = views;
    data['likes'] = likes;
    data['isView'] = isView;
    data['isloading'] = isloading;
    return data;
  }
}

class InsightLogs {
  String? sId;

  String? insightID;

  bool? active;

  String? createdAt;

  String? updatedAt;

  String? mate;

  String? postID;

  String? eventInsight;

  InsightLogs({
    this.sId,
    this.insightID,
    this.active,
    this.createdAt,
    this.updatedAt,
    this.mate,
    this.postID,
    this.eventInsight,
  });

  InsightLogs.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    insightID = json['insightID'];
    active = json['active'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    mate = json['mate'];
    postID = json['postID'];
    eventInsight = json['eventInsight'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['insightID'] = insightID;
    data['active'] = active;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['mate'] = mate;
    data['postID'] = postID;
    data['eventInsight'] = eventInsight;
    return data;
  }
}
