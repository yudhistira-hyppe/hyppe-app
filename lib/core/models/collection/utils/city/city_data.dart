class CityData {
  String? cityName;
  String? cityID;

  CityData.fromJSON(dynamic json) {
    try {
      cityName = json['cities'][0]['cityName'];
      cityID = json['cities'][0]['cityID'];
    } catch (e) {
      cityName = json['cityName'];
      cityID = json['cityID'];
    }
  }
}
