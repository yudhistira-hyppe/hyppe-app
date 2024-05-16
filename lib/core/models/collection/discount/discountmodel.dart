class DiscountModel {
  DiscountModel({
    this.id,
    this.type,
    this.name,
    this.package_id,
    this.thumbnail,
    this.used_stock,
    this.last_stock,
    this.active,
    this.status,
    this.code_package,
    this.stock,
    this.audiens,
    this.satuan_diskon,
    this.nominal_discount,
    this.min_use_disc,
    this.productID,
    this.productCode,
    this.productName,
    this.startCouponDate,
    this.endCouponDate,
    this.createdAt,
    this.updatedAt,
    this.checked = false,
    this.available,
    this.available_to_choose,
  });

  String? id;
  String? type;
  String? name;
  String? package_id;
  String? thumbnail;
  int? used_stock;
  int? last_stock;
  bool? active;
  bool? status;
  String? code_package;
  int? stock;
  String? audiens;
  String? satuan_diskon;
  int? nominal_discount;
  int? min_use_disc;
  String? productID;
  String? productCode;
  String? productName;
  String? startCouponDate;
  String? endCouponDate;
  String? createdAt;
  String? updatedAt;
  bool? checked;
  bool? available;
  bool? available_to_choose;

  factory DiscountModel.fromJson(Map<String, dynamic> json) => DiscountModel(
        id: json["_id"],
        type: json["type"]??'',
        name: json["name"]??'',
        package_id: json["package_id"]??'',
        thumbnail: json["thumbnail"]??'',
        used_stock: json["used_stock"]??0,
        last_stock: json["last_stock"]??0,
        active: json["active"]??false,
        status: json["status"]??false,
        code_package: json["code_package"]??'',
        stock: json["stock"]??0,
        audiens: json["audiens"]??'',
        satuan_diskon: json["satuan_diskon"]??'',
        nominal_discount: json["nominal_discount"]??0,
        min_use_disc: json["min_use_disc"]??0,
        productID: json["productID"]??'',
        productCode: json["productCode"]??'',
        productName: json["productName"]??'',
        startCouponDate: json["startCouponDate"]??'',
        endCouponDate: json["endCouponDate"]??'',
        createdAt: json["createdAt"]??'',
        updatedAt: json["updatedAt"]??'',
        checked: false,
        available: json["available"]??false,
        available_to_choose: json["available_to_choose"]??false,
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "type": type,
        "name": name,
        "package_id": package_id,
        "thumbnail": thumbnail,
        "used_stock": used_stock,
        "last_stock": last_stock,
        "active": active,
        "status": status,
        "code_package": code_package,
        "stock": stock,
        "audiens": audiens,
        "satuan_diskon": satuan_diskon,
        "nominal_discount": nominal_discount,
        "min_use_disc": min_use_disc,
        "productID": productID,
        "productCode": productCode,
        "productName": productName,
        "startCouponDate": startCouponDate,
        "endCouponDate": endCouponDate,
        "createdAt": createdAt,
        "updatedAt": updatedAt,
        "checked": checked,
        "available": available,
        "available_to_choose": available_to_choose,
      };
}