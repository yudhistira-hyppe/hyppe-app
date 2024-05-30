class BuyDataNew {
  BuyDataNew({
    this.nomorSertifikat,
    this.jenisKonten,
    this.creator,
    this.waktu,
    this.like,
    this.view,
    this.price,
    this.total
  });

  String? nomorSertifikat;
  String? jenisKonten;
  String? creator;
  String? waktu;
  bool? like;
  bool? view;
  int? price;
  int? total;

  factory BuyDataNew.fromJson(Map<String, dynamic> json) => BuyDataNew(
        nomorSertifikat: json["nomorSertifikat"],
        jenisKonten: json["jenisKonten"],
        creator: json["creator"],
        waktu: json["waktu"],
        like: json["like"],
        view: json["view"],
        price: json["price"],
        total: json["total"],
      );

  Map<String, dynamic> toJson() => {
        "nomornomorSertifikat":nomorSertifikat,
        "jenisKonten": jenisKonten,
        "creator": creator,
        "waktu": waktu,
        "like": like,
        "view": view,
        "price": price,
        "total": total,
      };
}
