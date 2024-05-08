import 'package:hyppe/core/models/collection/live_stream/comment_live_model.dart';

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
  List<CommentLiveModel>? comment;

  StreamingModel(
      {this.sId,
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
      this.comment,
      this.textUrl});

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
    if (json['comment'] != null) {
      comment = <CommentLiveModel>[];
      json['comment'].forEach((v) {
        comment!.add(CommentLiveModel.fromJson(v));
      });
    }
  }
}
