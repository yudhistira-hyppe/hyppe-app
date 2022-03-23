import 'package:hyppe/core/models/collection/search/search_account_data.dart';
import 'package:hyppe/core/models/collection/search/search_media_data.dart';

class Search {
  String? message;
  bool? isNext;
  List<SearchMediaData> data = [];
  List<SearchAccountsData> accountsData = [];

  Search.fromJson(Map<String, dynamic> json) {
    message = json["message"];
    if (json["data"] != null) {
      isNext = json["data"]["isNext"];
      json["data"]["posts"].forEach((v) => data.add(SearchMediaData.fromJson(v)));
    }
  }

  Search.fromJsonSearchGeneral(Map<String, dynamic> json) {
    message = json["message"];
    if (json["data"] != null) {
      isNext = json["data"]["isNext"];
      json["data"]["accounts"].forEach((v) => accountsData.add(SearchAccountsData.fromJson(v)));
    }
  }
}
