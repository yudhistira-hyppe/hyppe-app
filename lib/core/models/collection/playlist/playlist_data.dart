class PlaylistData {
  String? playlistID;
  String? playlistName;
  String? userID;
  String? visibility;
  String? status;

  PlaylistData.fromJsonResponseGet(Map<String, dynamic> json) {
    playlistID = json["playlistID"];
    playlistName = json["playlistName"];
  }

  PlaylistData.fromJsonResponsePost(Map<String, dynamic> json) {
    status = json["status"];
    userID = json["userID"];
    playlistID = json["playlistID"];
    visibility = json["visibility"];
    playlistName = json["playlistName"];
  }
}