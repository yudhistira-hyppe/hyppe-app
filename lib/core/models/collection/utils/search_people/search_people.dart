import 'package:hyppe/core/models/collection/comment_v2/comment_data_v2.dart';

class ModelSearchPeople {
  ModelSearchPeople({
    this.data,
  });

  List<SearchPeolpleData>? data;

  factory ModelSearchPeople.fromJson(Map<String, dynamic> json) => ModelSearchPeople(
        data: List<SearchPeolpleData>.from(json["data"].map((x) => SearchPeolpleData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data??[].map((x) => x.toJson())),
      };
}

class SearchPeolpleData {
  String? id;
  Avatar? avatar;
  String? idUserAuth;
  String? username;
  String? fullName;
  String? email;

  SearchPeolpleData({
    this.id,
    this.avatar,
    this.idUserAuth,
    this.username,
    this.fullName,
    this.email,
  });

  factory SearchPeolpleData.createPeopleData(Map<String, dynamic> object) => SearchPeolpleData(
        id: object['id'],
        avatar: object['avatar'] != null ? Avatar.fromJson(object['avatar']) : null,
        idUserAuth: object['idUserAuth'],
        username: object['username'],
        fullName: object['fullName'],
        email: object['email'],
      );

  static SearchPeolpleData fromJson(json) => SearchPeolpleData(
        id: json['_id'],
        avatar: json['avatar'] != null ? Avatar.fromJson(json['avatar']) : null,
        idUserAuth: json['idUserAuth'],
        username: json['username'],
        fullName: json['fullName'],
        email: json['email'],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "avatar": avatar?.toJson(),
        "idUserAuth": idUserAuth,
        "username": username,
        "fullName": fullName,
        "email": email,
      };

  void forEach(Null Function(dynamic v) param0) {}
}
