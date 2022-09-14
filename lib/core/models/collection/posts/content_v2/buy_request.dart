import 'dart:convert';

BuyRequest buyParamsFromJson(String str) => BuyRequest.fromJson(json.decode(str));

String buyParamsToJson(BuyRequest data) => json.encode(data.toJson());

class BuyRequest {
  BuyRequest({
    this.postid,
    this.amount,
    this.bankcode,
    this.paymentmethod,
    this.salelike,
    this.saleview,
    this.type,
  });

  List<PostId>? postid;
  int? amount;
  String? bankcode;
  String? paymentmethod;
  bool? salelike;
  bool? saleview;
  String? type;

  factory BuyRequest.fromJson(Map<String, dynamic> json) => BuyRequest(
      postid: List<PostId>.from(json["postid"].map((x) => PostId.fromJson(x))),
      amount: json["amount"],
      bankcode: json["bankcode"],
      paymentmethod: json["paymentmethod"],
      salelike: json["salelike"],
      saleview: json["saleview"],
      type: json['type']);

  Map<String, dynamic> toJson() => {
        "postid": List<dynamic>.from(postid!.map((x) => x.toJson())),
        "amount": amount,
        "bankcode": bankcode,
        "paymentmethod": paymentmethod,
        "salelike": salelike,
        "saleview": saleview,
        "type": type,
      };
}

class PostId {
  PostId({
    this.id,
    this.qty,
    this.totalAmount,
  });
  String? id;
  num? totalAmount;
  int? qty;

  factory PostId.fromJson(Map<String, dynamic> json) => PostId(
        id: json["id"],
        totalAmount: json["totalAmount"],
        qty: json["qty"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "qty": qty,
        "totalAmount": totalAmount,
      };
}
