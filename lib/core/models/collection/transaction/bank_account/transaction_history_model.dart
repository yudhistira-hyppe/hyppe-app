import 'package:hyppe/core/config/env.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/services/system.dart';

class TransactionHistoryModel {
  String? id;
  String? iduser;
  TransactionType? type;
  String? jenis;
  String? timestamp;
  String? description;
  String? noinvoice;
  String? nova;
  String? expiredtimeva;
  bool? salelike;
  bool? saleview;
  String? bank;
  int? amount;
  int? totalamount;
  String? status;
  String? fullName;
  String? email;
  String? postID;
  FeatureType? postType;
  String? descriptionContent;
  String? title;
  String? mediaBasePath;
  String? mediaUri;
  String? mediaType;
  String? mediaEndpoint;
  String? mediaThumbEndpoint;
  String? partnerTrxid;
  String? fullThumbPath;
  String? paymentmethode;
  bool? like;
  bool? view;
  String? namapembeli;
  String? emailpembeli;
  String? namapenjual;
  String? emailpenjual;
  String? penjual;
  String? pembeli;
  String? time;
  String? namaBank;
  String? namaRek;
  String? noRek;
  int? bankverificationcharge;
  int? adminFee;
  int? serviceFee;
  int? totalview;
  int? totallike;
  bool? apsara;
  MediaModel? media;
  String? debetKredit;
  String? from;
  num? duration;
  num? kredit;
  num? skipTime;
  String? iconVoucher;
  List<DetailTransaction>? detailTransaction;

  TransactionHistoryModel.fromJSON(dynamic json) {
    id = json['_id'];
    iduser = json['iduser'];
    type = System().convertTransactionType(json['type']);
    jenis = json['jenis'] ?? '';
    timestamp = json['timestamp'];
    description = json['description'];
    noinvoice = json['noinvoice'];
    nova = json['nova'];
    expiredtimeva = json['expiredtimeva'];
    salelike = json['salelike'];
    saleview = json['saleview'];
    bank = json['bank'];
    amount = json['amount'];
    totalamount = json['totalamount'];
    status = json['status'];
    fullName = json['fullName'];
    email = json['email'];
    postID = json['postID'];
    postType = json['postType'] != null ? System().getPostType(json['postType']) : System().getPostType('');
    descriptionContent = json['descriptionContent'] ?? '';
    title = json['title'] ?? '';
    mediaBasePath = json['mediaBasePath'];
    mediaUri = json['mediaUri'];
    mediaType = json['mediaType'];
    mediaEndpoint = json['mediaEndpoint'];
    mediaThumbEndpoint = json['mediaThumbEndpoint'];
    partnerTrxid = json['partnerTrxid'] ?? '';
    fullThumbPath = concatThumbUri();
    paymentmethode = json['paymentmethode'] ?? '';
    like = json['like'] ?? false;
    view = json['view'] ?? false;
    namapembeli = json['namapembeli'] ?? '';
    emailpembeli = json['emailpembeli'] ?? '';
    namapenjual = json['namapenjual'] ?? '';
    emailpenjual = json['emailpenjual'] ?? '';
    penjual = json['penjual'] ?? '';
    pembeli = json['pembeli'] ?? '';
    time = json['time'] ?? '';
    namaBank = json['namaBank'] ?? '';
    namaRek = json['namaRek'] ?? '';
    noRek = json['noRek'] ?? '';
    bankverificationcharge = json['bankverificationcharge'] ?? 0;
    adminFee = json['adminFee'] ?? 0;
    serviceFee = json['serviceFee'] ?? 0;
    totallike = json['totallike'] ?? 0;
    totalview = json['totalview'] ?? 0;
    debetKredit = json['debetKredit'] ?? '';
    apsara = json['apsara'] == null
        ? json['apsaraId'] != ''
            ? true
            : false
        : json['apsara'] != ''
            ? json['apsara']
            : false;
    media = json['media'] == null
        ? null
        : json['media'] is List
            ? null
            : MediaModel.fromJSON(json['media']);
    from = json['from'] ?? '';
    duration = (json['duration'] is int) ? json['duration'].toDouble() : json['duration'];
    skipTime = (json['skipTime'] is int) ? json['skipTime'].toDouble() : json['skipTime'];
    kredit = (json['kredit'] is int) ? json['kredit'].toDouble() : json['kredit'];
    iconVoucher = json['iconVoucher'];
    if (json['detailTransaction'] != null) {
      detailTransaction = <DetailTransaction>[];
      json['detailTransaction'].forEach((v) {
        detailTransaction!.add(DetailTransaction.fromJson(v));
      });
    }
  }

  String? concatThumbUri() {
    final fixMedia = mediaThumbEndpoint ?? mediaEndpoint;
    if (fixMedia!.isNotEmpty) {
      return Env.data.baseUrl + fixMedia + '?x-auth-token=${SharedPreference().readStorage(SpKeys.userToken)}&x-auth-user=${SharedPreference().readStorage(SpKeys.email)}';
    } else {
      return fixMedia;
    }
  }
}

class DetailTransaction {
  String? voucherID;
  String? noVoucher;
  String? codeVoucher;
  bool? isActive;
  String? expiredAt;
  int? qty;
  int? totalPrice;
  int? totalCredit;

  DetailTransaction({this.voucherID, this.noVoucher, this.codeVoucher, this.isActive, this.expiredAt, this.qty, this.totalPrice, this.totalCredit});

  DetailTransaction.fromJson(Map<String, dynamic> json) {
    voucherID = json['voucherID'];
    noVoucher = json['noVoucher'];
    codeVoucher = json['codeVoucher'];
    isActive = json['isActive'];
    expiredAt = json['expiredAt'];
    qty = json['qty'];
    totalPrice = json['totalPrice'];
    totalCredit = json['totalCredit'];
  }
}

class MediaModel {
  List<ImageInfo>? imageInfo = [];
  List<VideoList>? videoList = [];

  MediaModel({this.imageInfo = const [], this.videoList = const []});

  MediaModel.fromJSON(dynamic json) {
    imageInfo = json["ImageInfo"] != null ? List<ImageInfo>.from(json["ImageInfo"].map((x) => ImageInfo.fromJSON(x))) : [];
    videoList = json["VideoList"] != null ? List<VideoList>.from(json["VideoList"].map((x) => VideoList.fromJSON(x))) : [];
  }
}

class ImageInfo {
  String? url;
  ImageInfo({this.url = ''});
  ImageInfo.fromJSON(dynamic json) {
    url = json['URL'];
  }
}

class VideoList {
  String? coverURL;
  VideoList({this.coverURL = ''});
  VideoList.fromJSON(dynamic json) {
    coverURL = json['CoverURL'];
  }
}

class CountTransactionProgress {
  int? datacount;
  CountTransactionProgress({this.datacount});
  CountTransactionProgress.fromJSON(dynamic json) {
    datacount = json['datacount'];
  }
}
