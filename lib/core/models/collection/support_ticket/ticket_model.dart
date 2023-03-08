import 'package:hyppe/core/config/url_constants.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/models/collection/comment_v2/comment_data_v2.dart';
import 'package:hyppe/core/models/collection/utils/ticket/ticket_url.dart';
import 'package:hyppe/core/services/shared_preference.dart';

import '../../../config/env.dart';

class TicketModel {
  String? id;
  String? ticketNo;
  String? subject;
  String? body;
  String? dateTime;
  String? status;
  bool? isRead;
  bool? active;
  String? levelTicket;
  String? sourceTicket;
  String? categoryTicket;
  List<String>? mediaUri;
  List<String>? originalName;
  List<String>? fsSourceUri;
  List<String>? fsSourceName;
  List<String>? fsTargetUri;
  List<String> imageUrl = [];
  int? version;
  String? os;
  Avatar? avatar;
  String? mediaBasePath;
  String? mediaMime;
  String? mediaType;
  String? idUser;
  String? sender;
  String? receiver;
  String? category;
  String? levelName;
  String? sourceName;
  String? concat;
  String? pict;
  List<TicketDetail>? detail;
  TicketType? type;
  TicketStatus? statusEnum;

  TicketModel();

  TicketModel.fromJson(Map<String, dynamic> map) {
    final emailUser = SharedPreference().readStorage(SpKeys.email);
    final token = SharedPreference().readStorage(SpKeys.userToken);
    id = map['_id'];
    ticketNo = map['nomortiket'];
    subject = map['subject'];
    body = map['body'];
    dateTime = map['datetime'];
    status = map['status'];
    isRead = map['isRead'];
    active = map['active'];
    levelTicket = map['levelTicket'];
    sourceTicket = map['sourceTicket'];
    categoryTicket = map['categoryTicket'];
    if (map['mediaUri'] != null) {
      mediaUri = [];
      if (map['mediaUri'].isNotEmpty) {
        map['mediaUri'].forEach((v) => mediaUri?.add(v));
      }
    }
    if (map['originalName'] != null) {
      originalName = [];
      if (map['originalName'].isNotEmpty) {
        map['originalName'].forEach((v) => originalName?.add(v));
      }
    }
    if (map['fsSourceUri'] != null) {
      fsSourceUri = [];
      if (map['fsSourceUri'].isNotEmpty) {
        map['fsSourceUri'].forEach((v) => fsSourceUri?.add(v));
      }
    }
    if (map['fsSourceName'] != null) {
      fsSourceName = [];
      if (map['fsSourceName'].isNotEmpty) {
        map['fsSourceName'].forEach((v) => fsSourceName?.add(v));
      }
    }
    if (map['fsTargetUri'] != null) {
      fsSourceName = [];
      if (map['fsTargetUri'].isNotEmpty) {
        map['fsTargetUri'].forEach((v) => fsSourceName?.add(v));
      }
      for (var i = 0; i < fsSourceName!.length; i++) {
        imageUrl.add('${Env.data.baseUrl}${Env.data.versionApi}ticket/detail/supportfile/$id/$i?x-auth-token=$token&x-auth-user=$emailUser');
      }
    }
    version = map['version'];
    os = map['OS'];
    avatar = Avatar.fromJson(map['avatar']);
    mediaBasePath = map['mediaBasePath'];
    mediaMime = map['mediaMime'];
    mediaType = map['mediaType'];
    idUser = map['iduser'];
    sender = map['pengirim'];
    receiver = map['penerima'];
    category = map['nameCategory'];
    levelName = map['nameLevel'];
    sourceName = map['sourceName'];
    concat = map['concat'];
    pict = map['pict'];
    if (map['detail'] != null) {
      detail = [];
      if (map['detail'].isNotEmpty) {
        map['detail'].forEach((v) => detail?.add(TicketDetail.fromJson(v)));
      }
    }
    type = _getType(category ?? '');
    statusEnum = _getStatus(status ?? '');
  }

