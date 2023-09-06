class BannerRequest {
  String keyword;
  bool statustayang;
  bool ascending;
  int page;
  int limit;

  BannerRequest(
      {this.keyword = 'hyppe',
      this.statustayang = true,
      this.ascending = true,
      this.page = 0,
      this.limit = 10});

  // BannerRequest.fromJson(Map<String, dynamic> map){
  //   keyword = map['keyword'] ?? '';
  //   startdate = map['startdate'] ?? '';
  //   enddate = map['enddate'] ?? '';
  //   statustayang = map['statustayang'] ?? false;
  //   ascending = map['ascending'] ?? false;
  //   page = map['page'] ?? 0;
  //   limit = map['limit'] ?? 10;
  // }

  Map<String, dynamic> toJson() {
    final result = <String, dynamic>{};
    result['keyword'] = keyword;
    result['statustayang'] = statustayang;
    result['ascending'] = ascending;
    result['page'] = page;
    result['limit'] = limit;
    return result;
  }
}
