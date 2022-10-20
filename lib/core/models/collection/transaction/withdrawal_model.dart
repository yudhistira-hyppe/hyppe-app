class WithdrawalModal {
  String? idUser;
  int? amount;
  String? status;
  int? bankVerificationCharge;
  int? bankDisbursmentCharge;
  String? timestamp;
  bool? verified;
  String? description;
  String? partnerTrxid;
  int? totalamount;
  String? sId;

  WithdrawalModal({
    this.idUser,
    this.amount,
    this.status,
    this.bankVerificationCharge,
    this.bankDisbursmentCharge,
    this.timestamp,
    this.verified,
    this.description,
    this.partnerTrxid,
    this.totalamount,
    this.sId,
  });

  WithdrawalModal.fromJson(Map<String, dynamic> json) {
    idUser = json['idUser'];
    amount = json['amount'];
    status = json['status'];
    bankVerificationCharge = json['bankVerificationCharge'];
    bankDisbursmentCharge = json['bankDisbursmentCharge'];
    timestamp = json['timestamp'];
    verified = json['verified'];
    description = json['description'];
    partnerTrxid = json['partnerTrxid'];
    totalamount = json['totalamount'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['idUser'] = idUser;
    data['amount'] = amount;
    data['status'] = status;
    data['bankVerificationCharge'] = bankVerificationCharge;
    data['bankDisbursmentCharge'] = bankDisbursmentCharge;
    data['timestamp'] = timestamp;
    data['verified'] = verified;
    data['description'] = description;
    data['partnerTrxid'] = partnerTrxid;
    data['totalamount'] = totalamount;
    data['_id'] = sId;
    return data;
  }
}
