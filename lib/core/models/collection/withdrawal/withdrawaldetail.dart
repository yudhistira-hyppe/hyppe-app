class DetailWithdrawalModel {
  String? sId;
  String? idTransaction;
  String? noInvoice;
  int? amount;
  int? transactionFee;
  int? conversionFee;
  int? totalAmount;
  String? email;
  String? accNo;
  String? accName;
  String? bankName;
  String? status;
  String? createdAt;
  List<Tracking>? tracking;

  DetailWithdrawalModel(
      {this.sId,
      this.idTransaction,
      this.noInvoice,
      this.amount,
      this.transactionFee,
      this.conversionFee,
      this.totalAmount,
      this.email,
      this.accNo,
      this.accName,
      this.bankName,
      this.status,
      this.createdAt,
      this.tracking});

  DetailWithdrawalModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    idTransaction = json['idTransaction'];
    noInvoice = json['noInvoice'];
    amount = json['amount'];
    transactionFee = json['transactionFee'];
    conversionFee = json['conversionFee'];
    totalAmount = json['totalAmount'];
    email = json['email'];
    accNo = json['accNo'];
    accName = json['accName'];
    bankName = json['bankName'];
    status = json['status'];
    createdAt = json['createdAt'];
    if (json['tracking'] != null) {
      tracking = <Tracking>[];
      json['tracking'].forEach((v) {
        tracking!.add(Tracking.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['idTransaction'] = idTransaction;
    data['noInvoice'] = noInvoice;
    data['amount'] = amount;
    data['transactionFee'] = transactionFee;
    data['conversionFee'] = conversionFee;
    data['totalAmount'] = totalAmount;
    data['email'] = email;
    data['accNo'] = accNo;
    data['accName'] = accName;
    data['bankName'] = bankName;
    data['status'] = status;
    data['createdAt'] = createdAt;
    if (tracking != null) {
      data['tracking'] = tracking!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Tracking {
  String? title;
  String? status;
  String? action;
  String? timestamp;
  String? description;

  Tracking(
      {this.title, this.status, this.action, this.timestamp, this.description});

  Tracking.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    status = json['status'];
    action = json['action'];
    timestamp = json['timestamp'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['status'] = status;
    data['action'] = action;
    data['timestamp'] = timestamp;
    data['description'] = description;
    return data;
  }
}