class GiftLiveModel {
  String? sId;
  String? type;
  String? name;
  String? packageId;
  String? thumbnail;
  int? usedStock;
  int? lastStock;
  bool? active;
  bool? status;
  int? price;
  int? stock;
  String? typeGift;
  String? animation;

  GiftLiveModel({this.sId, this.type, this.name, this.packageId, this.thumbnail, this.usedStock, this.lastStock, this.active, this.status, this.price, this.stock, this.typeGift, this.animation});

  GiftLiveModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    type = json['type'];
    name = json['name'];
    packageId = json['package_id'];
    thumbnail = json['thumbnail'];
    usedStock = json['used_stock'];
    lastStock = json['last_stock'];
    active = json['active'];
    status = json['status'];
    price = json['price'];
    stock = json['stock'];
    typeGift = json['typeGift'];
    animation = json['animation'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = sId;
    data['type'] = type;
    data['name'] = name;
    data['package_id'] = packageId;
    data['thumbnail'] = thumbnail;
    data['used_stock'] = usedStock;
    data['last_stock'] = lastStock;
    data['active'] = active;
    data['status'] = status;
    data['price'] = price;
    data['stock'] = stock;
    data['typeGift'] = typeGift;
    data['animation'] = animation;
    return data;
  }
}
