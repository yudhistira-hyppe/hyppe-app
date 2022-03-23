import 'package:flutter/material.dart';
import 'package:hyppe/core/models/collection/utils/reaction/base_reaction.dart';

class ReactionInteractive extends BaseReaction {
  String? sId;
  String? reactionId;
  String? iconName;
  String? icon;
  String? utf;
  String? cts;
  String? createdAt;
  String? updatedAt;
  String? url;

  ReactionInteractive({
    this.sId,
    this.reactionId,
    this.iconName,
    this.icon,
    this.utf,
    this.cts,
    this.createdAt,
    this.updatedAt,
    this.url,
    String? postID,
    String? eventType,
    String? receiverParty,
  }) : super(
          postID: postID,
          eventType: eventType,
          receiverParty: receiverParty,
        );

  ReactionInteractive.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    reactionId = json['reactionId'];
    iconName = json['iconName'];
    icon = json['icon'];
    utf = json['utf'];
    cts = json['cts'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['reactionId'] = reactionId;
    data['iconName'] = iconName;
    data['icon'] = icon;
    data['utf'] = utf;
    data['cts'] = cts;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['url'] = url;
    return data;
  }

  @override
  bool operator ==(other) {
    if (identical(other, this)) return true;
    if (!(super == (other))) return false;

    return other is ReactionInteractive &&
        other.sId == sId &&
        other.reactionId == reactionId &&
        other.iconName == iconName &&
        other.icon == icon &&
        other.utf == utf &&
        other.cts == cts &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.url == url;
  }

  @override
  int get hashCode => hashValues(
        super.hashCode,
        sId,
        reactionId,
        iconName,
        icon,
        utf,
        cts,
        createdAt,
        updatedAt,
        url,
      );

  @override
  void copyWith(dynamic other) {
    super.copyWith(other);
    if (other is ReactionInteractive) {
      sId = other.sId;
      reactionId = other.reactionId;
      iconName = other.iconName;
      icon = other.icon;
      utf = other.utf;
      cts = other.cts;
      createdAt = other.createdAt;
      updatedAt = other.updatedAt;
      url = other.url;
    }
  }
}
