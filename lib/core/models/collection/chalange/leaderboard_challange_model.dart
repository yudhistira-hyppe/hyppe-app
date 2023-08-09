class LeaderboardChallangeModel {
  String? sId;
  String? challengeId;
  String? startDatetime;
  String? endDatetime;
  bool? isActive;
  int? session;
  String? timenow;
  List<Getlastrank>? getlastrank;
  String? status;
  String? joined;
  List<ChallengeData>? challengeData;
  List<SubChallenges>? subChallenges;
  int? totalSession;
  bool? onGoing;
  int? totalDays;
  String? noteTime;

  LeaderboardChallangeModel({
    this.sId,
    this.challengeId,
    this.startDatetime,
    this.endDatetime,
    this.isActive,
    this.session,
    this.timenow,
    this.getlastrank,
    this.status,
    this.joined,
    this.challengeData,
    this.subChallenges,
    this.totalSession,
    this.onGoing,
    this.totalDays,
    this.noteTime,
  });

  LeaderboardChallangeModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    challengeId = json['challengeId'];
    startDatetime = json['startDatetime'];
    endDatetime = json['endDatetime'];
    isActive = json['isActive'];
    session = json['session'];
    timenow = json['timenow'];
    if (json['getlastrank'] != null) {
      getlastrank = <Getlastrank>[];
      json['getlastrank'].forEach((v) {
        getlastrank!.add(new Getlastrank.fromJson(v));
      });
    }
    status = json['status'];
    joined = json['joined'];
    if (json['challenge_data'] != null) {
      challengeData = <ChallengeData>[];
      json['challenge_data'].forEach((v) {
        challengeData!.add(new ChallengeData.fromJson(v));
      });
    }
    if (json['subChallenges'] != null) {
      subChallenges = <SubChallenges>[];
      json['subChallenges'].forEach((v) {
        subChallenges!.add(new SubChallenges.fromJson(v));
      });
    }
    totalSession = json['totalSession'] ?? 0;
    onGoing = json['onGoing'];
    totalDays = json['totalDays'];
    noteTime = json['noteTime'];
  }
}

class Getlastrank {
  String? sId;
  String? idUser;
  String? idSubChallenge;
  int? ranking;
  int? score;
  List<History>? history;
  int? lastRank;
  bool? isUserLogin;
  List<PostChallengess>? postChallengess;
  List<String>? objectChallenge;
  String? username;
  String? email;
  Avatar? avatar;
  String? currentstatistik;
  String? winnerBadge;
  String? winnerBadgeOther;

  Getlastrank(
      {this.sId,
      this.idUser,
      this.idSubChallenge,
      this.ranking,
      this.score,
      this.history,
      this.lastRank,
      this.isUserLogin,
      this.postChallengess,
      this.objectChallenge,
      this.username,
      this.email,
      this.avatar,
      this.currentstatistik,
      this.winnerBadge,
      this.winnerBadgeOther});

  Getlastrank.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    idUser = json['idUser'];
    idSubChallenge = json['idSubChallenge'];
    ranking = json['ranking'] ?? 1;
    score = json['score'] ?? 0;
    if (json['history'] != null) {
      history = <History>[];
      json['history'].forEach((v) {
        history!.add(new History.fromJson(v));
      });
    }
    lastRank = json['lastRank'];
    isUserLogin = json['isUserLogin'];
    if (json['postChallengess'] != null) {
      postChallengess = <PostChallengess>[];
      json['postChallengess'].forEach((v) {
        postChallengess!.add(PostChallengess.fromJson(v));
      });
    }
    objectChallenge = json['objectChallenge'].cast<String>();
    username = json['username'];
    email = json['email'];
    avatar = json['avatar'] != null ? Avatar.fromJson(json['avatar']) : null;
    currentstatistik = json['currentstatistik'];
    winnerBadge = json['winnerBadge'];
    winnerBadgeOther = json['winnerBadgeOther'];
  }
}

class History {
  String? updatedAt;
  int? score;
  int? ranking;

  History({this.updatedAt, this.score, this.ranking});

  History.fromJson(Map<String, dynamic> json) {
    updatedAt = json['updatedAt'];
    score = json['score'];
    ranking = json['ranking'];
  }
}

