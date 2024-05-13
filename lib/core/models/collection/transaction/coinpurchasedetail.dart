class CointPurchaseDetailModel {
  CointPurchaseDetailModel({
    this.price,
    this.transaction_fee,
    this.discount,
    this.total_before_discount,
    this.total_payment
  });

  int? price;
  int? transaction_fee;
  int? discount;
  int? total_before_discount;
  int? total_payment;

  factory CointPurchaseDetailModel.fromJson(Map<String, dynamic> json) => CointPurchaseDetailModel(
        price: json["price"],
        transaction_fee: json["transaction_fee"],
        discount: json["discount"],
        total_payment: json["total_payment"],
        total_before_discount: json["total_before_discount"],
      );

  Map<String, dynamic> toJson() => {
        "price": price,
        "transaction_fee": transaction_fee,
        "discount": discount,
        "total_payment": total_payment
      };
}