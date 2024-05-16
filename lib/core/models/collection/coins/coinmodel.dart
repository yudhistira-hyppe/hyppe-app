class CointModel {
  CointModel({
    this.id,
    this.type,
    this.name,
    this.package_id,
    this.amount,
    this.thumbnail,
    this.createdAt,
    this.updatedAt,
    this.used_stock,
    this.last_stock,
    this.active,
    this.status,
    this.price,
    this.stock,
    this.checked = false,
  });

  String? id;
  String? type;
  String? name;
  String? package_id;
  int? amount;
  String? thumbnail;
  String? createdAt;
  String? updatedAt;
  int? used_stock;
  int? last_stock;
  bool? active;
  bool? status;
  int? price;
  int? stock;
  bool? checked;

  factory CointModel.fromJson(Map<String, dynamic> json) => CointModel(
        id: json["_id"],
        type: json["type"]??'',
        name: json["name"]??'',
        package_id: json["package_id"]??'',
        amount: json["amount"]??0,
        thumbnail: json["thumbnail"]??'',
        used_stock: json["used_stock"]??0,
        last_stock: json["last_stock"]??0,
        active: json["active"]??false,
        status: json["status"]??false,
        stock: json["stock"]??0,
        price: json["price"]??0,
        createdAt: json["createdAt"]??'',
        updatedAt: json["updatedAt"]??'',
        checked: false
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "type": type,
        "name": name,
        "package_id": package_id,
        "amount": amount,
        "thumbnail": thumbnail,
        "used_stock": used_stock,
        "last_stock": last_stock,
        "active": active,
        "status": status,
        "price": price,
        "stock": stock,
        "createdAt": createdAt,
        "updatedAt": updatedAt,
        "checked": checked
      };
}