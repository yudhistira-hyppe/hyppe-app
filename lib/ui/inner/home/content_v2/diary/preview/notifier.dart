import 'package:flutter/material.dart';
import 'package:hyppe/app.dart';
import 'package:hyppe/core/bloc/ads_video/bloc.dart';
import 'package:hyppe/core/bloc/ads_video/state.dart';

import 'package:hyppe/core/constants/enum.dart';

import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/models/collection/advertising/ads_video_data.dart';

import 'package:hyppe/core/query_request/contents_data_query.dart';

import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';

import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/playlist/notifier.dart';

import 'package:hyppe/ux/path.dart';

import 'package:hyppe/ux/routing.dart';

import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';

import 'package:hyppe/core/arguments/contents/diary_detail_screen_argument.dart';

import 'package:provider/provider.dart';

class PreviewDiaryNotifier with ChangeNotifier {
  final _system = System();
  final _routing = Routing();
  ScrollController scrollController = ScrollController();

  ContentsDataQuery contentsQuery = ContentsDataQuery()
    ..limit = 5
    ..featureType = FeatureType.diary;

  List<ContentData>? _diaryData;

  List<ContentData>? get diaryData => _diaryData;

  int currIndex = 0;
  int get currentIndex => currIndex;

  set diaryData(List<ContentData>? val) {
    _diaryData = val;
    notifyListeners();
  }

  setIsViewed(int index) {
    diaryData?[index].isViewed = true;
    notifyListeners();
  }

  List<ContentData>? _diaryDataTemp;
  List<ContentData>? get diaryDataTemp => _diaryDataTemp;
  set diaryDataTemp(List<ContentData>? val) {
    _diaryDataTemp = val;
    notifyListeners();
  }

  void onUpdate() => notifyListeners();

  int get itemCount => _diaryData == null ? 3 : (_diaryData?.length ?? 0);

  bool get hasNext => contentsQuery.hasNext;

  double _heightVid = 0.0;
  double _heightTitleFeature = 0.0;

  double get heightVid => _heightVid;
  double get heightTitleFeature => _heightTitleFeature;

  AdsVideo? _adsData;
  AdsVideo? get adsData => _adsData;

  bool _connectionError = false;
  bool get connectionError => _connectionError;
  set connectionError(bool state) {
    _connectionError = state;
    notifyListeners();
  }

  set adsData(val) {
    _adsData = val;
  }

  set heightVid(double val) {
    _heightVid = val;
    notifyListeners();
  }

  set heightTitleFeature(double val) {
    _heightTitleFeature = val;
    notifyListeners();
  }

  int _nextAdsShowed = 6;
  int get nextAdsShowed => _nextAdsShowed;
  set nextAdsShowed(int state) {
    _nextAdsShowed = state;
    notifyListeners();
  }

  initAdsCounter() {
    _nextAdsShowed = 6;
  }

  bool loadAds = false;
  // bool get loadAds => _loadAds;
  // set loadAds(bool state){
  //   _loadAds = state;
  //   notifyListeners();
  // }

  void setAdsData(int index, AdsData? adsData) {
    final withAds = diaryData?.where((element) => element.inBetweenAds != null).length ?? 0;
    final adsSize = diaryData?.length ?? 0;
    loadAds = false;
    if (adsData != null) {
      if (adsSize > nextAdsShowed) {
        if (diaryData?[nextAdsShowed].inBetweenAds == null) {
          diaryData?.insert(nextAdsShowed, ContentData(inBetweenAds: adsData));
          _nextAdsShowed = _nextAdsShowed + 6 + withAds;
          notifyListeners();
        }
      }
    } else {
      diaryData?.removeAt(index);
      notifyListeners();
    }
  }

  double scaleDiary(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const appBar = 50;
    const story = 72;
    final vid = (211 + _heightTitleFeature);
    // final _pic = 115;
    const bottomBar = 56;
    const spacer = 48;
    final sum = (appBar + bottomBar + story + vid + spacer);
    double result = size.height - sum;

    return result;
  }

