class SearchHistory{
  int? id;
  String? keyword;
  String? datetime;

  SearchHistory({
    this.id,
    this.keyword,
    this.datetime
  });

  SearchHistory.fromJson(Map<String, dynamic> map){
    id = map['id'];
    keyword = map['keyword'];
    datetime = map['datetime'];
  }

  Map<String, dynamic> toJson({bool withID = false}){
    final result = <String, dynamic>{};
    if(withID){
      result['id'] = id;
    }

    result['keyword'] = keyword;
    result['datetime'] = datetime;
    return result;
  }
}