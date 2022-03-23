import 'package:hyppe/core/models/collection/report/report_data.dart';

class Report {
  int? statusCode;
  List<ReportData> data = [];

  Report({this.statusCode});

  Report.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    if (json["data"].isNotEmpty) {
      json["data"].forEach((v) {
        data.add(ReportData.fromJson(v));
      });
    }
  }
}
