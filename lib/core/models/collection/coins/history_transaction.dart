class TransactionHistoryCoinModel {
  String? sId;
  String? email;
  String? userName;
  String? idTrans;
  String? type;
  String? noInvoice;
  int? coin;
  int? coinDiscount;
  int? totalCoin;
  String? createdAt;
  String? updatedAt;
  String? status;
  String? package;
  String? coa;

  TransactionHistoryCoinModel(
      {this.sId,
      this.email,
      this.userName,
      this.idTrans,
      this.type,
      this.noInvoice,
      this.coin,
      this.coinDiscount,
      this.totalCoin,
      this.createdAt,
      this.updatedAt,
      this.status,
      this.package,
      this.coa});

  TransactionHistoryCoinModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    email = json['email'];
    userName = json['userName'];
    idTrans = json['idTrans'];
    type = json['type'];
    noInvoice = json['noInvoice'];
    coin = json['coin'];
    coinDiscount = json['coinDiscount'];
    totalCoin = json['totalCoin'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    status = json['status'];
    package = json['package'];
    coa = json['coa'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['email'] = email;
    data['userName'] = userName;
    data['idTrans'] = idTrans;
    data['type'] = type;
    data['noInvoice'] = noInvoice;
    data['coin'] = coin;
    data['coinDiscount'] = coinDiscount;
    data['totalCoin'] = totalCoin;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['status'] = status;
    data['package'] = package;
    data['coa'] = coa;
    return data;
  }
}