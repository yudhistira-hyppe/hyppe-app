class ReportData {
  String? action;
  String? remarkID;
  String? reportType;
  String? remark;
  String? postID;
  String? userID;
  String? langID;
  String? commentID;
  String? storyID;
  String? ruserID;

  ReportData({this.postID, this.userID, this.remarkID, this.langID, this.commentID, this.storyID, this.ruserID, this.reportType});

  ReportData.fromJson(Map<String, dynamic> json) {
    action = json['action'];
    remarkID = json['remarkID'];
    reportType = json['reportType'];
    remark = json['remark'];
  }

  Map toMap() {
    var result = <String, dynamic>{};

    result['userID'] = userID;
    result['langID'] = langID;
    result['remarkID'] = remarkID;
    if (postID != null) result['postID'] = postID;
    if (ruserID != null) result['ruserID'] = ruserID;
    if (storyID != null) result['storyID'] = storyID;
    if (commentID != null) result['commentID'] = commentID;
    if (reportType != null) result['reportType'] = reportType;

    return result;
  }
}
