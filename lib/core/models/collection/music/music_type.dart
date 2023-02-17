
class MusicType{
  String? id;
  String? name;
  String? langIso;
  String? createdAt;
  String? updatedAt;
  MusicType({this.id, this.name, this.createdAt, this.updatedAt});

  MusicType.fromJson(Map<String, dynamic> map){
    id = map['_id'];
    name = map['name'];
    langIso = map['langIso'];
    createdAt = map['createdAt'];
    updatedAt = map['updatedAt'];
  }

  Map<String, dynamic> toJson(){
    final result = <String, dynamic>{};
    result['_id'] = id;
    result['name'] = name;
    result['langIso'] = langIso;
    result['createdAt'] = createdAt;
    result['updatedAt'] = updatedAt;
    return result;
  }
}

class MusicGroupType{
  String group;
  bool isSeeAll;
  MusicGroupType({required this.group, required this.isSeeAll});
}