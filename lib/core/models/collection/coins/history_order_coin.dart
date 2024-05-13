class HistoryOrderCoinModel {
  HistoryOrderCoinModel({
    this.id,
    this.status,
    this.description,
    this.totalamount,
    this.timestamp,
    this.vastatus,
    this.packagename
  });

  String? id;
  String? status;
  String? description;
  int? totalamount;
  String? timestamp;
  String? vastatus;
  String? packagename;

  factory HistoryOrderCoinModel.fromJson(Map<String, dynamic> json) => HistoryOrderCoinModel(
        id: json["_id"],
        status: json["status"]??'',
        description: json["description"]??'',
        totalamount: json["totalamount"]??0,
        timestamp: json["timestamp"]??'',
        vastatus: json["va_status"]??'',
        packagename: json["packagename"]??'',
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "status": status,
        "description": description,
        "totalamount": totalamount,
        "timestamp": timestamp,
        "va_status": vastatus,
        "packagename": packagename,
      };
}