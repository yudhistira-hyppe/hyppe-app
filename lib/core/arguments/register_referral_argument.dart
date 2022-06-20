class RegisterReferralArgument {
  String username; // user yang mau jadi referral
  String imei;

  RegisterReferralArgument({
    required this.username,
    required this.imei

  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['username'] = username;
    data['imei'] = imei;
    return data;
  }
}
