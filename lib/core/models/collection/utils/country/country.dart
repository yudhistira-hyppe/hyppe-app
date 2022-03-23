import 'package:hyppe/core/models/collection/utils/country/country_data.dart';

class Country {
  List<CountryData> data = [];

  Country({this.data = const []});

  Country.fromJSON(dynamic json) {
    try {
      if (json['data'] != null && json['data'].isNotEmpty) {
        json['data'].forEach((v) {
          data.add(CountryData.fromJson(v));
        });
      } else {
        data = [];
      }
    } catch (e) {
      if (json != null && json.isNotEmpty) {
        json.forEach((v) {
          data.add(CountryData.fromJson(v));
        });
      } else {
        data = [];
      }
    }
  }
}
