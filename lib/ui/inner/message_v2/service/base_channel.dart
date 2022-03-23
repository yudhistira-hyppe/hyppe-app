import 'package:flutter/material.dart';

class BaseChannel {
  /// This discuss Id
  String discussId;

  /// timestamp when this discuss is created
  int? createdAt;

  BaseChannel({
    required this.discussId,
    this.createdAt,
  });

  @override
  bool operator ==(other) {
    if (identical(other, this)) return true;

    return other is BaseChannel && other.discussId == discussId && other.createdAt == createdAt;
  }

  @override
  int get hashCode => hashValues(
        discussId,
        createdAt,
      );

  String get primaryKey => discussId;

  void copyWith(others) {
    if (others is! BaseChannel) return;

    discussId = others.discussId;
    createdAt = others.createdAt;
  }
}
