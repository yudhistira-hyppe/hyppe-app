import 'package:flutter/material.dart';
import 'package:flutter_aliplayer/flutter_aliplayer.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';

import '../../../../../../../core/bloc/ads_video/bloc.dart';
import '../../../../../../../core/bloc/ads_video/state.dart';
import '../../../../../../../core/constants/enum.dart';
import '../../../../../../../core/models/collection/advertising/ads_video_data.dart';

class VideoNotifier with ChangeNotifier {
  Map<String, AdsData?> mapInContentAds = {};
  setMapAdsContent(String id, AdsData? value) {
    mapInContentAds[id] = value;
    notifyListeners();
  }

  bool _isShowingAds = false;
  bool get isShowingAds => _isShowingAds;

  int firstIndex = 0;
  int get firstcurrentIndex => firstIndex;

  int currIndex = 0;
  int get currentIndex => currIndex;

  set isShowingAds(bool state) {
    _isShowingAds = state;
    notifyListeners();
  }

  AdsData? _tempAdsData = null;
  AdsData? get tempAdsData => _tempAdsData;
  set tempAdsData(AdsData? data) {
    _tempAdsData = data;
    notifyListeners();
  }

  setTempAdsData(AdsData? data) {
    _tempAdsData = data;
  }

  int _adsTime = 0;
  int get adsTime => _adsTime;
  set adsTime(int value) {
    _adsTime = value;
    notifyListeners();
  }

  int _adsCurrentPosition = 0;
  int get adsCurrentPosition => _adsCurrentPosition;
  set adsCurrentPosition(int value) {
    _adsCurrentPosition = value;
    notifyListeners();
  }

  int _adsCurrentPositionText = 0;
  int get adsCurrentPositionText => _adsCurrentPositionText;
  set adsCurrentPositionText(int value) {
    _adsCurrentPositionText = value;
    notifyListeners();
  }

  initAdsContent() {
    _adsCurrentPosition = 0;
    _adsCurrentPositionText = 0;
  }

  int _secondsSkip = 0;
  int get secondsSkip => _secondsSkip;
  set secondsSkip(int value) {
    _secondsSkip = value;
    notifyListeners();
  }

  bool _hasShowedAds = true;
  bool get hasShowedAds => _hasShowedAds;
  set hasShowedAds(bool state) {
    _hasShowedAds = state;
    notifyListeners();
  }

  setHasShowedAds(bool state) {
    _hasShowedAds = state;
  }

  bool _isFullScreen = false;
  bool get isFullScreen => _isFullScreen;
  set isFullScreen(bool state) {
    _isFullScreen = state;
    notifyListeners();
  }

  setIsFullScreen(bool state) {
    _isFullScreen = state;
  }

  int _adsVideoDuration = 0;
  int get adsVideoDuration => _adsVideoDuration;
  set adsVideoDuration(int value) {
    _adsVideoDuration = value;
    notifyListeners();
  }

  String _currentPostID = '';
  String get currentPostID => _currentPostID;
  set currentPostID(String value) {
    _currentPostID = value;
    notifyListeners();
  }

  initVideo() {
    _hasShowedAds = false;
    _isFullScreen = false;
  }

  AliPlayerView? adsAliPlayerView;
  FlutterAliplayer? adsAliplayer;
  FlutterAliplayer? betweenPlayer;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  set isLoading(bool state) {
    _isLoading = state;
    notifyListeners();
  }

  bool _loadVideo = false;
  bool get loadVideo => _loadVideo;
  set loadVideo(bool state) {
    _loadVideo = state;
    notifyListeners();
  }

  ///ADS IN BETWEEN === Hariyanto Lukman ===
  Future getAdsVideo(BuildContext context, int videoDuration) async {
    print('Hit Api Ads In Content');
    try {
      /// with Dummy
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
      //   "adsPlace": "First",
      //   "adsType": "Content Ads",
      //   "adsSkip": 7,
      //   "mediaType": "Video",
      //   "ctaButton": "AMBILL BURUAN!!",
      //   "videoId": "f69f4b404afd71eead563044f1fd0102"
      // };
      // await Future.delayed(const Duration(seconds: 1));
      // tempAdsData = AdsData.fromJson(map);
      // secondsSkip = tempAdsData?.adsSkip ?? 0;
      // final place = tempAdsData?.adsPlace;
      // if(place != null){
      //   double duration = videoDuration/ 1000;
      //   adsTime = place.getAdsTime(duration);
      // }else{
      //   adsTime = 2;
      // }

      ///with api
      final notifier = AdsDataBloc();
      await notifier.adsVideoBlocV2(context, AdsType.content);
      final fetch = notifier.adsDataFetch;

      if (fetch.adsDataState == AdsDataState.getAdsVideoBlocSuccess) {
        // print('data : ${fetch.data.toString()}');
        final data = fetch.data;
        tempAdsData = data.data;
        secondsSkip = tempAdsData?.adsSkip ?? 0;
        final place = tempAdsData?.adsPlace;
        isShowingAds = true;
        if (place != null) {
          double duration = videoDuration / 1000;
          adsTime = place.getAdsTime(duration);
        } else {
          adsTime = 2;
        }
        'videoId : ${tempAdsData?.videoId}'.logger();
      }
    } catch (e) {
      'Failed to fetch ads data $e'.logger();
    }
  }

  bool _isPlay = false;
  bool get isPlay => _isPlay;
  set isPlay(bool state) {
    _isPlay = state;
    notifyListeners();
  }
}
