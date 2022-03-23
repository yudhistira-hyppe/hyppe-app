import 'package:hyppe/core/constants/thumb/profile_image.dart';

class CommentCommentor {
  String? profilePicture;
  String? userID;
  String? fullName;
  String? username;
  String? isCelebrity;

  CommentCommentor({this.fullName, this.profilePicture, this.username, this.userID});

  CommentCommentor.fromJson(Map<String, dynamic> json) {
    if (json["profilePicture"] != null && json["profilePicture"].isNotEmpty) {
      profilePicture = json["profilePicture"];
    } else {
      profilePicture = PROFILEPICDEFAULT;
    }
    userID = json["userID"] as String?;
    fullName = json["fullName"] as String?;
    username = json["username"] as String?;
    isCelebrity = json["isCelebrity"] as String?;
  }
}
