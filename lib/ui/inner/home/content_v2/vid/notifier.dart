import 'package:flutter/material.dart';
import 'package:flutter_aliplayer/flutter_alilistplayer.dart';
import 'package:hyppe/app.dart';
import 'package:hyppe/core/arguments/contents/vid_detail_screen_argument.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/bloc/posts_v2/state.dart';
import 'package:hyppe/core/constants/utils.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/query_request/contents_data_query.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/entities/general_mixin/general_mixin.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/ui/constant/entities/report/notifier.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/playlist/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/widget/fullscreen/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

import '../../../../../core/bloc/ads_video/bloc.dart';
import '../../../../../core/bloc/ads_video/state.dart';
import '../../../../../core/models/collection/advertising/ads_video_data.dart';

class PreviewVidNotifier with ChangeNotifier, GeneralMixin {
  LocalizationModelV2 language = LocalizationModelV2();
  translate(LocalizationModelV2 translate) {
    language = translate;
    notifyListeners();
  }

  final _system = System();
  final _routing = Routing();

  ContentsDataQuery contentsQuery = ContentsDataQuery()
    ..limit = 5
    ..featureType = FeatureType.vid;
  PageController pageController = PageController();
  int _selectedRadioTile = 0;

  int get selectedRadioTile => _selectedRadioTile;

  set selectedRadioTile(int val) {
    _selectedRadioTile = val;
    notifyListeners();
  }

  List<ContentData>? _vidData;
  List<ContentData>? get vidData => _vidData;

  int currIndex = 0;
  int get currentIndex => currIndex;

  set vidData(List<ContentData>? val) {
    _vidData = val;
    notifyListeners();
  }

  setIsViewed(int index) {
    vidData?[index].isViewed = true;
    notifyListeners();
  }

  List<ContentData>? _vidDataTemp;
  List<ContentData>? get vidDataTemp => _vidDataTemp;
  set vidDataTemp(List<ContentData>? val) {
    _vidDataTemp = val;
    notifyListeners();
  }

  int get itemCount => _vidData?.length ?? 0;

  bool get hasNext => contentsQuery.hasNext;

  bool _forcePause = false;
  Duration? _currentPosition;
  ContentData? _selectedVidData;
  PostsState? _vidPostState;

  bool get forcePause => _forcePause;
  Duration? get currentPosition => _currentPosition;
  ContentData? get selectedVidData => _selectedVidData;
  PostsState? get vidPostState => _vidPostState;

  set forcePause(bool val) {
    _forcePause = val;
    notifyListeners();
  }

  set selectedVidData(ContentData? val) {
    _selectedVidData = val;
    notifyListeners();
  }

  set currentPosition(Duration? val) {
    _currentPosition = val;
    notifyListeners();
  }

  set vidPostState(PostsState? val) {
    _vidPostState = val;
    notifyListeners();
  }

  bool _isLoved = false;
  bool get isLoved => _isLoved;
  set isLoved(bool state) {
    _isLoved = state;
    notifyListeners();
  }

  int _pageIndex = -1;
  int get pageIndex => _pageIndex;

  set pageIndex(int index) {
    _pageIndex = index;
    notifyListeners();
  }

