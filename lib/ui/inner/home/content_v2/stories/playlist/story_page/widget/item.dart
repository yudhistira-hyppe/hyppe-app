import 'dart:math';
import 'package:flutter/material.dart';

class Item {
  static final random = Random();
  double? size;
  late Alignment alignment;
  Item() {
    alignment = Alignment(random.nextDouble() * 2 - 1, random.nextDouble() * 2 - 1);
    size = random.nextDouble() * 40 + 1;
  }
}