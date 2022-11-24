class BoostMasterModel {
  int? pendingTransaction;
  List<Interval>? interval;
  List<Session>? session;

  BoostMasterModel({this.interval, this.session});

  BoostMasterModel.fromJson(Map<String, dynamic> json) {
    pendingTransaction = json['pendingTransaction'] ?? 0;
    if (json['interval'] != null) {
      interval = <Interval>[];
      json['interval'].forEach((v) {
        interval!.add(Interval.fromJson(v));
      });
    }
    if (json['session'] != null) {
      session = <Session>[];
      json['session'].forEach((v) {
        session!.add(Session.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (interval != null) {
      data['interval'] = interval!.map((v) => v.toJson()).toList();
    }
    if (session != null) {
      data['session'] = session!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Interval {
  String? sId;
  String? value;
  String? remark;
  String? type;

  Interval({this.sId, this.value, this.remark, this.type});

  Interval.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    value = json['value'];
    remark = json['remark'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['value'] = value;
    data['remark'] = remark;
    data['type'] = type;
    return data;
  }
}

class Session {
  String? sId;
  String? name;
  String? start;
  String? end;
  String? type;

  Session({this.sId, this.name, this.start, this.end, this.type});

  Session.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    start = json['start'];
    end = json['end'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['start'] = start;
    data['end'] = end;
    data['type'] = type;
    return data;
  }
}
