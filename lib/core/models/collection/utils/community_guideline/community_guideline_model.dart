class CommunityGuidelinesModel {
  String? sId;
  String? name;
  String? titleId;
  String? titleEn;
  String? valueId;
  String? valueEn;
  String? createdAt;
  String? updatedAt;

  CommunityGuidelinesModel({
    this.sId,
    this.name,
    this.titleId,
    this.titleEn,
    this.valueId,
    this.valueEn,
    this.createdAt,
    this.updatedAt,
  });

  CommunityGuidelinesModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    titleId = json['title_id'];
    titleEn = json['title_en'];
    valueId = json['value_id'];
    valueEn = json['value_en'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }
}
