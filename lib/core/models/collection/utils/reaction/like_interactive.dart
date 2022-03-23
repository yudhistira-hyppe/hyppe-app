import 'package:flutter/material.dart';
import 'package:hyppe/core/models/collection/utils/reaction/base_reaction.dart';

class LikeInteractive extends BaseReaction {
  int? likes;

  LikeInteractive({
    this.likes,
    String? postID,
    String? eventType,
    String? receiverParty,
  }) : super(
          postID: postID,
          eventType: eventType,
          receiverParty: receiverParty,
        );

  LikeInteractive.fromJson(Map<String, dynamic> json) {
    likes = json['likes'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['likes'] = likes;
    return data;
  }

  @override
  bool operator ==(other) {
    if (identical(other, this)) return true;
    if (!(super == (other))) return false;

    return other is LikeInteractive && other.likes == likes;
  }

  @override
  int get hashCode => hashValues(
        super.hashCode,
        likes,
      );

  @override
  void copyWith(dynamic other) {
    super.copyWith(other);
    if (other is LikeInteractive) {
      likes = other.likes;
    }
  }
}
