class ReferralUserArgument {
  String email; // user yang mau jadi referral
  String imei;

  ReferralUserArgument({
    required this.email,
    required this.imei

  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['email'] = email;
    data['imei'] = imei;
    return data;
  }
}
