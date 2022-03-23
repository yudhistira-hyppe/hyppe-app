class PostReactionArgument {
  String? eventType;
  String? postID;
  String? receiverParty;
  String? reactionUri;

  PostReactionArgument({
    this.eventType,
    this.postID,
    this.receiverParty,
    this.reactionUri,
  });

  PostReactionArgument.fromJson(Map<String, dynamic> json) {
    eventType = json['eventType'];
    postID = json['postID'];
    receiverParty = json['receiverParty'];
    reactionUri = json['reactionUri'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['eventType'] = eventType;
    data['postID'] = postID;
    data['receiverParty'] = receiverParty;
    data['reactionUri'] = reactionUri;
    return data;
  }
}
