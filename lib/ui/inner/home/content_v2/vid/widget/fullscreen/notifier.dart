import 'package:flutter/material.dart';
import 'package:flutter_aliplayer/flutter_aliplayer.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';

import '../../../../../../../core/bloc/ads_video/bloc.dart';
import '../../../../../../../core/bloc/ads_video/state.dart';
import '../../../../../../../core/constants/enum.dart';
import '../../../../../../../core/models/collection/advertising/ads_video_data.dart';

class VideoNotifier with ChangeNotifier{

  bool _isShowingAds = false;
  bool get isShowingAds => _isShowingAds;
  set isShowingAds(bool state){
    _isShowingAds = state;
    notifyListeners();
  }

  AdsData? _tempAdsData = null;
  AdsData? get tempAdsData => _tempAdsData;
  set tempAdsData(AdsData? data){
    _tempAdsData = data;
    notifyListeners();
  }

  int _adsTime = 0;
  int get adsTime => _adsTime;
  set adsTime(int value){
    _adsTime = value;
    notifyListeners();
  }

  int _adsCurrentPosition = 0;
  int get adsCurrentPosition => _adsCurrentPosition;
  set adsCurrentPosition(int value){
    _adsCurrentPosition = value;
    notifyListeners();
  }

  int _adsCurrentPositionText = 0;
  int get adsCurrentPositionText => _adsCurrentPositionText;
  set adsCurrentPositionText(int value){
    _adsCurrentPositionText = value;
    notifyListeners();
  }

  int _secondsSkip = 0;
  int get secondsSkip => _secondsSkip;
  set secondsSkip (int value){
    _secondsSkip = value;
    notifyListeners();
  }

  bool _hasShowedAds = false;
  bool get hasShowedAds => _hasShowedAds;
  set hasShowedAds(bool state){
    _hasShowedAds = state;
    notifyListeners();
  }

  bool _isFullScreen = false;
  bool get isFullScreen => _isFullScreen;
  set isFullScreen(bool state){
    _isFullScreen = state;
    notifyListeners();
  }

  int _adsVideoDuration = 0;
  int get adsVideoDuration => _adsVideoDuration;
  set adsVideoDuration(int value){
    _adsVideoDuration = value;
    notifyListeners();
  }

  String _currentPostID = '';
  String get currentPostID => _currentPostID;
  set currentPostID(String value){
    _currentPostID = value;
    notifyListeners();
  }

  initVideo(){
    _hasShowedAds = false;
    _isFullScreen = false;
  }

  AliPlayerView? adsAliPlayerView;
  FlutterAliplayer? adsAliplayer;
  FlutterAliplayer? betweenPlayer;


  Future getAdsVideo(BuildContext context, int videoDuration) async {
    try {
      final notifier = AdsDataBloc();
      await notifier.adsVideoBlocV2(context, AdsType.content);
      final fetch = notifier.adsDataFetch;

      if (fetch.adsDataState == AdsDataState.getAdsVideoBlocSuccess) {
        // print('data : ${fetch.data.toString()}');
        final data = fetch.data;
        tempAdsData = data.data;
        secondsSkip = tempAdsData?.adsSkip ?? 0;
        final place = tempAdsData?.adsPlace;
        if(place != null){
          double duration = videoDuration/ 1000;
          adsTime = place.getAdsTime(duration);
        }else{
          adsTime = 2;
        }
        'videoId : ${tempAdsData?.videoId}'.logger();

      }
    } catch (e) {
      'Failed to fetch ads data $e'.logger();
    }
  }
}