class SignUpDataArgument {
  String email;
  String password;
  String deviceId;
  String imei;

  SignUpDataArgument({
    required this.email,
    required this.password,
    required this.deviceId,
    required this.imei,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['email'] = email;
    data['password'] = password;
    data['deviceId'] = deviceId;
    data['imei'] = imei;
    return data;
  }
}
