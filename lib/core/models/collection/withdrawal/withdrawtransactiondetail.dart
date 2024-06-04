class WithdrawtransactiondetailModel {
  WithdrawtransactiondetailModel({
    this.amount,
    this.convertFee,
    this.bankCharge,
    this.totalAmount
  });
  int? amount;
  int? convertFee;
  int? bankCharge;
  int? totalAmount;

  factory WithdrawtransactiondetailModel.fromJson(Map<String, dynamic> json) => WithdrawtransactiondetailModel(
        amount: json["amount"],
        convertFee: json["convertFee"],
        bankCharge: json["bankCharge"],
        totalAmount: json["totalAmount"]
      );

  Map<String, dynamic> toJson() => {
        "amount": amount,
        "convertFee": convertFee,
        "bankCharge": bankCharge,
        "totalAmount": totalAmount
      };
}
