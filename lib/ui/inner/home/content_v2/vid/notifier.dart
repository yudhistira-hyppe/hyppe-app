import 'package:flutter/material.dart';
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
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

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

  List<ContentData>? _vidData;

  List<ContentData>? get vidData => _vidData;

  int _selectedRadioTile = 0;

  int get selectedRadioTile => _selectedRadioTile;

  set selectedRadioTile(int val) {
    _selectedRadioTile = val;
    notifyListeners();
  }

  set vidData(List<ContentData>? val) {
    _vidData = val;
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

  Future<void> initialVid(BuildContext context, {bool reload = false, List<ContentData>? list}) async {
    List<ContentData> res = [];

    try {
      if (list != null) {
        if (reload) {
          contentsQuery.page = 1;
          contentsQuery.hasNext = true;
        }
        res.addAll(list);
        contentsQuery.hasNext = list.length == contentsQuery.limit;
        if (list != null) contentsQuery.page++;
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

        if (pageController.hasClients) {
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

  void reportContent(BuildContext context, ContentData data) {
    context.read<ReportNotifier>().contentData = data;
    ShowBottomSheet.onReportContent(context, postData: data, type: hyppeVid, inDetail: false);
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

  void navigateToHyppeVidDetail(BuildContext context, ContentData? data) async {
    final connect = await _system.checkConnections();
    if (connect) {
      _routing.move(Routes.vidDetail, argument: VidDetailScreenArgument(vidData: data));
    } else {
      ShowBottomSheet.onNoInternetConnection(context);
    }
  }
}
