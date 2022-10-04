import 'dart:math';

import 'package:flutter/material.dart';

import '../constants/shared_preference_keys.dart';
import '../services/shared_preference.dart';

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

  int getAdsCount(){
    try{
      int _countAds = SharedPreference().readStorage(SpKeys.countAds);
      print('success get count $_countAds');
      if (_countAds == null) {
        SharedPreference().writeStorage(SpKeys.countAds, 0);
        return 0;
      } else {
        return _countAds;
      }
    }catch(e){
      print('failed get count');
      SharedPreference().writeStorage(SpKeys.countAds, 0);
      return 0;
    }

  }

  void setAdsCount(int count){
    SharedPreference().writeStorage(SpKeys.countAds, count);
  }

  void incrementAdsCount(){
    final current = getAdsCount();
    if(current < 4){
      setAdsCount(getAdsCount() + 1);
    }else{
      setAdsCount(0);
    }
  }

}