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

extension ContextScreen on BuildContext {

  double getWidth() {
    return MediaQuery.of(this).size.width;
  }

  double getHeight() {
    return MediaQuery.of(this).size.height;
  }

  TextTheme getTextTheme() {
    return Theme.of(this).textTheme;
  }

  ColorScheme getColorScheme(){
    return Theme.of(this).colorScheme;
  }

  bool isDarkMode() {
    return SharedPreference().readStorage(SpKeys.themeData) ?? false;
  }

  int getAdsCount() {
    try {
      int _countAds = SharedPreference().readStorage(SpKeys.countAds);
      print('success get count $_countAds');
      if (_countAds == null) {
        SharedPreference().writeStorage(SpKeys.countAds, 0);
        return 0;
      } else {
        return _countAds;
      }
    } catch (e) {
      print('failed get count');
      SharedPreference().writeStorage(SpKeys.countAds, 0);
      return 0;
    }
  }

  void setAdsCount(int count) {
    SharedPreference().writeStorage(SpKeys.countAds, count);
  }

  String getNameByDate() {
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyyMMdd_HHmmss');
    return formatter.format(now);
  }

  void incrementAdsCount() {
    final current = getAdsCount();
    print('ads second : $current');
    if (current < 5) {
      setAdsCount(getAdsCount() + 1);
    } else {
      setAdsCount(0);
    }
  }

  String getCurrentDate() {
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    return formatter.format(now);
  }
}

extension StringDefine on String {
  ContentType? translateType() {
    if (this == "video") {
      return ContentType.video;
    } else if (this == "image") {
      return ContentType.image;
    }
    return null;
  }

  bool isImageFormat() {
    return System().lookupContentMimeType(this)?.contains('image') ?? false;
  }

  String getGenderByLanguage() {
    LocalizationModelV2 language = Provider.of<TranslateNotifierV2>(materialAppKey.currentContext!, listen: false).translate;
    if (this == 'MALE' || this == 'Laki-laki') {
      return language.male ?? 'Male';
    } else {
      return language.female ?? 'Female';
    }
  }

  bool canShowAds(){
    if(isNotEmpty){
      final lastDatetime = DateFormat("yyyy-MM-dd HH:mm:ss").parse(this);
      return lastDatetime.isAfterFifteen();
    }else{
      return true;
    }
  }

  String getDateFormat(String format, LocalizationModelV2 translate, {bool isToday = true}) {
    try {
      final initForm = DateFormat(format);
      final parsedDate = DateTime.parse(this);
      if (isToday) {
        if (parsedDate.isToday()) {
          return translate.today ?? 'Today';
        } else if (parsedDate.isYesterday()) {
          return translate.yesterday ?? 'Yesterday';
        }
      }
      final get = initForm.format(parsedDate);
      final DateFormat formatter = DateFormat('dd/MM/yyyy');
      return formatter.format(DateTime.parse(get));
    } catch (e) {
      return 'Error: $e';
    }
  }

  int getMilliSeconds(){
    return DateTime.parse(System().dateTimeRemoveT(this)).millisecondsSinceEpoch;
  }
}

extension IntegerExtension on int {
  String getMinutes() {
    if (this > 3600) {
      return 'more than 1 hour';
    } else {
      final minutes = Duration(seconds: this).inMinutes;
      final seconds = this % 60;
      if (seconds < 10) {
        return '$minutes:0$seconds';
      } else {
        return '$minutes:$seconds';
      }
    }
  }
}

extension SizeHelpers on Size{
  Size getFixSize(BuildContext context){
    final heightScreen = context.getHeight();
    final widthScreen = context.getWidth();
    double fixHeight = height;
    double fixWidth = width;
    if(widthScreen < fixWidth){
      final tempWidth = fixWidth;
      fixWidth = widthScreen;
      fixHeight = (fixHeight*fixWidth)/tempWidth;
    }
    if(heightScreen < fixHeight){
      final tempHeight = heightScreen;
      fixHeight = heightScreen;
      fixWidth = (fixWidth*fixHeight)/tempHeight;
    }
    return Size(fixWidth, fixHeight);
  }
}

extension DateHelpers on DateTime {
  bool isToday() {
    final now = DateTime.now();
    // print('DateHelpers ${now.day} : ${this.day}');
    // print('DateHelpers ${now.month} : ${this.month}');
    // print('DateHelpers ${now.year} : ${this.year}');
    return now.day == day && now.month == month && now.year == year;
  }

  bool isAfterFifteen(){
    final after15M = DateTime.now().subtract(const Duration(minutes: 15));
    return after15M.day >= day && after15M.month >= month && after15M.year >= year && after15M.hour >= hour && after15M.minute >= minute;
  }

  bool isYesterday() {
    final yesterday = DateTime.now().subtract(Duration(days: 1));
    return yesterday.day == day && yesterday.month == month && yesterday.year == year;
  }
}
