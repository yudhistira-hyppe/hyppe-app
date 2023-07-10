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
  String? objectChallenge;
  int? totalSession;

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
    this.objectChallenge,
    this.totalSession,
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
        getlastrank!.add(Getlastrank.fromJson(v));
      });
    }
    status = json['status'];
    joined = json['joined'];
    objectChallenge = json['objectChallenge'];
    totalSession = json['totalSession'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['challengeId'] = challengeId;
    data['startDatetime'] = startDatetime;
    data['endDatetime'] = endDatetime;
    data['isActive'] = isActive;
    data['session'] = session;
    data['timenow'] = timenow;
    if (getlastrank != null) {
      data['getlastrank'] = getlastrank!.map((v) => v.toJson()).toList();
    }
    data['status'] = status;
    data['joined'] = joined;
    data['objectChallenge'] = objectChallenge;
    return data;
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
  AvatarChallange? avatar;
  String? currentstatistik;
  String? winnerBadge;

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
      this.winnerBadge});

  Getlastrank.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    idUser = json['idUser'];
    idSubChallenge = json['idSubChallenge'];
    ranking = json['ranking'];
    score = json['score'];
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
        postChallengess!.add(new PostChallengess.fromJson(v));
      });
    }
    objectChallenge = json['objectChallenge'].cast<String>();
    username = json['username'];
    email = json['email'];
    avatar = json['avatar'] != null ? new AvatarChallange.fromJson(json['avatar']) : null;
    currentstatistik = json['currentstatistik'];
    winnerBadge = json['winnerBadge'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['idUser'] = idUser;
    data['idSubChallenge'] = idSubChallenge;
    data['ranking'] = ranking;
    data['score'] = score;
    if (history != null) {
      data['history'] = history!.map((v) => v.toJson()).toList();
    }
    data['lastRank'] = lastRank;
    data['isUserLogin'] = isUserLogin;
    if (postChallengess != null) {
      data['postChallengess'] = postChallengess!.map((v) => v.toJson()).toList();
    }
    data['objectChallenge'] = objectChallenge;
    data['username'] = username;
    data['email'] = email;
    if (avatar != null) {
      data['avatar'] = avatar!.toJson();
    }
    data['currentstatistik'] = currentstatistik;
    data['winnerBadge'] = winnerBadge;
    return data;
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

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['updatedAt'] = updatedAt;
    data['score'] = score;
    data['ranking'] = ranking;
    return data;
  }
}

class PostChallengess {
  String? sId;
  String? postID;
  String? postType;
  int? index;

  PostChallengess({this.sId, this.postID, this.postType, this.index});

  PostChallengess.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    postID = json['postID'];
    postType = json['postType'];
    index = json['index'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['postID'] = postID;
    data['postType'] = postType;
    data['index'] = index;
    return data;
  }
}

class AvatarChallange {
  String? mediaEndpoint;

  AvatarChallange({this.mediaEndpoint});

  AvatarChallange.fromJson(Map<String, dynamic> json) {
    mediaEndpoint = json['mediaEndpoint'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['mediaEndpoint'] = mediaEndpoint;
    return data;
  }
}
