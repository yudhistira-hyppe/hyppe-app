class WithdrawalTransactionModel {
  String? sId;
  String? type;
  String? idTransaction;
  String? noInvoice;
  String? createdAt;
  String? updatedAt;
  String? category;
  String? product;
  String? status;
  List<Detail>? detail;
  String? idUser;
  int? coinDiscount;
  int? coin;
  int? totalCoin;
  int? priceDiscont;
  int? price;
  int? totalPrice;

  WithdrawalTransactionModel(
      {this.sId,
      this.type,
      this.idTransaction,
      this.noInvoice,
      this.createdAt,
      this.updatedAt,
      this.category,
      this.product,
      this.status,
      this.detail,
      this.idUser,
      this.coinDiscount,
      this.coin,
      this.totalCoin,
      this.priceDiscont,
      this.price,
      this.totalPrice});

  WithdrawalTransactionModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    type = json['type'];
    idTransaction = json['idTransaction'];
    noInvoice = json['noInvoice'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    category = json['category'];
    product = json['product'];
    status = json['status'];
    if (json['detail'] != null) {
      detail = <Detail>[];
      json['detail'].forEach((v) {
        detail!.add(new Detail.fromJson(v));
      });
    }
    idUser = json['idUser'];
    coinDiscount = json['coinDiscount'];
    coin = json['coin'];
    totalCoin = json['totalCoin'];
    priceDiscont = json['priceDiscont'];
    price = json['price'];
    totalPrice = json['totalPrice'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['type'] = type;
    data['idTransaction'] = idTransaction;
    data['noInvoice'] = noInvoice;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['category'] = category;
    data['product'] = product;
    data['status'] = status;
    if (detail != null) {
      data['detail'] = detail!.map((v) => v.toJson()).toList();
    }
    data['idUser'] = idUser;
    data['coinDiscount'] = coinDiscount;
    data['coin'] = coin;
    data['totalCoin'] = totalCoin;
    data['priceDiscont'] = priceDiscont;
    data['price'] = price;
    data['totalPrice'] = totalPrice;
    return data;
  }
}

class Detail {
  int? biayPG;
  int? transactionFees;
  int? biayAdmin;
  int? amount;
  int? totalAmount;
  String? withdrawId;

  Detail(
      {this.biayPG,
      this.transactionFees,
      this.biayAdmin,
      this.amount,
      this.totalAmount,
      this.withdrawId});

  Detail.fromJson(Map<String, dynamic> json) {
    biayPG = json['biayPG'];
    transactionFees = json['transactionFees'];
    biayAdmin = json['biayAdmin'];
    amount = json['amount'];
    totalAmount = json['totalAmount'];
    withdrawId = json['withdrawId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['biayPG'] = biayPG;
    data['transactionFees'] = transactionFees;
    data['biayAdmin'] = biayAdmin;
    data['amount'] = amount;
    data['totalAmount'] = totalAmount;
    data['withdrawId'] = withdrawId;
    return data;
  }
}