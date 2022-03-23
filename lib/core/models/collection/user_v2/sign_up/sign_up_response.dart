import 'package:hyppe/core/models/collection/user_v2/profile/user_profile_insight_model.dart';

class SignUpResponse {
  String? event;
  String? email;
  String? status;
  String? fullName;
  String? userName;
  String? isComplete;
  List<String>? roles;
  List<String>? interest;
  String? isEmailVerified;
  UserProfileInsightModel? insight;

  @Deprecated('Ignore this')
  String? userID;

  SignUpResponse.fromJson(Map<String, dynamic> json) {
    insight = json['insight'] != null ? UserProfileInsightModel.fromJson(json['insight']) : null;
    interest = json['interest'] != null ? json['interest'].cast<String>() : [];
    roles = json['roles'] != null ? json['roles'].cast<String>() : [];
    fullName = json['fullName'];
    event = json['event'];
    email = json['email'];
    isEmailVerified = json['isEmailVerified'];
    userName = json['username'];
    isComplete = json['isComplete'];
    status = json['status'];
  }
}
