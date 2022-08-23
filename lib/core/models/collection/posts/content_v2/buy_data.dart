import 'dart:convert';

import 'package:hyppe/core/models/collection/posts/content_v2/privacy.dart';

BuyData buyDataFromJson(String str) => BuyData.fromJson(json.decode(str));

String buyDataToJson(BuyData data) => json.encode(data.toJson());

class BuyData {
  String? mediaBasePath;
  String? mediaUri;
  String? mediaType;
  String? mediaEndpoint;
  String? createdAt;
  String? updatedAt;
  String? postId;
  String? postType;
  String? description;
  String? title;
  bool? active;
  String? location;
  List<String>? tags;
  int? likes;
  int? shares;
  int? comments;
  bool? isOwned;
  int? views;
  Privacy? privacy;
  bool? isViewed;
  bool? allowComments;
  bool? isCertified;
  bool? saleLike;
  bool? saleView;
  int? adminFee;
  String? prosentaseAdminFee;
  int? price;
  int? totalAmount;
  bool? monetize;

  BuyData({
    this.mediaBasePath,
    this.mediaUri,
    this.mediaType,
    this.mediaEndpoint,
    this.createdAt,
    this.updatedAt,
    this.postId,
    this.postType,
    this.description,
    this.title,
    this.active,
    this.location,
    this.tags,
    this.likes,
    this.shares,
    this.comments,
    this.isOwned,
    this.views,
    this.privacy,
    this.isViewed,
    this.allowComments,
    this.isCertified,
    this.saleLike,
    this.saleView,
    this.adminFee,
    this.prosentaseAdminFee,
    this.price,
    this.totalAmount,
    this.monetize,
  });

  BuyData.fromJson(Map<String, dynamic> json) {
    mediaBasePath = json["mediaBasePath"];
    mediaUri = json["mediaUri"];
    mediaType = json["mediaType"];
    mediaEndpoint = json["mediaEndpoint"];
    createdAt = json["createdAt"];
    updatedAt = json["updatedAt"];
    postId = json["postID"];
    postType = json["postType"];
    description = json["description"];
    title = json["title"];
    active = json["active"];
    location = json["location"];
    tags = json['tags'] != null ? json['tags'].cast<String>() : [];
    likes = json["likes"];
    shares = json["shares"];
    comments = json["comments"];
    isOwned = json["isOwned"];
    views = json["views"];
    privacy = json['privacy'] != null ? Privacy.fromJson(json['privacy']) : null;
    isViewed = json["isViewed"];
    allowComments = json["allowComments"];
    isCertified = json["isCertified"];
    saleLike = json["saleLike"];
    saleView = json["saleView"];
    adminFee = json["adminFee"];
    prosentaseAdminFee = json["prosentaseAdminFee"];
    price = json["price"];
    totalAmount = json["totalAmount"];
    monetize = json["monetize"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['mediaBasePath'] = mediaBasePath;
    data['mediaUri'] = mediaUri;
    data['mediaType'] = mediaType;
    data['mediaEndpoint'] = mediaEndpoint;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['postID'] = postId;
    data['postType'] = postType;
    data['description'] = description;
    data['title'] = title;
    data['active'] = active;
    data['location'] = location;
    data['tags'] = tags;
    data['likes'] = likes;
    data['shares'] = shares;
    data['comments'] = comments;
    data['isOwned'] = isOwned;
    data['views'] = views;
    data['privacy'] = privacy != null ? privacy?.toJson() : '';
    data['isViewed'] = isViewed;
    data['allowComments'] = allowComments;
    data['isCertified'] = isCertified;
    data['saleLike'] = saleLike;
    data['saleView'] = saleView;
    data['adminFee'] = adminFee;
    data['prosentaseAdminFee'] = prosentaseAdminFee;
    data['price'] = price;
    data['totalAmount'] = totalAmount;
    data['monetize'] = monetize;
    return data;
  }
}
