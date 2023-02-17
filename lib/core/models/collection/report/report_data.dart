class ReportData {
  String? sId;
  String? description;
  String? language;
  String? reason;
  String? type;
  String? reasonEn;

  ReportData({this.sId, this.description, this.language, this.reason, this.type, this.reasonEn});

  ReportData.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    description = json['description'];
    language = json['language'];
    reason = json['reason'];
    reasonEn = json['reasonEn'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['description'] = description;
    data['language'] = language;
    data['reason'] = reason;
    data['reasonEn'] = reasonEn;
    data['type'] = type;
    return data;
  }
}
