class FollowUser {
  String? fUserID; // user yang mau di follow
  String? userID; // user yang mau nge follow
  String? sts; // status follow

  FollowUser({this.fUserID, this.userID, this.sts});

  Map toMap() {
    var result = <String, dynamic>{};
    result["fUserID"] = fUserID;
    result["userID"] = userID;
    result["sts"] = sts;

    return result;
  }
}