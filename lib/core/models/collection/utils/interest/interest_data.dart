import 'package:hyppe/core/services/system.dart';

class InterestData {
  String? id;
  String? cts;
  String? interestName;
  String? interestNameId;
  String? langID;
  String? icon;

  InterestData({
    this.cts,
    this.interestName,
    this.interestNameId,
    this.icon,
    this.id,
    this.langID,
  });

  InterestData.fromJson(Map<String, dynamic> json) {
    id = json["_id"];
    cts = json["cts"];
    interestName = System().bodyMultiLang(
      bodyEn: json["interestName"],
      bodyId: json["interestNameId"],
    );
    interestNameId = json["interestNameId"];
    langID = json["langID"];
    icon = json["icon"];
  }
}
