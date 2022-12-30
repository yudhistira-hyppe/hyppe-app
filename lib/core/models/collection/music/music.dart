import 'package:hyppe/core/extension/log_extension.dart';

class Music{
  String? id;
  String? musicTitle;
  String? artistName;
  String? albumName;
  String? releaseDate;
  String? genre;
  String? theme;
  String? mood;
  bool? isDelete;
  bool? isActive;
  String? createdAt;
  String? updatedAt;
  String? apsaraMusic;
  MusicUrl? apsaraMusicUrl;
  String? apsaraThumnail;
  String? apsaraThumnailUrl;
  bool isPlay = false;
  bool isLoad = false;
  bool isSelected = false;
  Music({this.id, this.musicTitle, this.artistName, this.albumName, this.releaseDate,
    this.genre, this.theme, this.mood, this.createdAt, this.updatedAt, this.isDelete,
    this.isActive, this.apsaraMusic, this.apsaraMusicUrl, this.apsaraThumnail, this.apsaraThumnailUrl});

  Music.fromJson(Map<String, dynamic> map) {
    id = map['_id'];
    musicTitle = map['musicTitle'];
    artistName = map['artistName'];
    albumName = map['albumName'];
    releaseDate = map['releaseDate'];
    genre = map['genre'];
    theme = map['theme'];
    mood = map['mood'];
    isDelete = map['isDelete'];
    isActive = map['isActive'];
    createdAt = map['createdAt'];
    updatedAt = map['updatedAt'];
    apsaraMusic = map['apsaraMusic'];
    if(map['apsaraMusicUrl'] != null){
      apsaraMusicUrl = MusicUrl.fromJson(map['apsaraMusicUrl']);
    }else{
      apsaraMusicUrl = MusicUrl();
    }

    apsaraThumnail = map['apsaraThumnail'];
    apsaraThumnailUrl = map['apsaraThumnailUrl'];
    isPlay = false;
    isLoad = false;
    isSelected = false;
  }



  Map<String, dynamic> toJson(){
    var result = <String, dynamic>{};
    result['id'] = id;
    result['musicTitle'] = musicTitle;
    result['artistName'] = artistName;
    result['albumName'] = albumName;
    result['releaseDate'] = releaseDate;
    result['genre'] = genre;
    result['theme'] = theme;
    result['mood'] = mood;
    result['isDelete'] = isDelete;
    result['isActive'] = isActive;
    result['createdAt'] = createdAt;
    result['updatedAt'] = updatedAt;
    result['apsaraMusic'] = apsaraMusic;
    result['apsaraMusicUrl'] = apsaraMusicUrl;
    result['apsaraThumnail'] = apsaraThumnail;
    result['apsaraThumnailUrl'] = apsaraThumnailUrl;
    result['is_play'] = isPlay;
    result['is_load'] = isLoad;
    result['is_selected'] = isSelected;
    return result;
  }
}

class MusicUrl{
  String? playUrl;
  double? duration;

  MusicUrl({this.playUrl, this.duration});

  MusicUrl.fromJson(Map<String, dynamic> map){
    if(map['PlayURL'] != null){
      playUrl = map['PlayURL'];
    }else{
      playUrl = map['PlayUrl'];
    }

    try{
      final String dur = map['Duration'];
      duration = double.parse(dur);
    }catch(e){
      'Error get String Duration : $e'.logger();
    }

  }

  Map<String, dynamic> toJson(){
    final result = <String, dynamic>{};
    result['PlayURL'] = playUrl;
    result['Duration'] = duration;
    return result;
  }
}

