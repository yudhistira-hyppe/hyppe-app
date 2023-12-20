import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_aliplayer/flutter_aliplayer.dart';
import 'package:hyppe/app.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/ui/inner/home/widget/ads_in_between.dart';
import 'package:hyppe/ui/inner/home/widget/ads_video_in_between.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../initial/hyppe/translate_v2.dart';
import '../../ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import '../bloc/ads_video/bloc.dart';
import '../bloc/ads_video/state.dart';
import '../bloc/posts_v2/bloc.dart';
import '../bloc/posts_v2/state.dart';
import '../constants/shared_preference_keys.dart';
import '../constants/themes/hyppe_colors.dart';
import '../models/collection/advertising/ads_video_data.dart';
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

  double getScreenDiagonal() => sqrt((getHeight() * getHeight()) + (getWidth() * getWidth()));

  double getScaleDiagonal() => getScreenDiagonal() /(sqrt((414 * 414) + (895 * 895)));

  double getHeightStatusBar() => MediaQuery.of(this).viewPadding.top;

  TextTheme getTextTheme() {
    return Theme.of(this).textTheme;
  }

  ColorScheme getColorScheme() {
    return Theme.of(this).colorScheme;
  }

  bool isDarkMode() {
    return SharedPreference().readStorage(SpKeys.themeData) ?? false;
  }

  int getAdsCount() {
    try {
      int _countAds = SharedPreference().readStorage(SpKeys.countAds);
      print('================== success get count $_countAds');
      if (_countAds == 0) {
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

  Future<AdsData?> getInBetweenAds() async {
    AdsData? data;
    // final Map<String, dynamic> map = {
    //   "adsId": "64f6b482441437a65cbf9049",
    //   "adsUrlLink": "https://youtu.be/XgqQBcJDhxI",
    //   "adsDescription": "test action day 4",
    //   "name": "test action day 4",
    //   "useradsId": "64feb97818d4a0ce8e58075c",
    //   "idUser": "62144570602c354635ed7b6d",
    //   "fullName": "Sukma Irawan",
    //   "email": "sukma_metal@yahoo.com",
    //   "username": "hariyantosubang",
    //   "avartar": {
    //     "mediaBasePath": "62144570602c354635ed7b6d/profilePict/62144570602c354635ed7b6d.jpeg",
    //     "mediaUri": "62144570602c354635ed7b6d.jpeg",
    //     "mediaType": "image",
    //     "mediaEndpoint": "/profilepict/0d0cf1aa-2b71-312b-7087-41e6ea7adfac"
    //   },
    //   "placingID": "633d3dd52f2800002d0064c2",
    //   "adsPlace": "Splash Screen",
    //   "adsType": "Sponsor Ads",
    //   "adsSkip": 7,
    //   "mediaType": "Video",
    //   "ctaButton": "AMBILL BURUAN!!",
    //   "videoId": "f69f4b404afd71eead563044f1fd0102"
    // };
    // await Future.delayed(const Duration(seconds: 1));
    // data = AdsData.fromJson(map);
    try {
      final notifier = AdsDataBloc();
      await notifier.adsVideoBlocV2(this, AdsType.between);
      final fetch = notifier.adsDataFetch;

      if (fetch.adsDataState == AdsDataState.getAdsVideoBlocSuccess) {
        // print('data : ${fetch.data.toString()}');
        data = fetch.data?.data;
      }
    } catch (e) {
      'Failed to fetch ads data $e'.logger();
    }
    return data;
  }

  Future<String> getAuth(BuildContext context, {String videoId = ''}) async {
    String result = '';
    try {
      final notifier = PostsBloc();
      await notifier.getAuthApsara(context, apsaraId: videoId);
      final fetch = notifier.postsFetch;
      if (fetch.postsState == PostsState.videoApsaraSuccess) {
        Map jsonMap = json.decode(fetch.data.toString());
        result = jsonMap['PlayAuth'] ?? '';
      }
      return result;
    } catch (e) {
      return '';
      // 'Failed to fetch ads data $e'.logger();
    }
  }

  Widget getAdsInBetween(AdsData? adsData, Function(VisibilityInfo)? onVisible, Function() onComplete, Function(FlutterAliplayer, String) getPlayer){
    if(adsData != null){
      if(adsData.mediaType?.toLowerCase() == 'video'){
        return AdsVideoInBetween( onVisibility: onVisible, data: adsData, afterReport: onComplete,getPlayer: getPlayer,);
      }else{
        return AdsInBetween(data: adsData, afterReport: onComplete,);
      }
    }
    return const SizedBox.shrink();
  }

  String getCurrentDate() {
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    return formatter.format(now);
  }

  bool isIndo() => SharedPreference().readStorage(SpKeys.isoCode) == 'id';

  Future showErrorConnection(LocalizationModelV2 language) async {
    await ShowBottomSheet().onShowColouredSheet(
      this,
      language.internetConnectionLost ?? ' ',
      maxLines: 3,
      borderRadius: 8,
      color: kHyppeTextLightPrimary,
      padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 12),
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 25),
    );
  }


}

