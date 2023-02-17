class StoryViewsData {
  String? profilePicture;
  String? userID;
  String? fullName;
  String? username;
  bool? isLoading;

  StoryViewsData(
      {this.profilePicture,
      this.userID,
      this.fullName,
      this.username,
      this.isLoading});

  StoryViewsData.setLoading() {
    isLoading = true;
  }

  StoryViewsData.fromJson(Map<String, dynamic> json) {
    profilePicture = json['profilePicture'];
    userID = json['userID'];
    fullName = json['fullName'];
    username = json['username'];
  }
}
