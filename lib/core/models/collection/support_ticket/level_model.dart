class LevelTicketModel {
  String? sId;
  String? nameLevel;
  String? descLevel;

  LevelTicketModel({this.sId, this.nameLevel, this.descLevel});

  LevelTicketModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    nameLevel = json['nameLevel'];
    descLevel = json['descLevel'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['nameLevel'] = nameLevel;
    data['descLevel'] = descLevel;
    return data;
  }
}
