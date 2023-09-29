import 'package:hyppe/core/models/collection/sticker/sticker_model.dart';

class StickerCategoryModel {
  late String id;
  late String queryname;
  late double height;
  late double heightStart;
  late double heightEnd;
  String? kategoritime;
  String? kategoriicon;
  List<StickerModel>? data;

  StickerCategoryModel({
    this.id = '',
    this.queryname = '',
    this.kategoritime,
    this.kategoriicon,
    this.data,
    this.height = 0,
    // this.heightStart = 0,
    // this.heightEnd = 0,
  });

  StickerCategoryModel.fromJson(Map<String, dynamic> json) {
    var query = '';
    id = json['_id'] ?? '';
    kategoritime = json['kategoritime'];
    kategoriicon = json['kategoriicon'];
    if (json['data'] != null) {
      data = <StickerModel>[];
      query = id;
      json['data'].forEach((v) {
        StickerModel sticker = StickerModel.fromJson(v);
        data!.add(sticker);
        query = "$query - ${sticker.name}";
      });
    }
    height = 0;
    heightStart = 0;
    heightEnd = 0;
    queryname = query;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = id;
    data['kategoritime'] = kategoritime;
    data['kategoriicon'] = kategoriicon;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
