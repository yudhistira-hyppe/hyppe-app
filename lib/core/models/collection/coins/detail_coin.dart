class DetailCoinModel {
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
  String? typeCategory;
  String? typeUser;
  String? vaNumber;
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
  String? contentId;
  String? status;
  String? expiredtimeva;
  String? idtrLama;
  String? postType;
  int? withdrawAmount;
  int? withdrawTotal;
  int? withdrawCost;
  String? adType;
  String? titleStream;
  String? productName;
  String? postOwner;
  String? timenow;

  DetailCoinModel(
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
      this.typeCategory,
      this.typeUser,
      this.vaNumber,
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
      this.contentId,
      this.status,
      this.expiredtimeva,
      this.idtrLama,
      this.postType,
      this.withdrawAmount,
      this.withdrawTotal,
      this.withdrawCost,
      this.adType,
      this.titleStream,
      this.productName,
      this.postOwner,
      this.timenow});

  DetailCoinModel.fromJson(Map<String, dynamic> json) {
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
    typeCategory = json['typeCategory'];
    typeUser = json['typeUser'];
    vaNumber = json['va_number'];
    idStream = json['idStream'];
    code = json['code'];
    namePaket = json['namePaket'];
    coa = json['coa'];
    coaDetailName = json['coaDetailName'];
    coaDetailStatus = json['coaDetailStatus'];
    postId = json['post_id'];
    credit = json['credit'];
    boostType = json['boost_type'];
    boostInterval = json['boost_interval'];
    boostUnit = json['boost_unit'];
    boostStart = json['boost_start'];
    emailbuyer = json['emailbuyer'];
    usernamebuyer = json['usernamebuyer'];
    emailseller = json['emailseller'];
    usernameseller = json['usernameseller'];
    contentId = json['content_id'];
    status = json['status'];
    expiredtimeva = json['expiredtimeva'];
    idtrLama = json['idtr_lama'];
    postType = json['post_type'];
    withdrawAmount = json['withdrawAmount'];
    withdrawTotal = json['withdrawTotal'];
    withdrawCost = json['withdrawCost'];
    adType = json['adType'];
    titleStream = json['titleStream'];
    productName = json['productName'];
    postOwner = json['post_owner'];
    timenow = json['timenow'];
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
    data['typeCategory'] = typeCategory;
    data['typeUser'] = typeUser;
    data['va_number'] = vaNumber;
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
    data['content_id'] = contentId;
    data['status'] = status;
    data['expiredtimeva'] = expiredtimeva;
    data['idtr_lama'] = idtrLama;
    data['post_type'] = postType;
    data['withdrawAmount'] = withdrawAmount;
    data['withdrawTotal'] = withdrawTotal;
    data['withdrawCost'] = withdrawCost;
    data['adType'] = adType;
    data['titleStream'] = titleStream;
    data['productName'] = productName;
    data['post_owner'] = postOwner;
    data['timenow'] = timenow;
    return data;
  }
}
