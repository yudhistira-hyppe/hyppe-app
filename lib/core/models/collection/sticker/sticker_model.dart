import 'package:flutter/material.dart';

class StickerModel {
  String? id;
  Key? key;
  String? name;
  String? kategori;
  String? image;
  String? createdAt;
  String? updatedAt;
  int? used;
  bool? status;
  bool? isDelete;
  int? index;
  String? type;
  int? countsearch;
  int? countused;
  Matrix4? matrix;
  List<num>? position;

  StickerModel({
    this.id,
    this.key,
    this.name,
    this.kategori,
    this.image,
    this.createdAt,
    this.updatedAt,
    this.used,
    this.status,
    this.isDelete,
    this.index,
    this.type,
    this.countsearch,
    this.countused,
    this.matrix,
    this.position,
  });

  StickerModel.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    name = json['name'];
    kategori = json['kategori'] ?? '';
    image = json['image'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    used = json['used'];
    status = json['status'];
    isDelete = json['isDelete'];
    index = json['index'];
    type = json['type'];
    countsearch = json['countsearch'];
    countused = json['countused'];
    if (json['position'] != null) {
      position = json['position'].cast<num>();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = id;
    data['key'] = key;
    data['name'] = name;
    data['kategori'] = kategori;
    data['image'] = image;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['used'] = used;
    data['status'] = status;
    data['isDelete'] = isDelete;
    data['index'] = index;
    data['type'] = type;
    data['countsearch'] = countsearch;
    data['countused'] = countused;
    data['position'] = position;
    data['matrix'] = matrix?.storage;
    return data;
  }
}