class PostChallengess {
  String? sId;
  String? postID;
  String? postType;
  int? index;
  String? mediaThumbEndpoint;
  String? description;

  PostChallengess({this.sId, this.postID, this.postType, this.index, this.mediaThumbEndpoint, this.description});

  PostChallengess.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    postID = json['postID'];
    postType = json['postType'];
    index = json['index'];
    mediaThumbEndpoint = json['mediaThumbEndpoint'];
    description = json['description'];
  }
}

class Avatar {
  String? mediaEndpoint;

  Avatar({this.mediaEndpoint});

  Avatar.fromJson(Map<String, dynamic> json) {
    mediaEndpoint = json['mediaEndpoint'];
  }
}

class ChallengeData {
  String? sId;
  String? nameChallenge;
  String? jenisChallenge;
  String? description;
  String? createdAt;
  String? updatedAt;
  int? durasi;
  String? startChallenge;
  String? endChallenge;
  String? startTime;
  String? endTime;
  String? jenisDurasi;
  bool? tampilStatusPengguna;
  String? objectChallenge;
  String? statusChallenge;
  List<Metrik>? metrik;
  List<Peserta>? peserta;
  List<LeaderBoard>? leaderBoard;
  List<KetentuanHadiah>? ketentuanHadiah;
  List<HadiahPemenang>? hadiahPemenang;
  List<BannerSearch>? bannerSearch;

  ChallengeData({
    this.sId,
    this.nameChallenge,
    this.jenisChallenge,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.durasi,
    this.startChallenge,
    this.endChallenge,
    this.startTime,
    this.endTime,
    this.jenisDurasi,
    this.tampilStatusPengguna,
    this.objectChallenge,
    this.statusChallenge,
    this.metrik,
    this.peserta,
    this.leaderBoard,
    this.ketentuanHadiah,
    this.hadiahPemenang,
    this.bannerSearch,
  });

  ChallengeData.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    nameChallenge = json['nameChallenge'];
    jenisChallenge = json['jenisChallenge'];
    description = json['description'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    durasi = json['durasi'];
    startChallenge = json['startChallenge'];
    endChallenge = json['endChallenge'];
    startTime = json['startTime'];
    endTime = json['endTime'];
    jenisDurasi = json['jenisDurasi'];
    tampilStatusPengguna = json['tampilStatusPengguna'];
    objectChallenge = json['objectChallenge'];
    statusChallenge = json['statusChallenge'];
    if (json['metrik'] != null) {
      metrik = <Metrik>[];
      json['metrik'].forEach((v) {
        metrik!.add(new Metrik.fromJson(v));
      });
    }
    if (json['peserta'] != null) {
      peserta = <Peserta>[];
      json['peserta'].forEach((v) {
        peserta!.add(new Peserta.fromJson(v));
      });
    }
    if (json['leaderBoard'] != null) {
      leaderBoard = <LeaderBoard>[];
      json['leaderBoard'].forEach((v) {
        leaderBoard!.add(new LeaderBoard.fromJson(v));
      });
    }
    if (json['ketentuanHadiah'] != null) {
      ketentuanHadiah = <KetentuanHadiah>[];
      json['ketentuanHadiah'].forEach((v) {
        ketentuanHadiah!.add(new KetentuanHadiah.fromJson(v));
      });
    }
    if (json['hadiahPemenang'] != null) {
      hadiahPemenang = <HadiahPemenang>[];
      json['hadiahPemenang'].forEach((v) {
        hadiahPemenang!.add(new HadiahPemenang.fromJson(v));
      });
    }
    if (json['bannerSearch'] != null) {
      bannerSearch = <BannerSearch>[];
      json['bannerSearch'].forEach((v) {
        bannerSearch!.add(new BannerSearch.fromJson(v));
      });
    }
  }
}

class Metrik {
  bool? aktivitas;
  bool? interaksi;
  List<AktivitasAkun>? aktivitasAkun;
  List<InteraksiKonten>? interaksiKonten;

  Metrik({this.aktivitas, this.interaksi, this.aktivitasAkun, this.interaksiKonten});

