import 'dart:convert';

BuyRequest buyParamsFromJson(String str) =>
    BuyRequest.fromJson(json.decode(str));

String buyParamsToJson(BuyRequest data) => json.encode(data.toJson());

class BuyRequest {
  BuyRequest({
    this.postid,
    this.amount,
    this.bankcode,
    this.paymentmethod,
    this.salelike,
    this.saleview,
  });

  String? postid;
  int? amount;
  String? bankcode;
  String? paymentmethod;
  bool? salelike;
  bool? saleview;

  factory BuyRequest.fromJson(Map<String, dynamic> json) => BuyRequest(
        postid: json["postid"],
        amount: json["amount"],
        bankcode: json["bankcode"],
        paymentmethod: json["paymentmethod"],
        salelike: json["salelike"],
        saleview: json["saleview"],
      );

  Map<String, dynamic> toJson() => {
        "postid": postid,
        "amount": amount,
        "bankcode": bankcode,
        "paymentmethod": paymentmethod,
        "salelike": salelike,
        "saleview": saleview,
      };
}
