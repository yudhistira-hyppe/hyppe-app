import 'package:hyppe/core/models/collection/utils/welcome/welcome_data.dart';

class Welcome {
  List<WelcomeData> data = [];

  Welcome.fromJSON(dynamic json) {
    try {
      if (json['data'] != null) {
        json['data'].forEach((v) {
          data.add(WelcomeData.fromJSON(v));
        });
      }
    } catch (e) {
      if (json != null && json.isNotEmpty) {
        data.add(WelcomeData.fromJSON(json[1]['content']));
      } else {
        data = [];
      }
    }
  }
}
