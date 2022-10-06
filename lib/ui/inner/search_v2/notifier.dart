import 'package:hyppe/core/arguments/contents/diary_detail_screen_argument.dart';
import 'package:hyppe/core/arguments/contents/pic_detail_screen_argument.dart';
import 'package:hyppe/core/arguments/contents/vid_detail_screen_argument.dart';
import 'package:hyppe/core/arguments/other_profile_argument.dart';
import 'package:hyppe/core/bloc/search_content/bloc.dart';
import 'package:hyppe/core/bloc/search_content/state.dart';
import 'package:hyppe/core/bloc/utils_v2/bloc.dart';
import 'package:hyppe/core/bloc/utils_v2/state.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/models/collection/search/search_content.dart';
import 'package:hyppe/core/models/collection/utils/search_people/search_people.dart';
import 'package:hyppe/core/models/combination_v2/get_user_profile.dart';
import 'package:hyppe/core/query_request/contents_data_query.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/other_profile/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:story_view/controller/story_controller.dart';

import '../../../core/arguments/contents/slided_pic_detail_screen_argument.dart';

class SearchNotifier with ChangeNotifier {
  LocalizationModelV2 language = LocalizationModelV2();
  translate(LocalizationModelV2 translate) {
    language = translate;
    notifyListeners();
  }

  List<SearchPeolpleData>? _searchPeolpleData;
  List<SearchPeolpleData>? get searchPeolpleData => _searchPeolpleData;

  SearchContentModel? _searchContent;
  SearchContentModel? get searchContent => _searchContent;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  ContentsDataQuery vidContentsQuery = ContentsDataQuery();
  ContentsDataQuery diaryContentsQuery = ContentsDataQuery();
  ContentsDataQuery picContentsQuery = ContentsDataQuery();
  UserInfoModel? _allContents;
  List<ContentData>? _listContentData;

  final _focusNode = FocusNode();
  final _focusNode1 = FocusNode();
  final _routing = Routing();
  final searchController = TextEditingController();
  final searchController1 = TextEditingController();
  int _pageIndex = 0;
  int _skip = 0;

  UserInfoModel? get allContents => _allContents;
  List<ContentData>? get listContentData => _listContentData;
  int get pageIndex => _pageIndex;
  FocusNode get focusNode => _focusNode;
  FocusNode get focusNode1 => _focusNode1;

  int get vidCount => allContents?.vids?.length ?? 0;
  bool get vidHasNext => vidContentsQuery.hasNext;

  int get diaryCount => allContents?.diaries?.length ?? 0;
  bool get diaryHasNext => diaryContentsQuery.hasNext;

  int get picCount => allContents?.pics?.length ?? 0;
  bool get picHasNext => picContentsQuery.hasNext;

  set searchPeolpleData(List<SearchPeolpleData>? val) {
    _searchPeolpleData = val;
    notifyListeners();
  }

  set isLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  set allContents(UserInfoModel? val) {
    _allContents = val;
    notifyListeners();
  }

  set searchContent(SearchContentModel? val) {
    _searchContent = val;
    notifyListeners();
  }

  set pageIndex(int val) {
    _pageIndex = val;
    notifyListeners();
  }

  onInitialSearch(BuildContext context) async {
    print('initial search');
    print(allContents?.diaries);
    print(allContents?.diaries![0].isApsara);
    if (allContents?.vids == null && allContents?.diaries == null && allContents?.pics == null) {
      vidContentsQuery.featureType = FeatureType.vid;
      diaryContentsQuery.featureType = FeatureType.diary;
      picContentsQuery.featureType = FeatureType.pic;

      vidContentsQuery.limit = 18;
      diaryContentsQuery.limit = 18;
      picContentsQuery.limit = 18;

      allContents = UserInfoModel();
      print('test24');
      allContents?.vids = await vidContentsQuery.reload(context);
      allContents?.diaries = await diaryContentsQuery.reload(context);
      allContents?.pics = await picContentsQuery.reload(context);
      notifyListeners();
    }
  }

