import 'package:hyppe/core/models/collection/playlist/playlist_data.dart';

class Playlist {
  int? total;
  int? statusCode;
  String? message;
  String? visibility;
  String? playlistName;
  PlaylistData? playlistData;
  List<PlaylistData> listPlaylistData = [];

  Playlist(
      {this.statusCode, this.message, this.total, this.visibility, this.playlistName, this.playlistData, this.listPlaylistData = const []});

  Playlist.fromJsonResponseGet(Map<String, dynamic> json) {
    statusCode = json["statusCode"];
    message = json["message"];
    total = json["total"];

    if (json["data"] == null && json["data"].isEmpty) {
      listPlaylistData = [];
    } else {
      json["data"].forEach((v) {
        listPlaylistData.add(PlaylistData.fromJsonResponseGet(v));
      });
    }
  }

  Playlist.fromJsonResponsePost(Map<String, dynamic> json) {
    statusCode = json["statusCode"];
    message = json["message"];
    playlistData = PlaylistData.fromJsonResponsePost(json["data"]["data"]);
  }

  static String _translateVisibility(String? v) {
    if (v == "Hanya Saya") {
      return "OM";
    }

    if (v == "Public") {
      return "P";
    }

    return "MF";
  }

  Map toMapPlaylistPost() {
    var _result = <String, dynamic>{};
    _result["playlistName"] = playlistName;
    _result["visibility"] = _translateVisibility(visibility);

    return _result;
  }
}
