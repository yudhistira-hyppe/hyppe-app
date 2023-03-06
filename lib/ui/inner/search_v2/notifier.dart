import 'dart:math';

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

  List paramSearch = ['all', 'listuser', 'listvid', 'listdiary'];

  int _tabIndex = 0;
  int get tabIndex => _tabIndex;

  int _limit = 0;
  int get limit => _limit;

  List<SearchPeolpleData>? _searchPeolpleData = [];
  List<SearchPeolpleData>? get searchPeolpleData => _searchPeolpleData;

  SearchContentModel? _searchContent;
  SearchContentModel? get searchContent => _searchContent;

  // bool _loadingSearch = true;
  // bool get loadingSearch => _loadingSearch;
  // set loadingSearch(bool state){
  //   _loadingSearch = state;
  //   notifyListeners();
  // }

  List<ContentData>? _searchVid;
  List<ContentData>? get searchVid => _searchVid;

  set searchVid(List<ContentData>? values){
    _searchVid = values;
    notifyListeners();
  }

  List<ContentData>? _searchDiary;
  List<ContentData>? get searchDiary => _searchDiary;

  set searchDiary(List<ContentData>? values){
    _searchDiary = values;
    notifyListeners();
  }

  List<ContentData>? _searchPic;
  List<ContentData>? get searchPic => _searchPic;

  set searchPic(List<ContentData>? values){
    _searchPic = values;
    notifyListeners();
  }

  List<Tags>? _searchHashtag;
  List<Tags>? get searchHashtag => _searchHashtag;

  set searchHashtag(List<Tags>? values){
    _searchHashtag = values;
    notifyListeners();
  }

  List<DataUser>? _searchUsers;
  List<DataUser>? get searchUsers => _searchUsers;

  set searchUsers(List<DataUser>? values){
    _searchUsers = values;
    notifyListeners();
  }

  SearchContentModel? _detailHashTag;
  SearchContentModel? get detailHashTag => _detailHashTag;
  set detailHashTag(SearchContentModel? val){
    _detailHashTag = val;
    notifyListeners();
  }

  SearchContentModel? _detailInterest;
  SearchContentModel? get detailInterest => _detailInterest;
  set detailInterest(SearchContentModel? val){
    _detailInterest = val;
    notifyListeners();
  }


  AllContents? _searchContentFirstPage;
  AllContents? get searchContentFirstPage => _searchContentFirstPage;

  bool _isLoading = true;
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

  set loadLandingPage(bool state){
    _loadLandingPage = state;
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

  set listInterest(List<Interest>? values){
    _listInterest = values;
    notifyListeners();
  }

  Map<String, SearchContentModel> _interestContents = {};
  Map<String, SearchContentModel> get interestContents => _interestContents;

  set interestContents(Map<String, SearchContentModel> values){
    _interestContents = values;
    notifyListeners();
  }

  Tags? _selectedHashtag;
  Tags? get selectedHashtag => _selectedHashtag;
  set selectedHashtag(Tags? data){
    _selectedHashtag = data;
    notifyListeners();
  }

  Interest? _selectedInterest;
  Interest? get selectedInterest => _selectedInterest;
  set selectedInterest(Interest? val){
    _selectedInterest = val;
    notifyListeners();
  }


  Future onSearchLandingPage(BuildContext context) async{
    try{
      loadLandingPage = true;
      final notifier = SearchContentBloc();
      await notifier.landingPageSearch(context);
      final fetch = notifier.searchContentFetch;
      if (fetch.searchContentState == SearchContentState.getSearchContentBlocSuccess) {
        LandingSearch res = LandingSearch.fromJson(fetch.data);
        listHashtag = res.tag ?? [];
        listInterest = res.interest ?? [];
      }else{
        throw 'Failed landing page search execution';
      }
    }catch(e){
      'Error onSearchLandingPage: $e'.logger();
    }finally{
      loadLandingPage = false;
      try{
        if(listInterest != null){
          if(listInterest!.isNotEmpty){
            await for(final value in getInterest(context, listInterest! )){
              final id = value?.interests?[0].id ?? '613bc4da9ec319617aa6c38e';
              if(value != null){
                interestContents[id] = value;
              }
            }
            notifyListeners();
          }
        }
      }catch(e){
        'Error Get Interest Contests'.logger();
      }

    }
  }

  Stream<SearchContentModel?> getInterest(BuildContext context, List<Interest> interests) async*{
    for(final interest in interests){
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
  set layout(SearchLayout val){
    _layout = val;
    notifyListeners();
  }

  startLayout(){
    _layout = SearchLayout.first;
  }

  HyppeType _contentTab = HyppeType.HyppeVid;
  HyppeType get contentTab => _contentTab;
  set contentTab(HyppeType type){
    _contentTab = type;
    notifyListeners();
  }

  HyppeType _hashtagTab = HyppeType.HyppeVid;
  HyppeType get hashtagTab => _hashtagTab;
  set hashtagTab(HyppeType type){
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

  Future onInitialSearchNew(BuildContext context, FeatureType featureType, {bool reload = false}) async {
    focusNode.unfocus();
    _layout = SearchLayout.first;
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

  // onScrollListener(BuildContext context, ScrollController scrollController) async {
  //   if (scrollController.offset >= scrollController.position.maxScrollExtent && !scrollController.position.outOfRange) {
  //     String email = SharedPreference().readStorage(SpKeys.email);
  //     String search = searchController.text;
  //     focusNode.unfocus();
  //     Map param = {};
  //     if (tabIndex == 1) {
  //       _skip = _skip1;
  //     }
  //     if (tabIndex == 2) {
  //       _skip = _skip2;
  //     }
  //     if (tabIndex == 3) {
  //       _skip = _skip3;
  //     }
  //     if (tabIndex == 4) {
  //       _skip = _skip4;
  //     }
  //     param = {
  //       "email": email,
  //       "keys": search,
  //       "listuser": tabIndex == 0 || tabIndex == 1 ? true : false,
  //       "listvid": tabIndex == 0 || tabIndex == 2 ? true : false,
  //       "listdiary": tabIndex == 0 || tabIndex == 3 ? true : false,
  //       "listpict": tabIndex == 0 || tabIndex == 4 ? true : false,
  //       "skip": _skip,
  //       "limit": _limit,
  //     };
  //
  //     final notifier = SearchContentBloc();
  //     await notifier.getSearchContent(context, param);
  //     final fetch = notifier.searchContentFetch;
  //     if (fetch.searchContentState == SearchContentState.getSearchContentBlocSuccess) {
  //       SearchContentModel _res = SearchContentModel.fromJson(fetch.data[0]);
  //       if (tabIndex == 1) {
  //         _skip1 += _limit;
  //         _searchContent?.users?.addAll(_res.users ?? []);
  //       }
  //       if (tabIndex == 2) {
  //         _skip2 += _limit;
  //         _searchContent?.vid = [...(_searchContent?.vid ?? []), ...(_res.vid ?? [])];
  //       }
  //       if (tabIndex == 3) {
  //         _skip3 += _limit;
  //         _searchContent?.diary = [...(_searchContent?.diary ?? []), ...(_res.diary ?? [])];
  //       }
  //       if (tabIndex == 4) {
  //         _skip4 += _limit;
  //         _searchContent?.pict = [...(_searchContent?.pict ?? []), ...(_res.pict ?? [])];
  //       }
  //     }
  //
  //     notifyListeners();
  //   }
  // }

  // void onSearchPost(
  //   BuildContext context, {
  //   String? value,
  //   int skip = 0,
  //   bool isMove = false,
  // }) async {
  //   if (isMove) {
  //     // _routing.moveReplacement(Routes.searcMoreComplete);
  //     layout = SearchLayout.searchMore;
  //     _tab1 = 0;
  //     _tab2 = 0;
  //     _tab3 = 0;
  //     _tab4 = 0;
  //     _skip1 = 0;
  //     _skip2 = 0;
  //     _skip3 = 0;
  //     _skip4 = 0;
  //   }
  //   if (!isMove && tabIndex == 0 && _searchContent != null) {
  //     return;
  //   }
  //   if (!isMove && tabIndex == 1 && _searchContent?.users != null && _tab1 > 1) {
  //     return;
  //   }
  //   if (!isMove && tabIndex == 2 && _searchContent?.vid != null && _tab2 > 1) {
  //     return;
  //   }
  //   if (!isMove && tabIndex == 3 && _searchContent?.diary != null && _tab3 > 1) {
  //     return;
  //   }
  //   if (!isMove && tabIndex == 4 && _searchContent?.pict != null && _tab4 > 1) {
  //     return;
  //   }
  //   final notifier = SearchContentBloc();
  //   String email = SharedPreference().readStorage(SpKeys.email);
  //   String search = value ?? searchController.text;
  //   Map param = {};
  //
  //   focusNode.unfocus();
  //
  //   isLoading = true;
  //   // _searchContent = null;
  //
  //   param = {
  //     "email": email,
  //     "keys": search,
  //     "listuser": tabIndex == 0 || tabIndex == 1 ? true : false,
  //     "listvid": tabIndex == 0 || tabIndex == 2 ? true : false,
  //     "listdiary": tabIndex == 0 || tabIndex == 3 ? true : false,
  //     "listpict": tabIndex == 0 || tabIndex == 4 ? true : false,
  //     "listtag": tabIndex == 0 || tabIndex == 5 ? true : false,
  //     "skip": skip,
  //     "limit": _limit,
  //   };
  //   await notifier.getSearchContent(context, param);
  //   final fetch = notifier.searchContentFetch;
  //   if (fetch.searchContentState == SearchContentState.getSearchContentBlocSuccess) {
  //     final _res = SearchContentModel.fromJson(fetch.data[0]);
  //
  //     if (tabIndex == 0) {
  //       _searchContent = _res;
  //     }
  //     if (tabIndex == 1) {
  //       _searchContent?.users = [];
  //       _searchContent?.users?.addAll(_res.users ?? []);
  //       _skip1 += _limit;
  //     }
  //     if (tabIndex == 2) {
  //       _searchContent?.vid = [];
  //       _searchContent?.vid = [...(_searchContent?.vid ?? []), ...(_res.vid ?? [])];
  //       _skip2 += _limit;
  //     }
  //     if (tabIndex == 3) {
  //       _searchContent?.diary = [];
  //       _searchContent?.diary = [...(_searchContent?.diary ?? []), ...(_res.diary ?? [])];
  //       _skip3 += _limit;
  //     }
  //     if (tabIndex == 4) {
  //       _searchContent?.pict = [];
  //       _searchContent?.pict = [...(_searchContent?.pict ?? []), ...(_res.pict ?? [])];
  //       _skip4 += _limit;
  //     }
  //   }
  //   // else {
  //   // _searchContent = null;
  //   // }
  //   isLoading = false;
  //   notifyListeners();
  // }

  void getDetail(BuildContext context, String keys, TypeApiSearch type, {reload = true}) async{
    try{
      isLoading = true;
      List<ContentData> currentVid = [];
      List<ContentData> currentDairy = [];
      List<ContentData> currentPic = [];
      int currentSkip = 0;
      if(!reload){
        if(type == TypeApiSearch.detailHashTag){
          currentVid = detailHashTag?.vid ?? [];
          currentDairy = detailHashTag?.diary ?? [];
          currentPic = detailHashTag?.pict ?? [];
          final lenghtVid = currentVid.length;
          final lenghtDiary = currentDairy.length;
          final lenghtPic = currentPic.length;
          currentSkip = [lenghtVid, lenghtDiary, lenghtPic].reduce(max);
        }else if(type == TypeApiSearch.detailInterest){
          currentVid = detailInterest?.vid ?? [];
          currentDairy = detailInterest?.diary ?? [];
          currentPic = detailInterest?.pict ?? [];
          final lenghtVid = currentVid.length;
          final lenghtDiary = currentDairy.length;
          final lenghtPic = currentPic.length;
          currentSkip = [lenghtVid, lenghtDiary, lenghtPic].reduce(max);
        }
        if(currentSkip%12 != 0){
          throw 'hitApiGetDetail : preventing api because the system must reduce useless action';
        }
      }
      final _res = await _hitApiGetDetail(context, keys, type, currentSkip);
      if(_res != null){
        final videos = _res.vid;
        final diaries = _res.diary;
        final pics = _res.diary;
        if(type == TypeApiSearch.detailHashTag){
          if(!reload){
            detailHashTag?.vid = [...currentVid, ...(videos ?? [])];
            detailHashTag?.diary = [...currentDairy, ...(diaries ?? [])];
            detailHashTag?.pict = [...currentPic, ...(pics ?? [])];
          }else{
            detailHashTag = _res;
          }
        }else if(type == TypeApiSearch.detailInterest){
          if(!reload){
            detailInterest?.vid = [...currentVid, ...(videos ?? [])];
            detailInterest?.diary = [...currentDairy, ...(diaries ?? [])];
            detailInterest?.pict = [...currentPic, ...(pics ?? [])];
          }else{
            detailInterest = _res;
          }
        }
      }

    }catch(e){
      'Error getDetail: $e'.logger();
    }finally{
      isLoading = false;
    }
  }

  Future<SearchContentModel?> _hitApiGetDetail(BuildContext context, String keys, TypeApiSearch typeApi, int currentSkip) async{
    try{
      String email = SharedPreference().readStorage(SpKeys.email);

      final param = {
        "email": email,
        "keys": keys,
        "listvid": true,
        "listdiary": true,
        "listpict": true,
        "skip": currentSkip,
        "limit": 12,
      };
      final notifier = SearchContentBloc();
      await notifier.getSearchContent(context, param, type: typeApi);
      final fetch = notifier.searchContentFetch;
      if (fetch.searchContentState == SearchContentState.getSearchContentBlocSuccess) {
        final _res = SearchContentModel.fromJson(fetch.data[0]);
        return _res;
      }else if(fetch.searchContentState == SearchContentState.getSearchContentBlocError){
        throw 'getAllDataSearch failed $typeApi';
      }else{
        throw 'undefined';
      }
    }catch(e){
      'Error _hitApiGetDetail: $e'.logger();
      return null;
    }
  }

  void getDataSearch(
      BuildContext context, {SearchLoadData typeSearch = SearchLoadData.all}) async {
    isLoading = true;


    try{

      String email = SharedPreference().readStorage(SpKeys.email);
      String search = searchController.text;
      if(search.isHashtag()){
        search = search.replaceFirst('#', '');
      }
      Map<String, dynamic> param = {};
      if(typeSearch == SearchLoadData.all){
        focusNode.unfocus();
      }

      const _slimit = 12;
      final lenghtVid = _searchVid?.length ?? 12;
      final lenghtDiary = _searchDiary?.length ?? 12;
      final lenghtPic = _searchPic?.length ?? 12;


      // _searchContent = null;
      var skipContent = [lenghtVid, lenghtDiary, lenghtPic].reduce(max);

      final int currentSkip = typeSearch == SearchLoadData.all ? 0 :
      typeSearch == SearchLoadData.hashtag ? (_searchHashtag?.length ?? 0) :
      typeSearch == SearchLoadData.content ? skipContent :
      typeSearch == SearchLoadData.user ? _searchUsers?.length ?? 0 : 0;
      if((currentSkip != 0 && typeSearch != SearchLoadData.all) || (currentSkip != 0 && typeSearch != SearchLoadData.user) || (currentSkip != 0 && typeSearch != SearchLoadData.hashtag)){
        throw 'Error get all because the state is not from beginning';
      }else if(currentSkip%_slimit != 0){
        throw 'Error because we have to prevent the action for refusing wasting action';
      }
      switch(typeSearch){
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
            "limit": _slimit,
          };
          await  _hitApiGetSearchData(context, param, typeSearch);
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
            "skip": currentSkip,
            "limit": _slimit,
          };
          await  _hitApiGetSearchData(context, param, typeSearch);
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
            "skip": currentSkip,
            "limit": _slimit,
          };
          await  _hitApiGetSearchData(context, param, typeSearch);
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
            "limit": _slimit,
          };
          await  _hitApiGetSearchData(context, param, typeSearch);
          break;

      }


      isLoading = false;
    }catch(e){
      isLoading = false;
      'Error getAllDataSearch: $e'.logger();
    }finally{

    }

  }

  Future _hitApiGetSearchData(BuildContext context, Map<String, dynamic> req, SearchLoadData typeSearch) async{
    try{
      final notifier = SearchContentBloc();
      await notifier.getSearchContent(context, req);
      final fetch = notifier.searchContentFetch;
      if (fetch.searchContentState == SearchContentState.getSearchContentBlocSuccess) {
        final _res = SearchContentModel.fromJson(fetch.data[0]);
        switch(typeSearch){
          case SearchLoadData.all:
            searchUsers = _res.users;
            searchVid = _res.vid;
            searchDiary = _res.diary;
            searchPic = _res.pict;
            searchHashtag = _res.tags;
            break;
          case SearchLoadData.content:
            searchVid = [...(searchVid ?? []), ...(_res.vid ?? [])];
            searchDiary = [...(searchDiary ?? []), ...(_res.diary ?? [])];
            searchPic = [...(searchPic ?? []), ...(_res.pict ?? [])];
            break;
          case SearchLoadData.user:
            if((searchUsers ?? []).contains(_res.users) && searchUsers?.length == 12){
              searchUsers = [...(searchUsers ?? []), ...(_res.users ?? [])];
            }else{
              searchUsers = _res.users;
            }
            break;
          case SearchLoadData.hashtag:
            if((searchHashtag ?? []).contains(_res.tags) && searchHashtag?.length == 12){
              searchHashtag = [...(searchHashtag ?? []), ...(_res.tags ?? [])];
            }else{
              searchHashtag = _res.tags;
            }

            break;
        }

      }else if(fetch.searchContentState == SearchContentState.getSearchContentBlocError){
        throw 'getAllDataSearch failed $typeSearch';
      }
    }catch(e){
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

  void moveSearchMore() {
    print('kesini seacrhmore');
    focusNode1.unfocus();
    focusNode1.canRequestFocus = false;
    _routing.move(Routes.searcMore);
  }

  void backPage() {
    searchController1.clear();
    layout = SearchLayout.first;
    // _routing.moveBack();
  }

  void backFromSearchMore() {
    searchController1.text = '';
    searchController.clear();
    layout = SearchLayout.first;
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
    if (_updatedData2 != null) {
      _updatedData2.reportedStatus = '';
    }

    notifyListeners();
  }
}