extension StringDefine on String {

  String textToTitleCase() {
    if (length > 1) {
      return this[0].toUpperCase() + substring(1).toLowerCase();
      /*or text[0].toUpperCase() + text.substring(1).toLowerCase(), if you want absolute title case*/
    } else if (length == 1) {
      return this[0].toUpperCase();
    }
    return '';
  }

  bool withHttp(){
    if(length > 5){
      return substring(0, 4) == 'http';
    }else{
      return false;
    }

  }

  bool isSVG(){
    return toLowerCase().contains('.svg');
  }

  String get capitalizeFirstofEach =>
      split(' ')
      .map((element) => element.textToTitleCase())
      .toList()
      .join(' ');

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
    if (toLowerCase() == 'male' || toLowerCase() == 'laki-laki') {
      return language.male ?? 'Male';
    } else {
      return language.female ?? 'Female';
    }
  }

  bool canShowAds() {
    if (isNotEmpty) {
      final lastDatetime = DateFormat("yyyy-MM-dd HH:mm:ss").parse(this);
      return lastDatetime.isAfterFifteen();
    } else {
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

  int getMilliSeconds() {
    return DateTime.parse(System().dateTimeRemoveT(this)).millisecondsSinceEpoch;
  }

  bool isEmail() {
    return (substring(0, 6) == 'email:');
  }

  bool isHashtag() {
    if (isEmpty) {
      return false;
    }
    return (substring(0, 1) == '#');
  }

  Future<Uint8List?> getThumbBlob() async{
    try{
      final ByteData data =
      await NetworkAssetBundle(Uri.parse(this)).load(this);
      final Uint8List bytes = data.buffer.asUint8List();
      return bytes;
    }catch(e){
      'Error getThumbBlob: $e'.logger();
      return null;
    }
  }

  String trimNewLines(){
    final values = split('\n');
    String result = '';
    for(final value in values){
      if(value.isNotEmpty){
        result += '$value\n';
      }
    }
    return result;
  }

  bool hasEmoji(){
    return contains(RegExp(r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])'));
  }

  bool isUrlLink(){
    RegExp exp = new RegExp(r'(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+\.[\w/\-?=%.]+');
    return exp.hasMatch(this);
  }

  int convertInteger(){
    try{
      return int.parse(this);
    }catch(e){
      return 0;
    }
  }

  int getAdsTime(double seconds){
    if(toLowerCase() == 'first'){
      return 2;
    }else if(toLowerCase() == 'mid'){
      print('adsSkip seconds: ${seconds/2}');
      return seconds~/2;
    }else{
      return (seconds - 2).toInt();
    }
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

  String getCountShort(){
    if(this >= 1000000){
      final million = (this / 1000000).ceil();
      final hundred = (this / 100000).ceil();
      return '$million.${hundred}M';
    }else if(this >= 1000){
      final thousand = (this / 1000).ceil();
      final hundred = (this / 100).ceil();
      return '$thousand.${hundred}K';
    }else{
      return toString();
    }
  }
}

extension NumExtension on num {
  bool isInteger() => this is int || this == roundToDouble();
}

extension ListExtentsion on List? {
  bool isNotNullAndEmpty() {
    if (this == null) {
      return true;
    } else {
      if (this!.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    }
  }
}

extension SizeHelpers on Size {
  Size getFixSize(BuildContext context) {
    final heightScreen = context.getHeight();
    final widthScreen = context.getWidth();
    double fixHeight = height;
    double fixWidth = width;
    if (widthScreen < fixWidth) {
      final tempWidth = fixWidth;
      fixWidth = widthScreen;
      fixHeight = (fixHeight * fixWidth) / tempWidth;
    }
    if (heightScreen < fixHeight) {
      final tempHeight = heightScreen;
      fixHeight = heightScreen;
      fixWidth = (fixWidth * fixHeight) / tempHeight;
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

  bool isAfterFifteen() {
    final after15M = DateTime.now().subtract(const Duration(minutes: 1));
    print("hariiiiiii ============");
    print(after15M);
    print(after15M.minute);
    print(day);
    print(month);
    print(minute);
    print(day);
    return after15M.day >= day && after15M.month >= month && after15M.year >= year && after15M.hour >= hour && after15M.minute >= minute;
  }

  bool isYesterday() {
    final yesterday = DateTime.now().subtract(Duration(days: 1));
    return yesterday.day == day && yesterday.month == month && yesterday.year == year;
  }
}

extension DurationExt on Duration{
  String formatter() => [
    inMinutes.remainder(60).toString().padLeft(2, '0'),
    inSeconds.remainder(60).toString().padLeft(2, '0')
  ].join(":");

  String detail() => [
    inHours.remainder(60).toString().padLeft(2, '0'),
    inMinutes.remainder(60).toString().padLeft(2, '0'),
    inSeconds.remainder(60).toString().padLeft(2, '0')
  ].join(":");
}
