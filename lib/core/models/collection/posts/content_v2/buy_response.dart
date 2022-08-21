// To parse this JSON data, do
//
//     final buyResponse = buyResponseFromJson(jsonString);

import 'dart:convert';

BuyResponse buyResponseFromJson(String str) =>
    BuyResponse.fromJson(json.decode(str));

String buyResponseToJson(BuyResponse data) => json.encode(data.toJson());

class BuyResponse {
  BuyResponse({
    this.noinvoice,
    this.postid,
    this.idusersell,
    this.namaPenjual,
    this.iduserbuyer,
    this.namaPembeli,
    this.amount,
    this.paymentmethod,
    this.status,
    this.description,
    this.nova,
    this.expiredtimeva,
    this.salelike,
    this.saleview,
    this.bank,
    this.bankvacharge,
    this.totalamount,
    this.accountbalance,
    this.timestamp,
    this.id,
  });

  String? noinvoice;
  String? postid;
  String? idusersell;
  String? namaPenjual;
  String? iduserbuyer;
  String? namaPembeli;
  int? amount;
  String? paymentmethod;
  String? status;
  String? description;
  String? nova;
  String? expiredtimeva;
  bool? salelike;
  bool? saleview;
  String? bank;
  int? bankvacharge;
  int? totalamount;
  int? accountbalance;
  String? timestamp;
  String? id;

  factory BuyResponse.fromJson(Map<String, dynamic> json) => BuyResponse(
        noinvoice: json["noinvoice"],
        postid: json["postid"],
        idusersell: json["idusersell"],
        namaPenjual: json["NamaPenjual"],
        iduserbuyer: json["iduserbuyer"],
        namaPembeli: json["NamaPembeli"],
        amount: json["amount"],
        paymentmethod: json["paymentmethod"],
        status: json["status"],
        description: json["description"],
        nova: json["nova"],
        expiredtimeva: json["expiredtimeva"],
        salelike: json["salelike"],
        saleview: json["saleview"],
        bank: json["bank"],
        bankvacharge: json["bankvacharge"],
        totalamount: json["totalamount"],
        accountbalance: json["accountbalance"],
        timestamp: json["timestamp"],
        id: json["_id"],
      );

  Map<String, dynamic> toJson() => {
        "noinvoice": noinvoice,
        "postid": postid,
        "idusersell": idusersell,
        "NamaPenjual": namaPenjual,
        "iduserbuyer": iduserbuyer,
        "NamaPembeli": namaPembeli,
        "amount": amount,
        "paymentmethod": paymentmethod,
        "status": status,
        "description": description,
        "nova": nova,
        "expiredtimeva": expiredtimeva,
        "salelike": salelike,
        "saleview": saleview,
        "bank": bank,
        "bankvacharge": bankvacharge,
        "totalamount": totalamount,
        "accountbalance": accountbalance,
        "timestamp": timestamp,
        "_id": id,
      };
}
