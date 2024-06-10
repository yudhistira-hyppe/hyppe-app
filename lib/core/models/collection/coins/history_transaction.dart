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
  String? idTransLama;
  String? package;
  String? noInvoiceLama;
  String? expiredtimeva;
  String? coa;
  String? coaDetailName;
  String? coaDetailStatus;
  List<Detail>? detail;
  String? vaNumber;
  String? titleId;
  String? titleEn;
  String? contentId;
  String? contentEn;

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
      this.idTransLama,
      this.package,
      this.noInvoiceLama,
      this.expiredtimeva,
      this.coa,
      this.coaDetailName,
      this.coaDetailStatus,
      this.detail,
      this.vaNumber,
      this.titleId,
      this.titleEn,
      this.contentId,
      this.contentEn});

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
    idTransLama = json['idTransLama'];
    package = json['package'];
    noInvoiceLama = json['noInvoiceLama'];
    expiredtimeva = json['expiredtimeva'];
    coa = json['coa'];
    coaDetailName = json['coaDetailName'];
    coaDetailStatus = json['coaDetailStatus'];
    if (json['detail'] != null) {
      detail = <Detail>[];
      json['detail'].forEach((v) {
        detail!.add(Detail.fromJson(v));
      });
    }
    vaNumber = json['vaNumber'];
    titleId = json['desc_title_id'];
    titleEn = json['desc_title_en'];
    contentId = json['desc_content_id'];
    contentEn = json['desc_content_en'];
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
    data['idTransLama'] = idTransLama;
    data['package'] = package;
    data['noInvoiceLama'] = noInvoiceLama;
    data['expiredtimeva'] = expiredtimeva;
    data['coa'] = coa;
    data['coaDetailName'] = coaDetailName;
    data['coaDetailStatus'] = coaDetailStatus;
    if (detail != null) {
      data['detail'] = detail!.map((v) => v.toJson()).toList();
    }
    data['vaNumber'] = vaNumber;
    data['desc_title_id'] = titleId;
    data['desc_title_en'] = titleEn;
    data['desc_content_id'] = contentId;
    data['desc_content_en'] = contentEn;
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
