class SearchAccountsData {
  bool? isCelebrity;
  String? fullName;
  String? email;
  String? username;
  String? userID;
  bool? isFollowing;
  String? profilePicture;

  SearchAccountsData.fromJson(Map<String, dynamic> json) {
    isCelebrity = json['isCelebrity'];
    fullName = json['fullName'];
    email = json['email'];
    username = json['username'];
    userID = json['userID'];
    isFollowing = json['isFollowing'] ?? false;
    profilePicture = json['profilePicture'];
  }
}
