class DocumentData {
  String? documentId;
  String? documentName;
  String? countryCode;
  String? langIso;
  String? createdAt;
  String? updatedAt;

  DocumentData.fromJson(Map<String, dynamic> json) {
    documentId = json["documentId"];
    documentName = json['documentName'];
    countryCode = json['countryCode'];
    langIso = json['langIso'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }
}
