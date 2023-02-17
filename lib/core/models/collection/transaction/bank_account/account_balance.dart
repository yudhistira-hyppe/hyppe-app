class AccountBalanceModel {
  int? totalsaldo;
  int? totalpenarikan;

  AccountBalanceModel.fromJSON(dynamic json) {
    totalsaldo = json['totalsaldo'] ?? 0;
    totalpenarikan = json['totaltotalpenarikansaldo'] ?? 0;
  }
}
