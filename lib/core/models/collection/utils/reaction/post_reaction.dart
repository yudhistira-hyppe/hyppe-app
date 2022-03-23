class PostReaction {
  final String? postID;
  final String? userID;
  final String? rUserID;
  final String? reactionID;
  final bool? isLike;
  final String? commentID;
  final String? commentType;
  final dynamic reaction;
  final String? reactionType;
  final String? reactionUnicode;

  const PostReaction(
      {this.postID,
        this.userID,
        this.rUserID,
        this.reactionID,
        this.isLike,
        this.commentID,
        this.commentType,
        this.reaction,
        this.reactionType,
        this.reactionUnicode});

  Map toMap() {
    var result = <String, dynamic>{};

    result["postID"] = postID;
    result["userID"] = userID;
    result["rUserID"] = rUserID;
    if (isLike!) result["reactionID"] = reactionID;
    result["isLike"] = isLike;

    return result;
  }

  Map toMapStoryReaction() {
    var result = <String, dynamic>{};

    result["storyID"] = postID;
    result["userID"] = userID;
    result["rUserID"] = rUserID;
    result["reactionId"] = reactionID;
    result["isLike"] = isLike;

    return result;
  }

  Map toMapReactOnComment() {
    var result = <String, dynamic>{};

    result["postID"] = postID;
    result["userID"] = userID;
    result["cID"] = commentID;
    result["cType"] = commentType;
    result["reaction"] = reaction;
    result["reactionID"] = reactionID;
    result["reactionType"] = reactionType;
    result["reactionUnicode"] = reactionUnicode;

    return result;
  }
}