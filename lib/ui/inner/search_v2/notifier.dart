import 'package:hyppe/core/arguments/contents/diary_detail_screen_argument.dart';
import 'package:hyppe/core/arguments/contents/pic_detail_screen_argument.dart';
import 'package:hyppe/core/arguments/contents/vid_detail_screen_argument.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/models/combination_v2/get_user_profile.dart';
import 'package:hyppe/core/query_request/contents_data_query.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';

class SearchNotifier with ChangeNotifier {
  LocalizationModelV2 language = LocalizationModelV2();
  translate(LocalizationModelV2 translate) {
    language = translate;
    notifyListeners();
  }

  ContentsDataQuery vidContentsQuery = ContentsDataQuery();
  ContentsDataQuery diaryContentsQuery = ContentsDataQuery();
  ContentsDataQuery picContentsQuery = ContentsDataQuery();
  UserInfoModel? _allContents;
  List<ContentData>? _listContentData;

  final _focusNode = FocusNode();
  final _routing = Routing();
  final searchController = TextEditingController();
  int _pageIndex = 0;

  UserInfoModel? get allContents => _allContents;
  List<ContentData>? get listContentData => _listContentData;
  int get pageIndex => _pageIndex;
  FocusNode get focusNode => _focusNode;

  int get vidCount => allContents?.vids?.length ?? 0;
  bool get vidHasNext => vidContentsQuery.hasNext;

  int get diaryCount => allContents?.diaries?.length ?? 0;
  bool get diaryHasNext => diaryContentsQuery.hasNext;

  int get picCount => allContents?.pics?.length ?? 0;
  bool get picHasNext => picContentsQuery.hasNext;

  set allContents(UserInfoModel? val) {
    _allContents = val;
    notifyListeners();
  }

  set pageIndex(int val) {
    _pageIndex = val;
    notifyListeners();
  }

  onInitialSearch(BuildContext context) async {
    if (allContents?.vids == null && allContents?.diaries == null && allContents?.pics == null) {
      vidContentsQuery.featureType = FeatureType.vid;
      diaryContentsQuery.featureType = FeatureType.diary;
      picContentsQuery.featureType = FeatureType.pic;

      vidContentsQuery.limit = 18;
      diaryContentsQuery.limit = 18;
      picContentsQuery.limit = 18;

      allContents = UserInfoModel();
      allContents?.vids = await vidContentsQuery.reload(context);
      allContents?.diaries = await diaryContentsQuery.reload(context);
      allContents?.pics = await picContentsQuery.reload(context);
      notifyListeners();
    }
  }

  onScrollListener(BuildContext context, ScrollController scrollController) async {
    if (scrollController.offset >= scrollController.position.maxScrollExtent && !scrollController.position.outOfRange) {
      switch (pageIndex) {
        case 0:
          {
            if (!vidContentsQuery.loading && vidHasNext) {
              vidContentsQuery.limit = 6;
              List<ContentData> _res = await vidContentsQuery.loadNext(context);
              if (_res.isNotEmpty) {
                allContents!.vids = [...allContents!.vids!, ..._res];
              } else {
                print("Post Vid Dah Mentok");
              }
              notifyListeners();
            }
          }
          break;
        case 1:
          {
            if (!diaryContentsQuery.loading && diaryHasNext) {
              diaryContentsQuery.limit = 6;
              List<ContentData> _res = await diaryContentsQuery.loadNext(context);
              if (_res.isNotEmpty) {
                allContents!.diaries = [...allContents!.diaries!, ..._res];
              } else {
                print("Post Diary Dah Mentok");
              }
              notifyListeners();
            }
          }
          break;
        case 2:
          {
            if (!picContentsQuery.loading && picHasNext) {
              picContentsQuery.limit = 6;
              List<ContentData> _res = await picContentsQuery.loadNext(context);
              if (_res.isNotEmpty) {
                allContents!.pics = [...allContents!.pics!, ..._res];
              } else {
                print("Post Pic Dah Mentok");
              }
              notifyListeners();
            }
          }
          break;
      }
    }
  }

  void onSearchPost(BuildContext context, {String? value}) async {
    String search = value ?? searchController.text;
    vidContentsQuery.searchText = search;
    diaryContentsQuery.searchText = search;
    picContentsQuery.searchText = search;
    focusNode.unfocus();

    allContents!.vids = await vidContentsQuery.reload(context);
    allContents!.diaries = await diaryContentsQuery.reload(context);
    allContents!.pics = await picContentsQuery.reload(context);
    notifyListeners();
  }

  Future navigateToSeeAllScreen(BuildContext context, List<ContentData> data, int index) async {
    bool connect = await System().checkConnections();
    if (connect) {
      if (pageIndex == 0) _routing.move(Routes.vidDetail, argument: VidDetailScreenArgument(vidData: data[index]));
      if (pageIndex == 1) _routing.move(Routes.diaryDetail, argument: DiaryDetailScreenArgument(diaryData: data, index: index.toDouble()));
      if (pageIndex == 2) _routing.move(Routes.picDetail, argument: PicDetailScreenArgument(picData: data[index]));
    } else {
      ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
        _routing.moveBack();
        navigateToSeeAllScreen(context, data, index);
      });
    }
  }
}
