class SearchMediaData {
  String? creator;
  String? postType;
  String? postContent;
  String? description;
  String? userID;
  String? postID;
  List<String> htags = [];
  bool? isFollowing;

  SearchMediaData({this.creator, this.postType, this.postContent, this.description, this.userID, this.htags = const [], this.isFollowing});

  SearchMediaData.fromJson(Map<String, dynamic> json) {
    creator = json['creator'];
    postType = json['postType'];
    postContent = json['postContent'];
    description = json['description'];
    userID = json['userID'];
    postID = json['postID'];
    if (json['htags'] != null) {
      htags = json['htags'].cast<String>();
    }
    isFollowing = json['isFollowing'];
  }

  Map<String, String?> toJson() {
    final Map<String, String?> data = <String, String?>{};
    data['postType'] = postType;
    data['userID'] = userID;
    data['postID'] = postID;
    data['isSearch'] = 'true';
    return data;
  }
}
