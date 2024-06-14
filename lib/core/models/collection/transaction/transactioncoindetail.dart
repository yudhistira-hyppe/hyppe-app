class DetailTransactionCoin {
  String? sId;
  String? type;
  String? idTransaction;
  String? noInvoice;
  String? category;
  String? product;
  List<String>? voucherDiskon;
  String? idUser;
  int? coinDiscount;
  int? coin;
  int? totalCoin;
  int? priceDiscont;
  int? price;
  int? totalPrice;
  String? status;
  List<Detail>? detail;
  String? createdAt;
  String? updatedAt;
  String? typeCategory;
  String? typeUser;
  String? vaNumber;
  int? transactionFees;
  int? biayPG;
  String? idStream;
  String? code;
  String? namePaket;
  String? coa;
  String? coaDetailName;
  String? coaDetailStatus;
  String? postId;
  String? credit;
  String? boostType;
  String? boostInterval;
  String? boostUnit;
  String? boostStart;
  String? emailbuyer;
  String? usernamebuyer;
  String? emailseller;
  String? usernameseller;
  int? amount;
  String? paymentmethod;
  String? description;
  String? bank;
  int? totalamount;
  String? productId;
  String? expiredtimeva;
  String? idtrLama;
  String? postType;
  int? withdrawAmount;
  int? withdrawTotal;
  int? withdrawCost;
  int? coinadminfee;
  String? adType;
  String? titleStream;
  String? methodename;
  String? productName;
  String? packageId;
  String? timenow;
  String? bankname;
  String? bankcode;
  String? urlEbanking;
  String? bankIcon;
  String? atm;
  String? internetBanking;
  String? mobileBanking;
  String? pemberi;
  String? penerima;

  DetailTransactionCoin(
      {this.sId,
      this.type,
      this.idTransaction,
      this.noInvoice,
      this.category,
      this.product,
      this.voucherDiskon,
      this.idUser,
      this.coinDiscount,
      this.coin,
      this.totalCoin,
      this.priceDiscont,
      this.price,
      this.totalPrice,
      this.status,
      this.detail,
      this.createdAt,
      this.updatedAt,
      this.typeCategory,
      this.typeUser,
      this.vaNumber,
      this.transactionFees,
      this.biayPG,
      this.idStream,
      this.code,
      this.namePaket,
      this.coa,
      this.coaDetailName,
      this.coaDetailStatus,
      this.postId,
      this.credit,
      this.boostType,
      this.boostInterval,
      this.boostUnit,
      this.boostStart,
      this.emailbuyer,
      this.usernamebuyer,
      this.emailseller,
      this.usernameseller,
      this.amount,
      this.paymentmethod,
      this.description,
      this.bank,
      this.totalamount,
      this.productId,
      this.expiredtimeva,
      this.idtrLama,
      this.postType,
      this.withdrawAmount,
      this.withdrawTotal,
      this.withdrawCost,
      this.coinadminfee,
      this.adType,
      this.titleStream,
      this.methodename,
      this.productName,
      this.packageId,
      this.timenow,
      this.bankname,
      this.bankcode,
      this.urlEbanking,
      this.bankIcon,
      this.atm,
      this.internetBanking,
      this.mobileBanking,
      this.pemberi,
      this.penerima});

  DetailTransactionCoin.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    type = json['type'];
    idTransaction = json['idTransaction'];
    noInvoice = json['noInvoice'];
    category = json['category'];
    product = json['product'];
    voucherDiskon = json['voucherDiskon'].cast<String>();
    idUser = json['idUser'];
    coinDiscount = json['coinDiscount'];
    coin = json['coin'];
    totalCoin = json['totalCoin'];
    priceDiscont = json['priceDiscont'];
    price = json['price'];
    totalPrice = json['totalPrice'];
    status = json['status'];
    if (json['detail'] != null) {
      detail = <Detail>[];
      json['detail'].forEach((v) {
        detail!.add(Detail.fromJson(v));
      });
    }
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    typeCategory = json['typeCategory'];
    typeUser = json['typeUser'];
    vaNumber = json['va_number'];
    transactionFees = json['transactionFees'];
    biayPG = json['biayPG'];
    idStream = json['idStream'];
    code = json['code'];
    namePaket = json['namePaket'];
    coa = json['coa'];
    coaDetailName = json['coaDetailName'];
    coaDetailStatus = json['coaDetailStatus'];
    postId = json['post_id'];
    credit = json['credit'].toString();
    boostType = json['boost_type'];
    boostInterval = json['boost_interval'];
    boostUnit = json['boost_unit'];
    boostStart = json['boost_start'];
    emailbuyer = json['emailbuyer'];
    usernamebuyer = json['usernamebuyer'];
    emailseller = json['emailseller'];
    usernameseller = json['usernameseller'];
    amount = json['amount'];
    paymentmethod = json['paymentmethod'];
    description = json['description'];
    bank = json['bank'];
    totalamount = json['totalamount'];
    productId = json['product_id'];
    expiredtimeva = json['expiredtimeva'];
    idtrLama = json['idtr_lama'];
    postType = json['post_type'];
    withdrawAmount = json['withdrawAmount'];
    withdrawTotal = json['withdrawTotal'];
    withdrawCost = json['withdrawCost'];
    coinadminfee = json['coinadminfee'];
    adType = json['adType'];
    titleStream = json['titleStream'];
    methodename = json['methodename'];
    productName = json['productName'];
    packageId = json['package_id'];
    timenow = json['timenow'];
    bankname = json['bankname'];
    bankcode = json['bankcode'];
    urlEbanking = json['urlEbanking'];
    bankIcon = json['bankIcon'];
    atm = json['atm'];
    internetBanking = json['internetBanking'];
    mobileBanking = json['mobileBanking'];
    pemberi = json['pemberi'];
    penerima = json['penerima']??'';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['type'] = type;
    data['idTransaction'] = idTransaction;
    data['noInvoice'] = noInvoice;
    data['category'] = category;
    data['product'] = product;
    data['voucherDiskon'] = voucherDiskon;
    data['idUser'] = idUser;
    data['coinDiscount'] = coinDiscount;
    data['coin'] = coin;
    data['totalCoin'] = totalCoin;
    data['priceDiscont'] = priceDiscont;
    data['price'] = price;
    data['totalPrice'] = totalPrice;
    data['status'] = status;
    if (detail != null) {
      data['detail'] = detail!.map((v) => v.toJson()).toList();
    }
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['typeCategory'] = typeCategory;
    data['typeUser'] = typeUser;
    data['va_number'] = vaNumber;
    data['transactionFees'] = transactionFees;
    data['biayPG'] = biayPG;
    data['idStream'] = idStream;
    data['code'] = code;
    data['namePaket'] = namePaket;
    data['coa'] = coa;
    data['coaDetailName'] = coaDetailName;
    data['coaDetailStatus'] = coaDetailStatus;
    data['post_id'] = postId;
    data['credit'] = credit;
    data['boost_type'] = boostType;
    data['boost_interval'] = boostInterval;
    data['boost_unit'] = boostUnit;
    data['boost_start'] = boostStart;
    data['emailbuyer'] = emailbuyer;
    data['usernamebuyer'] = usernamebuyer;
    data['emailseller'] = emailseller;
    data['usernameseller'] = usernameseller;
    data['amount'] = amount;
    data['paymentmethod'] = paymentmethod;
    data['description'] = description;
    data['bank'] = bank;
    data['totalamount'] = totalamount;
    data['product_id'] = productId;
    data['expiredtimeva'] = expiredtimeva;
    data['idtr_lama'] = idtrLama;
    data['post_type'] = postType;
    data['withdrawAmount'] = withdrawAmount;
    data['withdrawTotal'] = withdrawTotal;
    data['withdrawCost'] = withdrawCost;
    data['coinadminfee'] = coinadminfee;
    data['adType'] = adType;
    data['titleStream'] = titleStream;
    data['methodename'] = methodename;
    data['productName'] = productName;
    data['package_id'] = packageId;
    data['timenow'] = timenow;
    data['bankname'] = bankname;
    data['bankcode'] = bankcode;
    data['urlEbanking'] = urlEbanking;
    data['bankIcon'] = bankIcon;
    data['atm'] = atm;
    data['internetBanking'] = internetBanking;
    data['mobileBanking'] = mobileBanking;
    data['pemberi'] = pemberi;
    data['penerima'] = penerima;
    return data;
  }
}

