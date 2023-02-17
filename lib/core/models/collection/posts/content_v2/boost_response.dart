class BoostResponse {
  String? noinvoice;
  Postid? postid;
  String? idusersell;
  String? iduserbuyer;
  String? namaPembeli;
  int? amount;
  String? paymentmethod;
  String? status;
  String? description;
  String? idva;
  String? nova;
  String? expiredtimeva;
  String? bank;
  int? bankvacharge;
  List<Detail>? detail;
  int? totalamount;
  String? accountbalance;
  String? timestamp;
  String? sId;

  BoostResponse(
      {this.noinvoice,
      this.postid,
      this.idusersell,
      this.iduserbuyer,
      this.namaPembeli,
      this.amount,
      this.paymentmethod,
      this.status,
      this.description,
      this.idva,
      this.nova,
      this.expiredtimeva,
      this.bank,
      this.bankvacharge,
      this.detail,
      this.totalamount,
      this.accountbalance,
      this.timestamp,
      this.sId});

  BoostResponse.fromJson(Map<String, dynamic> json) {
    noinvoice = json['noinvoice'];
    postid = json['postid'] != null ? Postid.fromJson(json['postid']) : null;
    idusersell = json['idusersell'];
    iduserbuyer = json['iduserbuyer'];
    namaPembeli = json['NamaPembeli'];
    amount = json['amount'];
    paymentmethod = json['paymentmethod'];
    status = json['status'];
    description = json['description'];
    idva = json['idva'];
    nova = json['nova'];
    expiredtimeva = json['expiredtimeva'];
    bank = json['bank'];
    bankvacharge = json['bankvacharge'];
    if (json['detail'] != null) {
      detail = <Detail>[];
      json['detail'].forEach((v) {
        detail!.add(Detail.fromJson(v));
      });
    }
    totalamount = json['totalamount'];
    accountbalance = json['accountbalance'];
    timestamp = json['timestamp'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['noinvoice'] = noinvoice;
    if (postid != null) {
      data['postid'] = postid!.toJson();
    }
    data['idusersell'] = idusersell;
    data['iduserbuyer'] = iduserbuyer;
    data['NamaPembeli'] = namaPembeli;
    data['amount'] = amount;
    data['paymentmethod'] = paymentmethod;
    data['status'] = status;
    data['description'] = description;
    data['idva'] = idva;
    data['nova'] = nova;
    data['expiredtimeva'] = expiredtimeva;
    data['bank'] = bank;
    data['bankvacharge'] = bankvacharge;
    if (detail != null) {
      data['detail'] = detail!.map((v) => v.toJson()).toList();
    }
    data['totalamount'] = totalamount;
    data['accountbalance'] = accountbalance;
    data['timestamp'] = timestamp;
    data['_id'] = sId;
    return data;
  }
}

class Postid {
  String? noinvoice;
  String? postid;
  String? idusersell;
  String? iduserbuyer;
  int? amount;
  String? paymentmethod;
  String? status;
  String? description;
  String? nova;
  String? expiredtimeva;
  String? bank;
  String? ppn;
  int? totalamount;
  String? accountbalance;
  String? timestamp;
  String? updatedAt;
  String? payload;
  String? idva;
  String? type;
  List<Detail>? detail;
  Response? response;
  String? sId;
  int? iV;

  Postid(
      {this.noinvoice,
      this.postid,
      this.idusersell,
      this.iduserbuyer,
      this.amount,
      this.paymentmethod,
      this.status,
      this.description,
      this.nova,
      this.expiredtimeva,
      this.bank,
      this.ppn,
      this.totalamount,
      this.accountbalance,
      this.timestamp,
      this.updatedAt,
      this.payload,
      this.idva,
      this.type,
      this.detail,
      this.response,
      this.sId,
      this.iV});

  Postid.fromJson(Map<String, dynamic> json) {
    noinvoice = json['noinvoice'];
    postid = json['postid'];
    idusersell = json['idusersell'];
    iduserbuyer = json['iduserbuyer'];
    amount = json['amount'];
    paymentmethod = json['paymentmethod'];
    status = json['status'];
    description = json['description'];
    nova = json['nova'];
    expiredtimeva = json['expiredtimeva'];
    bank = json['bank'];
    ppn = json['ppn'];
    totalamount = json['totalamount'];
    accountbalance = json['accountbalance'];
    timestamp = json['timestamp'];
    updatedAt = json['updatedAt'];
    payload = json['payload'];
    idva = json['idva'];
    type = json['type'];
    if (json['detail'] != null) {
      detail = <Detail>[];
      json['detail'].forEach((v) {
        detail!.add(Detail.fromJson(v));
      });
    }
    response = json['response'] != null ? Response.fromJson(json['response']) : null;
    sId = json['_id'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['noinvoice'] = noinvoice;
    data['postid'] = postid;
    data['idusersell'] = idusersell;
    data['iduserbuyer'] = iduserbuyer;
    data['amount'] = amount;
    data['paymentmethod'] = paymentmethod;
    data['status'] = status;
    data['description'] = description;
    data['nova'] = nova;
    data['expiredtimeva'] = expiredtimeva;
    data['bank'] = bank;
    data['ppn'] = ppn;
    data['totalamount'] = totalamount;
    data['accountbalance'] = accountbalance;
    data['timestamp'] = timestamp;
    data['updatedAt'] = updatedAt;
    data['payload'] = payload;
    data['idva'] = idva;
    data['type'] = type;
    if (detail != null) {
      data['detail'] = detail!.map((v) => v.toJson()).toList();
    }
    if (response != null) {
      data['response'] = response!.toJson();
    }
    data['_id'] = sId;
    data['__v'] = iV;
    return data;
  }
}

class Detail {
  String? id;
  Interval? interval;
  Session? session;
  String? type;
  String? dateStart;
  String? datedateEnd;
  int? totalAmount;
  int? qty;

  Detail({this.id, this.interval, this.session, this.type, this.dateStart, this.datedateEnd, this.totalAmount, this.qty});

  Detail.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    interval = json['interval'] != null ? Interval.fromJson(json['interval']) : null;
    session = json['session'] != null ? Session.fromJson(json['session']) : null;
    type = json['type'];
    dateStart = json['dateStart'];
    datedateEnd = json['datedateEnd'];
    totalAmount = json['totalAmount'];
    qty = json['qty'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    if (interval != null) {
      data['interval'] = interval!.toJson();
    }
    if (session != null) {
      data['session'] = session!.toJson();
    }
    data['type'] = type;
    data['dateStart'] = dateStart;
    data['datedateEnd'] = datedateEnd;
    data['totalAmount'] = totalAmount;
    data['qty'] = qty;
    return data;
  }
}

class Interval {
  String? sId;
  String? value;
  String? remark;
  String? langIso;
  String? type;

  Interval({this.sId, this.value, this.remark, this.langIso, this.type});

  Interval.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    value = json['value'];
    remark = json['remark'];
    langIso = json['langIso'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['value'] = value;
    data['remark'] = remark;
    data['langIso'] = langIso;
    data['type'] = type;
    return data;
  }
}

class Session {
  String? sId;
  String? name;
  String? langIso;
  String? start;
  String? end;
  String? type;

  Session({this.sId, this.name, this.langIso, this.start, this.end, this.type});

  Session.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    langIso = json['langIso'];
    start = json['start'];
    end = json['end'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['langIso'] = langIso;
    data['start'] = start;
    data['end'] = end;
    data['type'] = type;
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
    status = json['status'] != null ? Status.fromJson(json['status']) : null;
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
