class UpdateCommentReaction {
  int? count;
  List<String?>? reactions = [];

  UpdateCommentReaction({this.reactions, this.count});

  UpdateCommentReaction.fromJson(Map<String, dynamic> json) {
    count = json["data"]["count"];
    if (json["data"]["reactions"].isEmpty) {
      reactions = [];
    } else {
      json["data"]["reactions"].forEach((v) {
        reactions?.add(v["icon"]);
      });
    }
  }
}