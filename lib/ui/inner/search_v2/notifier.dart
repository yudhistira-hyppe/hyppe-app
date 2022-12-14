import 'package:hyppe/core/arguments/contents/diary_detail_screen_argument.dart';
import 'package:hyppe/core/arguments/contents/pic_detail_screen_argument.dart';
import 'package:hyppe/core/arguments/contents/vid_detail_screen_argument.dart';
import 'package:hyppe/core/arguments/other_profile_argument.dart';
import 'package:hyppe/core/bloc/search_content/bloc.dart';
import 'package:hyppe/core/bloc/search_content/state.dart';
import 'package:hyppe/core/bloc/utils_v2/bloc.dart';
import 'package:hyppe/core/bloc/utils_v2/state.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/utils.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/models/collection/search/search_content.dart';
import 'package:hyppe/core/models/collection/utils/search_people/search_people.dart';
import 'package:hyppe/core/models/combination_v2/get_user_profile.dart';
import 'package:hyppe/core/query_request/contents_data_query.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/entities/report/notifier.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/other_profile/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:story_view/controller/story_controller.dart';

import '../../../core/arguments/contents/slided_pic_detail_screen_argument.dart';
import '../../../core/bloc/posts_v2/bloc.dart';

class SearchNotifier with ChangeNotifier {
  LocalizationModelV2 language = LocalizationModelV2();
  translate(LocalizationModelV2 translate) {
    language = translate;
    notifyListeners();
  }

  List<SearchPeolpleData>? _searchPeolpleData = [];
  List<SearchPeolpleData>? get searchPeolpleData => _searchPeolpleData;

  SearchContentModel? _searchContent;
  SearchContentModel? get searchContent => _searchContent;

  SearchContentModel? _searchContentFirstPage;
  SearchContentModel? get searchContentFirstPage => _searchContentFirstPage;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  ContentsDataQuery vidContentsQuery = ContentsDataQuery();
  ContentsDataQuery diaryContentsQuery = ContentsDataQuery();
  ContentsDataQuery picContentsQuery = ContentsDataQuery();
  UserInfoModel _allContents = UserInfoModel();
  List<ContentData>? _listContentData;

  final _focusNode = FocusNode();
  final _focusNode1 = FocusNode();
  final _routing = Routing();
  final searchController = TextEditingController();
  final searchController1 = TextEditingController();
  int _pageIndex = 0;
  int _skip = 0;
  int _skipVid = 1;
  int _skipDiary = 1;
  int _skipPict = 1;

  UserInfoModel get allContents => _allContents;
  List<ContentData>? get listContentData => _listContentData;
  int get pageIndex => _pageIndex;
  FocusNode get focusNode => _focusNode;
  FocusNode get focusNode1 => _focusNode1;

  // List<ContentData>? _initDataVid = null;
  // List<ContentData>? get initDataVid => _initDataVid;
  // set initDataVid(List<ContentData>? data){
  //   _initDataVid = data;
  //   notifyListeners();
  // }
  //
  // List<ContentData>? _initDataDiary = null;
  // List<ContentData>? get initDataDiary => _initDataDiary;
  // set initDataDiary(List<ContentData>? data){
  //   _initDataDiary = data;
  //   notifyListeners();
  // }
  //
  // List<ContentData>? _initDataPic = null;
  // List<ContentData>? get initDataPic => _initDataPic;
  // set initDataPic(List<ContentData>? data){
  //   _initDataPic = data;
  //   notifyListeners();
  // }

  int get vidCount => _searchContentFirstPage?.vid?.data == null
      ? 18
      : _vidHasNext
          ? (_searchContentFirstPage?.vid?.data?.length ?? 0) + 2
          : (_searchContentFirstPage?.vid?.data?.length ?? 0);

  bool _vidHasNext = false;
  // bool get vidHasNext => vidContentsQuery.hasNext;
  bool get vidHasNext => _vidHasNext;

