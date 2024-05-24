class TransactionBuyContentModel {
  TransactionBuyContentModel({
    this.noinvoice,
    this.postid,
    this.email,
    this.namaPenjual,
    this.waktu,
    this.amount,
    this.paymentmethod,
    this.diskon,
    this.jenisTransaksi,
    this.platform,
    this.total
  });

  String? id;
  String? noinvoice;
  String? postid;
  String? email;
  String? namaPenjual;
  String? waktu;
  int? amount;
  String? paymentmethod;
  int? diskon;
  String? jenisTransaksi;
  String? platform;
  int? total;

  factory TransactionBuyContentModel.fromJson(Map<String, dynamic> json) => TransactionBuyContentModel(
        noinvoice: json["noinvoice"],
        postid: json["postid"],
        paymentmethod: json["paymentmethod"],
        email: json["email"],
        namaPenjual: json["namaPenjual"],
        waktu: json["waktu"],
        amount: json["amount"],
        diskon: json["diskon"],
        jenisTransaksi: json["jenisTransaksi"],
        platform: json["platform"],
        total: json["total"]
      );

  Map<String, dynamic> toJson() => {
        "noinvoice": noinvoice,
        "postid": postid,
        "paymentmethod": paymentmethod,
        "email": email,
        "namaPenjual": namaPenjual,
        "waktu": waktu,
        "amount": amount,
        "diskon": diskon,
        "jenisTransaksi": jenisTransaksi,
        "platform": platform,
        "total": total
      };
}