  Metrik.fromJson(Map<String, dynamic> json) {
    aktivitas = json['Aktivitas'];
    interaksi = json['Interaksi'];
    if (json['AktivitasAkun'] != null) {
      aktivitasAkun = <AktivitasAkun>[];
      json['AktivitasAkun'].forEach((v) {
        aktivitasAkun!.add(AktivitasAkun.fromJson(v));
      });
    }
    if (json['InteraksiKonten'] != null) {
      interaksiKonten = <InteraksiKonten>[];
      json['InteraksiKonten'].forEach((v) {
        interaksiKonten!.add(InteraksiKonten.fromJson(v));
      });
    }
  }
}

class AktivitasAkun {
  int? referal;
  int? ikuti;

  AktivitasAkun({this.referal, this.ikuti});

  AktivitasAkun.fromJson(Map<String, dynamic> json) {
    referal = json['Referal'];
    ikuti = json['Ikuti'];
  }
}

class InteraksiKonten {
  String? tagar;
  List<BuatKonten>? buatKonten;
  List<BuatKonten>? suka;
  List<Tonton>? tonton;

  InteraksiKonten({this.tagar, this.buatKonten, this.suka, this.tonton});

  InteraksiKonten.fromJson(Map<String, dynamic> json) {
    tagar = json['tagar'];
    if (json['buatKonten'] != null) {
      buatKonten = <BuatKonten>[];
      json['buatKonten'].forEach((v) {
        buatKonten!.add(new BuatKonten.fromJson(v));
      });
    }
    if (json['suka'] != null) {
      suka = <BuatKonten>[];
      json['suka'].forEach((v) {
        suka!.add(new BuatKonten.fromJson(v));
      });
    }
    if (json['tonton'] != null) {
      tonton = <Tonton>[];
      json['tonton'].forEach((v) {
        tonton!.add(new Tonton.fromJson(v));
      });
    }
  }
}

class BuatKonten {
  int? hyppeVid;
  int? hyppePic;
  int? hyppeDiary;

  BuatKonten({this.hyppeVid, this.hyppePic, this.hyppeDiary});

  BuatKonten.fromJson(Map<String, dynamic> json) {
    hyppeVid = json['HyppeVid'];
    hyppePic = json['HyppePic'];
    hyppeDiary = json['HyppeDiary'];
  }
}

class Tonton {
  int? hyppeVid;
  int? hyppeDiary;

  Tonton({this.hyppeVid, this.hyppeDiary});

  Tonton.fromJson(Map<String, dynamic> json) {
    hyppeVid = json['HyppeVid'];
    hyppeDiary = json['HyppeDiary'];
  }
}

class Peserta {
  String? tipeAkunTerverikasi;
  String? caraGabung;
  List<JenisKelamin>? jenisKelamin;
  List<String>? lokasiPengguna;

  Peserta({
    this.tipeAkunTerverikasi,
    this.caraGabung,
    this.jenisKelamin,
    this.lokasiPengguna,
  });

  Peserta.fromJson(Map<String, dynamic> json) {
    tipeAkunTerverikasi = json['tipeAkunTerverikasi'];
    caraGabung = json['caraGabung'];
    if (json['jenisKelamin'] != null) {
      jenisKelamin = <JenisKelamin>[];
      json['jenisKelamin'].forEach((v) {
        jenisKelamin!.add(new JenisKelamin.fromJson(v));
      });
    }
    lokasiPengguna = json['lokasiPengguna'].cast<String>();
  }
}

class JenisKelamin {
  String? lAKILAKI;
  String? pEREMPUAN;
  String? oTHER;

  JenisKelamin({this.lAKILAKI, this.pEREMPUAN, this.oTHER});

  JenisKelamin.fromJson(Map<String, dynamic> json) {
    lAKILAKI = json['LAKI-LAKI'];
    pEREMPUAN = json['PEREMPUAN'];
    oTHER = json['OTHER'];
  }
}

class LeaderBoard {
  bool? tampilBadge;
  int? height;
  int? weight;
  int? maxSize;
  int? minSize;
  String? warnaBackground;
  String? formatFile;
  String? bannerLeaderboard;

