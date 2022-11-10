import 'package:hyppe/core/models/collection/report/report_data.dart';

class Report {
  int? statusCode;
  List<ReportData> data = [];
  String? message;

  Report({this.statusCode});

  Report.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    message = json['message'] ?? '';
    if (json["data"].isNotEmpty) {
      json["data"].forEach((v) {
        data.add(ReportData.fromJson(v));
      });
    }
  }
}
