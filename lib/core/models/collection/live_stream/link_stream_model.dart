class LinkStreamModel {
  bool? status;
  String? userId;
  int? expireTime;
  String? urlStream;
  String? urlIngest;
  String? createAt;
  String? sId;

  LinkStreamModel({this.status, this.userId, this.expireTime, this.urlStream, this.urlIngest, this.createAt, this.sId});

  LinkStreamModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    userId = json['userId'];
    expireTime = json['expireTime'];
    urlStream = json['urlStream'];
    urlIngest = json['urlIngest'];
    createAt = json['createAt'];
    sId = json['_id'];
  }
}
