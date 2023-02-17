import '../models/collection/faq/faq_detail.dart';

class FAQArgument{
  List<FAQDetail> details = [];
  bool isLogin = false;

  FAQArgument({required this.details, this.isLogin = false});

  FAQArgument.fromJson(Map<String, dynamic> map){
    if(map['details'] != null){
      map['details'].forEach((v){
        details.add(FAQDetail.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson(){
    final result = <String, dynamic>{};
    result['details'] = details.map((e) => e.toJson()).toList();
    return result;
  }
}