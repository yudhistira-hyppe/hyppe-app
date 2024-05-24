class BoostpostResponseModel {
  String? noinvoice;
  String? postid;
  String? idusersell;
  String? iduserbuyer;
  String? namaPembeli;
  String? emailbuyer;
  int? amount;
  String? paymentmethod;
  String? status;
  String? description;
  Detail? detail;
  int? totalamount;
  int? accountbalance;
  String? timestamp;
  String? sId;

  BoostpostResponseModel(
      {this.noinvoice,
      this.postid,
      this.idusersell,
      this.iduserbuyer,
      this.namaPembeli,
      this.emailbuyer,
      this.amount,
      this.paymentmethod,
      this.status,
      this.description,
      this.detail,
      this.totalamount,
      this.accountbalance,
      this.timestamp,
      this.sId});

  BoostpostResponseModel.fromJson(Map<String, dynamic> json) {
    noinvoice = json['noinvoice'];
    postid = json['postid'];
    idusersell = json['idusersell'];
    iduserbuyer = json['iduserbuyer'];
    namaPembeli = json['NamaPembeli'];
    emailbuyer = json['emailbuyer'];
    amount = json['amount'];
    paymentmethod = json['paymentmethod'];
    status = json['status'];
    description = json['description'];
    detail =
        json['detail'] != null ? Detail.fromJson(json['detail']) : null;
    totalamount = json['totalamount'];
    accountbalance = json['accountbalance'];
    timestamp = json['timestamp'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['noinvoice'] = noinvoice;
    data['postid'] = postid;
    data['idusersell'] = idusersell;
    data['iduserbuyer'] = iduserbuyer;
    data['NamaPembeli'] = namaPembeli;
    data['emailbuyer'] = emailbuyer;
    data['amount'] = amount;
    data['paymentmethod'] = paymentmethod;
    data['status'] = status;
    data['description'] = description;
    if (detail != null) {
      data['detail'] = detail!.toJson();
    }
    data['totalamount'] = totalamount;
    data['accountbalance'] = accountbalance;
    data['timestamp'] = timestamp;
    data['_id'] = sId;
    return data;
  }
}

class Detail {
  String? postID;
  String? typeData;
  String? discont;
  int? amount;
  int? discountCoin;
  int? totalAmount;
  int? qty;
  Interval? interval;
  Session? session;
  String? type;
  String? dateStart;
  String? datedateEnd;

  Detail(
      {this.postID,
      this.typeData,
      this.discont,
      this.amount,
      this.discountCoin,
      this.totalAmount,
      this.qty,
      this.interval,
      this.session,
      this.type,
      this.dateStart,
      this.datedateEnd});

  Detail.fromJson(Map<String, dynamic> json) {
    postID = json['postID'];
    typeData = json['typeData'];
    discont = json['discont'];
    amount = json['amount'];
    discountCoin = json['discountCoin'];
    totalAmount = json['totalAmount'];
    qty = json['qty'];
    interval = json['interval'] != null
        ? Interval.fromJson(json['interval'])
        : null;
    session =
        json['session'] != null ? Session.fromJson(json['session']) : null;
    type = json['type'];
    dateStart = json['dateStart'];
    datedateEnd = json['datedateEnd'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['postID'] = postID;
    data['typeData'] = typeData;
    data['discont'] = discont;
    data['amount'] = amount;
    data['discountCoin'] = discountCoin;
    data['totalAmount'] = totalAmount;
    data['qty'] = qty;
    if (interval != null) {
      data['interval'] = interval!.toJson();
    }
    if (session != null) {
      data['session'] = session!.toJson();
    }
    data['type'] = type;
    data['dateStart'] = dateStart;
    data['datedateEnd'] = datedateEnd;
    return data;
  }
}

class Interval {
  String? sId;
  String? value;
  String? remark;
  String? type;
  String? langIso;

  Interval({this.sId, this.value, this.remark, this.type, this.langIso});

  Interval.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    value = json['value'];
    remark = json['remark'];
    type = json['type'];
    langIso = json['langIso'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = sId;
    data['value'] = value;
    data['remark'] = remark;
    data['type'] = type;
    data['langIso'] = langIso;
    return data;
  }
}

class Session {
  String? sId;
  String? name;
  String? start;
  String? end;
  String? type;
  String? nameId;
  String? langIso;

  Session(
      {this.sId,
      this.name,
      this.start,
      this.end,
      this.type,
      this.nameId,
      this.langIso});

  Session.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    start = json['start'];
    end = json['end'];
    type = json['type'];
    nameId = json['nameId'];
    langIso = json['langIso'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = sId;
    data['name'] = name;
    data['start'] = start;
    data['end'] = end;
    data['type'] = type;
    data['nameId'] = nameId;
    data['langIso'] = langIso;
    return data;
  }
}