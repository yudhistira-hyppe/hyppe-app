class PostReactionArgument {
  String? eventType;
  String? postID;
  String? receiverParty;
  String? reactionUri;
  List<String>? userView;
  List<String>? userLike;
  num? saleAmount;
  String? createdAt;
  List? mediaSource;
  String? description;
  bool? active;

  PostReactionArgument({
    this.eventType,
    this.postID,
    this.receiverParty,
    this.reactionUri,
    this.userView,
    this.userLike,
    this.saleAmount,
    this.createdAt,
    this.mediaSource,
    this.description,
    this.active,
  });

  PostReactionArgument.fromJson(Map<String, dynamic> json) {
    eventType = json['eventType'];
    postID = json['postID'];
    receiverParty = json['receiverParty'];
    reactionUri = json['reactionUri'];
    if (json['userView'] != null) {
      userView = json['userView'].cast<String>();
    }
    if (json['userLike'] != null) {
      userLike = json['userLike'].cast<String>();
    }
    if (json['mediaSource'] != null) {
      mediaSource = <MediaSource>[];
      json['mediaSource'].forEach((v) {
        mediaSource!.add(MediaSource.fromJson(v));
      });
    } else {
      mediaSource = [];
    }
    saleAmount = json['saleAmount'] ?? 0;
    createdAt = json['createdAt'];
    description = json['description'] ?? '';
    active = json['active'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['eventType'] = eventType;
    data['postID'] = postID;
    data['receiverParty'] = receiverParty;
    data['reactionUri'] = reactionUri;
    data['description'] = description;
    data['active'] = active;
    data['createdAt'] = createdAt;
    data['mediaSource'] = mediaSource;
    return data;
  }
}

class MediaSource {
  String? key;
  bool? isActive;
  String? originalName;
  String? mediaMime;
  String? klas;
  bool? apsara;
  String? mediaType;
  String? apsaraId;

  MediaSource({this.key, this.isActive, this.originalName, this.mediaMime, this.klas, this.apsara, this.mediaType, this.apsaraId});

  MediaSource.fromJson(Map<String, dynamic> json) {
    key = json['key'];
    isActive = json['isActive'];
    originalName = json['originalName'];
    mediaMime = json['mediaMime'];
    klas = json['_class'];
    apsara = json['apsara'];
    mediaType = json['mediaType'];
    apsaraId = json['apsaraId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['key'] = key;
    data['isActive'] = isActive;
    data['originalName'] = originalName;
    data['mediaMime'] = mediaMime;
    data['_class'] = klas;
    data['apsara'] = apsara;
    data['mediaType'] = mediaType;
    data['apsaraId'] = apsaraId;
    return data;
  }
}
