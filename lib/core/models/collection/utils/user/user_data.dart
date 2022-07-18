class UserData {
  int? userId;
  String? userName;
  String? userFullName;
  String? image;

  UserData({
    this.userId,
    this.userName,
    this.userFullName,
    this.image,
  });
  static UserData fromJson(json) => UserData(
        userId: json['userId'],
        userName: json['userName'],
        userFullName: json['userFullName'],
        image: json['image'],
      );
}
