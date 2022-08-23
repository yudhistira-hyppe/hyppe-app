class BankData {
  BankData({
    this.id,
    this.bankcode,
    this.bankname,
    this.bankIcon,
    this.atm,
    this.internetBanking,
    this.mobileBanking,
  });

  String? id;
  String? bankcode;
  String? bankname;
  String? bankIcon;
  String? atm;
  String? internetBanking;
  String? mobileBanking;

  factory BankData.fromJson(Map<String, dynamic> json) => BankData(
        id: json["_id"],
        bankcode: json["bankcode"],
        bankname: json["bankname"],
        bankIcon: json["bankIcon"],
        atm: json["atm"],
        internetBanking: json["internetBanking"],
        mobileBanking: json["mobileBanking"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "bankcode": bankcode,
        "bankname": bankname,
        "bankIcon": bankIcon,
        "atm": atm,
        "internetBanking": internetBanking,
        "mobileBanking": mobileBanking,
      };
}
