class ViewAdsRequest{
  int? watchingTime;
  String? adsId;
  String? useradsId;

  ViewAdsRequest({
    this.watchingTime,
    this.adsId,
    this.useradsId
  });

  ViewAdsRequest.fromJson(Map<String, dynamic> json){
    watchingTime = json['watchingTime'] ?? 0;
    adsId = json['adsId'] ?? '';
    useradsId = json['useradsId'] ?? '';
  }

  Map<String, dynamic> toJson(){
    final Map<String, dynamic> result = <String, dynamic>{};
    result['watchingTime'] = watchingTime ?? 0;
    result['adsId'] = adsId ?? '';
    result['useradsId'] = useradsId ?? '';
    return result;
  }
}