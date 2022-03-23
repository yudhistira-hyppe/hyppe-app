class IdProofData {
  String? isIdVerified;
  bool? isComplete;
  String? idProofName;
  String? idProofNumber;
  String? idProofUrl;

  IdProofData.fromJson(Map<String, dynamic> json) {
    isIdVerified = json['isIdVerified'];
    isComplete = json['isComplete'];
    idProofName = json['idProofName'];
    idProofNumber = json['idProofNumber'];
    idProofUrl = json['idProofUrl'];
  }
}
