import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/models/collection/user_v2/profile/user_profile_model.dart';

class UserInfoModel {
  UserProfileModel? profile;
  List<ContentData>? vids;
  List<ContentData>? diaries;
  List<ContentData>? pics;

  UserInfoModel({
    this.profile,
    this.vids,
    this.diaries,
    this.pics,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userProfile'] = profile?.toJson();
    data['userVid'] = [];
    data['userDiary'] = [];
    data['userPic'] = [];
    if (vids != null) {
      for (var v in vids!) {
        data['userVid'].add(v.toJson());
      }
    }
    if (diaries != null) {
      for (var v in diaries!) {
        data['userDiary'].add(v.toJson());
      }
    }
    if (pics != null) {
      for (var v in pics!) {
        data['userPic'].add(v.toJson());
      }
    }
    return data;
  }
}
