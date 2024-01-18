import 'package:flutter/material.dart';
import 'package:flutter_aliplayer/flutter_aliplayer.dart';
import 'package:hyppe/core/arguments/follow_user_argument.dart';
import 'package:hyppe/core/bloc/follow/bloc.dart';
import 'package:hyppe/core/bloc/follow/state.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/utils.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/models/collection/advertising/ads_video_data.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/query_request/contents_data_query.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/core/arguments/contents/pic_detail_screen_argument.dart';
import 'package:hyppe/ui/constant/entities/general_mixin/general_mixin.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/show_general_dialog.dart';
import 'package:hyppe/ui/inner/main/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';
import '../../../../../app.dart';
import '../../../../../core/arguments/contents/slided_pic_detail_screen_argument.dart';
import '../../notifier_v2.dart';

class PreviewPicNotifier with ChangeNotifier, GeneralMixin {
  final _system = System();
  final _routing = Routing();
  ScrollController scrollController = ScrollController();
  bool isConnect = true;
  bool isLoading = false;
  bool isMute = true;

  LocalizationModelV2 language = LocalizationModelV2();
  translate(LocalizationModelV2 translate) {
    language = translate;
    notifyListeners();
  }

  ContentsDataQuery contentsQuery = ContentsDataQuery()
    ..limit = 5
    ..featureType = FeatureType.pic;

  List<ContentData>? _pic;
  Offset positionDxDy = const Offset(0, 0);

  List<ContentData>? get pic => _pic;

  set pic(List<ContentData>? val) {
    _pic = val;
    notifyListeners();
  }

  setIsViewed(int index) {
    pic?[index].isViewed = true;
    notifyListeners();
  }

  List<ContentData>? _picTemp = [];
  List<ContentData>? get picTemp => _picTemp;
  set picTemp(List<ContentData>? val) {
    _picTemp = val;
    notifyListeners();
  }

  int get itemCount => _pic == null ? 2 : (pic?.length ?? 0);

  bool get hasNext => contentsQuery.hasNext;

  Future<void> initialPic(BuildContext context, {bool reload = false, List<ContentData>? list}) async {
    List<ContentData> res = [];
    'initialPic page : ${contentsQuery.page}'.logger();
    try {
      // var index = pic?.indexWhere((element) => element.postID == picTemp?.last.postID) ?? 0;
      // print(pic?.length ?? 0);
      // print(index);
      // print(picTemp?.last.postID);
      // print(picTemp?.last.description);

      if (list != null) {
        if (reload) {
          contentsQuery.hasNext = true;
          contentsQuery.page = 1;
        }
        res.addAll(list);
        contentsQuery.hasNext = list.length == contentsQuery.limit;
        if (list.isNotEmpty) contentsQuery.page++;
        'initialPic nextpage : ${contentsQuery.page}'.logger();
      } else {
        if (reload) {
          'reload contentsQuery : satu'.logger();
          res = await contentsQuery.reload(context);
        } else {
          res = await contentsQuery.loadNext(context, isLandingPage: true);
        }
      }

      'ini pict initial 3'.logger();
      if (reload) {
        pic = res;
        // if ((pic?.length ?? 0) >= 2) {
        //   picTemp = [];
        //   for (var i = 0; i < 2; i++) {
        //     picTemp?.add(pic![i]);
        //   }
        // }

        if (scrollController.hasClients) {
          homeClick = true;
          // notifier.scrollController.animateTo(0, duration: const Duration(milliseconds: 1000), curve: Curves.ease);
          (Routing.navigatorKey.currentContext ?? context).read<MainNotifier>().scrollController.animateTo(0, duration: const Duration(milliseconds: 1000), curve: Curves.ease);
          // scrollController.animateTo(
          //   scrollController.initialScrollOffset,
          //   duration: const Duration(milliseconds: 300),
          //   curve: Curves.easeIn,
          // );
        }
      } else {
        pic = [...(pic ?? [] as List<ContentData>)] + res;
        // if ((pic?.length ?? 0) >= 2) {
        //   // picTemp?.removeAt(0);
        //   // var index = picTemp?.indexWhere((element) => element.postID == picTemp?.last.postID);
        //   // print("------== index ${index}");
        //   // // picTemp?.add(pic![picTemp?.length ?? 0 + 1]);

        //   // var total = picTemp?.length ?? 0;
        //   // if ((pic?.length ?? 0) > (total ?? 0)) {
        //   //   picTemp?.add(pic![total + 1]);
        //   // }
        //   notifyListeners();
        // }
      }
      // final _searchData = context.read<SearchNotifier>();
      // print('ini pict initial');
      // if (_searchData.initDataPic != null) {
      //   print('initDataPic is null');
      //   if (visibility == 'PUBLIC') {
      //     try {
      //       _searchData.initDataPic = pic?.sublist(0, 18);
      //       print('initDataPic is ${_searchData.initDataPic?.length}');
      //     } catch (e) {
      //       _searchData.initDataPic = pic;
      //       print('initDataPic is ${_searchData.initDataPic?.length}');
      //     }
      //   }else{
      //     if(_searchData.initDataPic!.isEmpty){
      //       if (visibility == 'PUBLIC') {
      //         try {
      //           _searchData.initDataPic = pic?.sublist(0, 18);
      //           print('initDataVid is ${_searchData.initDataPic?.length}');
      //         } catch (e) {
      //           _searchData.initDataPic = pic;
      //           print('initDataVid is ${_searchData.initDataPic?.length}');
      //         }
      //       }
      //     }
      //   }
      //   // _searchData.picContentsQuery.featureType = FeatureType.pic;
      //   // _searchData.allContents.pics = pic;
      // }
    } catch (e) {
      'load pic list: ERROR: $e'.logger();
    }
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
    final withAds = pic?.where((element) => element.inBetweenAds != null).length ?? 0;
    final adsSize = pic?.length ?? 0;
    loadAds = false;
    if (adsData != null) {
      if (adsSize > nextAdsShowed) {
        if (pic?[nextAdsShowed].inBetweenAds == null) {
          pic?.insert(nextAdsShowed, ContentData(inBetweenAds: adsData));
          _nextAdsShowed = _nextAdsShowed + 6 + withAds;
          notifyListeners();
        }
      }
    } else {
      pic?.removeAt(index);
      notifyListeners();
    }
  }

