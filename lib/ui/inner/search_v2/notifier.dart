import 'dart:math';

import 'package:hyppe/app.dart';
import 'package:hyppe/core/arguments/contents/diary_detail_screen_argument.dart';
import 'package:hyppe/core/arguments/contents/vid_detail_screen_argument.dart';
import 'package:hyppe/core/arguments/other_profile_argument.dart';
import 'package:hyppe/core/bloc/search_content/bloc.dart';
import 'package:hyppe/core/bloc/search_content/state.dart';
import 'package:hyppe/core/bloc/utils_v2/bloc.dart';
import 'package:hyppe/core/bloc/utils_v2/state.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/utils.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/models/collection/search/search_content.dart';
import 'package:hyppe/core/models/collection/utils/search_people/search_people.dart';
import 'package:hyppe/core/models/combination_v2/get_user_profile.dart';
import 'package:hyppe/core/query_request/contents_data_query.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/entities/report/notifier.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/other_profile/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:story_view/controller/story_controller.dart';

import '../../../core/arguments/contents/slided_diary_detail_screen_argument.dart';
import '../../../core/arguments/contents/slided_pic_detail_screen_argument.dart';
import '../../../core/arguments/contents/slided_vid_detail_screen_argument.dart';
import '../../../core/bloc/posts_v2/bloc.dart';
import '../../../core/constants/themes/hyppe_colors.dart';
import '../../../core/models/collection/database/search_history.dart';
import '../../constant/widget/custom_loading.dart';
import 'hashtag/widget/grid_hashtag_diary.dart';
import 'hashtag/widget/grid_hashtag_pic.dart';
import 'hashtag/widget/grid_hashtag_vid.dart';

class SearchNotifier with ChangeNotifier {
  LocalizationModelV2 language = LocalizationModelV2();
  translate(LocalizationModelV2 translate) {
    language = translate;
    notifyListeners();
  }

  List paramSearch = ['all', 'listuser', 'listvid', 'listdiary'];

  int _tabIndex = 0;
  int get tabIndex => _tabIndex;

  int _limit = 0;
  int get limit => _limit;

  List<SearchPeolpleData>? _searchPeolpleData = [];
  List<SearchPeolpleData>? get searchPeolpleData => _searchPeolpleData;

  SearchContentModel? _searchContent;
  SearchContentModel? get searchContent => _searchContent;

  bool _connectionError = false;
  bool get connectionError => _connectionError;
  set connectionError(bool state) {
    _connectionError = state;
    notifyListeners();
  }

  bool _loadNavigate = false;
  bool get loadNavigate => _loadNavigate;
  set loadNavigate(bool state) {
    _loadNavigate = state;
    notifyListeners();
  }

  bool _isZoom = false;
  bool get isZoom => _isZoom;
  set isZoom(bool state) {
    _isZoom = state;
    notifyListeners();
  }

  Future checkConnection() async {
    bool connect = await System().checkConnections();
    connectionError = !connect;
  }

  List<ContentData>? _searchVid;
  List<ContentData>? get searchVid => _searchVid;

  set searchVid(List<ContentData>? values) {
    _searchVid = values;
    notifyListeners();
  }

  List<ContentData>? _searchDiary;
  List<ContentData>? get searchDiary => _searchDiary;

  set searchDiary(List<ContentData>? values) {
    _searchDiary = values;
    notifyListeners();
  }

  List<ContentData>? _searchPic;
  List<ContentData>? get searchPic => _searchPic;

  set searchPic(List<ContentData>? values) {
    _searchPic = values;
    notifyListeners();
  }

  List<Tags>? _searchHashtag;
  List<Tags>? get searchHashtag => _searchHashtag;

  set searchHashtag(List<Tags>? values) {
    _searchHashtag = values;
    notifyListeners();
  }

  List<DataUser>? _searchUsers;
  List<DataUser>? get searchUsers => _searchUsers;

  set searchUsers(List<DataUser>? values) {
    _searchUsers = values;
    notifyListeners();
  }

  Map<String, SearchContentModel?> mapDetailHashtag = {};

  SearchContentModel? getMapHashtag(String tag) {
    return mapDetailHashtag[tag];
  }

  setMapHashtag(SearchContentModel value, String tag) {
    mapDetailHashtag[tag] = value;
  }

  deleteMapHashtag(String tag) {
    mapDetailHashtag[tag] = null;
  }

  SearchContentModel? _detailHashTag;
  SearchContentModel? get detailHashTag => _detailHashTag;
  set detailHashTag(SearchContentModel? val) {
    _detailHashTag = val;
    notifyListeners();
  }

  bool _isHasNextPic = false;
  bool get isHasNextPic => _isHasNextPic;
  set isHasNextPic(bool state) {
    _isHasNextPic = state;
    notifyListeners();
  }

  setHasNextPic(bool state) {
    _isHasNextPic = state;
  }

  bool _isHasNextVid = false;
  bool get isHasNextVid => _isHasNextVid;
  set isHasNextVid(bool state) {
    _isHasNextVid = state;
    notifyListeners();
  }

  setHasNextVid(bool state) {
    _isHasNextVid = state;
  }

  bool _isHasNextDiary = false;
  bool get isHasNextDiary => _isHasNextDiary;
  set isHasNextDiary(bool state) {
    _isHasNextDiary = state;
    notifyListeners();
  }

  setHasNextDiary(bool state) {
    _isHasNextDiary = state;
  }

  bool _intHasNextPic = false;
  bool get intHasNextPic => _intHasNextPic;
  set intHasNextPic(bool state) {
    _intHasNextPic = state;
    notifyListeners();
  }

  setIntHasNextPic(bool state) {
    _intHasNextPic = state;
  }

  bool _intHasNextVid = false;
  bool get intHasNextVid => _intHasNextVid;
  set intHasNextVid(bool state) {
    _intHasNextVid = state;
    notifyListeners();
  }

  setIntHasNextVid(bool state) {
    _intHasNextVid = state;
  }

  bool _intHasNextDiary = false;
  bool get intHasNextDiary => _intHasNextDiary;
  set intHasNextDiary(bool state) {
    _intHasNextDiary = state;
    notifyListeners();
  }

  setIntHasNextDiary(bool state) {
    _intHasNextDiary = state;
  }

  List<ContentData>? _hashtagVid;
  List<ContentData>? get hashtagVid => _hashtagVid;
  set hashtagVid(List<ContentData>? data) {
    _hashtagVid = data;
    notifyListeners();
  }

  initAllHasNext() {
    _isHasNextVid = true;
    _isHasNextDiary = true;
    _isHasNextPic = true;
  }

  List<ContentData>? _hashtagDiary;
  List<ContentData>? get hashtagDiary => _hashtagDiary;
  set hashtagDiary(List<ContentData>? data) {
    _hashtagDiary = data;
    notifyListeners();
  }

  List<ContentData>? _hashtagPic;
  List<ContentData>? get hashtagPic => _hashtagPic;
  set hashtagPic(List<ContentData>? data) {
    _hashtagPic = data;
    notifyListeners();
  }

