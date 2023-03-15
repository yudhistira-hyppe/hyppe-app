import 'dart:typed_data';

class LocalThumbnail{
  String? id;
  Uint8List? thumbnail;

  LocalThumbnail({required this.id, required this.thumbnail});

  LocalThumbnail.fromJson(Map<String, dynamic> json){
    id = json['id_post'];
    thumbnail = json['image'];
  }

  Map<String, dynamic> toJson(){
    final result = <String, dynamic>{};
    result['id_post'] = id;
    result['image'] = thumbnail;
    return result;
  }
}