class CreatePostResponse {
  int? statusCode;
  String? message;
  String? postID;
  String? postType;
  String? userID;
  String? description;
  String? cts;
  String? typeFile;
  String? visibility;
  bool? allowComments;
  List<String>? postContentR = [];
  List<String?>? postContentS = [];

  CreatePostResponse(
      {this.statusCode,
      this.message,
      this.postID,
      this.postType,
      this.userID,
      this.description,
      this.cts,
      this.visibility,
      this.typeFile,
      this.allowComments,
      this.postContentS,
      this.postContentR});

  CreatePostResponse.fromJson(Map<String, dynamic> json) {
    statusCode = json["statusCode"];
    message = json["message"];
    postID = json["data"]["postID"];
    json["data"]["postContent"].forEach((v) {
      postContentR?.add(v);
    });
    postType = json["data"]["postType"];
    userID = json["data"]["userID"];
    description = json["data"]["description"];
    cts = json["data"]["cts"];
  }
}
