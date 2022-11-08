import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/enum.dart';
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

  ContentsDataQuery contentsQuery = ContentsDataQuery()..featureType = FeatureType.pic;

  List<ContentData>? _pic;

  List<ContentData>? get pic => _pic;

  set pic(List<ContentData>? val) {
    _pic = val;
    notifyListeners();
  }

  int get itemCount => _pic == null ? 2 : (pic?.length ?? 0);

  bool get hasNext => contentsQuery.hasNext;

  Future<void> initialPic(BuildContext context, {bool reload = false, List<ContentData>? list = null, String? visibility = null}) async {
    List<ContentData> res = [];

    try {
      if (list != null) {
        res.addAll(list);
      } else {
        if (reload) {
          print('reload contentsQuery : satu');
          res = await contentsQuery.reload(context);
        } else {
          res = await contentsQuery.loadNext(context);
        }
      }

      print('ini pict initial 3');
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
      final _searchData = context.read<SearchNotifier>();
      print('ini pict initial');
      if (_searchData.initDataPic == null) {
        print('initDataPic is null');
        if (visibility == 'PUBLIC') {
          try {
            _searchData.initDataPic = pic?.sublist(0, 18);
            print('initDataPic is ${_searchData.initDataPic?.length}');
          } catch (e) {
            _searchData.initDataPic = pic;
            print('initDataPic is ${_searchData.initDataPic?.length}');
          }
        }else{
          if(_searchData.initDataPic!.isEmpty){
            if (visibility == 'PUBLIC') {
              try {
                _searchData.initDataPic = pic?.sublist(0, 18);
                print('initDataVid is ${_searchData.initDataPic?.length}');
              } catch (e) {
                _searchData.initDataPic = pic;
                print('initDataVid is ${_searchData.initDataPic?.length}');
              }
            }
          }
        }
        // _searchData.picContentsQuery.featureType = FeatureType.pic;
        // _searchData.allContents!.pics = pic;
      }
    } catch (e) {
      'load pic list: ERROR: $e'.logger();
    }
  }

  void scrollListener(BuildContext context) {
    if (scrollController.offset >= scrollController.position.maxScrollExtent && !scrollController.position.outOfRange && !contentsQuery.loading && hasNext) {
      print('initialPic : 2');
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
      print(pic);
      Routing().move(Routes.picSlideDetailPreview, argument: SlidedPicDetailScreenArgument(picData: pic, index: index.toDouble()));
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

  // Future<bool> addPostViewMixin(BuildContext context, ContentData data) async {
  //   String? _userID = SharedPreference().readStorage(SpKeys.userID);
  //   final _result = await addPostView(context, data: AddPostView(userID: data.userID, postID: data.postID, vUserID: _userID));

  //   return _result;
  // }
}
