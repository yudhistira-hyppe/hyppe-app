import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';

class AdvertisingData {
  String? postID;
  List<PreRoll>? preRoll;
  List<MidRoll>? midRoll;
  List<PostRoll>? postRoll;
  List<Roll> ads = [];

  AdvertisingData({
    this.postID,
    this.preRoll,
    this.midRoll,
    this.postRoll,
  });

  AdvertisingData.fromJson(Map<String, dynamic> json, Metadata? metadata) {
    postID = json['postID'];
    if (json['preRoll'] != null) {
      preRoll = <PreRoll>[];
      json['preRoll'].forEach((v) {
        preRoll!.add(PreRoll.fromJson(v));
      });
    }
    if (json['midRoll'] != null) {
      midRoll = <MidRoll>[];
      json['midRoll'].forEach((v) {
        midRoll!.add(MidRoll.fromJson(v));
      });
    }
    if (json['postRoll'] != null) {
      postRoll = <PostRoll>[];
      json['postRoll'].forEach((v) {
        postRoll!.add(PostRoll.fromJson(v));
      });
    }

    _addAds(metadata);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['postID'] = postID;
    if (preRoll != null) {
      data['preRoll'] = preRoll!.map((v) => v.toJson()).toList();
    }
    if (midRoll != null) {
      data['midRoll'] = midRoll!.map((v) => v.toJson()).toList();
    }
    if (postRoll != null) {
      data['postRoll'] = postRoll!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  void _addAds(Metadata? metadata) {
    /// TODO(BACKEND): Add support for multiple ads, and include playingAt in the /adsroster endpoint

    // Add ads from preroll
    if (preRoll != null) {
      for (var i = 0; i < (preRoll?.length ?? 0); i++) {
        ads.add(Roll(
          rollUri: preRoll?[i].preRollUri,
          playingAt: metadata!.preRoll,
          rollDuration: preRoll?[i].preRollDuration,
        ));
      }
    }

    // Add ads from midroll
    if (midRoll != null) {
      for (var i = 0; i < (midRoll?.length ?? 0); i++) {
        ads.add(Roll(
          rollUri: midRoll?[i].midRollUri,
          // playingAt: metadata!.midRoll,
          playingAt: 0,
          rollDuration: midRoll?[i].midRollDuration,
        ));
      }
    }

    // Add ads from postroll
    if (postRoll != null) {
      for (var i = 0; i < (postRoll?.length ?? 0); i++) {
        ads.add(Roll(
          rollUri: postRoll?[i].postRollUri,
          playingAt: metadata!.postRoll! - 2,
          rollDuration: postRoll?[i].postRollDuration,
        ));
      }
    }

    // Sort ads by playingAt
    if (ads.isNotEmpty) {
      ads.sort((a, b) => a.playingAt!.compareTo(b.playingAt!));
    }
  }
}

class Roll {
  int? playingAt;
  String? rollUri;
  int? rollDuration;

  Roll({
    this.rollUri,
    this.playingAt,
    this.rollDuration,
  });
}

class PreRoll {
  int? preRollDuration;
  String? preRollUri;

  PreRoll({
    this.preRollDuration,
    this.preRollUri,
  });

  PreRoll.fromJson(Map<String, dynamic> json) {
    preRollDuration = json['preRollDuration'];
    preRollUri = json['preRollUri'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['preRollDuration'] = preRollDuration;
    data['preRollUri'] = preRollUri;
    return data;
  }
}

class MidRoll {
  int? midRollDuration;
  String? midRollUri;

  MidRoll({
    this.midRollDuration,
    this.midRollUri,
  });

  MidRoll.fromJson(Map<String, dynamic> json) {
    midRollDuration = json['midRollDuration'];
    midRollUri = json['midRollUri'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['midRollDuration'] = midRollDuration;
    data['midRollUri'] = midRollUri;
    return data;
  }
}

class PostRoll {
  int? postRollDuration;
  String? postRollUri;

  PostRoll({
    this.postRollDuration,
    this.postRollUri,
  });

  PostRoll.fromJson(Map<String, dynamic> json) {
    postRollDuration = json['postRollDuration'];
    postRollUri = json['postRollUri'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['postRollDuration'] = postRollDuration;
    data['postRollUri'] = postRollUri;
    return data;
  }
}
