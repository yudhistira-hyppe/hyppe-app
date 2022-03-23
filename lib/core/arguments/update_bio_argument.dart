class UpdateBioArgument {
  String? email;
  String? bio;
  String? fullName;

  UpdateBioArgument({
    this.email,
    this.bio,
    this.fullName,
  });

  UpdateBioArgument.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    bio = json['bio'];
    fullName = json['fullName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['email'] = email;
    data['bio'] = bio;
    data['fullName'] = fullName;
    data["event"] = "UPDATE_BIO";
    data["status"] = "IN_PROGRESS";
    return data;
  }
}