  void scrollListener(BuildContext context) {
    if (scrollController.offset >= scrollController.position.maxScrollExtent && !scrollController.position.outOfRange && !contentsQuery.loading && hasNext) {
      'initialPic : 2'.logger();
      initialPic(context);
    }
  }

  void getTemp(index, lastIndex, indexArray) {
    if (index != 0) {
      if (lastIndex < index && (pic?.length ?? 0) > (picTemp?.length ?? 0)) {
        picTemp?.add(pic![indexArray + 1]);
        var total = picTemp?.length;
        if (total == 4) {
          // picTemp?.removeAt(0);
        }
        final ids = picTemp?.map((e) => e.postID).toSet();
        picTemp?.retainWhere((x) => ids!.remove(x.postID));
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

  void navigateToHyppePicDetail(BuildContext context, ContentData? data) async {
    final connect = await _system.checkConnections();
    if (connect) {
      _routing.move(Routes.picDetail, argument: PicDetailScreenArgument(picData: data));
    } else {
      ShowBottomSheet.onNoInternetConnection(context);
    }
  }

  void navigateToSlidedDetailPic(BuildContext context, int index) async {
    final connect = await _system.checkConnections();
    if (connect) {
      Routing().move(Routes.picSlideDetailPreview,
          argument: SlidedPicDetailScreenArgument(picData: pic, index: index.toDouble(), page: contentsQuery.page, limit: contentsQuery.limit, type: TypePlaylist.landingpage));
    } else {
      ShowBottomSheet.onNoInternetConnection(context);
    }
    // Routing().move(Routes.picSlideDetailPreview, argument: SlidedPicDetailScreenArgument(picData: _listData, index: index));
  }

  void navigateToSeeAll(BuildContext context) async {
    final connect = await _system.checkConnections();
    if (connect) {
      _routing.move(Routes.picSeeAllScreen);
    } else {
      ShowBottomSheet.onNoInternetConnection(context);
    }
  }

  Future<void> followUser(BuildContext context, ContentData dataContent, {bool checkIdCard = true, isUnFollow = false, String receiverParty = '', bool isloading = false}) async {
    try {
      dataContent.insight?.isloadingFollow = true;
      print(isloading);
      notifyListeners();
      final notifier = FollowBloc();
      await notifier.followUserBlocV2(
        context,
        data: FollowUserArgument(
          receiverParty: dataContent.email ?? '',
          eventType: isUnFollow ? InteractiveEventType.unfollow : InteractiveEventType.following,
        ),
      );
      final fetch = notifier.followFetch;
      if (fetch.followState == FollowState.followUserSuccess) {
        print('asdasdasd');
        if (isUnFollow) {
          print('1');
          dataContent.following = false;
          dataContent.insight?.isloadingFollow = false;
          notifyListeners();
        } else {
          print('3');
          dataContent.following = true;
          dataContent.insight?.isloadingFollow = false;
          notifyListeners();
        }
      }
      context.read<HomeNotifier>().updateFollowing(context, email: dataContent.email ?? '', statusFollowing: !isUnFollow);

      //   },
      //   uploadContentAction: false,
      // );

      notifyListeners();
    } catch (e) {
      isloading = false;
      'follow user: ERROR: $e'.logger();
    }
  }

  void reportContent(BuildContext context, ContentData data, {FlutterAliplayer? fAliplayer, String? key, required Function() onCompleted}) {
    if (fAliplayer != null) {
      fAliplayer.pause();
    }
    ShowBottomSheet().onReportContent(context, postData: data, type: hyppePic, inDetail: false, fAliplayer: fAliplayer, onCompleted: onCompleted, key: key);
  }

  void initialPicConnection(BuildContext context) async {
    final connect = await _system.checkConnections();
      if (!connect) {
        isConnect = false;
        notifyListeners();
        // ignore: use_build_context_synchronously
        ShowGeneralDialog.showToastAlert(
          context,
          language.internetConnectionLost ?? ' Error',
          () async {},
        );
      } else {
        isConnect = true;
        notifyListeners();
      }
  }
}
