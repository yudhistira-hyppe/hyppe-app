class TransactionCoinModel {
  TransactionCoinModel({
    this.id,
    this.noinvoice,
    this.postid,
    this.amount,
    this.paymentmethod,
    this.status,
    this.description,
    this.idva,
    this.nova,
    this.expiredtimeva,
    this.bank,
    this.productCode,
    this.totalamount,
    this.timestamp,
    this.diskon
  });

  String? id;
  String? noinvoice;
  String? postid;
  int? amount;
  String? paymentmethod;
  String? status;
  String? description;
  String? idva;
  String? nova;
  String? expiredtimeva;
  String? bank;
  String? productCode;
  int? totalamount;
  String? timestamp;
  int? diskon;

  factory TransactionCoinModel.fromJson(Map<String, dynamic> json) => TransactionCoinModel(
        id: json["_id"],
        noinvoice: json["noinvoice"],
        postid: json["postid"],
        amount: json["amount"],
        paymentmethod: json["paymentmethod"],
        status: json["status"],
        description: json["description"],
        idva: json["idva"],
        nova: json["nova"],
        expiredtimeva: json["expiredtimeva"],
        bank: json["bank"],
        productCode: json["productCode"],
        totalamount: json["totalamount"],
        timestamp: json["timestamp"],
        diskon: json["diskon"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "noinvoice": noinvoice,
        "postid": postid,
        "amount": amount,
        "paymentmethod": paymentmethod,
        "status": status,
        "description": description,
        "idva": idva,
        "nova": nova,
        "expiredtimeva": expiredtimeva,
        "bank": bank,
        "productCode": productCode,
        "totalamount": totalamount,
        "timestamp": timestamp,
        "diskon": diskon,
      };
}

class CoinTransModel {
  CoinTransModel({
    this.id,
    this.qty,
    this.jmlcoin,
    this.price,
    this.totalAmount
  });

  String? id;
  int? qty;
  int? jmlcoin;
  int? price;
  int? totalAmount;

  factory CoinTransModel.fromJson(Map<String, dynamic> json) => CoinTransModel(
        id: json["id"],
        qty: json["qty"],
        jmlcoin: json["jmlcoin"],
        price: json["price"],
        totalAmount: json["qty"] * json["totalAmount"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "qty": qty,
        "jmlcoin": jmlcoin,
        "price": price,
        "totalAmount": totalAmount
      };
}