  String _tagImageMain = '';
  String get tagImageMain => _tagImageMain;
  set tagImageMain(String val) {
    _tagImageMain = val;
    notifyListeners();
  }

  int _countTag = 0;
  int get countTag => _countTag;
  set countTag(int value) {
    _countTag = value;
    notifyListeners();
  }

  Tags? _currentHashtag;
  Tags? get currentHashtag => _currentHashtag;
  set currentHashtag(Tags? data) {
    _currentHashtag = data;
    notifyListeners();
  }

  SearchContentModel? _detailInterest;
  SearchContentModel? get detailInterest => _detailInterest;
  set detailInterest(SearchContentModel? val) {
    _detailInterest = val;
    notifyListeners();
  }

  AllContents? _searchContentFirstPage;
  AllContents? get searchContentFirstPage => _searchContentFirstPage;

  bool isloadingGetMore = false;
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _loadTagDetail = true;
  bool get loadTagDetail => _loadTagDetail;
  set loadTagDetail(bool val) {
    _loadTagDetail = val;
    notifyListeners();
  }

  bool _loadIntDetailPic = true;
  bool get loadIntDetailPic => _loadIntDetailPic;
  set loadIntDetailPic(bool val) {
    _loadIntDetailPic = val;
    notifyListeners();
  }

  bool _loadIntDetailDiary = true;
  bool get loadIntDetailDiary => _loadIntDetailDiary;
  set loadIntDetailDiary(bool val) {
    _loadIntDetailDiary = val;
    notifyListeners();
  }

  bool _loadIntDetailVid = true;
  bool get loadIntDetailVid => _loadIntDetailVid;
  set loadIntDetailVid(bool val) {
    _loadIntDetailVid = val;
    notifyListeners();
  }

  initDetailInterest() {
    _loadIntDetailPic = true;
    _loadIntDetailDiary = true;
    _loadIntDetailVid = true;
  }

  removeInterestItem(String key, String postID) {
    final interest = interestContents[key];
    if (interest != null) {
      interest.vid?.removeWhere((element) => element.postID == postID);
      interest.pict?.removeWhere((element) => element.postID == postID);
      interest.diary?.removeWhere((element) => element.postID == postID);
      notifyListeners();
    }
  }

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

  int _tab1 = 0;
  int _tab2 = 0;
  int _tab3 = 0;
  int _tab4 = 0;

  int get tab1 => _tab1;
  int get tab2 => _tab2;
  int get tab3 => _tab3;
  int get tab4 => _tab4;

  int _skip1 = 0;
  int _skip2 = 0;
  int _skip3 = 0;
  int _skip4 = 0;

  int get skip1 => _skip1;
  int get skip2 => _skip2;
  int get skip3 => _skip3;
  int get skip4 => _skip4;

  // void getHashtag() async{
  //   listHashtag = [];
  //   loadHashtag = true;
  //   Future.delayed(const Duration(seconds: 2), (){
  //     loadHashtag = false;
  //     listHashtag = [Hashtag("#WisataIndonesia", 600), Hashtag('#WisataJakarta', 700), Hashtag('#WisataBandung', 300)];
  //   });
  //   notifyListeners();
  // }
  //
  // List<Hashtag>? _listHashtag;
  // bool _loadHashtag = true;
  // bool get loadHashtag => _loadHashtag;
  // set loadHashtag(bool state){
  //   _loadHashtag = state;
  //   notifyListeners();
  // }

  bool _loadLandingPage = true;
  bool get loadLandingPage => _loadLandingPage;

  set loadLandingPage(bool state) {
    _loadLandingPage = state;
    notifyListeners();
  }

  bool _loadContents = true;
  bool get loadContents => _loadContents;

  set loadContents(bool state) {
    _loadContents = state;
    notifyListeners();
  }

  bool _hasNext = false;
  bool get hasNext => _hasNext;
  set hasNext(bool state) {
    _hasNext = state;
    notifyListeners();
  }

  List<Tags>? _listHashtag;
  List<Tags>? get listHashtag => _listHashtag;

  set listHashtag(List<Tags>? val) {
    _listHashtag = val;
    notifyListeners();
  }

  List<Interest>? _listInterest;
  List<Interest>? get listInterest => _listInterest;

  set listInterest(List<Interest>? values) {
    _listInterest = values;
    notifyListeners();
  }

  Map<String, SearchContentModel> _interestContents = {};
  Map<String, SearchContentModel> get interestContents => _interestContents;

  set interestContents(Map<String, SearchContentModel> values) {
    _interestContents = values;
    notifyListeners();
  }

  Tags? _selectedHashtag;
  Tags? get selectedHashtag => _selectedHashtag;
  set selectedHashtag(Tags? data) {
    _selectedHashtag = data;
    notifyListeners();
  }

  Interest? _selectedInterest;
  Interest? get selectedInterest => _selectedInterest;
  set selectedInterest(Interest? val) {
    _selectedInterest = val;
    notifyListeners();
  }

  List<SearchHistory>? _riwayat = [];
  List<SearchHistory>? get riwayat => _riwayat;
  set riwayat(List<SearchHistory>? values) {
    _riwayat = values;
    notifyListeners();
  }

  Future onSearchLandingPage(BuildContext context) async {
    checkConnection();
    try {
      loadLandingPage = true;
      final notifier = SearchContentBloc();
      await notifier.landingPageSearch(context);
      final fetch = notifier.searchContentFetch;
      if (fetch.searchContentState == SearchContentState.getSearchContentBlocSuccess) {
        LandingSearch res = LandingSearch.fromJson(fetch.data);
        listHashtag = res.tag ?? [];
        listInterest = res.interest ?? [];
      } else {
        throw 'Failed landing page search execution';
      }
    } catch (e) {
      'Error onSearchLandingPage: $e'.logger();
    } finally {
      loadLandingPage = false;
      // getAllInterestContents(context);
    }
  }

  Future getAllInterestContents(BuildContext context) async {
    try {
      loadContents = true;
      if (listInterest != null) {
        if (listInterest!.isNotEmpty) {
          await for (final value in getInterest(context, listInterest!)) {
            final id = value?.interests?[0].id ?? '613bc4da9ec319617aa6c38e';
            if (value != null) {
              interestContents[id] = value;
            }
          }
          notifyListeners();
        }
      }
    } catch (e) {
      'Error Get Interest Contests'.logger();
    } finally {
      loadContents = false;
    }
  }

  Stream<SearchContentModel?> getInterest(BuildContext context, List<Interest> interests) async* {
    for (final interest in interests) {
      yield await _hitApiGetDetail(context, interest.id ?? '613bc4da9ec319617aa6c38e', TypeApiSearch.detailInterest, 0);
    }
  }

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

  SearchLayout _layout = SearchLayout.first;
  SearchLayout get layout => _layout;
  set layout(SearchLayout val) {
    _layout = val;
    notifyListeners();
  }