  int get diaryCount => _searchContentFirstPage?.diary?.data == null
      ? 18
      : _diaryHasNext
          ? (_searchContentFirstPage?.diary?.data?.length ?? 0) + 2
          : (_searchContentFirstPage?.diary?.data?.length ?? 0);

  bool _diaryHasNext = false;
  bool get diaryHasNext => _diaryHasNext;

  int get picCount => _searchContentFirstPage?.pict?.data == null
      ? 18
      : _picHasNext
          ? (_searchContentFirstPage?.pict?.data?.length ?? 0) + 2
          : (_searchContentFirstPage?.pict?.data?.length ?? 0);

  bool _picHasNext = false;
  // bool get picHasNext => picContentsQuery.hasNext;
  bool get picHasNext => _picHasNext;

  set searchPeolpleData(List<SearchPeolpleData>? val) {
    _searchPeolpleData = val;
    notifyListeners();
  }

  set isLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  set allContents(UserInfoModel val) {
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

  void onUpdate() => notifyListeners();

  onInitialSearch(BuildContext context) async {
    if (allContents.vids == null && allContents.diaries == null && allContents.pics == null) {
      vidContentsQuery.featureType = FeatureType.vid;
      diaryContentsQuery.featureType = FeatureType.diary;
      picContentsQuery.featureType = FeatureType.pic;

      vidContentsQuery.limit = 18;
      diaryContentsQuery.limit = 18;
      picContentsQuery.limit = 18;

      allContents = UserInfoModel();
      print('reload contentsQuery : 23');
      allContents.vids = await vidContentsQuery.reload(context);
      allContents.diaries = await diaryContentsQuery.reload(context);
      allContents.pics = await picContentsQuery.reload(context);
      notifyListeners();
    }
  }

  onInitialSearchNew(BuildContext context) async {
    focusNode.unfocus();
    isLoading = true;
    _searchContentFirstPage = SearchContentModel();
    _searchContentFirstPage?.diary = Diary();
    _searchContentFirstPage?.diary?.data = [];
    _searchContentFirstPage?.vid = Diary();
    _searchContentFirstPage?.vid?.data = [];
    _searchContentFirstPage?.pict = Diary();
    _searchContentFirstPage?.pict?.data = [];
    _vidHasNext = true;
    _diaryHasNext = true;
    _picHasNext = true;
    _skip = 1;
    _skipVid = 1;
    _skipDiary = 1;
    _skipPict = 1;
    notifyListeners();

    try {
      final allContents = await allReload(context);
      vidContentsQuery.featureType = FeatureType.vid;
      diaryContentsQuery.featureType = FeatureType.diary;
      picContentsQuery.featureType = FeatureType.pic;
      _searchContentFirstPage?.vid?.data = allContents.video;
      _searchContentFirstPage?.diary?.data = allContents.diary;
      _searchContentFirstPage?.pict?.data = allContents.pict;
      print('skipnya $_skipVid');
      // _searchContent?.vid?.data = await getListPosts(context, FeatureType.vid);
      // _searchContent?.diary?.data = await getListPosts(context, FeatureType.diary);
      // _searchContent?.pict?.data = await getListPosts(context, FeatureType.pic);
    } catch (e) {
      'onInitialSearchNew : $e'.logger();
    } finally {
      isLoading = false;

      notifyListeners();
    }
  }

  Future<AllContents> allReload(BuildContext context, {bool myContent = false, bool otherContent = false}) async {
    AllContents? res;
    // final notifier = PostsBloc();
    //
    // await notifier.getAllContentsBlocV2(context, pageNumber: page, visibility: notifierMain.visibilty, myContent: myContent, otherContent: otherContent);
    // final fetch = notifier.postsFetch;
    // '${AllContents.fromJson(fetch.data).toJson()}'.logger();
    // res = AllContents.fromJson(fetch.data);
    // return res;
    try {
      final notifier = PostsBloc();

      await notifier.getAllContentsBlocV2(context, pageNumber: 1, pageRows: 18, visibility: 'PUBLIC', myContent: myContent, otherContent: otherContent);
      final fetch = notifier.postsFetch;
      '${AllContents.fromJson(fetch.data).toJson()}'.logger();
      res = AllContents.fromJson(fetch.data);
      print('res haha ${res.diary?.length}');
      return res;
    } catch (e) {
      'landing page error : $e'.logger();
      return AllContents(story: [], video: [], diary: [], pict: []);
    }
  }

  Future<List<ContentData>> getListPosts(BuildContext context, FeatureType type, {bool myContent = false, bool otherContent = false}) async {
    print('reload');

    List<ContentData>? res;
    try {
      final notifier = PostsBloc();
      await notifier.getContentsBlocV2(context,
          postID: null, pageRows: 18, pageNumber: 0, type: type, searchText: searchController.text, onlyMyData: false, visibility: 'PUBLIC', myContent: myContent, otherContent: otherContent);
      final fetch = notifier.postsFetch;

      res = (fetch.data as List<dynamic>?)?.map((e) => ContentData.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      '$e'.logger();
      rethrow;
    } finally {}

    return res ?? [];
  }

  onScrollListenerFirstPage(BuildContext context, ScrollController scrollController, FeatureType type) async {
    if (scrollController.offset >= scrollController.position.maxScrollExtent && !scrollController.position.outOfRange) {
      List<ContentData>? res = [];
      focusNode.unfocus();
      switch (type) {
        case FeatureType.vid:
          print('skipnya $_skipVid');
          print('skipnya2 $_skip');
          _skipVid = _skip + _skipVid;
          vidContentsQuery.page = _skipVid;
          print('skipnya $_skipVid');
          vidContentsQuery.featureType = FeatureType.vid;
          vidContentsQuery.limit = 18;
          res = await vidContentsQuery.loadNext(context, isLandingPage: true);
          _searchContentFirstPage?.vid?.data = [...(_searchContentFirstPage?.vid?.data ?? []), ...(res)];
          break;
        case FeatureType.diary:
          _skipDiary = _skip + _skipDiary;
          diaryContentsQuery.page = _skipDiary;
          diaryContentsQuery.featureType = FeatureType.diary;
          diaryContentsQuery.limit = 18;
          res = await diaryContentsQuery.loadNext(context, isLandingPage: true);
          _searchContentFirstPage?.diary?.data = [...(_searchContentFirstPage?.diary?.data ?? []), ...(res)];
          break;
        default:
          _skipPict = _skip + _skipPict;
          picContentsQuery.page = _skipPict;
          picContentsQuery.limit = 18;
          picContentsQuery.featureType = FeatureType.pic;
          res = await picContentsQuery.loadNext(context, isLandingPage: true);
          _searchContentFirstPage?.pict?.data = [...(_searchContentFirstPage?.pict?.data ?? []), ...(res)];
      }

      notifyListeners();
      try {
        return res;
      } catch (e) {
        'landing page error : $e'.logger();
        return AllContents(story: [], video: [], diary: [], pict: []);
      }
    }
  }

  onScrollListener(BuildContext context, ScrollController scrollController) async {
    if (scrollController.offset >= scrollController.position.maxScrollExtent && !scrollController.position.outOfRange) {
      String search = searchController.text;
      focusNode.unfocus();
      _skip += 18;
      final notifier = SearchContentBloc();
      await notifier.getSearchContent(context, keys: search, skip: _skip, limit: 18);
      final fetch = notifier.searchContentFetch;
      if (fetch.searchContentState == SearchContentState.getSearchContentBlocSuccess) {
        SearchContentModel _res = SearchContentModel.fromJson(fetch.data);
        // if (_res.vid?.data?.isEmpty ?? true) {
        //   _vidHasNext = false;
        // } else if (_res.vid?.skip == 0) {
        //   _vidHasNext = false;
        // } else if ((_res.vid?.data?.length ?? 0) % 18 == 0) {
        //   if ((_res.vid?.skip ?? 0) == (_res.vid?.totalFilter ?? 0)) {
        //     _vidHasNext = false;
        //   } else {
        //     _vidHasNext = true;
        //   }
        // } else {
        //   _vidHasNext = false;
        // }
        // if (_res.diary?.data?.isEmpty ?? true) {
        //   _diaryHasNext = false;
        // } else if (_res.diary?.skip == 0) {
        //   _diaryHasNext = false;
        // } else if ((_res.diary?.data?.length ?? 0) % 18 == 0) {
        //   if ((_res.diary?.skip ?? 0) == (_res.diary?.totalFilter ?? 0)) {
        //     _diaryHasNext = false;
        //   } else {
        //     _diaryHasNext = true;
        //   }
        // } else {
        //   _diaryHasNext = false;
        // }
        // if (_res.pict?.data?.isEmpty ?? true) {
        //   _picHasNext = false;
        // } else if (_res.pict?.skip == 0) {
        //   _picHasNext = false;
        // } else if ((_res.pict?.data?.length ?? 0) % 18 == 0) {
        //   if ((_res.pict?.skip ?? 0) == (_res.pict?.totalFilter ?? 0)) {
        //     _picHasNext = false;
        //   } else {
        //     _picHasNext = true;
        //   }
        // } else {
        //   _picHasNext = false;
        // }

        // if (_picHasNext || _diaryHasNext || _vidHasNext) {
        // _skip += 18;
        // }

        _searchContent?.users?.data?.addAll(_res.users?.data ?? []);
        _searchContent?.diary?.data = [...(_searchContent?.diary?.data ?? []), ...(_res.diary?.data ?? [])];
        _searchContent?.pict?.data = [...(_searchContent?.pict?.data ?? []), ...(_res.pict?.data ?? [])];
        _searchContent?.vid?.data = [...(_searchContent?.vid?.data ?? []), ...(_res.vid?.data ?? [])];
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
    await notifier.getSearchContent(context, keys: search, skip: skip, limit: 18);
    final fetch = notifier.searchContentFetch;
    if (fetch.searchContentState == SearchContentState.getSearchContentBlocSuccess) {
      final _res = SearchContentModel.fromJson(fetch.data);
      // if (_res.vid?.data?.isEmpty ?? true) {
      //   _vidHasNext = false;
      // } else if (_res.vid?.skip == 0) {
      //   _vidHasNext = false;
      // } else if ((_res.vid?.data?.length ?? 0) % 18 == 0) {
      //   if ((_res.vid?.skip ?? 0) == (_res.vid?.totalFilter ?? 0)) {
      //     _vidHasNext = false;
      //   } else {
      //     _vidHasNext = true;
      //   }
      // } else {
      //   _vidHasNext = false;
      // }
      // if (_res.diary?.data?.isEmpty ?? true) {
      //   _diaryHasNext = false;
      // } else if (_res.diary?.skip == 0) {
      //   _diaryHasNext = false;
      // } else if ((_res.diary?.data?.length ?? 0) % 18 == 0) {
      //   if ((_res.diary?.skip ?? 0) == (_res.diary?.totalFilter ?? 0)) {
      //     _diaryHasNext = false;
      //   } else {
      //     _diaryHasNext = true;
      //   }
      // } else {
      //   _diaryHasNext = false;
      // }
      // if (_res.pict?.data?.isEmpty ?? true) {
      //   _picHasNext = false;
      // } else if (_res.pict?.skip == 0) {
      //   _picHasNext = false;
      // } else if ((_res.pict?.data?.length ?? 0) % 18 == 0) {
      //   if ((_res.pict?.skip ?? 0) == (_res.pict?.totalFilter ?? 0)) {
      //     _picHasNext = false;
      //   } else {
      //     _picHasNext = true;
      //   }
      // } else {
      //   _picHasNext = false;
      // }
      _searchContent = _res;
    }
    // else {
    // _searchContent = null;
    // }
    isLoading = false;
    notifyListeners();
  }

  Future navigateToSeeAllScreen(BuildContext context, List<ContentData> data, int index) async {
    focusNode.unfocus();
    bool connect = await System().checkConnections();
    if (connect) {
      if (pageIndex == 0) _routing.move(Routes.vidDetail, argument: VidDetailScreenArgument(vidData: data[index]));
      if (pageIndex == 1)
        _routing.move(Routes.diaryDetail,
            argument: DiaryDetailScreenArgument(diaryData: data, index: index.toDouble(), page: diaryContentsQuery.page, limit: diaryContentsQuery.limit, type: TypePlaylist.search));
      if (pageIndex == 2)
        _routing.move(Routes.picSlideDetailPreview,
            argument: SlidedPicDetailScreenArgument(picData: data, index: index.toDouble(), page: picContentsQuery.page, limit: picContentsQuery.limit, type: TypePlaylist.search));
    } else {
      ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
        _routing.moveBack();
        navigateToSeeAllScreen(context, data, index);
      });
    }
  }

  Future navigateToSeeAllScreen2(BuildContext context, List<ContentData> data, int index, int selectIndex) async {
    context.read<ReportNotifier>().inPosition = contentPosition.search;
    focusNode.unfocus();
    bool connect = await System().checkConnections();
    if (connect) {
      // VidDetailScreenArgument()..postID = deepLink.queryParameters['postID']
      if (selectIndex == 2) {
        context.read<ReportNotifier>().type = 'vid';
        _routing.move(Routes.vidDetail,
            argument: VidDetailScreenArgument(vidData: data[index])
              ..postID = data[index].postID
              ..backPage = true);
      }
      if (selectIndex == 3) {
        context.read<ReportNotifier>().type = 'diary';
        _routing.move(Routes.diaryDetail,
            argument: DiaryDetailScreenArgument(diaryData: data, index: index.toDouble(), page: diaryContentsQuery.page, limit: diaryContentsQuery.limit, type: TypePlaylist.search)
              ..postID = data[index].postID
              ..backPage = true);
      }
      if (selectIndex == 4) {
        context.read<ReportNotifier>().type = 'pict';
        _routing.move(Routes.picSlideDetailPreview,
            argument: SlidedPicDetailScreenArgument(picData: data, index: index.toDouble(), page: picContentsQuery.page, limit: picContentsQuery.limit, type: TypePlaylist.search)
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
    searchController1.clear();
    _routing.moveBack();
  }

  void backFromSearchMore() {
    searchController1.text = '';
    searchController.clear();
    _routing.moveBack();
    notifyListeners();
  }

  Future searchPeople(BuildContext context, {input}) async {
    final notifier = UtilsBlocV2();
    if (input.length > 2) {
      isLoading = true;
      await notifier.getSearchPeopleBloc(context, input, 0, 20);
      final fetch = notifier.utilsFetch;
      if (fetch.utilsState == UtilsState.searchPeopleSuccess) {
        _searchPeolpleData = [];

        fetch.data.forEach((v) {
          _searchPeolpleData?.add(SearchPeolpleData.fromJson(v));
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
    Provider.of<OtherProfileNotifier>(context, listen: false).userEmail = data.email;
    storyController.pause();
    _routing.move(Routes.otherProfile, argument: OtherProfileArgument(senderEmail: data.email)).whenComplete(() => storyController.play());
  }

  void showContentSensitive(BuildContext context, {required String postID, required String content, bool? isReport}) {
    ContentData? _updatedData;
    ContentData? _updatedData2;

    switch (content) {
      case hyppeVid:
        _updatedData = _searchContent?.vid?.data?.firstWhere((element) => element.postID == postID);
        break;
      case hyppeDiary:
        _updatedData = _searchContent?.diary?.data?.firstWhere((element) => element.postID == postID);
        break;
      case hyppePic:
        _updatedData = _searchContent?.pict?.data?.firstWhere((element) => element.postID == postID);
        break;
      default:
        "$content It's Not a content of $postID".logger();
        break;
    }

    if (_updatedData != null) {
      _updatedData.reportedStatus = '';
    }
    if (_updatedData2 != null) {
      _updatedData2.reportedStatus = '';
    }

    notifyListeners();
  }
}