  Map<String, dynamic> toJson() {
    final result = <String, dynamic>{};
    result['_id'] = id;
    result['ticketNo'] = ticketNo;
    result['subject'] = subject;
    result['body'] = body;
    result['dateTime'] = dateTime;
    result['status'] = status;
    result['active'] = active;
    result['levelTicket'] = levelTicket;
    result['sourceTicket'] = sourceTicket;
    result['categoryTicket'] = categoryTicket;
    result['sender'] = sender;
    result['receiver'] = receiver;
    result['category'] = category;
    result['levelName'] = levelName;
    result['sourceName'] = sourceName;
    result['concat'] = concat;
    result['pict'] = pict;
    return result;
  }

  TicketType _getType(String category) {
    if (category == 'Akun dan Verifikasi') {
      return TicketType.accountVerification;
    } else if (category == 'Konten') {
      return TicketType.content;
    } else if (category == 'Transaksi') {
      return TicketType.transaction;
    } else if (category == 'Kepemilikan') {
      return TicketType.owner;
    } else if (category == 'Masalah Teknis dan Bug') {
      return TicketType.problemBugs;
    } else if (category == 'Iklan') {
      return TicketType.ads;
    } else {
      return TicketType.content;
    }
  }

  TicketStatus _getStatus(String status) {
    if (status == 'onprogress') {
      return TicketStatus.inProgress;
    } else if (status == 'close') {
      return TicketStatus.solved;
    } else if (status == 'new') {
      return TicketStatus.newest;
    } else {
      return TicketStatus.notSolved;
    }
  }
}

class TicketDetail {
  String? id;
  String? type;
  String? body;
  String? datetime;
  String? idUser;
  String? status;
  String? fullname;
  String? email;
  List<String>? mediaUri;
  List<String>? originalName;
  List<String>? fsSourceUri;
  List<String>? fsSourceName;
  List<String>? fsTargetUri;
  List<TicketUrl> ticketUrls = [];
  Avatar? avatar;

  TicketDetail.fromJson(Map<String, dynamic> map) {
    final emailUser = SharedPreference().readStorage(SpKeys.email);
    final token = SharedPreference().readStorage(SpKeys.userToken);
    id = map['_id'];
    type = map['type'];
    body = map['body'];
    datetime = map['datetime'];
    idUser = map['IdUser'];
    status = map['status'];
    fullname = map['fullName'];
    email = map['email'];
    if (map['mediaUri'] != null) {
      mediaUri = [];
      if (map['mediaUri'].isNotEmpty) {
        map['mediaUri'].forEach((v) => mediaUri?.add(v));
      }
    }
    if (map['originalName'] != null) {
      originalName = [];
      if (map['originalName'].isNotEmpty) {
        map['originalName'].forEach((v) => originalName?.add(v));
      }
    }
    if (map['fsSourceUri'] != null) {
      fsSourceUri = [];
      if (map['fsSourceUri'].isNotEmpty) {
        map['fsSourceUri'].forEach((v) => fsSourceUri?.add(v));
      }
    }
    if (map['fsSourceName'] != null) {
      fsSourceName = [];
      if (map['fsSourceName'].isNotEmpty) {
        map['fsSourceName'].forEach((v) => fsSourceName?.add(v));
      }
    }
    if (map['fsTargetUri'] != null) {
      fsTargetUri = [];
      if (map['fsTargetUri'].isNotEmpty) {
        map['fsTargetUri'].forEach((v) => fsTargetUri?.add(v));
      }
      for (var i = 0; i < fsTargetUri!.length; i++) {
        ticketUrls.add(TicketUrl(localDir: fsTargetUri![i], realUrl: '${Env.data.baseUrl}${Env.data.versionApi}ticket/detail/supportfile/$id/$i?x-auth-token=$token&x-auth-user=$emailUser'));
      }
    }

    avatar = Avatar.fromJson(map['avatar']);
  }

  get mediaEndpoint => null;
}
