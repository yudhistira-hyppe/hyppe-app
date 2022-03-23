class InterestData {
  String? cts;
  String? interestName;
  String? langID;
  String? icon;

  InterestData({this.cts, this.interestName, this.icon, this.langID});

  InterestData.fromJson(Map<String, dynamic> json) {
    cts = json["cts"];
    interestName = json["interestName"];
    langID = json["langID"];
    icon = json["icon"];
  }
}