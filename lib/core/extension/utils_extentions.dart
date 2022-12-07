import 'package:flutter/material.dart';
import 'package:hyppe/app.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../initial/hyppe/translate_v2.dart';
import '../constants/shared_preference_keys.dart';
import '../models/collection/localization_v2/localization_model.dart';
import '../services/shared_preference.dart';
import '../services/system.dart';

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

  bool isDarkMode(){
    return SharedPreference().readStorage(SpKeys.themeData) ?? false;
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

  String getNameByDate(){
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyyMMdd_HHmmss');
    return formatter.format(now);
  }

  void incrementAdsCount(){
    final current = getAdsCount();
    print('ads second : $current');
    if(current < 4){
      setAdsCount(getAdsCount() + 1);
    }else{
      setAdsCount(0);
    }
  }

  String getCurrentDate(){
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    return formatter.format(now);
  }

  // Future setAllContents(AllContents value) async{
  //   final box = Boxes.boxDataContents;
  //   await box.putAt(0, value);
  // }
  //
  // AllContents? getAllContents(){
  //   final box = Boxes.boxDataContents;
  //   final value = box.getAt(0);
  //   return value;
  // }
  //
  // bool isLandPageNotEmpty(){
  //   final notifierMain = Provider.of<HomeNotifier>(this, listen: false);
  //   final box = Boxes.boxDataContents;
  //   return box.get(notifierMain.visibilty) != null;
  // }

}

extension StringDefine on String{
  ContentType? translateType(){
    if (this == "video") {
      return ContentType.video;
    } else if (this == "image") {
      return ContentType.image;
    }
    return null;
  }

  bool isImageFormat(){
    return System().lookupContentMimeType(this)?.contains('image') ?? false;
  }

  String getGenderByLanguage(){
    LocalizationModelV2 language = Provider.of<TranslateNotifierV2>(materialAppKey.currentContext!, listen: false).translate;
    if(this == 'MALE'){
      return language.male ?? 'Male';
    }else{
      return language.female ?? 'Female';
    }
  }
}

extension IntegerExtension on int{
  String getMinutes(){
    if(this > 3600){
      return 'more than 1 hour';
    }else{
      final minutes = Duration(seconds: this).inMinutes;
      final seconds = this%60;
      if(seconds < 10){
        return '$minutes:0$seconds';
      }else{
        return '$minutes:$seconds';
      }

    }
  }
}

// extension GetContentType on ContentType{
//   String? getValue(){
//     if(this == ContentType.video){
//       return "video";
//     }else if(this == ContentType.image){
//       return ""
//     }
//   }
// }