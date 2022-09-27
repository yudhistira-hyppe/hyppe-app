import 'package:flutter/material.dart';

extension contextScreen on BuildContext{
  double getWidth(){
    return MediaQuery.of(this).size.width;
  }

  double getHeight(){
    return MediaQuery.of(this).size.height;
  }

  TextTheme getTextTheme(){
    return Theme.of(this).textTheme;
  }
}