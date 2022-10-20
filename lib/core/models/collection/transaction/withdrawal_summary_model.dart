class WithdrawalSummaryModel {
  String? name;
  String? bankName;
  String? bankAccount;
  int? amount;
  int? totalAmount;
  int? adminFee;
  int? chargeInquiry;
  bool? statusInquiry;

  WithdrawalSummaryModel({
    this.name,
    this.bankName,
    this.bankAccount,
    this.amount,
    this.totalAmount,
    this.adminFee,
    this.chargeInquiry,
    this.statusInquiry,
  });

  WithdrawalSummaryModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    bankName = json['bankName'];
    bankAccount = json['bankAccount'];
    amount = json['amount'];
    totalAmount = json['totalAmount'];
    adminFee = json['adminFee'];
    chargeInquiry = json['chargeInquiry'];
    statusInquiry = json['statusInquiry'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['bankName'] = bankName;
    data['bankAccount'] = bankAccount;
    data['amount'] = amount;
    data['totalAmount'] = totalAmount;
    data['adminFee'] = adminFee;
    data['chargeInquiry'] = chargeInquiry;
    data['statusInquiry'] = statusInquiry;
    return data;
  }
}
