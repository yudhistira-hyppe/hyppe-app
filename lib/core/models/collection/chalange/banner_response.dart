class BannerData {
  String? id;
  String? title;
  String? url;
  String? image;
  String? createdAt;
  bool? statusTayang;
  String? fullName;

  BannerData({
    this.id,
    this.title,
    this.url,
    this.image,
    this.createdAt,
    this.statusTayang,
    this.fullName,
  });

  BannerData.fromJson(Map<String, dynamic> map){
    id = map['_id'];
    title = map['title'];
    url = map['url'];
    image = map['image'];
    createdAt = map['createdAt'];
    statusTayang = map['statusTayang'];
    fullName = map['fullName'];
  }

  Map<String, dynamic> toJson(){
    final Map<String, dynamic> result = {};
    result['_id'] = id;
    result['title'] = title;
    result['url'] = url;
    result['image'] = image;
    result['createdAt'] = createdAt;
    result['statusTayang'] = statusTayang;
    result['fullName'] = fullName;
    return result;
  }
}
