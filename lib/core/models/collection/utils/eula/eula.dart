import 'package:hyppe/core/models/collection/utils/eula/eula_data.dart';

class Eula {
  List<EulaData> data = [];

  Eula.fromJSON(dynamic json) {
    try {
      if (json['data'] != null && json['data'].isNotEmpty) {
        json['data'].forEach((v) {
          data.add(EulaData.fromJSON(v));
        });
      } else {
        data = [];
      }
    } catch (e) {
      if (json != null && json.isNotEmpty) {
        json.forEach((v) {
          data.add(EulaData.fromJSON(v));
        });
      } else {
        data = [];
      }
    }
  }
}
