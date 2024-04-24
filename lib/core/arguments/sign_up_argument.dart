class SignUpDataArgument {
  String email;
  String password;
  String deviceId;
  String imei;
  String platForm;
  String lang;
  String? referral;

  SignUpDataArgument({required this.email, required this.password, required this.deviceId, required this.imei, required this.platForm, this.lang = 'id', this.referral});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['email'] = email;
    data['password'] = password;
    data['deviceId'] = deviceId;
    data['imei'] = imei;
    data['regSrc'] = platForm;
    data['lang'] = lang;
    data['referral'] = referral;
    return data;
  }
}