class Detail {
  int? biayPG;
  int? transactionFees;
  int? amount;
  int? totalDiskon;
  int? totalAmount;
  Payload? payload;
  String? vaNumber;
  String? partnerUserId;
  bool? success;
  String? txDate;
  String? usernameDisplay;
  String? trxExpirationDate;
  String? partnerTrxId;
  String? trxId;
  String? settlementTime;
  String? settlementStatus;

  Detail(
      {this.biayPG,
      this.transactionFees,
      this.amount,
      this.totalDiskon,
      this.totalAmount,
      this.payload,
      this.vaNumber,
      this.partnerUserId,
      this.success,
      this.txDate,
      this.usernameDisplay,
      this.trxExpirationDate,
      this.partnerTrxId,
      this.trxId,
      this.settlementTime,
      this.settlementStatus});

  Detail.fromJson(Map<String, dynamic> json) {
    biayPG = json['biayPG'];
    transactionFees = json['transactionFees'];
    amount = json['amount'];
    totalDiskon = json['totalDiskon'];
    totalAmount = json['totalAmount'];
    payload =
        json['payload'] != null ? Payload.fromJson(json['payload']) : null;
    vaNumber = json['va_number'];
    partnerUserId = json['partner_user_id'];
    success = json['success'];
    txDate = json['tx_date'];
    usernameDisplay = json['username_display'];
    trxExpirationDate = json['trx_expiration_date'];
    partnerTrxId = json['partner_trx_id'];
    trxId = json['trx_id'];
    settlementTime = json['settlement_time'];
    settlementStatus = json['settlement_status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['biayPG'] = biayPG;
    data['transactionFees'] = transactionFees;
    data['amount'] = amount;
    data['totalDiskon'] = totalDiskon;
    data['totalAmount'] = totalAmount;
    if (payload != null) {
      data['payload'] = payload!.toJson();
    }
    data['va_number'] = vaNumber;
    data['partner_user_id'] = partnerUserId;
    data['success'] = success;
    data['tx_date'] = txDate;
    data['username_display'] = usernameDisplay;
    data['trx_expiration_date'] = trxExpirationDate;
    data['partner_trx_id'] = partnerTrxId;
    data['trx_id'] = trxId;
    data['settlement_time'] = settlementTime;
    data['settlement_status'] = settlementStatus;
    return data;
  }
}

class Payload {
  String? vaNumber;

  Payload({this.vaNumber});

  Payload.fromJson(Map<String, dynamic> json) {
    vaNumber = json['va_number'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['va_number'] = vaNumber;
    return data;
  }
}