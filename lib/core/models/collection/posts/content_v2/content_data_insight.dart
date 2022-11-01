import 'package:hive/hive.dart';

part 'content_data_insight.g.dart';

@HiveType(typeId: 3)
class ContentDataInsight extends HiveObject {
  @HiveField(0)
  int? shares;

  @HiveField(1)
  int? follower;

  @HiveField(2)
  int? comments;

  @HiveField(3)
  int? following;

  @HiveField(4)
  int? reactions;

  @HiveField(5)
  int? views;

  @HiveField(6)
  int? likes;

  @HiveField(7)
  bool isPostLiked = false;

  @HiveField(8)
  bool isView = false;

  @HiveField(9)
  List<InsightLogs>? insightLogs;

  ContentDataInsight({
    this.shares,
    this.insightLogs,
    this.follower,
    this.comments,
    this.following,
    this.reactions,
    this.views,
    this.likes,
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
    // isPostLiked = insightLogs != null && insightLogs!.where((element) => element.eventInsight?.toLowerCase() == 'like').isNotEmpty;
    isPostLiked = isLike;
    isView = (json['isView'] != null) ? json['isView'] : false;
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
    return data;
  }
}

@HiveType(typeId: 5)
class InsightLogs extends HiveObject {
  @HiveField(0)
  String? sId;

  @HiveField(1)
  String? insightID;

  @HiveField(2)
  bool? active;

  @HiveField(3)
  String? createdAt;

  @HiveField(4)
  String? updatedAt;

  @HiveField(5)
  String? mate;

  @HiveField(6)
  String? postID;

  @HiveField(7)
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
