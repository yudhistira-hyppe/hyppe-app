
class User {
  String? id;
  String? title;
  String? url;
  String? textUrl;
  String? userId;
  User1? user;
  bool? status;
  int? expireTime;
  String? createAt;
  String? tokenAgora;

  User({this.id, this.title, this.url, this.textUrl, this.userId, this.user, this.status, this.expireTime, this.createAt, this.tokenAgora});

  User.fromJson(Map<String, dynamic> json) {
    if(json["_id"] is String) {
      id = json["_id"];
    }
    if(json["title"] is String) {
      title = json["title"];
    }
    if(json["url"] is String) {
      url = json["url"];
    }
    if(json["textUrl"] is String) {
      textUrl = json["textUrl"];
    }
    if(json["userId"] is String) {
      userId = json["userId"];
    }
    if(json["user"] is Map) {
      user = json["user"] == null ? null : User1.fromJson(json["user"]);
    }
    if(json["status"] is bool) {
      status = json["status"];
    }
    if(json["expireTime"] is int) {
      expireTime = json["expireTime"];
    }
    if(json["createAt"] is String) {
      createAt = json["createAt"];
    }
    if(json["tokenAgora"] is String) {
      tokenAgora = json["tokenAgora"];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["_id"] = id;
    _data["title"] = title;
    _data["url"] = url;
    _data["textUrl"] = textUrl;
    _data["userId"] = userId;
    if(user != null) {
      _data["user"] = user?.toJson();
    }
    _data["status"] = status;
    _data["expireTime"] = expireTime;
    _data["createAt"] = createAt;
    _data["tokenAgora"] = tokenAgora;
    return _data;
  }
}

class User1 {
  String? id;
  String? email;
  String? fullName;
  String? username;

  User1({this.id, this.email, this.fullName, this.username});

  User1.fromJson(Map<String, dynamic> json) {
    if(json["_id"] is String) {
      id = json["_id"];
    }
    if(json["email"] is String) {
      email = json["email"];
    }
    if(json["fullName"] is String) {
      fullName = json["fullName"];
    }
    if(json["username"] is String) {
      username = json["username"];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["_id"] = id;
    _data["email"] = email;
    _data["fullName"] = fullName;
    _data["username"] = username;
    return _data;
  }
}