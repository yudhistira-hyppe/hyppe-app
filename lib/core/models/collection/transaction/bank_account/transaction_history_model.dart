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
  String? partnerTrxid;
  String? fullThumbPath;
  String? paymentmethode;
  bool? like;
  bool? view;
  String? namapembeli;
  String? emailpembeli;
  String? time;
  String? namaBank;
  String? namaRek;
  String? noRek;
  int? bankverificationcharge;
  int? adminFee;
  int? totalview;
  int? totallike;

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
    partnerTrxid = json['partnerTrxid'] ?? '';
    fullThumbPath = concatThumbUri();
    paymentmethode = json['paymentmethode'] ?? '';
    like = json['like'] ?? false;
    view = json['view'] ?? false;
    namapembeli = json['namapembeli'] ?? '';
    emailpembeli = json['emailpembeli'] ?? '';
    time = json['time'] ?? '';
    namaBank = json['namaBank'] ?? '';
    namaRek = json['namaRek'] ?? '';
    noRek = json['noRek'] ?? '';
    bankverificationcharge = json['bankverificationcharge'] ?? 0;
    adminFee = json['adminFee'] ?? 0;
    totallike = json['totallike'] ?? 0;
    totalview = json['totalview'] ?? 0;
  }

  String? concatThumbUri() {
    return Env.data.baseUrl + (mediaEndpoint ?? '') + '?x-auth-token=${SharedPreference().readStorage(SpKeys.userToken)}&x-auth-user=${SharedPreference().readStorage(SpKeys.email)}';
  }
}
