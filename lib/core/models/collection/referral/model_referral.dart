class ModelReferral {
  String? parent;
  int? responseCode;
  int? data;
  Messages? messages;
  List<ListReferral>? list;

  ModelReferral(
      {this.parent, this.responseCode, this.data, this.messages, this.list});

  ModelReferral.fromJson(Map<String, dynamic> json) {
    parent = json['parent'];
    responseCode = json['response_code'];
    data = json['data'];
    messages = json['messages'] != null
        ? new Messages.fromJson(json['messages'])
        : null;
    if (json['list'] != null) {
      list = <ListReferral>[];
      json['list'].forEach((v) {
        list!.add(new ListReferral.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['parent'] = this.parent;
    data['response_code'] = this.responseCode;
    data['data'] = this.data;
    if (this.messages != null) {
      data['messages'] = this.messages!.toJson();
    }
    if (this.list != null) {
      data['list'] = this.list!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Messages {
  List<String>? info;

  Messages({this.info});

  Messages.fromJson(Map<String, dynamic> json) {
    info = json['info'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['info'] = this.info;
    return data;
  }
}

class ListReferral {
  String? sId;
  String? parent;
  String? children;
  bool? active;
  bool? verified;
  String? imei;
  String? createdAt;
  String? updatedAt;

  ListReferral(
      {this.sId,
      this.parent,
      this.children,
      this.active,
      this.verified,
      this.imei,
      this.createdAt,
      this.updatedAt});

  ListReferral.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    parent = json['parent'];
    children = json['children'];
    active = json['active'];
    verified = json['verified'];
    imei = json['imei'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['parent'] = this.parent;
    data['children'] = this.children;
    data['active'] = this.active;
    data['verified'] = this.verified;
    data['imei'] = this.imei;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}
