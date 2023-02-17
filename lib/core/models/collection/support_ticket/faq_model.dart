class FaqModel {
  String? sId;
  String? usercreate;
  String? email;
  String? kategori;
  String? datetime;
  String? tipe;
  bool? active;

  FaqModel({this.sId, this.usercreate, this.email, this.kategori, this.datetime, this.tipe, this.active});

  FaqModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    usercreate = json['usercreate'];
    email = json['email'];
    kategori = json['kategori'];
    datetime = json['datetime'];
    tipe = json['tipe'];
    active = json['active'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['usercreate'] = usercreate;
    data['email'] = email;
    data['kategori'] = kategori;
    data['datetime'] = datetime;
    data['tipe'] = tipe;
    data['active'] = active;
    return data;
  }
}
