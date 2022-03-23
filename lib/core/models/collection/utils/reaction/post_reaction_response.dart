class PostReactionResponse {
  int? statusCode;
  String? message;
  bool? status;
  int? lCount;
  int? dlCount;
  int? data; // variable for add story reaction response

  PostReactionResponse(
      {this.statusCode, this.message, this.status = false});

  PostReactionResponse.fromJson(Map<String, dynamic> json) {
    statusCode = json["statusCode"];
    message = json["message"];
    status = json["data"]["status"];
    lCount = json["data"]["lCount"];
    dlCount = json["data"]["dlCount"];
  }

  PostReactionResponse.fromJsonAddStoryReaction(
      Map<String, dynamic> json) {
    statusCode = json["statusCode"];
    message = json["message"];
    data = json["data"];
  }
}
