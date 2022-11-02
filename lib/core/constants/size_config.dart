import 'dart:math' show sqrt;
import 'package:flutter/material.dart';

class SizeConfig {
  static late MediaQueryData _mediaQueryData;
  static double? screenWidth;
  static double? screenHeight;
  static late double screenDiagonal;
  static late double scaleDiagonal;
  static late double paddingTop;
  static late double paddingBottom;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    paddingBottom = _mediaQueryData.padding.bottom;
    paddingTop = _mediaQueryData.padding.top;
    screenDiagonal = sqrt((screenHeight ?? 0 * (screenHeight ?? 0)) + (screenWidth ?? 0 * (screenHeight ?? 0)));
    scaleDiagonal = screenDiagonal / (sqrt((414 * 414) + (895 * 895)));
  }
}