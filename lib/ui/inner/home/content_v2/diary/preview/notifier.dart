import 'package:flutter/material.dart';
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

  set diaryData(List<ContentData>? val) {
    _diaryData = val;
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

  double scaleDiary(BuildContext context) {
    final _size = MediaQuery.of(context).size;
    const _appBar = 50;
    const _story = 72;
    final _vid = (211 + _heightTitleFeature);
    // final _pic = 115;
    const _bottomBar = 56;
    const _spacer = 48;
    final _sum = (_appBar + _bottomBar + _story + _vid + _spacer);
    double _result = _size.height - _sum;

    return _result;
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
        if ((diaryData?.length ?? 0) >= 2) {
          diaryDataTemp = [];
          for (var i = 0; i < 2; i++) {
            diaryDataTemp?.add(diaryData![i]);
          }
        }

        if (scrollController.hasClients) {
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

  void navigateToShortVideoPlayer(BuildContext context, int index, {List<ContentData>? data}) async {
    final connect = await _system.checkConnections();
    if (connect) {
      _routing.move(
        Routes.diaryDetail,
        argument: DiaryDetailScreenArgument(
          diaryData: diaryData,
          index: index.toDouble(),
          page: contentsQuery.page,
          limit: contentsQuery.limit,
          type: TypePlaylist.landingpage,
        ),
      );
    } else {
      ShowBottomSheet.onNoInternetConnection(context);
    }
  }

  void navigateToSeeAll(BuildContext context) async {
    final connect = await _system.checkConnections();
    if (connect) {
      _routing.move(Routes.diarySeeAllScreen);
    } else {
      ShowBottomSheet.onNoInternetConnection(context);
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
        context.read<VidDetailNotifier>().getAuth(context, videoId: adsData?.data?.videoId ?? '').then((value) => adsData?.data?.apsaraAuth = value);

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
