class EffectModel {
  String? postID;
  String? namafile;
  String? descFile;
  String? fileAssetName;
  String? fileAssetBasePath;
  String? fileAssetUri;
  String? mediaName;
  String? mediaBasePath;
  String? mediaUri;
  String? mediaThumName;
  String? mediaThumBasePath;
  String? mediaThumUri;
  bool? status;

  EffectModel({
    this.postID,
    this.namafile,
    this.descFile,
    this.fileAssetName,
    this.fileAssetBasePath,
    this.fileAssetUri,
    this.mediaName,
    this.mediaBasePath,
    this.mediaUri,
    this.mediaThumName,
    this.mediaThumBasePath,
    this.mediaThumUri,
    this.status,
  });

  EffectModel.fromJson(Map<String, dynamic> json) {
    postID = json['_id'];
    namafile = json['namafile'];
    descFile = json['descFile'];
    fileAssetName = json['fileAssetName'];
    fileAssetBasePath = json['fileAssetBasePath'];
    fileAssetUri = json['fileAssetUri'];
    mediaName = json['mediaName'];
    mediaBasePath = json['mediaBasePath'];
    mediaUri = json['mediaUri'];
    mediaThumName = json['mediaThumName'];
    mediaThumBasePath = json['mediaThumBasePath'];
    mediaThumUri = json['mediaThumUri'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = postID;
    data['namafile'] = namafile;
    data['descFile'] = descFile;
    data['fileAssetName'] = fileAssetName;
    data['fileAssetBasePath'] = fileAssetBasePath;
    data['fileAssetUri'] = fileAssetUri;
    data['mediaName'] = mediaName;
    data['mediaBasePath'] = mediaBasePath;
    data['mediaUri'] = mediaUri;
    data['mediaThumName'] = mediaThumName;
    data['mediaThumBasePath'] = mediaThumBasePath;
    data['mediaThumUri'] = mediaThumUri;
    data['status'] = status;
    return data;
  }
}
