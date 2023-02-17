import 'package:hyppe/core/models/collection/faq/faq_detail.dart';

class FAQData{
  String? _id;
  String? kategori;
  String? tipe;
  String? datetime;
  String? idUser;
  bool? active;
  String? child;
  List<FAQDetail> detail = [];

  FAQData.fromJson(Map<String,dynamic> map){
    _id = map['_id'];
    kategori = map['kategori'];
    tipe = map['tipe'];
    datetime = map['datetime'];
    idUser = map['IdUser'];
    active = map['active'];
    child = map['child'];
    if(map['detail'] != null){
      map['detail'].forEach((v){
        detail.add(FAQDetail.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson(){
    final result = <String, dynamic>{};
    result['_id'] = _id;
    result['kategori'] = kategori;
    result['tipe'] = tipe;
    result['datetime'] = datetime;
    result['IdUser'] = idUser;
    result['active'] = active;
    result['child'] = child;
    result['detail'] = detail.map((e) => e.toJson()).toList();
    return result;
  }
}