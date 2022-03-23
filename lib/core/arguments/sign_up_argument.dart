class SignUpDataArgument {
  String email;
  String password;
  String deviceId;

  SignUpDataArgument({
    required this.email,
    required this.password,
    required this.deviceId,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['email'] = email;
    data['password'] = password;
    data['deviceId'] = deviceId;
    return data;
  }
}
