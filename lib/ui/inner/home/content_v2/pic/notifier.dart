import 'package:flutter/material.dart';
import 'package:hyppe/core/arguments/follow_user_argument.dart';
import 'package:hyppe/core/bloc/follow/bloc.dart';
import 'package:hyppe/core/bloc/follow/state.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/utils.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/query_request/contents_data_query.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/core/arguments/contents/pic_detail_screen_argument.dart';
import 'package:hyppe/ui/constant/entities/general_mixin/general_mixin.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/inner/search_v2/notifier.dart';
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

  LocalizationModelV2 language = LocalizationModelV2();
  translate(LocalizationModelV2 translate) {
    language = translate;
    notifyListeners();
  }

  ContentsDataQuery contentsQuery = ContentsDataQuery()
    ..limit = 5
    ..featureType = FeatureType.pic;

  List<ContentData>? _pic;

  List<ContentData>? get pic => _pic;

  set pic(List<ContentData>? val) {
    _pic = val;
    notifyListeners();
  }

  int get itemCount => _pic == null ? 2 : (pic?.length ?? 0);

  bool get hasNext => contentsQuery.hasNext;

  Future<void> initialPic(BuildContext context, {bool reload = false, List<ContentData>? list}) async {
    List<ContentData> res = [];
    'initialPic page : ${contentsQuery.page}'.logger();
    try {
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

        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.initialScrollOffset,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeIn,
          );
        }
      } else {
        pic = [...(pic ?? [] as List<ContentData>)] + res;
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

  void scrollListener(BuildContext context) {
    if (scrollController.offset >= scrollController.position.maxScrollExtent && !scrollController.position.outOfRange && !contentsQuery.loading && hasNext) {
      'initialPic : 2'.logger();
      initialPic(context);
    }
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

      print("=============data ${dataContent.following}");
      //   },
      //   uploadContentAction: false,
      // );

      notifyListeners();
    } catch (e) {
      isloading = false;
      'follow user: ERROR: $e'.logger();
    }
  }

  void reportContent(BuildContext context, ContentData data) {
    ShowBottomSheet.onReportContent(context, postData: data, type: hyppePic, inDetail: false);
  }
}
