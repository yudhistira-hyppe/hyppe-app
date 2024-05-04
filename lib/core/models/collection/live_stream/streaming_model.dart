class StreamingModel {
  String? sId;
  String? title;
  String? userId;
  int? expireTime;
  String? startLive;
  bool? status;
  String? urlStream;
  String? urlIngest;
  String? createAt;
  String? endLive;
  bool? pause;
  bool? commentDisabled;
  int? viewCountActive;
  String? urlLink;
  String? textUrl;

  StreamingModel({
    this.sId,
    this.title,
    this.userId,
    this.expireTime,
    this.startLive,
    this.status,
    this.urlStream,
    this.urlIngest,
    this.createAt,
    this.endLive,
    this.pause,
    this.commentDisabled,
    this.viewCountActive,
    this.urlLink,
    this.textUrl
  });

  StreamingModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    title = json['title'];
    userId = json['userId'];
    expireTime = json['expireTime'];
    startLive = json['startLive'];
    status = json['status'];
    urlStream = json['urlStream'];
    urlIngest = json['urlIngest'];
    createAt = json['createAt'];
    endLive = json['endLive'];
    pause = json['pause'];
    commentDisabled = json['commentDisabled'];
    viewCountActive = json['viewCountActive'] ?? 0;
    urlLink = json['urlLink'];
    textUrl = json['textUrl'];
  }
}
