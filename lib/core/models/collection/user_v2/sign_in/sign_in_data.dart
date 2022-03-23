import 'package:hyppe/core/constants/enum.dart';

class SignInData {
  String? userId;
  bool? isEmailVerified;
  UserType? userType;
  String? fullName;
  String? email;
  bool? isComplete;
  String? username;
  String? token;

  SignInData.fromJson(Map<String, dynamic> json) {
    userId = json["userID"];
    isEmailVerified = json["isEmailVerified"] is bool
        ? json["isEmailVerified"]
        : json["isEmailVerified"] == 'true'
            ? true
            : false;
    userType = _serializeUserType(isEmailVerified);
    fullName = json['fullName'];
    email = json['email'];
    isComplete = json['isComplete'] is bool
        ? json['isComplete']
        : json['isComplete'] == 'true'
            ? true
            : false;
    username = json['username'];
    token = json['token'];
  }

  static UserType? _serializeUserType(bool? type) {
    switch (type) {
      case false:
        return UserType.notVerified;
      case true:
        return UserType.verified;
    }
  }
}
