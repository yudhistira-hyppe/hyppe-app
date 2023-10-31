class BetterPlayerAdsConfiguration {
  String? postID;
  List<BetterPlayerRoll>? rolls;

  BetterPlayerAdsConfiguration({
    this.rolls,
    this.postID,
  });
}

class BetterPlayerRoll {
  String? rollUri;
  int? rollDuration;

  BetterPlayerRoll({
    this.rollUri,
    this.rollDuration,
  });

  factory BetterPlayerRoll.fromJson(Map<String, dynamic> json) => BetterPlayerRoll(
        rollUri: json["rollUri"],
        rollDuration: json["rollDuration"],
      );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['rollUri'] = rollUri;
    data['rollDuration'] = rollDuration;
    return data;
  }

  @override
  String toString() {
    return 'BetterPlayerRoll{rollUri: $rollUri, rollDuration: $rollDuration}';
  }
}
