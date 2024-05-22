class BoostContent {
  String? typeBoost;
  IntervalBoost? intervalBoost;
  SessionBoost? sessionBoost;
  String? dateBoostStart;
  String? dateBoostEnd;
  int? priceBoost;
  int? priceBankVaCharge;
  int? priceTotal;

  BoostContent({this.typeBoost, this.intervalBoost, this.sessionBoost, this.dateBoostStart, this.dateBoostEnd, this.priceBoost, this.priceBankVaCharge, this.priceTotal});

  BoostContent.fromJson(Map<String, dynamic> json) {
    typeBoost = json['typeBoost'];
    intervalBoost = json['intervalBoost'] != null ? IntervalBoost.fromJson(json['intervalBoost']) : null;
    sessionBoost = json['sessionBoost'] != null ? SessionBoost.fromJson(json['sessionBoost']) : null;
    dateBoostStart = json['dateBoostStart'];
    dateBoostEnd = json['dateBoostEnd'];
    priceBoost = json['priceBoost'];
    priceBankVaCharge = json['priceBankVaCharge'];
    priceTotal = json['priceTotal'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['typeBoost'] = typeBoost;
    if (intervalBoost != null) {
      data['intervalBoost'] = intervalBoost!.toJson();
    }
    if (sessionBoost != null) {
      data['sessionBoost'] = sessionBoost!.toJson();
    }
    data['dateBoostStart'] = dateBoostStart;
    data['dateBoostEnd'] = dateBoostEnd;
    data['priceBoost'] = priceBoost;
    data['priceBankVaCharge'] = priceBankVaCharge;
    data['priceTotal'] = priceTotal;
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
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
