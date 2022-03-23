import 'package:flutter/material.dart';

class BaseReaction {
  String? postID;

  String? eventType;

  String? receiverParty;

  BaseReaction({
    this.postID,
    this.eventType,
    this.receiverParty,
  });

  @override
  bool operator ==(other) {
    if (identical(other, this)) return true;

    return other is BaseReaction && other.postID == postID && other.eventType == eventType && other.receiverParty == receiverParty;
  }

  @override
  int get hashCode => hashValues(
        postID,
        eventType,
        receiverParty,
      );

  void copyWith(others) {
    if (others is! BaseReaction) return;

    postID = others.postID;
    eventType = others.eventType;
    receiverParty = others.receiverParty;
  }
}
