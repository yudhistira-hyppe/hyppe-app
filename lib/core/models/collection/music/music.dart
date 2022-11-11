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
  int? duration;
  String? url;
  String? urlThumbnail;
  bool isPlay = false;
  bool isLoad = false;
  bool isSelected = false;
  Music({this.id, this.musicTitle, this.artistName, this.albumName, this.releaseDate,
    this.genre, this.theme, this.mood, this.createdAt, this.updatedAt, this.isDelete,
    this.isActive, this.apsaraMusic, this.duration, this.url, this.urlThumbnail});

  Music.fromJson(Map<String, dynamic> map){
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
    duration = map['duration'];
    url = map['url'];
    urlThumbnail = map['url_thumbnail'];
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
    result['duration'] = duration;
    result['url'] = url;
    result['url_thumbnail'] = urlThumbnail;
    result['is_play'] = isPlay;
    result['is_load'] = isLoad;
    result['is_selected'] = isSelected;
    return result;
  }
}