  Future<void> initialDiary(BuildContext context, {bool reload = false, List<ContentData>? list}) async {
    List<ContentData> res = [];

    try {
      if (list != null) {
        if (reload) {
          contentsQuery.page = 1;
          contentsQuery.hasNext = true;
        }
        res.addAll(list);
        contentsQuery.hasNext = list.length == contentsQuery.limit;
        if (list.isNotEmpty) contentsQuery.page++;
      } else {
        if (reload) {
          'reload contentsQuery : 4'.logger();
          res = await contentsQuery.reload(context);
        } else {
          res = await contentsQuery.loadNext(context, isLandingPage: true);
        }
      }

      if (reload) {
        diaryData = res;
        // if ((diaryData?.length ?? 0) >= 2) {
        //   diaryDataTemp = [];
        //   for (var i = 0; i < 2; i++) {
        //     diaryDataTemp?.add(diaryData![i]);
        //   }
        // }

        if (scrollController.hasClients) {
          homeClick = true;

          scrollController.animateTo(
            scrollController.initialScrollOffset,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeIn,
          );
        }
      } else {
        diaryData = [...(diaryData ?? [] as List<ContentData>)] + res;
      }
      // final _searchData = context.read<SearchNotifier>();
      // if (_searchData.initDataDiary == null) {
      //   // _searchData.diaryContentsQuery.featureType = FeatureType.diary;
      //   print('initDataDiary is null');
      //   if(visibility == 'PUBLIC'){
      //     try{
      //       _searchData.initDataDiary = diaryData?.sublist(0, 18);
      //       print('initDataDiary is ${_searchData.initDataDiary?.length}');
      //     }catch(e){
      //       _searchData.initDataDiary = diaryData;
      //       print('initDataDiary is ${_searchData.initDataDiary?.length}');
      //     }
      //
      //   }else{
      //     if(_searchData.initDataDiary?.isEmpty ?? true){
      //       if (visibility == 'PUBLIC') {
      //         try {
      //           _searchData.initDataDiary = diaryData?.sublist(0, 18);
      //           print('initDataVid is ${_searchData.initDataDiary?.length}');
      //         } catch (e) {
      //           _searchData.initDataDiary = diaryData;
      //           print('initDataVid is ${_searchData.initDataDiary?.length}');
      //         }
      //       }
      //     }
      //   }
      // }
    } catch (e) {
      'load diary list: ERROR: $e'.logger();
    }
  }

  void scrollListener(BuildContext context) {
    if (scrollController.offset >= scrollController.position.maxScrollExtent && !scrollController.position.outOfRange && !contentsQuery.loading && hasNext) {
      initialDiary(context);
    }
  }

  Future navigateToShortVideoPlayer(BuildContext context, int index, {List<ContentData>? data, Function(int e)? function, bool? isMute, int? seekPosition}) async {
    final connect = await _system.checkConnections();
    if (connect) {
      var res = await _routing.move(
        Routes.diaryFull,
        argument: DiaryDetailScreenArgument(
          diaryData: diaryData,
          index: index.toDouble(),
          page: contentsQuery.page,
          limit: contentsQuery.limit,
          type: TypePlaylist.landingpage,
          function: function,
          ismute: isMute,
          seekPosition: seekPosition,
        ),
      );
      return res;
    } else {
      ShowBottomSheet.onNoInternetConnection(Routing.navigatorKey.currentContext ?? context);
    }
  }

  void navigateToSeeAll(BuildContext context) async {
    final connect = await _system.checkConnections();
    if (connect) {
      _routing.move(Routes.diarySeeAllScreen);
    } else {
      ShowBottomSheet.onNoInternetConnection(Routing.navigatorKey.currentContext ?? context);
    }
  }

  Future getAdsVideo(BuildContext context, bool isContent) async {
    try {
      final notifier = AdsDataBloc();
      await notifier.adsVideoBloc(context, isContent);
      final fetch = notifier.adsDataFetch;

      if (fetch.adsDataState == AdsDataState.getAdsVideoBlocSuccess) {
        // print('data : ${fetch.data.toString()}');
        adsData = fetch.data;
        context.read<VidDetailNotifier>().getAuth(Routing.navigatorKey.currentContext ?? context, videoId: adsData?.data?.videoId ?? '').then((value) => adsData?.data?.apsaraAuth = value);

        // await getAdsVideoApsara(_newClipData?.data?.videoId ?? '');
      }
    } catch (e) {
      'Failed to fetch ads data $e'.logger();
    }
  }

  void getTemp(index, lastIndex, indexArray) {
    if (index != 0) {
      if (lastIndex < index && (diaryData?.length ?? 0) > (diaryDataTemp?.length ?? 0)) {
        diaryDataTemp?.add(diaryData![indexArray + 1]);
        var total = diaryDataTemp?.length;
        if (total == 4) {
          // picTemp?.removeAt(0);
        }
      } else {
        // picTemp?.insert(0, pic![indexArray - 1]);
        // var total = picTemp?.length;
        // if (total == 4) {
        //   picTemp?.removeLast();
        // }
      }
    }
    notifyListeners();
  }
}