  bool _isFromComplete = false;
  bool get isFromComplete => _isFromComplete;
  set isFromComplete(bool state) {
    _isFromComplete = state;
    notifyListeners();
  }

  startLayout() {
    _layout = SearchLayout.first;
    _isFromComplete = false;
  }

  initDetailHashtag() {
    _hashtagTab = HyppeType.HyppePic;
    _loadTagDetail = true;
  }

  initSearchAll() {
    _contentTab = HyppeType.HyppePic;
  }

  HyppeType _mainContentTab = HyppeType.HyppePic;
  HyppeType get mainContentTab => _mainContentTab;
  set mainContentTab(HyppeType type) {
    _mainContentTab = type;
    notifyListeners();
  }

  HyppeType _contentTab = HyppeType.HyppePic;
  HyppeType get contentTab => _contentTab;
  set contentTab(HyppeType type) {
    _contentTab = type;
    notifyListeners();
  }

  HyppeType _hashtagTab = HyppeType.HyppePic;
  HyppeType get hashtagTab => _hashtagTab;
  set hashtagTab(HyppeType type) {
    _hashtagTab = type;
    notifyListeners();
  }

  int get vidCount => _searchContentFirstPage?.video == null
      ? 18
      : _vidHasNext
          ? (_searchContentFirstPage?.video?.length ?? 0) + 2
          : (_searchContentFirstPage?.video?.length ?? 0);

  bool _vidHasNext = false;
  // bool get vidHasNext => vidContentsQuery.hasNext;
  bool get vidHasNext => _vidHasNext;

  int get diaryCount => _searchContentFirstPage?.diary == null
      ? 18
      : _diaryHasNext
          ? (_searchContentFirstPage?.diary?.length ?? 0) + 2
          : (_searchContentFirstPage?.diary?.length ?? 0);

  bool _diaryHasNext = false;
  bool get diaryHasNext => _diaryHasNext;

  int get picCount => _searchContentFirstPage?.pict == null
      ? 18
      : _picHasNext
          ? (_searchContentFirstPage?.pict?.length ?? 0) + 2
          : (_searchContentFirstPage?.pict?.length ?? 0);

  bool _picHasNext = false;
  // bool get picHasNext => picContentsQuery.hasNext;
  bool get picHasNext => _picHasNext;

  set searchPeolpleData(List<SearchPeolpleData>? val) {
    _searchPeolpleData = val;
    notifyListeners();
  }

  set limit(int val) {
    _limit = val;
    notifyListeners();
  }

  set tabIndex(int val) {
    _tabIndex = val;
    if (_tabIndex == 1) {
      _tab1++;
    }
    if (_tabIndex == 2) {
      _tab2++;
    }
    if (_tabIndex == 3) {
      _tab3++;
    }
    if (_tabIndex == 4) {
      _tab4++;
    }
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
    _searchUsers = [];
    _searchHashtag = [];
    searchController.clear();
  }

  void getHistories() async {
    riwayat = await globalDB.getHistories();
  }

  void insertHistory(BuildContext context, String keyword) async {
    final checkData = await globalDB.getHistoryByKeyword(keyword);
    final date = System().getCurrentDate();
    if (checkData == null) {
      await globalDB.insertHistory(SearchHistory(keyword: keyword, datetime: date));
    } else {
      await globalDB.updateHistory(SearchHistory(keyword: keyword, datetime: date));
    }
  }

  void deleteHistory(SearchHistory data) async {
    await globalDB.deleteHistory(data);
    getHistories();
  }

