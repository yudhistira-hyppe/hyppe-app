class ProvinceData {
  String? stateName;
  String? stateID;

  ProvinceData.fromJSON(Map<String, dynamic> json) {
    stateID = json["stateID"];
    stateName = json["stateName"];
  }
}