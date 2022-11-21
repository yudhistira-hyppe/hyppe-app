class Boosted {
  String? type;
  String? boostDate;
  BoostInterval? boostInterval;
  BoostSession? boostSession;
  List<BoostViewer>? boostViewer;

  Boosted({this.type, this.boostDate, this.boostInterval, this.boostSession, this.boostViewer});

  Boosted.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    boostDate = json['boostDate'];
    boostInterval = json['boostInterval'] != null ? BoostInterval.fromJson(json['boostInterval']) : null;
    boostSession = json['boostSession'] != null ? BoostSession.fromJson(json['boostSession']) : null;
    if (json['boostViewer'] != null) {
      boostViewer = <BoostViewer>[];
      json['boostViewer'].forEach((v) {
        boostViewer!.add(BoostViewer.fromJson(v));
      });
    }
  }
}

class BoostInterval {
  String? id;
  String? value;
  String? remark;

  BoostInterval({this.id, this.value, this.remark});

  BoostInterval.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    value = json['value'];
    remark = json['remark'];
  }
}

class BoostSession {
  String? id;
  String? start;
  String? end;
  String? timeStart;
  String? timeEnd;
  String? name;

  BoostSession({this.id, this.start, this.end, this.timeStart, this.timeEnd, this.name});

  BoostSession.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    start = json['start'];
    end = json['end'];
    timeStart = json['timeStart'];
    timeEnd = json['timeEnd'];
    name = json['name'];
  }
}

class BoostViewer {
  String? email;
  String? createAt;
  String? timeEnd;
  bool? isLast;

  BoostViewer({this.email, this.createAt, this.timeEnd, this.isLast});

  BoostViewer.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    createAt = json['createAt'];
    timeEnd = json['timeEnd'];
    isLast = json['isLast'];
  }
}