  Future onInitialSearchNew(BuildContext context, FeatureType featureType, {bool reload = false}) async {
    focusNode.unfocus();
    _layout = SearchLayout.first;
    _isFromComplete = false;
    print('reload search');
    print(reload);
    print(reload == false);

    if (featureType == FeatureType.vid) {
      if ((_searchContentFirstPage?.video != null || (_searchContentFirstPage?.video?.length ?? 0) > 0) && reload == false) {
        return null;
      } else {
        if (!reload) {
          isLoading = true;
        }
        _searchContentFirstPage = AllContents();
        // _searchContentFirstPage?.video = [];
      }
    }

    if (featureType == FeatureType.diary) {
      if (_searchContentFirstPage?.diary != null || (_searchContentFirstPage?.diary?.length ?? 0) > 0) {
        return;
      } else {
        isLoading = true;
        _searchContentFirstPage?.diary = [];
      }
    }

    if (featureType == FeatureType.pic) {
      if (_searchContentFirstPage?.pict != null || (_searchContentFirstPage?.pict?.length ?? 0) > 0) {
        return null;
      } else {
        isLoading = true;
        _searchContentFirstPage?.pict = [];
      }
    }
    _vidHasNext = true;
    _diaryHasNext = true;
    _picHasNext = true;
    _skip = 1;
    _skipVid = 1;
    _skipDiary = 1;
    _skipPict = 1;
    notifyListeners();

    try {
      final allContents = await allReload(
        context,
        featureType: System().validatePostTypeV2(featureType),
      );
      if (featureType == FeatureType.vid) {
        vidContentsQuery.featureType = FeatureType.vid;
        _searchContentFirstPage?.video = allContents.video;
      }
      if (featureType == FeatureType.diary) {
        diaryContentsQuery.featureType = FeatureType.diary;
        _searchContentFirstPage?.diary = allContents.diary;
      }
      if (featureType == FeatureType.pic) {
        picContentsQuery.featureType = FeatureType.pic;
        _searchContentFirstPage?.pict = allContents.pict;
      }

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

  Future<AllContents> allReload(BuildContext context, {bool myContent = false, bool otherContent = false, String? featureType}) async {
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

      await notifier.getAllContentsBlocV2(context, pageNumber: 1, pageRows: 18, visibility: 'PUBLIC', myContent: myContent, otherContent: otherContent, postType: featureType);
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
          _searchContentFirstPage?.video = [...(_searchContentFirstPage?.video ?? []), ...(res)];
          break;
        case FeatureType.diary:
          _skipDiary = _skip + _skipDiary;
          diaryContentsQuery.page = _skipDiary;
          diaryContentsQuery.featureType = FeatureType.diary;
          diaryContentsQuery.limit = 18;
          res = await diaryContentsQuery.loadNext(context, isLandingPage: true);
          _searchContentFirstPage?.diary = [...(_searchContentFirstPage?.diary ?? []), ...(res)];
          break;
        default:
          _skipPict = _skip + _skipPict;
          picContentsQuery.page = _skipPict;
          picContentsQuery.limit = 18;
          picContentsQuery.featureType = FeatureType.pic;
          res = await picContentsQuery.loadNext(context, isLandingPage: true);
          _searchContentFirstPage?.pict = [...(_searchContentFirstPage?.pict ?? []), ...(res)];
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

  Future getDetailHashtag(BuildContext context, String keys, {reload = true, HyppeType? hyppe, bool force = false}) async {
    print('getDetailHashtag keys: $keys');
    final detail = mapDetailHashtag[keys];
    checkConnection();
    try {
      final lenghtVid = mapDetailHashtag[keys]?.vid?.length ?? 0;
      final lenghtDiary = mapDetailHashtag[keys]?.diary?.length ?? 0;
      final lenghtPic = mapDetailHashtag[keys]?.pict?.length ?? 0;
      if (reload) {
        if (force) {
          initAllHasNext();
          loadTagDetail = true;
          final _res = await _hitApiGetDetail(context, keys.replaceAll(' ', ''), TypeApiSearch.detailHashTag, 0, type: hyppe);
          if (_res != null) {
            mapDetailHashtag[keys] = _res;
            final videos = mapDetailHashtag[keys]?.vid ?? [];
            final diaries = mapDetailHashtag[keys]?.diary ?? [];
            final pics = mapDetailHashtag[keys]?.pict ?? [];
            final hashtags = mapDetailHashtag[keys]?.tags ?? [];

            if (hashtags.isNotNullAndEmpty()) {
              _currentHashtag = hashtags.first;
              final extraTag = _currentHashtag;
              final count = (extraTag != null ? (extraTag.total ?? 0) : 0);
              if ((pics.isEmpty) && (diaries.isEmpty) && (videos.isEmpty)) {
                _countTag = 0;
              } else {
                _countTag = count;
              }
            } else {
              _countTag = 0;
            }
            // for(int i = 0; pics.length > i; i++){
            //   final _pic = pics[i];
            //   await pics[i].getBlob();
            //   if(_pic.blob == null){
            //     saveThumb(_pic);
            //   }
            // }
            mapDetailHashtag[keys]?.vid = videos;
            mapDetailHashtag[keys]?.diary = diaries;
            mapDetailHashtag[keys]?.pict = pics;
            detailHashTag = mapDetailHashtag[keys];
            if (pics.isNotNullAndEmpty()) {
              final data = pics[0];
              final url = ((data.isApsara ?? false) ? (data.mediaThumbEndPoint ?? '') : System().showUserPicture(data.mediaThumbEndPoint) ?? '');
              _tagImageMain = url;
            } else {
              _tagImageMain = '';
            }
          }
          loadTagDetail = false;
        } else {
          if (detail == null) {
            initAllHasNext();
            loadTagDetail = true;
            final _res = await _hitApiGetDetail(context, keys.replaceAll(' ', ''), TypeApiSearch.detailHashTag, 0, type: hyppe);
            if (_res != null) {
              mapDetailHashtag[keys] = _res;
              final videos = mapDetailHashtag[keys]?.vid ?? [];
              final diaries = mapDetailHashtag[keys]?.diary ?? [];
              final pics = mapDetailHashtag[keys]?.pict ?? [];
              final hashtags = mapDetailHashtag[keys]?.tags ?? [];

              if (hashtags.isNotNullAndEmpty()) {
                _currentHashtag = hashtags.first;
                final extraTag = _currentHashtag;
                final count = (extraTag != null ? (extraTag.total ?? 0) : 0);
                if ((pics.isEmpty) && (diaries.isEmpty) && (videos.isEmpty)) {
                  _countTag = 0;
                } else {
                  _countTag = count;
                }
              } else {
                _countTag = 0;
              }
              // for(int i = 0; pics.length > i; i++){
              //   final _pic = pics[i];
              //   await pics[i].getBlob();
              //   if(_pic.blob == null){
              //     saveThumb(_pic);
              //   }
              // }
              mapDetailHashtag[keys]?.vid = videos;
              mapDetailHashtag[keys]?.diary = diaries;
              mapDetailHashtag[keys]?.pict = pics;
              detailHashTag = mapDetailHashtag[keys];
              if (pics.isNotNullAndEmpty()) {
                final data = pics[0];
                final url = ((data.isApsara ?? false) ? (data.mediaThumbEndPoint ?? '') : System().showUserPicture(data.mediaThumbEndPoint) ?? '');
                _tagImageMain = url;
              } else {
                _tagImageMain = '';
              }
            }
            loadTagDetail = false;
          } else {
            detailHashTag = mapDetailHashtag[keys];
            final videos = mapDetailHashtag[keys]?.vid ?? [];
            final diaries = mapDetailHashtag[keys]?.diary ?? [];
            final pics = mapDetailHashtag[keys]?.pict ?? [];
            final hashtags = mapDetailHashtag[keys]?.tags ?? [];
            if (hashtags.isNotNullAndEmpty()) {
              _currentHashtag = hashtags.first;
              final extraTag = _currentHashtag;
              final count = (extraTag != null ? (extraTag.total ?? 0) : 0);
              if ((pics.isEmpty) && (diaries.isEmpty) && (videos.isEmpty)) {
                _countTag = 0;
              } else {
                _countTag = count;
              }
            } else {
              _countTag = 0;
            }
            if (pics.isNotNullAndEmpty()) {
              final data = pics[0];
              final url = ((data.isApsara ?? false) ? (data.mediaThumbEndPoint ?? '') : System().showUserPicture(data.mediaThumbEndPoint) ?? '');
              _tagImageMain = url;
            } else {
              _tagImageMain = '';
            }
          }
        }

        notifyListeners();
      } else {
        final currentSkip = hyppe == HyppeType.HyppeVid
            ? lenghtVid
            : hyppe == HyppeType.HyppeDiary
                ? lenghtDiary
                : hyppe == HyppeType.HyppePic
                    ? lenghtPic
                    : 0;
        if (currentSkip % 12 == 0) {
          if (!hasNext) {
            hasNext = true;
            final _res = await _hitApiGetDetail(context, keys.replaceAll(' ', ''), TypeApiSearch.detailHashTag, currentSkip, type: hyppe);
            if (_res != null) {
              if (currentSkip != 0) {
                final videos = _res.vid;
                final diaries = _res.diary;
                final pics = _res.pict;
                if (hyppe == HyppeType.HyppePic) {
                  if (pics?.isEmpty ?? true) {
                    isHasNextPic = false;
                  }
                }

                if (hyppe == HyppeType.HyppeDiary) {
                  if (diaries?.isEmpty ?? true) {
                    isHasNextDiary = false;
                  }
                }

                if (hyppe == HyppeType.HyppeVid) {
                  if (videos?.isEmpty ?? true) {
                    isHasNextVid = false;
                  }
                }

                if (hyppe == HyppeType.HyppeVid) {
                  for (final video in videos ?? []) {
                    mapDetailHashtag[keys]?.vid?.add(video);
                  }
                  // _hashtagVid = [...(_hashtagVid ?? []), ...(videos ?? [])];
                } else if (hyppe == HyppeType.HyppeDiary) {
                  for (final diary in diaries ?? []) {
                    mapDetailHashtag[keys]?.diary?.add(diary);
                  }
                  // _hashtagDiary = [...(_hashtagDiary ?? []), ...(diaries ?? [])];
                } else if (hyppe == HyppeType.HyppePic) {
                  for (ContentData pic in pics ?? []) {
                    // await pic.getBlob();
                    mapDetailHashtag[keys]?.pict?.add(pic);
                    // if(pic.blob == null){
                    //   saveThumb(pic);
                    // }
                  }
                  // _hashtagPic = [...(_hashtagPic ?? []), ...(pics ?? [])];
                }
              }
            }
          }
        }
        detailHashTag = mapDetailHashtag[keys];
        hasNext = false;
      }
    } catch (e) {
      if (loadTagDetail) {
        loadTagDetail = false;
      }
      if (_hasNext) {
        hasNext = false;
      }

      'Error getDetail: $e'.logger();
    } finally {
      if (loadTagDetail) {
        loadTagDetail = false;
      }
      if (_hasNext) {
        hasNext = false;
      }
    }
  }

  Future saveThumb(ContentData dataitem) async {
    if (!(dataitem.isApsara ?? true)) {
      final imageUrl = System().showUserPicture(dataitem.mediaThumbEndPoint);
      if (imageUrl?.isNotEmpty ?? false) {
        final id = dataitem.postID;
        if (id != null) {
          System().saveThumbnail(imageUrl!, id);
        }
      }
    }
  }

  Future getDetailInterest(BuildContext context, String keys, {reload = true, HyppeType? hyppe}) async {
    try {
      final currentVid = interestContents[keys]?.vid ?? [];
      final currentDairy = interestContents[keys]?.diary ?? [];
      final currentPic = interestContents[keys]?.pict ?? [];
      final lenghtVid = currentVid.length;
      final lenghtDiary = currentDairy.length;
      final lenghtPic = currentPic.length;
      checkConnection();
      print('the interest id: $keys');
      if (reload) {
        initDetailInterest();
        if (interestContents[keys] == null) {
          interestContents[keys] = SearchContentModel();
        }

        notifyListeners();
        _hitApiGetDetail(context, keys, TypeApiSearch.detailInterest, 0, type: HyppeType.HyppePic).then((value) {
          if (value != null) {
            interestContents[keys]?.pict = value.pict;
            notifyListeners();
            Future.delayed(const Duration(milliseconds: 500), () {
              loadIntDetailPic = false;
            });
          }
        });
        _hitApiGetDetail(context, keys, TypeApiSearch.detailInterest, 0, type: HyppeType.HyppeDiary).then((value) {
          if (value != null) {
            interestContents[keys]?.diary = value.diary;
            notifyListeners();
            Future.delayed(const Duration(milliseconds: 500), () {
              loadIntDetailDiary = false;
            });
          }
        });
        await _hitApiGetDetail(context, keys, TypeApiSearch.detailInterest, 0, type: HyppeType.HyppeVid).then((value) {
          if (value != null) {
            interestContents[keys]?.vid = value.vid;
            notifyListeners();
            Future.delayed(const Duration(milliseconds: 500), () {
              loadIntDetailVid = false;
            });
          }
        });
      } else {
        if (isloadingGetMore) {
          return;
        }
        final currentSkip = hyppe == HyppeType.HyppeVid
            ? lenghtVid
            : hyppe == HyppeType.HyppeDiary
                ? lenghtDiary
                : hyppe == HyppeType.HyppePic
                    ? lenghtPic
                    : 0;
        if (currentSkip % 12 == 0) {
          if (hyppe == HyppeType.HyppeVid) {
            intHasNextVid = true;
          } else if (hyppe == HyppeType.HyppeDiary) {
            intHasNextDiary = true;
          } else if (hyppe == HyppeType.HyppePic) {
            intHasNextPic = true;
          }
          isloadingGetMore = true;
          final _res = await _hitApiGetDetail(context, keys, TypeApiSearch.detailInterest, currentSkip, type: hyppe);
          if (_res != null) {
            if (currentSkip != 0) {
              final videos = _res.vid;
              final diaries = _res.diary;
              final pics = _res.pict;
              if (hyppe == HyppeType.HyppeVid) {
                if (videos?.isEmpty ?? true) {
                  intHasNextVid = false;
                }
              }
              if (hyppe == HyppeType.HyppeDiary) {
                if (diaries?.isEmpty ?? true) {
                  intHasNextDiary = false;
                }
              }
              if (hyppe == HyppeType.HyppePic) {
                if (pics?.isEmpty ?? true) {
                  intHasNextPic = false;
                }
              }

              if (hyppe == HyppeType.HyppeVid) {
                for (final video in videos ?? []) {
                  interestContents[keys]?.vid?.add(video);
                }
                // _hashtagVid = [...(_hashtagVid ?? []), ...(videos ?? [])];
              } else if (hyppe == HyppeType.HyppeDiary) {
                for (final diary in diaries ?? []) {
                  interestContents[keys]?.diary?.add(diary);
                }
                // _hashtagDiary = [...(_hashtagDiary ?? []), ...(diaries ?? [])];
              } else if (hyppe == HyppeType.HyppePic) {
                for (final pic in pics ?? []) {
                  interestContents[keys]?.pict?.add(pic);
                }
                // _hashtagPic = [...(_hashtagPic ?? []), ...(pics ?? [])];
              }
              notifyListeners();
            }
          }
        }
        isloadingGetMore = false;
        hasNext = false;
      }
    } catch (e) {
      if (loadIntDetailPic) {
        _loadIntDetailPic = false;
      }
      if (loadIntDetailDiary) {
        _loadIntDetailDiary = false;
      }
      if (loadIntDetailVid) {
        _loadIntDetailVid = false;
      }
      if (hyppe == HyppeType.HyppeVid) {
        _intHasNextVid = false;
      }
      if (hyppe == HyppeType.HyppeDiary) {
        _intHasNextDiary = false;
      }
      if (hyppe == HyppeType.HyppePic) {
        _intHasNextPic = false;
      }
      notifyListeners();

      'Error getDetail: $e'.logger();
    } finally {
      if (loadIntDetailPic) {
        _loadIntDetailPic = false;
      }
      if (loadIntDetailDiary) {
        _loadIntDetailDiary = false;
      }
      if (loadIntDetailVid) {
        _loadIntDetailVid = false;
      }
      if (hyppe == HyppeType.HyppeVid) {
        _intHasNextVid = false;
      }
      if (hyppe == HyppeType.HyppeDiary) {
        _intHasNextDiary = false;
      }
      if (hyppe == HyppeType.HyppePic) {
        _intHasNextPic = false;
      }
      notifyListeners();
    }
  }

  List<Widget> getGridHashtag(String hashtag, bool fromRoute, ScrollController controller, double top) {
    Map<String, List<Widget>> map = {
      'Vid': [
        GridHashtagVid(
          tag: hashtag,
          controller: controller,
          top: top,
        ),
        if ((_detailHashTag?.vid ?? []).length % limitSearch == 0 && (_detailHashTag?.vid ?? []).isNotEmpty && isHasNextVid)
          SliverToBoxAdapter(
            child: Container(margin: EdgeInsets.only(bottom: fromRoute ? 90 : 30), width: double.infinity, height: 40, alignment: Alignment.center, child: const CustomLoading()),
          )
      ],
      'Diary': [
        GridHashtagDiary(
          tag: hashtag,
          controller: controller,
          top: top,
        ),
        if ((_detailHashTag?.diary ?? []).length % limitSearch == 0 && (_detailHashTag?.diary ?? []).isNotEmpty && isHasNextDiary)
          SliverToBoxAdapter(
            child: Container(margin: EdgeInsets.only(bottom: fromRoute ? 90 : 30), width: double.infinity, height: 40, alignment: Alignment.center, child: const CustomLoading()),
          )
      ],
      'Pic': [
        GridHashtagPic(
          tag: hashtag,
          controller: controller,
          top: top,
        ),
        if ((_detailHashTag?.pict ?? []).length % limitSearch == 0 && (_detailHashTag?.pict ?? []).isNotEmpty && isHasNextPic)
          SliverToBoxAdapter(
            child: Container(margin: EdgeInsets.only(bottom: fromRoute ? 90 : 30), width: double.infinity, height: 40, alignment: Alignment.center, child: const CustomLoading()),
          )
      ]
    };
    final key = System().getTitleHyppe(hashtagTab);
    return map[key] ??
        [
          GridHashtagVid(
            tag: hashtag,
            controller: controller,
            top: top,
          ),
          if ((hashtagVid ?? []).length % limitSearch == 0)
            SliverToBoxAdapter(
              child: Container(margin: EdgeInsets.only(bottom: fromRoute ? 90 : 30), width: double.infinity, height: 40, alignment: Alignment.center, child: const CustomLoading()),
            )
        ];
  }

  Future<SearchContentModel?> _hitApiGetDetail(BuildContext context, String keys, TypeApiSearch typeApi, int currentSkip, {HyppeType? type}) async {
    try {
      String email = SharedPreference().readStorage(SpKeys.email);
      var param = <String, dynamic>{};
      if (type != null) {
        param = {
          "email": email,
          "keys": keys,
          "listvid": type == HyppeType.HyppeVid ? true : false,
          "listdiary": type == HyppeType.HyppeDiary ? true : false,
          "listpict": type == HyppeType.HyppePic ? true : false,
          "skip": currentSkip,
          "limit": limitSearch,
        };
      } else {
        param = {
          "email": email,
          "keys": keys,
          "listvid": true,
          "listdiary": true,
          "listpict": true,
          "skip": 0,
          "limit": limitSearch,
        };
      }

      final notifier = SearchContentBloc();
      if (typeApi == TypeApiSearch.detailInterest) {
        await notifier.getDetailContents(context, param, type: typeApi);
      } else {
        await notifier.getSearchContent(context, param, type: typeApi);
      }

      final fetch = notifier.searchContentFetch;
      if (fetch.searchContentState == SearchContentState.getSearchContentBlocSuccess) {
        final _res = SearchContentModel.fromJson(fetch.data[0]);
        return _res;
      } else if (fetch.searchContentState == SearchContentState.getSearchContentBlocError) {
        throw 'getAllDataSearch failed $typeApi';
      } else {
        throw 'undefined';
      }
    } catch (e) {
      'Error _hitApiGetDetail: $e'.logger();
      return null;
    }
  }

  Future<List<ContentData>> getDetailContents(BuildContext context, String keys, HyppeType type, TypeApiSearch api, int limit, {int? skip}) async {
    try {
      loadPlaylist = true;
      String email = SharedPreference().readStorage(SpKeys.email);
      var param = <String, dynamic>{};
      param = {
        "email": email,
        "keys": keys,
        "listvid": type == HyppeType.HyppeVid ? true : false,
        "listdiary": type == HyppeType.HyppeDiary ? true : false,
        "listpict": type == HyppeType.HyppePic ? true : false,
        "skip": skip ?? 0,
        "limit": limit,
      };

      if (api == TypeApiSearch.normal) {
        param['listtag'] = false;
        param['listuser'] = false;
      }

      final notifier = SearchContentBloc();
      await notifier.getDetailContents(context, param, type: api);
      final fetch = notifier.searchContentFetch;
      if (fetch.searchContentState == SearchContentState.getSearchContentBlocSuccess) {
        final _res = SearchContentModel.fromJson(fetch.data[0]);
        return type == HyppeType.HyppePic
            ? (_res.pict ?? [])
            : type == HyppeType.HyppeDiary
                ? (_res.diary ?? [])
                : (_res.vid ?? []);
      } else if (fetch.searchContentState == SearchContentState.getSearchContentBlocError) {
        throw 'getDetailContents failed';
      } else {
        throw 'undefined';
      }
    } catch (e) {
      'Error getDetailContents: $e'.logger();
      return [];
    } finally {
      loadPlaylist = false;
    }
  }

  String _lastKey = '';
  setEmptyLastKey() {
    _lastKey = '';
  }

  Future getDataSearch(BuildContext context, {SearchLoadData typeSearch = SearchLoadData.all, bool reload = true, bool forceLoad = false}) async {
    checkConnection();
    String search = searchController.text;
    if (forceLoad) {
      hitApiSearchData(context, search, typeSearch: typeSearch, reload: reload);
    } else {
      print('result reload: $_lastKey $search');
      if (search.isNotEmpty) {
        if (_lastKey != search) {
          _lastKey = search;
          hitApiSearchData(context, search, typeSearch: typeSearch, reload: reload);
        } else if (forceLoad) {
          hitApiSearchData(context, search, typeSearch: typeSearch, reload: reload);
        }
      } else {
        setEmptyLastKey();
      }
    }
  }

  Future hitApiSearchData(BuildContext context, String search, {SearchLoadData typeSearch = SearchLoadData.all, bool reload = true}) async {
    try {
      final lenghtVid = _searchVid?.length ?? limitSearch;
      final lenghtDiary = _searchDiary?.length ?? limitSearch;
      final lenghtPic = _searchPic?.length ?? limitSearch;
      var skipContent = [lenghtVid, lenghtDiary, lenghtPic].reduce(max);

      final int currentSkip = typeSearch == SearchLoadData.all
          ? 0
          : typeSearch == SearchLoadData.hashtag
              ? (_searchHashtag?.length ?? 0)
              : typeSearch == SearchLoadData.content
                  ? skipContent
                  : typeSearch == SearchLoadData.user
                      ? _searchUsers?.length ?? 0
                      : 0;
      if ((currentSkip != 0 && typeSearch == SearchLoadData.all)) {
        throw 'Error get all because the state is not from beginning $currentSkip';
      } else if (currentSkip % limitSearch != 0) {
        if (!reload) {
          throw 'Error because we have to prevent the action for refusing wasting action';
        }
      }

      if (reload) {
        if (typeSearch == TypeApiSearch.detailHashTag) {
          initAllHasNext();
        }
        isLoading = true;
      }

      String email = SharedPreference().readStorage(SpKeys.email);

      if (search.isHashtag()) {
        search = search.replaceFirst('#', '');
      }
      Map<String, dynamic> param = {};
      if (typeSearch == SearchLoadData.all) {
        focusNode.unfocus();
      }

      switch (typeSearch) {
        case SearchLoadData.all:
          param = {
            "email": email,
            "keys": search,
            "listuser": true,
            "listvid": true,
            "listdiary": true,
            "listpict": true,
            "listtag": true,
            "skip": currentSkip,
            "limit": limitSearch,
          };
          await _hitApiGetSearchData(context, param, typeSearch, reload);
          insertHistory(context, search);
          break;
        case SearchLoadData.user:
          param = {
            "email": email,
            "keys": search,
            "listuser": true,
            "listvid": false,
            "listdiary": false,
            "listpict": false,
            "listtag": false,
            "skip": reload ? 0 : currentSkip,
            "limit": limitSearch,
          };
          await _hitApiGetSearchData(context, param, typeSearch, reload);
          break;
        case SearchLoadData.hashtag:
          param = {
            "email": email,
            "keys": search,
            "listuser": false,
            "listvid": false,
            "listdiary": false,
            "listpict": false,
            "listtag": true,
            "skip": reload ? 0 : currentSkip,
            "limit": limitSearch,
          };
          await _hitApiGetSearchData(context, param, typeSearch, reload);
          break;
        case SearchLoadData.content:
          param = {
            "email": email,
            "keys": search,
            "listuser": false,
            "listvid": true,
            "listdiary": true,
            "listpict": true,
            "listtag": false,
            "skip": currentSkip,
            "limit": limitSearch,
          };
          await _hitApiGetSearchData(context, param, typeSearch, reload);
          break;
      }
    } catch (e) {
      'Error getAllDataSearch: $e'.logger();
    } finally {
      if (reload) {
        isLoading = false;
      }
    }
  }

  Future _hitApiGetSearchData(BuildContext context, Map<String, dynamic> req, SearchLoadData typeSearch, bool reload) async {
    try {
      final notifier = SearchContentBloc();
      print('_hitApiGetSearchData#1 ${context.getCurrentDate()}');
      await notifier.getSearchContent(context, req);
      print('_hitApiGetSearchData ${context.getCurrentDate()}');
      final fetch = notifier.searchContentFetch;
      if (fetch.searchContentState == SearchContentState.getSearchContentBlocSuccess) {
        final _res = SearchContentModel.fromJson(fetch.data[0]);
        switch (typeSearch) {
          case SearchLoadData.all:
            // isHasNextVid = true;
            // isHasNextDiary = true;
            // isHasNextPic = true;
            searchUsers = _res.users;
            searchVid = _res.vid;
            searchDiary = _res.diary;
            searchPic = _res.pict;
            searchHashtag = _res.tags;
            break;
          case SearchLoadData.content:
            final videos = _res.vid ?? [];
            final diaries = _res.diary ?? [];
            final picts = _res.pict ?? [];
            if (videos.isEmpty) {
              isHasNextVid = false;
            } else {
              searchVid = [...(searchVid ?? []), ...videos];
            }
            if (diaries.isEmpty) {
              isHasNextDiary = false;
            } else {
              searchDiary = [...(searchDiary ?? []), ...diaries];
            }
            if (picts.isEmpty) {
              isHasNextPic = false;
            } else {
              searchPic = [...(searchPic ?? []), ...picts];
            }

            break;
          case SearchLoadData.user:
            if (!reload) {
              searchUsers = [...(searchUsers ?? []), ...(_res.users ?? [])];
            } else {
              searchUsers = _res.users;
            }
            break;
          case SearchLoadData.hashtag:
            if (!reload) {
              searchHashtag = [...(searchHashtag ?? []), ...(_res.tags ?? [])];
            } else {
              searchHashtag = _res.tags;
            }

            break;
        }
      } else if (fetch.searchContentState == SearchContentState.getSearchContentBlocError) {
        throw 'getAllDataSearch failed $typeSearch';
      }
    } catch (e) {
      rethrow;
    }
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
    print(index);
    print(selectIndex);
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
            argument: DiaryDetailScreenArgument(diaryData: data, index: index.toDouble(), page: diaryContentsQuery.page, limit: diaryContentsQuery.limit, type: TypePlaylist.search));
      }
      if (selectIndex == 4) {
        context.read<ReportNotifier>().type = 'pict';
        _routing.move(Routes.picSlideDetailPreview,
            argument: SlidedPicDetailScreenArgument(picData: data, index: index.toDouble(), page: picContentsQuery.page, limit: picContentsQuery.limit, type: TypePlaylist.search));
      }
    } else {
      ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
        _routing.moveBack();
        navigateToSeeAllScreen2(context, data, index, selectIndex);
      });
    }
  }

  Future navigateToSeeAllScreen3(BuildContext context, List<ContentData> data, int index, HyppeType type) async {
    context.read<ReportNotifier>().inPosition = contentPosition.search;
    focusNode.unfocus();
    bool connect = await System().checkConnections();
    if (connect) {
      switch (type) {
        case HyppeType.HyppeVid:
          context.read<ReportNotifier>().type = 'vid';
          _routing.move(Routes.vidDetail,
              argument: VidDetailScreenArgument(vidData: data[index])
                ..postID = data[index].postID
                ..backPage = true);
          break;
        case HyppeType.HyppeDiary:
          context.read<ReportNotifier>().type = 'diary';
          _routing.move(Routes.diaryDetail,
              argument: DiaryDetailScreenArgument(diaryData: data, index: index.toDouble(), page: diaryContentsQuery.page, limit: diaryContentsQuery.limit, type: TypePlaylist.search));
          break;
        case HyppeType.HyppePic:
          context.read<ReportNotifier>().type = 'pict';
          _routing.move(Routes.picSlideDetailPreview,
              argument: SlidedPicDetailScreenArgument(picData: data, index: index.toDouble(), page: picContentsQuery.page, limit: picContentsQuery.limit, type: TypePlaylist.search));
      }
    } else {
      ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
        _routing.moveBack();
        navigateToSeeAllScreen3(context, data, index, type);
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
    setEmptyLastKey();
    if (isFromComplete) {
      layout = SearchLayout.searchMore;
      _isFromComplete = false;
    } else {
      layout = SearchLayout.first;
      _isFromComplete = false;
    }
    // _routing.moveBack();
  }

  void backFromSearchMore() {
    searchController1.text = '';
    // setEmptyLastKey();
    // searchController.clear();
    if (layout == SearchLayout.searchMore) {
      layout = SearchLayout.first;
      _isFromComplete = false;
    } else {
      if (isFromComplete) {
        layout = SearchLayout.searchMore;
        _isFromComplete = false;
      } else {
        layout = SearchLayout.first;
        _isFromComplete = false;
      }
    }

    // _routing.moveBack();
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

  void navigateToOtherProfile(BuildContext context, ContentData data) {
    Provider.of<OtherProfileNotifier>(context, listen: false).userEmail = data.email;
    _routing.move(Routes.otherProfile, argument: OtherProfileArgument(senderEmail: data.email));
  }

  void showContentSensitive(BuildContext context, {required String postID, required String content, bool? isReport}) {
    ContentData? _updatedData;
    ContentData? _updatedData2;

    switch (content) {
      case hyppeVid:
        _updatedData = _searchContentFirstPage?.video?.firstWhere((element) => element.postID == postID);
        break;
      case hyppeDiary:
        _updatedData = _searchContentFirstPage?.diary?.firstWhere((element) => element.postID == postID);
        break;
      case hyppePic:
        _updatedData = _searchContentFirstPage?.pict?.firstWhere((element) => element.postID == postID);
        break;
      default:
        "$content It's Not a content of $postID".logger();
        break;
    }

    print('ini postid ${postID}');
    print('ini postid ${content}');
    print('ini postid ${_updatedData?.postID}');

    if (_updatedData != null) {
      _updatedData.reportedStatus = '';
    }
    _updatedData2?.reportedStatus = '';

    notifyListeners();
  }

  int _heightBox = 0;
  int get heightBox => _heightBox;

  int heightIndex = 0;

  set heightBox(val) {
    _heightBox = val;
    notifyListeners();
  }

  bool _loadPlaylist = false;
  bool get loadPlaylist => _loadPlaylist;
  set loadPlaylist(bool state) {
    _loadPlaylist = state;
    notifyListeners();
  }

  scrollAuto(String index) {
    var indexHei = int.parse(index) + 1;
    print(indexHei);
    var hasilBagi = indexHei / 3;
    heightIndex = 0;
    print(hasilBagi);
    if (hasilBagi.isInteger()) {
      hasilBagi = hasilBagi;
    } else {
      hasilBagi += 1;
    }
    print("========== height box ${heightBox}");
    print("========== height box ${hasilBagi.toInt()}");
    heightIndex = (heightBox * hasilBagi.toInt() - heightBox);
    print("========== height box ${heightIndex}");
  }

  navigateToSeeAllScreen4(
      BuildContext context, List<ContentData> data, int index, HyppeType type, TypeApiSearch api, String keys, PageSrc pageSrc, ScrollController controller, double heightBox, double heightTop) async {
    context.read<ReportNotifier>().inPosition = contentPosition.myprofile;
    final connect = await System().checkConnections();
    if (connect) {
      var result;
      loadNavigate = true;

      switch (type) {
        case HyppeType.HyppePic:
          final pics = await getDetailContents(context, keys, type, api, data.length);
          if (pageSrc == PageSrc.searchData) {
            searchPic = pics;
          } else if (pageSrc == PageSrc.hashtag) {
            mapDetailHashtag[keys]?.pict = pics;
          } else if (pageSrc == PageSrc.interest) {
            interestContents[keys]?.pict = pics;
          }
          result = await _routing.move(Routes.scrollPic,
              argument: SlidedPicDetailScreenArgument(
                  page: index,
                  type: TypePlaylist.search,
                  titleAppbar: pageSrc == PageSrc.hashtag
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomTextWidget(
                              textToDisplay: language.topPic ?? 'Top Pic',
                              textStyle: TextStyle(fontSize: 10, color: kHyppeBurem),
                            ),
                            fourPx,
                            Text(
                              "#$keys",
                              style: TextStyle(color: kHyppeTextLightPrimary),
                            )
                          ],
                        )
                      : const Text(
                          "Pic",
                          style: TextStyle(color: kHyppeTextLightPrimary),
                        ),
                  pageSrc: pageSrc,
                  picData: pics,
                  key: keys,
                  heightBox: heightBox,
                  heightTopProfile: heightTop,
                  scrollController: controller));
          // _routing.move(Routes.picSlideDetailPreview,
          //     argument: SlidedPicDetailScreenArgument(picData: user.pics, index: index.toDouble(), page: picContentsQuery.page, limit: picContentsQuery.limit, type: TypePlaylist.mine));
          if (result != null) {
            scrollAuto(result);
          }
          loadNavigate = false;
          break;
        case HyppeType.HyppeDiary:
          final diaries = await getDetailContents(context, keys, type, api, data.length);
          if (pageSrc == PageSrc.searchData) {
            searchDiary = diaries;
          } else if (pageSrc == PageSrc.hashtag) {
            mapDetailHashtag[keys]?.diary = diaries;
          } else if (pageSrc == PageSrc.interest) {
            interestContents[keys]?.diary = diaries;
          }
          result = await _routing.move(Routes.scrollDiary,
              argument: SlidedDiaryDetailScreenArgument(
                  page: index,
                  type: TypePlaylist.search,
                  titleAppbar: pageSrc == PageSrc.hashtag
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomTextWidget(
                              textToDisplay: language.topDiaty ?? 'Top Diary',
                              textStyle: TextStyle(fontSize: 10, color: kHyppeBurem),
                            ),
                            fourPx,
                            Text(
                              "#$keys",
                              style: TextStyle(color: kHyppeTextLightPrimary),
                            )
                          ],
                        )
                      : const Text(
                          "Diary",
                          style: TextStyle(color: kHyppeTextLightPrimary),
                        ),
                  pageSrc: pageSrc,
                  diaryData: diaries,
                  key: keys,
                  heightBox: heightBox,
                  heightTopProfile: heightTop,
                  scrollController: controller));
          // _routing.move(Routes.diaryDetail,
          //     argument: DiaryDetailScreenArgument(diaryData: user.diaries, index: index.toDouble(), page: diaryContentsQuery.page, limit: diaryContentsQuery.limit, type: TypePlaylist.mine));
          if (result != null) {
            scrollAuto(result);
          }
          loadNavigate = false;
          break;
        case HyppeType.HyppeVid:
          final vids = await getDetailContents(context, keys, type, api, data.length);
          if (pageSrc == PageSrc.searchData) {
            searchVid = vids;
          } else if (pageSrc == PageSrc.hashtag) {
            mapDetailHashtag[keys]?.vid = vids;
          } else if (pageSrc == PageSrc.interest) {
            interestContents[keys]?.vid = vids;
          }
          result = await _routing.move(Routes.scrollVid,
              argument: SlidedVidDetailScreenArgument(
                  page: index,
                  type: TypePlaylist.search,
                  titleAppbar: pageSrc == PageSrc.hashtag
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomTextWidget(
                              textToDisplay: language.topVid ?? 'Top Vic',
                              textStyle: TextStyle(fontSize: 10, color: kHyppeBurem),
                            ),
                            fourPx,
                            Text(
                              "#$keys",
                              style: TextStyle(color: kHyppeTextLightPrimary),
                            )
                          ],
                        )
                      : const Text(
                          "Vid",
                          style: TextStyle(color: kHyppeTextLightPrimary),
                        ),
                  pageSrc: pageSrc,
                  vidData: vids,
                  key: keys,
                  heightBox: heightBox,
                  heightTopProfile: heightTop,
                  scrollController: controller));
          // result = await _routing.move(Routes.vidDetail, argument: VidDetailScreenArgument(vidData: user.vids?[index]));
          if (result != null) {
            scrollAuto(result);
          }
          loadNavigate = false;
          break;
      }
    } else {
      connectionError = !connect;
    }
  }
}
