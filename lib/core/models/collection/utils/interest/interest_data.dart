import 'package:hyppe/core/services/system.dart';

class InterestData {
  String? cts;
  String? interestName;
  String? interestNameId;
  String? langID;
  String? icon;
  String? id;

  InterestData({
    this.cts,
    this.interestName,
    this.interestNameId,
    this.icon,
    this.id,
    this.langID,
  });

  InterestData.fromJson(Map<String, dynamic> json) {
    cts = json["cts"];
    id = json['_id'];
    interestName = System().bodyMultiLang(
      bodyEn: json["interestName"],
      bodyId: json["interestNameId"],
    );
    interestNameId = json["interestNameId"];
    langID = json["langID"];
    icon = json["icon"];
  }
}
