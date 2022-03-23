class BookmarkData {
  String? contentID;
  String? contentUrl;
  String? status;

  BookmarkData.fromJson(Map<String, dynamic> json) {
    status = json["status"];
    contentID = json["contentID"];
    contentUrl = json["contentUrl"];
  }
}