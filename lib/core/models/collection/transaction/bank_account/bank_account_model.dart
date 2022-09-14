class ListBankAccountModel {
  List<BankAccount> data = [];

  ListBankAccountModel({this.data = const []});

  ListBankAccountModel.fromJSON(dynamic json) {
    if (json != null && json.isNotEmpty) {
      json.forEach((v) {
        data.add(BankAccount.fromJSON(v));
      });
    }
  }
}

class BankAccount {
  String? id;
  String? idBank;
  String? userId;
  String? noRek;
  String? nama;
  String? bankName;
  bool? statusInquiry;

  BankAccount.fromJSON(dynamic json) {
    id = json['_id'];
    idBank = json['idBank'];
    userId = json['userId'];
    noRek = json['noRek'];
    nama = json['nama'];
    bankName = json['bankname'];
    statusInquiry = json['statusInquiry'];
  }
}
