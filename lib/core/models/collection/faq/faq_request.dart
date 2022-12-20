class FAQRequest{
  String? type;
  String? kategori;

  FAQRequest({required this.type, required this.kategori});

  FAQRequest.fromJson(Map<String, dynamic> map){
    type = map['tipe'];
    kategori = map['kategori'];
  }

  Map<String, dynamic> toJson(){
    final result = <String, dynamic>{};
    result['tipe'] = type;
    result['kategori'] = kategori ?? '';
    return result;
  }
}