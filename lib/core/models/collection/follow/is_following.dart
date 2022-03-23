class IsFollowing {
  int? statusCode;
  String? message;
  String? sts;

  IsFollowing({this.statusCode, this.message});

  IsFollowing.fromJson(Map<String, dynamic> json, {bool fromCache = false}) {
    statusCode = json["statusCode"];
    message = json["message"];
    sts = !fromCache ? json["data"]["sts"] : json["sts"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['statusCode'] = statusCode;
    data['message'] = message;
    data['sts'] = sts;
    return data;
  }
}
