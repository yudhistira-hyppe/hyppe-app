class RegisterReferralArgument {
  String? username; // user yang mau jadi referral
  String imei;
  String? email;
  List? listchallenge;

  RegisterReferralArgument({
    this.username,
    required this.imei,
    this.email,
    this.listchallenge,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    username != null ? data['username'] = username : '';
    data['imei'] = imei;
    email != null ? data['email'] = email : '';
    if (listchallenge != null) {
      data['listchallenge'] = listchallenge;
    }
    return data;
  }
}
