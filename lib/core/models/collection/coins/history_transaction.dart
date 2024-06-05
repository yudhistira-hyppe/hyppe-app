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
  String? noInvoiceLama;
  String? coa;
  String? coaDetailName;
  String? coaDetailStatus;
  List<Detail>? detail;
  String? descTitleId;
  String? descTitleEn;
  String? descContentId;
  String? descContentEn;

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
      this.noInvoiceLama,
      this.coa,
      this.coaDetailName,
      this.coaDetailStatus,
      this.detail,
      this.descTitleId,
      this.descTitleEn,
      this.descContentId,
      this.descContentEn});

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
    noInvoiceLama = json['noInvoiceLama'];
    coa = json['coa'];
    coaDetailName = json['coaDetailName'];
    coaDetailStatus = json['coaDetailStatus'];
    if (json['detail'] != null) {
      detail = <Detail>[];
      json['detail'].forEach((v) {
        detail!.add(Detail.fromJson(v));
      });
    }
    descTitleId = json['desc_title_id'];
    descTitleEn = json['desc_title_en'];
    descContentId = json['desc_content_id'];
    descContentEn = json['desc_content_en'];
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
    data['noInvoiceLama'] = noInvoiceLama;
    data['coa'] = coa;
    data['coaDetailName'] = coaDetailName;
    data['coaDetailStatus'] = coaDetailStatus;
    if (detail != null) {
      data['detail'] = detail!.map((v) => v.toJson()).toList();
    }
    data['desc_title_id'] = descTitleId;
    data['desc_title_en'] = descTitleEn;
    data['desc_content_id'] = descContentId;
    data['desc_content_en'] = descContentEn;
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
  Response? response;

  Detail(
      {this.biayPG,
      this.transactionFees,
      this.amount,
      this.totalDiskon,
      this.totalAmount,
      this.payload,
      this.response});

  Detail.fromJson(Map<String, dynamic> json) {
    biayPG = json['biayPG'];
    transactionFees = json['transactionFees'];
    amount = json['amount'];
    totalDiskon = json['totalDiskon'];
    totalAmount = json['totalAmount'];
    payload =
        json['payload'] != null ? Payload.fromJson(json['payload']) : null;
    response = json['response'] != null
        ? Response.fromJson(json['response'])
        : null;
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
    if (response != null) {
      data['response'] = response!.toJson();
    }
    return data;
  }
}

class Payload {
  String? vaNumber;
  int? amount;
  String? partnerUserId;
  bool? success;
  String? txDate;
  String? usernameDisplay;
  String? trxExpirationDate;
  String? partnerTrxId;
  String? trxId;
  String? settlementTime;
  String? settlementStatus;

  Payload(
      {this.vaNumber,
      this.amount,
      this.partnerUserId,
      this.success,
      this.txDate,
      this.usernameDisplay,
      this.trxExpirationDate,
      this.partnerTrxId,
      this.trxId,
      this.settlementTime,
      this.settlementStatus});

  Payload.fromJson(Map<String, dynamic> json) {
    vaNumber = json['va_number'];
    amount = json['amount'];
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
    data['va_number'] = vaNumber;
    data['amount'] = amount;
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

class Response {
  String? id;
  int? amount;
  Status? status;
  String? vaNumber;
  String? bankCode;
  bool? isOpen;
  bool? isSingleUse;
  int? expirationTime;
  String? vaStatus;
  String? usernameDisplay;
  String? partnerUserId;
  int? counterIncomingPayment;
  int? trxExpirationTime;
  int? trxCounter;

  Response(
      {this.id,
      this.amount,
      this.status,
      this.vaNumber,
      this.bankCode,
      this.isOpen,
      this.isSingleUse,
      this.expirationTime,
      this.vaStatus,
      this.usernameDisplay,
      this.partnerUserId,
      this.counterIncomingPayment,
      this.trxExpirationTime,
      this.trxCounter});

  Response.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    amount = json['amount'];
    status =
        json['status'] != null ? Status.fromJson(json['status']) : null;
    vaNumber = json['va_number'];
    bankCode = json['bank_code'];
    isOpen = json['is_open'];
    isSingleUse = json['is_single_use'];
    expirationTime = json['expiration_time'];
    vaStatus = json['va_status'];
    usernameDisplay = json['username_display'];
    partnerUserId = json['partner_user_id'];
    counterIncomingPayment = json['counter_incoming_payment'];
    trxExpirationTime = json['trx_expiration_time'];
    trxCounter = json['trx_counter'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['amount'] = amount;
    if (status != null) {
      data['status'] = status!.toJson();
    }
    data['va_number'] = vaNumber;
    data['bank_code'] = bankCode;
    data['is_open'] = isOpen;
    data['is_single_use'] = isSingleUse;
    data['expiration_time'] = expirationTime;
    data['va_status'] = vaStatus;
    data['username_display'] = usernameDisplay;
    data['partner_user_id'] = partnerUserId;
    data['counter_incoming_payment'] = counterIncomingPayment;
    data['trx_expiration_time'] = trxExpirationTime;
    data['trx_counter'] = trxCounter;
    return data;
  }
}

class Status {
  String? code;
  String? message;

  Status({this.code, this.message});

  Status.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['code'] = code;
    data['message'] = message;
    return data;
  }
}