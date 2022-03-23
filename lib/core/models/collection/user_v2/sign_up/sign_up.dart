class SignUp {
  String? email;
  String? password;
  String? deviceId;
  String? langIso;
  List<String?>? listOfInterest;
  String? gender;

  SignUp({this.email, this.password, this.deviceId, this.langIso, this.listOfInterest, this.gender});

  Map<String, dynamic> toJson() {
    var result = <String, dynamic>{};
    result["email"] = email;
    result["password"] = password;
    result["deviceId"] = deviceId;
    result["langIso"] = langIso;
    if (listOfInterest!.isNotEmpty) {
      result["interest"] = listOfInterest;
    }
    result["gender"] = gender;
    return result;
  }
}
