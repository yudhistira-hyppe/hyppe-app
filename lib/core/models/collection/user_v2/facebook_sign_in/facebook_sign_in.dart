class FacebookSignIn {
  String? email;
  String? id;
  Picture? picture;
  String? name;

  FacebookSignIn({this.email, this.id, this.picture, this.name});

  FacebookSignIn.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    id = json['id'];
    picture =
        json['picture'] != null ? Picture.fromJson(json['picture']) : null;
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['email'] = this.email;
    data['id'] = this.id;
    if (this.picture != null) {
      data['picture'] = this.picture?.toJson();
    }
    data['name'] = this.name;
    return data;
  }
}

class Picture {
  Picture? picture;

  Picture({this.picture});

  Picture.fromJson(Map<String, dynamic> json) {
    picture =
        json['picture'] != null ? new Picture.fromJson(json['picture']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.picture != null) {
      data['picture'] = this.picture?.toJson();
    }
    return data;
  }
}

class Pictures {
  bool? isSilhouette;
  int? height;
  String? url;
  int? width;

  Pictures({this.isSilhouette, this.height, this.url, this.width});

  Pictures.fromJson(Map<String, dynamic> json) {
    isSilhouette = json['is_silhouette'];
    height = json['height'];
    url = json['url'];
    width = json['width'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['is_silhouette'] = this.isSilhouette;
    data['height'] = this.height;
    data['url'] = this.url;
    data['width'] = this.width;
    return data;
  }
}
