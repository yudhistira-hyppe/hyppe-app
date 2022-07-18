import 'package:hyppe/core/models/collection/utils/user/user_data.dart';

class User {
  List<UserData> data = [];

  User({this.data = const []});

  User.fromJSON(dynamic json) {
    try {
      if (json["data"] != null) {
        json['data'][0]['data'].forEach((v) {
          data.add(UserData.fromJson(v));
        });
      }
    } catch (e) {
      if (json != null && json.isNotEmpty) {
        json.forEach((v) {
          data.add(UserData.fromJson(v));
        });
      } else {
        data = [];
      }
    }
  }
}
