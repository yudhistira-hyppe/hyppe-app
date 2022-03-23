class CreateMessageResponse {
  String? mate;
  String? room;
  String? email;
  List<DisqusLogs> disqusLogs = [];

  CreateMessageResponse({
    this.mate,
    this.room,
    this.email,
    this.disqusLogs = const [],
  });

  CreateMessageResponse.fromJson(Map<String, dynamic> json) {
    mate = json['mate'];
    if (json['disqusLogs'] != null) {
      json['disqusLogs'].forEach((v) {
        disqusLogs.add(DisqusLogs.fromJson(v));
      });
    }
    email = json['email'];
    room = json['room'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['mate'] = mate;
    data['room'] = room;
    data['email'] = email;
    data['disqusLogs'] = disqusLogs.map((v) => v.toJson()).toList();
    return data;
  }
}

class DisqusLogs {
  String? createdAt;
  String? txtMessages;
  String? receiver;
  String? postType;
  String? sender;
  bool? active;
  String? parentID;
  String? updatedAt;

  DisqusLogs({
    this.sender,
    this.active,
    this.parentID,
    this.receiver,
    this.postType,
    this.updatedAt,
    this.createdAt,
    this.txtMessages,
  });

  DisqusLogs.fromJson(Map<String, dynamic> json) {
    createdAt = json['createdAt'];
    txtMessages = json['txtMessages'];
    receiver = json['receiver'];
    postType = json['postType'];
    sender = json['sender'];
    active = json['active'];
    parentID = json['parentID'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['createdAt'] = createdAt;
    data['txtMessages'] = txtMessages;
    data['receiver'] = receiver;
    data['postType'] = postType;
    data['sender'] = sender;
    data['active'] = active;
    data['parentID'] = parentID;
    data['updatedAt'] = updatedAt;
    return data;
  }
}