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
  int? coinadminfee;
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
  String? idPaket;
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
  String? contentid;
  int? amount;
  String? paymentmethod;
  String? status;
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
  String? adType;
  String? titleStream;
  String? methodename;
  String? productName;
  String? timenow;
  String? bankname;
  String? bankcode;
  String? urlEbanking;
  String? bankIcon;
  String? atm;
  String? internetBanking;
  String? mobileBanking;
  String? titleId;
  String? titleEn;
  String? contentId;
  String? contentEn;

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
      this.coinadminfee,
      this.createdAt,
      this.updatedAt,
      this.typeCategory,
      this.typeUser,
      this.vaNumber,
      this.transactionFees,
      this.contentid,
      this.biayPG,
      this.idStream,
      this.code,
      this.namePaket,
      this.idPaket,
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
      this.status,
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
      this.adType,
      this.titleStream,
      this.methodename,
      this.productName,
      this.timenow,
      this.bankname,
      this.bankcode,
      this.urlEbanking,
      this.bankIcon,
      this.atm,
      this.internetBanking,
      this.mobileBanking,
      this.titleEn,
      this.titleId,
      this.contentId,
      this.contentEn});

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
    contentid = json['content_id'];
    totalCoin = json['totalCoin'];
    priceDiscont = json['priceDiscont'];
    price = json['price'];
    totalPrice = json['totalPrice'];
    coinadminfee = json['coinadminfee'];
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
    idPaket = json['package_id'];
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
    status = json['status'];
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
    adType = json['adType'];
    titleStream = json['titleStream'];
    methodename = json['methodename'];
    productName = json['productName'];
    timenow = json['timenow'];
    bankname = json['bankname'];
    bankcode = json['bankcode'];
    urlEbanking = json['urlEbanking'];
    bankIcon = json['bankIcon'];
    atm = json['atm'];
    internetBanking = json['internetBanking'];
    mobileBanking = json['mobileBanking'];
    titleId = json['desc_title_id'];
    titleEn = json['desc_title_en'];
    contentId = json['desc_content_id'];
    contentEn = json['desc_content_en'];
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
    data['content_id'] = contentid;
    data['totalCoin'] = totalCoin;
    data['priceDiscont'] = priceDiscont;
    data['price'] = price;
    data['totalPrice'] = totalPrice;
    data['coinadminfee'] = coinadminfee;
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
    data['package_id'] = idPaket;
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
    data['status'] = status;
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
    data['adType'] = adType;
    data['titleStream'] = titleStream;
    data['methodename'] = methodename;
    data['productName'] = productName;
    data['timenow'] = timenow;
    data['bankname'] = bankname;
    data['bankcode'] = bankcode;
    data['urlEbanking'] = urlEbanking;
    data['bankIcon'] = bankIcon;
    data['atm'] = atm;
    data['internetBanking'] = internetBanking;
    data['mobileBanking'] = mobileBanking;
    data['desc_title_id'] = titleId;
    data['desc_title_en'] = titleEn;
    data['desc_content_id'] = contentId;
    data['desc_content_en'] = contentEn;
    return data;
  }
}
