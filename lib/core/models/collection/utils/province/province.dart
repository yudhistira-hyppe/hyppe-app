import 'package:hyppe/core/models/collection/utils/province/province_data.dart';

class Province {
  List<ProvinceData> data = [];

  Province({this.data = const []});

  Province.fromJSON(dynamic json) {
    try {
      if (json['data'] != null && json['data'].isNotEmpty) {
        json['data'].forEach((v) {
          data.add(ProvinceData.fromJSON(v));
        });
      } else {
        data = [];
      }
    } catch (e) {
      if (json != null && json.isNotEmpty) {
        json.forEach((v) {
          data.add(ProvinceData.fromJSON(v));
        });
      } else {
        data = [];
      }
    }
  }
}