  LeaderBoard({this.tampilBadge, this.height, this.weight, this.maxSize, this.minSize, this.warnaBackground, this.formatFile, this.bannerLeaderboard});

  LeaderBoard.fromJson(Map<String, dynamic> json) {
    tampilBadge = json['tampilBadge'] is String
        ? json['tampilBadge'] == "true"
            ? true
            : false
        : json['tampilBadge'] ?? false;
    height = json['Height'];
    weight = json['Weight'];
    maxSize = json['maxSize'];
    minSize = json['minSize'];
    warnaBackground = json['warnaBackground'];
    formatFile = json['formatFile'];
    bannerLeaderboard = json['bannerLeaderboard'];
  }
}

class KetentuanHadiah {
  bool? badgePemenang;
  int? height;
  int? weight;
  int? maxSize;
  int? minSize;
  String? formatFile;
  List<Badge>? badge;

  KetentuanHadiah({this.badgePemenang, this.height, this.weight, this.maxSize, this.minSize, this.formatFile, this.badge});

  KetentuanHadiah.fromJson(Map<String, dynamic> json) {
    badgePemenang = json['badgePemenang'];
    height = json['Height'];
    weight = json['Weight'];
    maxSize = json['maxSize'];
    minSize = json['minSize'];
    formatFile = json['formatFile'];
    if (json['badge'] != null) {
      badge = <Badge>[];
      json['badge'].forEach((v) {
        badge!.add(new Badge.fromJson(v));
      });
    }
  }
}

class Badge {
  String? juara1;
  String? juara2;
  String? juara3;

  Badge({this.juara1, this.juara2, this.juara3});

  Badge.fromJson(Map<String, dynamic> json) {
    juara1 = json['juara1'];
    juara2 = json['juara2'];
    juara3 = json['juara3'];
  }
}

class HadiahPemenang {
  String? currency;
  int? juara1;
  int? juara2;
  int? juara3;

  HadiahPemenang({this.currency, this.juara1, this.juara2, this.juara3});

  HadiahPemenang.fromJson(Map<String, dynamic> json) {
    currency = json['currency'];
    juara1 = json['juara1'];
    juara2 = json['juara2'];
    juara3 = json['juara3'];
  }
}

class BannerSearch {
  int? height;
  int? weight;
  int? maxSize;
  int? minSize;
  String? formatFile;
  String? image;

  BannerSearch({this.height, this.weight, this.maxSize, this.minSize, this.formatFile, this.image});

  BannerSearch.fromJson(Map<String, dynamic> json) {
    height = json['Height'];
    weight = json['Weight'];
    maxSize = json['maxSize'];
    minSize = json['minSize'];
    formatFile = json['formatFile'];
    image = json['image'];
  }
}

class SubChallenges {
  int? tahun;
  List<DetailSub>? detail;

  SubChallenges({this.tahun, this.detail});

  SubChallenges.fromJson(Map<String, dynamic> json) {
    tahun = json['tahun'];
    if (json['detail'] != null) {
      detail = <DetailSub>[];
      json['detail'].forEach((v) {
        detail!.add(new DetailSub.fromJson(v));
      });
    }
  }
}

class DetailSub {
  int? bulan;
  int? tahun;
  List<Detail>? detail;

  DetailSub({this.bulan, this.tahun, this.detail});

  DetailSub.fromJson(Map<String, dynamic> json) {
    bulan = json['bulan'];
    tahun = json['tahun'];
    if (json['detail'] != null) {
      detail = <Detail>[];
      json['detail'].forEach((v) {
        detail!.add(new Detail.fromJson(v));
      });
    }
  }
}

class Detail {
  String? sId;
  String? challengeId;
  String? startDatetime;
  String? endDatetime;
  bool? isActive;
  int? session;
  int? tahun;
  int? bulan;

  Detail({this.sId, this.challengeId, this.startDatetime, this.endDatetime, this.isActive, this.session, this.tahun, this.bulan});

  Detail.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    challengeId = json['challengeId'];
    startDatetime = json['startDatetime'];
    endDatetime = json['endDatetime'];
    isActive = json['isActive'];
    session = json['session'];
    tahun = json['tahun'];
    bulan = json['bulan'];
  }
}