  double? _currentPage = 0;
  double? get currentPage => _currentPage;
  set currentPage(double? val) {
    _currentPage = val;
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

  void setInBetweenAds(int index, AdsData? adsData) {
    final withAds = vidData?.where((element) => element.inBetweenAds != null).length ?? 0;
    final adsSize = vidData?.length ?? 0;
    loadAds = false;
    if (adsData != null) {
      if (adsSize > nextAdsShowed) {
        if (vidData?[nextAdsShowed].inBetweenAds == null) {
          vidData?.insert(nextAdsShowed, ContentData(inBetweenAds: adsData));
          _nextAdsShowed = _nextAdsShowed + 6 + withAds;
          notifyListeners();
        }
      }
    } else {
      vidData?.removeAt(index);
      notifyListeners();
    }
  }
  // setInBetweenAds(int index, AdsData? adsData){
  //   vidData?[index].inBetweenAds = adsData;
  //   notifyListeners();
  // }

  setAdsData(int index, AdsData? adsData, BuildContext context) {
    vidData?[index].adsData = adsData;
    if (adsData == null) {
      context.read<VideoNotifier>().isPlay = false;
    }
    notifyListeners();
  }

  Future<void> initialVid(BuildContext context, {bool reload = false, List<ContentData>? list}) async {
    List<ContentData> res = [];

    try {
      if (list != null) {
        print('masuk list tidak kosong');
        if (reload) {
          print('masuk list tidak kosong 2');
          contentsQuery.page = 1;
          contentsQuery.hasNext = true;
        }
        print('masuk list tidak kosong 3');
        print('$list');
        res.addAll(list);
        contentsQuery.hasNext = list.length == contentsQuery.limit;
        contentsQuery.page++;
      } else {
        if (reload) {
          'reload contentsQuery : 15'.logger();
          res = await contentsQuery.reload(context);
        } else {
          print('load next video');
          res = await contentsQuery.loadNext(context);
        }
      }

      if (reload) {
        vidData = res;

        // if ((vidData?.length ?? 0) >= 2) {
        //   vidDataTemp = [];
        //   for (var i = 0; i < 2; i++) {
        //     vidDataTemp?.add(vidData![i]);
        //   }
        // }

        if (pageController.hasClients) {
          homeClick = true;
          pageController.animateToPage(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeIn,
          );
        }
        // final _searchData = context.read<SearchNotifier>();
        // if(_searchData.initDataVid == null){
        //   _searchData.initDataVid = [];
        //   if (visibility == 'PUBLIC') {
        //     try {
        //       _searchData.initDataVid = vidData?.sublist(0, 18);
        //       print('initDataVid is ${_searchData.initDataVid?.length}');
        //     } catch (e) {
        //       _searchData.initDataVid = vidData;
        //       print('initDataVid is ${_searchData.initDataVid?.length}');
        //     }
        //   }
        // }else{
        //   if(_searchData.initDataVid?.isEmpty ?? true){
        //     if (visibility == 'PUBLIC') {
        //       try {
        //         _searchData.initDataVid = vidData?.sublist(0, 18);
        //         print('initDataVid is ${_searchData.initDataVid?.length}');
        //       } catch (e) {
        //         _searchData.initDataVid = vidData;
        //         print('initDataVid is ${_searchData.initDataVid?.length}');
        //       }
        //     }
        //   }
        // }
      } else {
        'initial video'.logger();
        vidData = [...(vidData ?? [] as List<ContentData>)] + res;
      }
      // final _searchData = context.read<SearchNotifier>();
      // _searchData.allContents = UserInfoModel();
      // print('ini video data');
      // print(_searchData);
      // print(_searchData.allContents);
      // // print(_searchData.allContents.vids);
      // if (_searchData.initDataVid == null) {
      //   // _searchData.vidContentsQuery.featureType = FeatureType.vid;
      //   print('initDataVid is null');
      //   if (visibility == 'PUBLIC') {
      //     try {
      //       _searchData.initDataVid = vidData?.sublist(0, 18);
      //       print('initDataVid is ${_searchData.initDataVid?.length}');
      //     } catch (e) {
      //       _searchData.initDataVid = vidData;
      //       print('initDataVid is ${_searchData.initDataVid?.length}');
      //     }
      //   }
      // }
      // print('ini video data22');
      // print(_searchData.allContents?.vids);
    } catch (e) {
      'load vid list: ERROR: $e'.logger();
    }
  }

  void scrollListener(BuildContext context) {
    if (pageController.offset >= pageController.position.maxScrollExtent && !pageController.position.outOfRange && !contentsQuery.loading && hasNext) {
      initialVid(context);
    }
  }

  void navigateToSeeAll(BuildContext context) async {
    final connect = await System().checkConnections();
    if (connect) {
      forcePause = true;
      await Routing().move(Routes.vidSeeAllScreen).whenComplete(() {
        forcePause = false;
      });
    } else {
      ShowBottomSheet.onNoInternetConnection(context);
    }
  }

  void setAliPlayer(int index, FlutterAliplayer player) {
    vidData?[index].fAliplayer = player;
    notifyListeners();
  }

  void reportContent(BuildContext context, ContentData data) {
    context.read<ReportNotifier>().contentData = data;
    ShowBottomSheet().onReportContent(context, postData: data, type: hyppeVid, inDetail: false);
  }

  void showUserTag(BuildContext context, index, postId) {
    ShowBottomSheet.onShowUserTag(context, value: _vidData?[index].tagPeople ?? [], function: () {}, postId: postId);
  }

  void onDeleteSelfTagUserContent(BuildContext context, {required String postID, required String content, required String email}) {
    // ContentData? _updatedData;

    final index = vidData?.indexWhere((element) => element.postID == postID);
    if (index != null) {
      vidData?[index].tagPeople?.removeWhere((element) => element.email == email);
    }

    notifyListeners();
  }

  void navigateToHyppeVidDetail(BuildContext context, ContentData? data, {bool fromLAnding = false}) async {
    final connect = await _system.checkConnections();
    if (connect) {
      _routing.move(Routes.vidDetail,
          argument: VidDetailScreenArgument(
            vidData: data,
            fromLAnding: fromLAnding,
          )
            ..postID = data?.postID
            ..backPage = true);
    } else {
      ShowBottomSheet.onNoInternetConnection(context);
    }
  }

  bool _canPlayOpenApps = true;
  bool get canPlayOpenApps => _canPlayOpenApps;

  set canPlayOpenApps(val) {
    _canPlayOpenApps = val;
  }

  AdsVideo? _adsData;
  AdsVideo? get adsData => _adsData;

  set adsData(val) {
    _adsData = val;
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
    print("----------000000---------");
    print(lastIndex < index);
    print((vidData?.length ?? 0) > (vidDataTemp?.length ?? 0));
    if (index != 0) {
      if (lastIndex < index && (vidData?.length ?? 0) > (vidDataTemp?.length ?? 0)) {
        vidDataTemp?.add(vidData![indexArray + 1]);
        var total = vidDataTemp?.length;
        if (total == 4) {
          // picTemp?.removeAt(0);
        }
        final ids = vidDataTemp?.map((e) => e.postID).toSet();
        vidDataTemp?.retainWhere((x) => ids!.remove(x.postID));
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
