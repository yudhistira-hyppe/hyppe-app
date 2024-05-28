class BoostContent {
  String? typeBoost;
  IntervalBoost? intervalBoost;
  SessionBoost? sessionBoost;
  String? dateBoostStart;
  String? dateBoostEnd;
  int? priceBoost;
  int? discount;
  int? priceTotal;

  BoostContent({this.typeBoost, this.intervalBoost, this.sessionBoost, this.dateBoostStart, this.dateBoostEnd, this.priceBoost, this.discount, this.priceTotal});

  BoostContent.fromJson(Map<String, dynamic> json) {
    typeBoost = json['typeBoost'];
    intervalBoost = json['interval'] != null ? IntervalBoost.fromJson(json['interval']) : null;
    sessionBoost = json['session'] != null ? SessionBoost.fromJson(json['session']) : null;
    dateBoostStart = json['dateStart'];
    dateBoostEnd = json['dateEnd'];
    priceBoost = json['price'];
    discount = json['discount'];
    priceTotal = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['typeBoost'] = typeBoost;
    if (intervalBoost != null) {
      data['interval'] = intervalBoost!.toJson();
    }
    if (sessionBoost != null) {
      data['session'] = sessionBoost!.toJson();
    }
    data['dateStart'] = dateBoostStart;
    data['dateEnd'] = dateBoostEnd;
    data['price'] = priceBoost;
    data['discount'] = discount;
    data['total'] = priceTotal;
    return data;
  }
}

class IntervalBoost {
  String? sId;
  String? value;
  String? remark;
  String? type;

  IntervalBoost({this.sId, this.value, this.remark, this.type});

  IntervalBoost.fromJson(Map<String, dynamic> json) {
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

class SessionBoost {
  String? sId;
  String? name;
  String? start;
  String? end;
  String? type;

  SessionBoost({this.sId, this.name, this.start, this.end, this.type});

  SessionBoost.fromJson(Map<String, dynamic> json) {
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
