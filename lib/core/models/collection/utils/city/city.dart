import 'package:hyppe/core/models/collection/utils/city/city_data.dart';

class City {
  List<CityData> data = [];

  City({this.data = const []});

  City.fromJSON(dynamic json) {
    try {
      if (json["data"] != null) {
        json['data'][0]['data'].forEach((v) {
          data.add(CityData.fromJSON(v));
        });
      }
    } catch (e) {
      if (json != null && json.isNotEmpty) {
        json.forEach((v) {
          data.add(CityData.fromJSON(v));
        });
      } else {
        data = [];
      }
    }
  }
}
