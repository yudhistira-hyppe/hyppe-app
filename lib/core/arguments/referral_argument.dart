class ReferralUserArgument {
  String email; // user yang mau jadi referral
  String imei;
  List? listchallenge;

  ReferralUserArgument({
    required this.email,
    required this.imei,
    this.listchallenge,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['email'] = email;
    data['imei'] = imei;
    if (listchallenge != null) {
      data['listchallenge'] = listchallenge;
    }
    return data;
  }
}
