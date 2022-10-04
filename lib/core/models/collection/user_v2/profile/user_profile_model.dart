import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/models/collection/user_v2/profile/user_profile_avatar_model.dart';
import 'package:hyppe/core/models/collection/user_v2/profile/user_profile_insight_model.dart';

class UserProfileModel {
  String? country;
  String? area;
  String? city;
  String? gender;
  String? mobileNumber;
  List<String>? roles;
  String? fullName;
  String? bio;
  UserProfileAvatarModel? avatar;
  UserProfileInsightModel? insight;
  bool? isEmailVerified;
  UserType? userType;
  String? token;
  String? langIso;
  List<String>? interest;
  String? profileID;
  String? dob;
  String? event;
  String? email;
  String? username;
  bool? isComplete;
  String? isIdVerified;
  String? status;
  String? refreshToken;
  String? idProofNumber;
  IdProofStatus? idProofStatus;
  bool? pinCreate;
  bool? pinVerified;

  UserProfileModel({
    this.country,
    this.area,
    this.city,
    this.gender,
    this.mobileNumber,
    this.roles,
    this.fullName,
    this.bio,
    this.avatar,
    this.insight,
    this.isEmailVerified,
    this.token,
    this.langIso,
    this.interest,
    this.profileID,
    this.dob,
    this.event,
    this.email,
    this.username,
    this.isComplete,
    this.isIdVerified,
    this.status,
    this.refreshToken,
    this.idProofNumber,
    this.pinCreate,
    this.pinVerified,
  });

  UserProfileModel.fromJson(Map<String, dynamic> json) {
    country = json['country'];
    idProofNumber = json['idProofNumber'];
    area = json['area'];
    city = json['city'];
    gender = json['gender'];
    mobileNumber = json['mobileNumber'];
    roles = json['roles'] != null ? json['roles'].cast<String>() : [];
    fullName = json['fullName'];
    bio = json['bio'];
    avatar = json['avatar'] != null ? UserProfileAvatarModel.fromJson(json['avatar']) : null;
    insight = json['insight'] != null ? UserProfileInsightModel.fromJson(json['insight']) : null;
    isEmailVerified = json["isEmailVerified"] is bool
        ? json["isEmailVerified"]
        : json["isEmailVerified"] == 'true'
            ? true
            : false;
    userType = _serializeUserType(isEmailVerified);
    token = json['token'];
    langIso = json['langIso'];
    interest = json['interest'] != null ? json['interest'].cast<String>() : [];
    profileID = json['profileID'];
    dob = json['dob'];
    event = json['event'];
    email = json['email'];
    username = json['username'];
    isComplete = json['isComplete'] is bool
        ? json['isComplete']
        : json['isComplete'] == "true"
            ? true
            : false;
    isIdVerified = json['isIdVerified'] ?? false;
    status = json['status'];
    refreshToken = json['refreshToken'];
    idProofStatus = _serializeIdProofStatus(json['idProofStatus']);
    pinVerified = json['pin_verified'] ?? false;
    pinCreate = json['pin_create'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['country'] = country;
    data['idProofNumber'] = idProofNumber;
    data['area'] = area;
    data['city'] = city;
    data['gender'] = gender;
    data['mobileNumber'] = mobileNumber;
    data['roles'] = roles;
    data['fullName'] = fullName;
    data['bio'] = bio;
    if (avatar != null) {
      data['avatar'] = avatar?.toJson();
    }
    if (insight != null) {
      data['insight'] = insight?.toJson();
    }
    data['isEmailVerified'] = isEmailVerified;
    data['userType'] = userType;
    data['token'] = token;
    data['langIso'] = langIso;
    data['interest'] = interest;
    data['profileID'] = profileID;
    data['dob'] = dob;
    data['event'] = event;
    data['email'] = email;
    data['username'] = username;
    data['isComplete'] = isComplete;
    data['isIdVerified'] = isIdVerified;
    data['status'] = status;
    data['refreshToken'] = refreshToken;
    data['pin_verified'] = pinVerified;
    data['pin_create'] = pinCreate;
    return data;
  }

  static UserType? _serializeUserType(bool? type) {
    switch (type) {
      case false:
        return UserType.notVerified;
      case true:
        return UserType.verified;
    }
  }

  static IdProofStatus? _serializeIdProofStatus(String? status) {
    switch (status) {
      case 'INITIAL':
        return IdProofStatus.initial;
      case 'IN_PROGRESS':
        return IdProofStatus.inProgress;
      case 'COMPLETE':
        return IdProofStatus.complete;
      case 'REVOKE':
        return IdProofStatus.revoke;
    }
  }
}
