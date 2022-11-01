class CategoryTicketModel {
  String? sId;
  String? nameCategory;
  String? desc;

  CategoryTicketModel({this.sId, this.nameCategory, this.desc});

  CategoryTicketModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    nameCategory = json['nameCategory'];
    desc = json['desc'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['nameCategory'] = nameCategory;
    data['desc'] = desc;
    return data;
  }
}
