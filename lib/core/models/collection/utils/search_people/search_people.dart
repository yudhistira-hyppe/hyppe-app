import 'package:hyppe/core/models/collection/comment_v2/comment_data_v2.dart';
import 'package:hyppe/core/models/collection/common/user_badge_model.dart';

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
  UserBadgeModel? urluserBadge;

  SearchPeolpleData({
    this.id,
    this.avatar,
    this.idUserAuth,
    this.username,
    this.fullName,
    this.email,
    this.urluserBadge,
  });

  factory SearchPeolpleData.createPeopleData(Map<String, dynamic> object) => SearchPeolpleData(
        id: object['id'],
        avatar: object['avatar'] != null ? Avatar.fromJson(object['avatar']) : null,
        idUserAuth: object['idUserAuth'],
        username: object['username'],
        fullName: object['fullName'],
        email: object['email'],
        urluserBadge:
            object['urluserBadge'] != null && object['urluserBadge'].isNotEmpty
                ? object['urluserBadge'] is List
                    ? UserBadgeModel.fromJson(object['urluserBadge'].first)
                    : UserBadgeModel.fromJson(object['urluserBadge'])
                : null,
      );

  static SearchPeolpleData fromJson(json) => SearchPeolpleData(
        id: json['_id'],
        avatar: json['avatar'] != null ? Avatar.fromJson(json['avatar']) : null,
        idUserAuth: json['idUserAuth'],
        username: json['username'],
        fullName: json['fullName'],
        email: json['email'],
        urluserBadge:
            json['urluserBadge'] != null && json['urluserBadge'].isNotEmpty
                ? json['urluserBadge'] is List
                    ? UserBadgeModel.fromJson(json['urluserBadge'].first)
                    : UserBadgeModel.fromJson(json['urluserBadge'])
                : null,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "avatar": avatar?.toJson(),
        "idUserAuth": idUserAuth,
        "username": username,
        "fullName": fullName,
        "email": email,
        "urluserBadge": urluserBadge,
      };

  void forEach(Null Function(dynamic v) param0) {}
}
