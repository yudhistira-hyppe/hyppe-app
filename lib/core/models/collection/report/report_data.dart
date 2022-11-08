class ReportData {
  String? sId;
  String? description;
  String? language;
  String? reason;
  String? type;

  ReportData({this.sId, this.description, this.language, this.reason, this.type});

  ReportData.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    description = json['description'];
    language = json['language'];
    reason = json['reason'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['description'] = description;
    data['language'] = language;
    data['reason'] = reason;
    data['type'] = type;
    return data;
  }
}
