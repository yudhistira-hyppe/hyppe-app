class SignUpCompleteProfiles {
  String? email;
  String? country;
  String? area;
  String? city;
  String? mobileNumber;
  String? idProofNumber;
  String? gender;
  String? dateOfBirth;
  String? langIso;
  String? bio;
  String? fullName;
  List<String>? interests;
  String? username;
  String? urlLink;
  String? judulLink;

  SignUpCompleteProfiles({
    this.email,
    this.country,
    this.area,
    this.city,
    this.mobileNumber,
    this.idProofNumber,
    this.gender,
    this.dateOfBirth,
    this.langIso,
    this.bio,
    this.fullName,
    this.interests,
    this.username,
    this.urlLink,
    this.judulLink
  });

  Map<String, dynamic> toUpdateProfileJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["email"] = email;
    data["fullName"] = fullName;
    data["country"] = country;
    data["area"] = area;
    data["city"] = city;
    data["mobileNumber"] = mobileNumber;
    data["idProofNumber"] = idProofNumber;
    data["gender"] = gender;
    data["dob"] = dateOfBirth;
    data["langIso"] = langIso;
    data["interest"] = interests;
    // if (username != null) {
    //   data["username"] = username;
    // }
    data["event"] = "UPDATE_PROFILE";
    data["status"] = "COMPLETE_BIO";
    data["urlLink"] = urlLink;
    data["judulLink"] = judulLink;
    return data;
  }

  Map<String, dynamic> toUpdateBioJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["email"] = email;
    data["bio"] = bio;
    data["fullName"] = fullName;
    if (username != null) {
      data["username"] = username;
    }
    data["event"] = "UPDATE_BIO";
    data["status"] = "IN_PROGRESS";
    data["urlLink"] = urlLink;
    data["judulLink"] = judulLink;
    return data;
  }
}
