class ErrorModel {
  int? statusCode;
  String? error;
  String? message;

  ErrorModel({this.statusCode, this.error, this.message});

  ErrorModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    error = json['error'];
    message = json['message'] ?? json['messages']['info'][0];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['statusCode'] = statusCode;
    data['error'] = error;
    data['message'] = message;
    return data;
  }
}
