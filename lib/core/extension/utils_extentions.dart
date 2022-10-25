
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/models/hive_box/boxes.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../ui/inner/home/notifier_v2.dart';
import '../constants/shared_preference_keys.dart';
import '../models/collection/posts/content_v2/content_data.dart';
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

  Future setAllContents(AllContents value) async{
    final box = Boxes.boxDataContents;
    await box.putAt(0, value);
  }

  AllContents? getAllContents(){
    final box = Boxes.boxDataContents;
    final value = box.getAt(0);
    return value;
  }

  bool isLandPageNotEmpty(){
    final notifierMain = Provider.of<HomeNotifier>(this, listen: false);
    final box = Boxes.boxDataContents;
    return box.get(notifierMain.visibilty) != null;
  }

}

extension ContentTypeDefine on String{
  ContentType? translateType(){
    if (this == "video") {
      return ContentType.video;
    } else if (this == "image") {
      return ContentType.image;
    }
    return null;
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