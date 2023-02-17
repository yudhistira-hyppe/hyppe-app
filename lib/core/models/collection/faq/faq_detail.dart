class FAQDetail{
  String? child;
  String? title;
  String? shortDescription;
  String? description;
  List<FAQDetail> detail = [];

  FAQDetail({
    this.child,
    this.title,
    this.shortDescription,
    this.description,
    this.detail = const []
  });

  FAQDetail.fromJson(Map<String, dynamic> map){
    child = map['child'];
    title = map['title'];
    shortDescription = map['shortDescription'];
    description = map['description'];
    if(map['detail'] != null){
      map['detail'].forEach((v){
        detail.add(FAQDetail.fromJson(v));
      });
    }

  }

  Map<String, dynamic> toJson(){
    final result = <String, dynamic>{};
    result['child'] = child;
    result['title'] = title;
    result['shortDescription'] = shortDescription;
    result['description'] = description;
    result['detail'] = detail.map((e) => e.toJson()).toList();
    return result;
  }
}