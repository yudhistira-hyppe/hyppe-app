class DetailTransactionCoin {
  String? sId;
  String? type;
  String? idTransaction;
  String? noInvoice;
  String? category;
  String? product;
  String? idUser;
  int? coinDiscount;
  int? coin;
  int? totalCoin;
  int? priceDiscont;
  int? price;
  int? totalPrice;
  String? createdAt;
  String? updatedAt;
  String? emailbuyer;
  String? vaNumber;
  int? transactionFees;
  int? biayPG;
  String? code;
  String? namePaket;
  int? amount;
  String? paymentmethod;
  String? status;
  String? description;
  String? bank;
  int? totalamount;
  String? packageid;
  String? methodename;
  String? bankname;
  String? bankcode;
  String? jenisTransaksi;

  DetailTransactionCoin(
      {this.sId,
      this.type,
      this.idTransaction,
      this.noInvoice,
      this.category,
      this.product,
      this.idUser,
      this.coinDiscount,
      this.coin,
      this.totalCoin,
      this.priceDiscont,
      this.price,
      this.totalPrice,
      this.createdAt,
      this.updatedAt,
      this.emailbuyer,
      this.vaNumber,
      this.transactionFees,
      this.biayPG,
      this.code,
      this.namePaket,
      this.amount,
      this.paymentmethod,
      this.status,
      this.description,
      this.bank,
      this.totalamount,
      this.packageid,
      this.methodename,
      this.bankname,
      this.bankcode,
      this.jenisTransaksi});

  DetailTransactionCoin.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    type = json['type'];
    idTransaction = json['idTransaction'];
    noInvoice = json['noInvoice'];
    category = json['category'];
    product = json['product'];
    idUser = json['idUser'];
    coinDiscount = json['coinDiscount'];
    coin = json['coin'];
    totalCoin = json['totalCoin'];
    priceDiscont = json['priceDiscont'];
    price = json['price'];
    totalPrice = json['totalPrice'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    emailbuyer = json['emailbuyer'];
    vaNumber = json['va_number'];
    transactionFees = json['transactionFees'];
    biayPG = json['biayPG'];
    code = json['code'];
    namePaket = json['namePaket'];
    amount = json['amount'];
    paymentmethod = json['paymentmethod'];
    status = json['status'];
    description = json['description'];
    bank = json['bank'];
    totalamount = json['totalamount'];
    packageid = json['product_id'];
    methodename = json['methodename'];
    bankname = json['bankname'];
    bankcode = json['bankcode'];
    jenisTransaksi = json['jenisTransaksi'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['type'] = type;
    data['idTransaction'] = idTransaction;
    data['noInvoice'] = noInvoice;
    data['category'] = category;
    data['product'] = product;
    data['idUser'] = idUser;
    data['coinDiscount'] = coinDiscount;
    data['coin'] = coin;
    data['totalCoin'] = totalCoin;
    data['priceDiscont'] = priceDiscont;
    data['price'] = price;
    data['totalPrice'] = totalPrice;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['emailbuyer'] = emailbuyer;
    data['va_number'] = vaNumber;
    data['transactionFees'] = transactionFees;
    data['biayPG'] = biayPG;
    data['code'] = code;
    data['namePaket'] = namePaket;
    data['amount'] = amount;
    data['paymentmethod'] = paymentmethod;
    data['status'] = status;
    data['description'] = description;
    data['bank'] = bank;
    data['totalamount'] = totalamount;
    data['product_id'] = packageid;
    data['methodename'] = methodename;
    data['bankname'] = bankname;
    data['bankcode'] = bankcode;
    data['jenisTransaksi'] = jenisTransaksi;
    return data;
  }
}