  onScrollListener(BuildContext context, ScrollController scrollController) async {
    print("scroll");
    if (scrollController.offset >= scrollController.position.maxScrollExtent && !scrollController.position.outOfRange) {
      _skip += 10;

      String search = searchController.text;
      focusNode.unfocus();

      final notifier = SearchContentBloc();

      await notifier.getSearchContent(context, keys: search, skip: _skip, limit: 10);
      final fetch = notifier.searchContentFetch;
      if (fetch.searchContentState == SearchContentState.getSearchContentBlocSuccess) {
        SearchContentModel _res = SearchContentModel.fromJson(fetch.data);
        _searchContent!.users!.data!.addAll(_res.users!.data!);
        _searchContent!.diary!.data!.addAll(_res.diary!.data!);
        _searchContent!.pict!.data!.addAll(_res.pict!.data!);
        _searchContent!.vid!.data!.addAll(_res.vid!.data!);
      }

      notifyListeners();
    }
  }

  void onSearchPost(BuildContext context, {String? value, int skip = 0}) async {
    _routing.moveReplacement(Routes.searcMoreComplete);
    String search = value ?? searchController.text;
    focusNode.unfocus();

    final notifier = SearchContentBloc();

    isLoading = true;
    _searchContent = null;
    await notifier.getSearchContent(context, keys: search, skip: skip, limit: 10);
    final fetch = notifier.searchContentFetch;
    if (fetch.searchContentState == SearchContentState.getSearchContentBlocSuccess) {
      _searchContent = SearchContentModel.fromJson(fetch.data);
    } else {
      _searchContent = null;
    }
    isLoading = false;
    notifyListeners();
  }

  Future navigateToSeeAllScreen(BuildContext context, List<ContentData> data, int index) async {
    focusNode.unfocus();
    bool connect = await System().checkConnections();
    if (connect) {
      if (pageIndex == 0) _routing.move(Routes.vidDetail, argument: VidDetailScreenArgument(vidData: data[index]));
      if (pageIndex == 1) _routing.move(Routes.diaryDetail, argument: DiaryDetailScreenArgument(diaryData: data, index: index.toDouble()));
      if (pageIndex == 2) _routing.move(Routes.picSlideDetailPreview, argument: SlidedPicDetailScreenArgument(picData: data, index: index.toDouble()));
    } else {
      ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
        _routing.moveBack();
        navigateToSeeAllScreen(context, data, index);
      });
    }
  }

  Future navigateToSeeAllScreen2(BuildContext context, List<ContentData> data, int index, int selectIndex) async {
    focusNode.unfocus();
    bool connect = await System().checkConnections();
    if (connect) {
      // VidDetailScreenArgument()..postID = deepLink.queryParameters['postID']
      if (selectIndex == 2) {
        _routing.move(Routes.vidDetail,
            argument: VidDetailScreenArgument(vidData: data[index])
              ..postID = data[index].postID
              ..backPage = true);
      }
      if (selectIndex == 3) {
        _routing.move(Routes.diaryDetail,
            argument: DiaryDetailScreenArgument(diaryData: data, index: index.toDouble())
              ..postID = data[index].postID
              ..backPage = true);
      }
      if (selectIndex == 4) {
        _routing.move(Routes.picDetail,
            argument: PicDetailScreenArgument(picData: data[index])
              ..postID = data[index].postID
              ..backPage = true);
      }
    } else {
      ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
        _routing.moveBack();
        navigateToSeeAllScreen2(context, data, index, selectIndex);
      });
    }
  }

  void moveSearchMore() {
    print('kesini seacrhmore');
    focusNode1.unfocus();
    focusNode1.canRequestFocus = false;
    _routing.move(Routes.searcMore);
  }

  void backPage() {
    searchController1.text = '';
    _routing.moveBack();
  }

  void backFromSearchMore() {
    searchController1.text = '';
    searchController.text = '';
  }

  Future searchPeople(BuildContext context, {input}) async {
    print(input);
    final notifier = UtilsBlocV2();
    if (input.length > 2) {
      isLoading = true;
      await notifier.getSearchPeopleBloc(context, input, 0, 20);
      final fetch = notifier.utilsFetch;
      if (fetch.utilsState == UtilsState.searchPeopleSuccess) {
        _searchPeolpleData = [];

        fetch.data.forEach((v) {
          _searchPeolpleData!.add(SearchPeolpleData.fromJson(v));
        });
        isLoading = false;
        notifyListeners();
      }
      _isLoading = false;
    } else {
      print('kesini search');
      _searchPeolpleData = [];
      notifyListeners();
    }
  }

  void navigateToOtherProfile(BuildContext context, ContentData data, StoryController storyController) {
    Provider.of<OtherProfileNotifier>(context, listen: false).userEmail = data.email!;
    storyController.pause();
    _routing.move(Routes.otherProfile, argument: OtherProfileArgument(senderEmail: data.email)).whenComplete(() => storyController.play());
  }
}
