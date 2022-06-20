class SignUpDataArgument {
  String email;
  String password;
  String deviceId;
  String imei;
  String platForm;

  SignUpDataArgument({
    required this.email,
    required this.password,
    required this.deviceId,
    required this.imei,
    required this.platForm
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['email'] = email;
    data['password'] = password;
    data['deviceId'] = deviceId;
    data['imei'] = imei;
    data['regSrc'] = platForm;
    return data;
  }
}
