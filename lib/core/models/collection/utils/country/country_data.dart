class CountryData {
  String? countryID;
  String? country;

  CountryData({this.countryID, this.country});

  CountryData.fromJson(Map<String, dynamic> json) {
    countryID = json["countryID"];
    country = json["country"];
  }
}