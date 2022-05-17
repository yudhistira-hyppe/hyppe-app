class ReferralUserArgument {
  String email; // user yang mau jadi referral

  ReferralUserArgument({
    required this.email,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['email'] = email;
    return data;
  }
}
