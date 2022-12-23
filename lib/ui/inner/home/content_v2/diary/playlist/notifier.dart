import 'dart:convert';
import 'dart:math';
import 'package:hyppe/core/arguments/contents/diary_detail_screen_argument.dart';
import 'package:hyppe/core/arguments/follow_user_argument.dart';
import 'package:hyppe/core/bloc/follow/bloc.dart';
import 'package:hyppe/core/bloc/follow/state.dart';
import 'package:hyppe/core/bloc/posts_v2/bloc.dart';
import 'package:hyppe/core/bloc/posts_v2/state.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/utils/dynamic_link/dynamic_link.dart';
import 'package:hyppe/core/query_request/contents_data_query.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/entities/general_mixin/general_mixin.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/preview/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:provider/provider.dart';

import 'package:story_view/story_view.dart';

import '../../../../../../core/bloc/ads_video/bloc.dart';
import '../../../../../../core/bloc/ads_video/state.dart';
import '../../../../../../core/models/collection/advertising/ads_video_data.dart';
import '../../../../../../core/models/collection/localization_v2/localization_model.dart';
import '../../profile/other_profile/notifier.dart';
import '../../profile/self_profile/notifier.dart';

class DiariesPlaylistNotifier with ChangeNotifier, GeneralMixin {
  final _sharedPrefs = SharedPreference();
  ContentsDataQuery contentsQuery = ContentsDataQuery()
    ..page = 2
    ..limit = 5
    ..featureType = FeatureType.diary;

  LocalizationModelV2 language = LocalizationModelV2();
  translate(LocalizationModelV2 translate) {
    language = translate;
    notifyListeners();
  }

  DiaryDetailScreenArgument? _routeArgument;
  List<ContentData>? _listData;
  int _currentDiary = 0;
  double? _currentPage = 0;
  bool _forcePause = false;

  AdsData _adsData = AdsData();
  AdsData get adsData => _adsData;
  String _adsUrl = '';
  String get adsUrl => _adsUrl;

  bool _isSponsored = false;
  bool get isSponsored => _isSponsored;

  List<ContentData>? get listData => _listData;
  int get currentDiary => _currentDiary;
  double? get currentPage => _currentPage;
  bool get forcePause => _forcePause;

  List<StoryItem> _result = [];
  List<StoryItem> get result => _result;

  bool _isLoadMine = false;
  bool _isLoadOther = false;
  bool _isLoadSearch = false;

  setCurrentDiary(int val) => _currentDiary = val;

  set currentPage(double? val) {
    _currentPage = val;
    notifyListeners();
  }

  set forcePause(bool val) {
    _forcePause = val;
    notifyListeners();
  }

  set listData(List<ContentData>? val) {
    _listData = val;
    notifyListeners();
  }

  set result(List<StoryItem> val) {
    _result = val;
    notifyListeners();
  }

  ////////////////////////////////////////////////////////
  void onUpdate() => notifyListeners();

  Future initAdsData(BuildContext context) async {
    _adsUrl = '';
    final count = context.getAdsCount();
    String? urlAds;

    if (count == null) {
      context.setAdsCount(0);
    } else {
      if (count == 2) {
        'type ads : Sponsored Ads'.logger();
        _isSponsored = true;
        urlAds = await getAdsVideo(context, false);
      }
    }
    if (urlAds != null) {
      _adsUrl = urlAds;
    }
  }

  Future initializeData(BuildContext context, StoryController storyController, ContentData data) async {
    _result = [];
    String urlApsara = '';

    initAdsData(context);

    if (data.isApsara ?? false) {
      await getVideoApsara(context, data.apsaraId ?? '').then((value) {
        if(value != null){
          urlApsara = value;
        }
      });
    }
    _result.add(
      StoryItem.pageVideo(
        urlApsara != '' ? urlApsara : data.fullContentPath ?? '',
        // 'https://multiplatform-f.akamaihd.net/i/multi/will/bunny/big_buck_bunny_,640x360_400,640x360_700,640x360_1000,950x540_1500,.f4v.csmil/master.m3u8',
        requestHeaders: {
          'post-id': data.postID ?? '',
          'x-auth-user': _sharedPrefs.readStorage(SpKeys.email),
          'x-auth-token': _sharedPrefs.readStorage(SpKeys.userToken),
        },
        controller: storyController,
        duration: Duration(seconds: data.metadata?.duration ?? 15),
      ),
    );
    notifyListeners();
  }

  Future getVideoApsara(BuildContext context, String apsaraId) async {
    try {
      final notifier = PostsBloc();
      await notifier.getVideoApsaraBlocV2(context, apsaraId: apsaraId);

      final fetch = notifier.postsFetch;

      if (fetch.postsState == PostsState.videoApsaraSuccess) {
        Map jsonMap = json.decode(fetch.data.toString());
        return jsonMap['PlayUrl'].toString();
      }
    } catch (e) {
      'Failed to fetch ads data ${e}'.logger();
      return '';
    }
  }

  Future<String?> getAdsVideo(BuildContext context, bool isContent) async {
    try {
      final notifier = AdsDataBloc();
      await notifier.adsVideoBloc(context, isContent);
      final fetch = notifier.adsDataFetch;

      if (fetch.adsDataState == AdsDataState.getAdsVideoBlocSuccess) {
        // print('data : ${fetch.data.toString()}');
        final _newClipData = fetch.data;
        _adsData = _newClipData.data;
        return await getAdsVideoApsara(context, _newClipData.data.videoId ?? '');
      }
    } catch (e) {
      'Failed to fetch ads data $e'.logger();
    }
    return null;
  }

  Future<String?> getAdsVideoApsara(BuildContext context, String apsaraId) async {
    try {
      final notifier = PostsBloc();
      await notifier.getVideoApsaraBlocV2(context, apsaraId: apsaraId);

      final fetch = notifier.postsFetch;

      if (fetch.postsState == PostsState.videoApsaraSuccess) {
        Map jsonMap = json.decode(fetch.data.toString());
        'jsonMap video Apsara : $jsonMap'.logger();
        return jsonMap['PlayUrl'];
      }
    } catch (e) {
      'Failed to fetch ads data ${e}'.logger();
    }
    return null;
  }

  double degreeToRadian(double deg) => deg * pi / 180;

  void onWillPop(bool mounted) {
    if (mounted) {
      if (_routeArgument?.postID != null && _routeArgument?.backPage == false) {
        'ada postid'.logger();
        Routing().moveAndPop(Routes.lobby);
      } else {
        'tanpa postid'.logger();
        Routing().moveBack();
      }
    }
  }

  onNextPage({
    required BuildContext context,
    required ContentData data,
    required bool mounted,
  }) {
    // onWillPop(mounted);
    // System().increaseViewCount(context, data).whenComplete(() => notifyListeners());
    System().increaseViewCount(context, data);
  }

  void initState(BuildContext context, DiaryDetailScreenArgument routeArgument) {
    _routeArgument = routeArgument;
    _currentPage = _routeArgument?.index;

    if (_routeArgument?.postID != null) {
      _initialDiary(context);
    } else {
      _listData = _routeArgument?.diaryData;
      contentsQuery.limit = _routeArgument?.limit ?? 5;
      contentsQuery.page = _routeArgument?.page ?? 2;
      _listData.logger();
      notifyListeners();
    }
  }

  Future<void> _initialDiary(
    BuildContext context,
  ) async {
    Future<List<ContentData>> _resFuture;

    contentsQuery.postID = _routeArgument?.postID;

    try {
      'reload contentsQuery : 3'.logger();
      _resFuture = contentsQuery.reload(context);
      final res = await _resFuture;
      _listData = res;
      notifyListeners();
      _followUser(context);
    } catch (e) {
      'load diary: ERROR: $e'.logger();
    }
  }

  Future<void> nextPlaylistDiary(BuildContext context, int value) async {
    print('onPageChanged Image : masuk');
    if (_routeArgument?.type == TypePlaylist.landingpage && (listData?.length ?? 0) % (contentsQuery.limit) == 0) {
      if (value == ((listData?.length ?? 0) - 1)) {
        print('onPageChanged Image : masuk');
        try {
          final values = await contentsQuery.loadNext(context, isLandingPage: true);
          if (values.isNotEmpty) {
            listData = [...(listData ?? []) as List<ContentData>] + values;
            final prev = context.read<PreviewDiaryNotifier>();
            prev.initialDiary(context, list: values);
          }
        } catch (e) {
          'TypePlaylist.landingpage nextload error : $e'.logger();
        }
      }
    } else if (_routeArgument?.type == TypePlaylist.search) {
      if (!_isLoadSearch) {
        if (value >= ((listData?.length ?? 0) - 6)) {
          try {
            _isLoadSearch = true;
          } catch (e) {
            'TypePlaylist.search nextload error : $e'.logger();
          } finally {
            _isLoadSearch = false;
          }
        }
      }
    } else if (_routeArgument?.type == TypePlaylist.mine && (listData?.length ?? 0) % (contentsQuery.limit) == 0) {
      if (!_isLoadMine) {
        if (value >= ((listData?.length ?? 0) - 6)) {
          try {
            _isLoadMine = true;
            final values = await contentsQuery.loadNext(context, myContent: true);
            if (values.isNotEmpty) {
              listData = [...(listData ?? []) as List<ContentData>] + values;
              final prev = context.read<SelfProfileNotifier>();
              prev.user.diaries = [...(prev.user.diaries ?? []), ...values];
            }
          } catch (e) {
            'TypePlaylist.mine nextload error : $e'.logger();
          } finally {
            _isLoadMine = false;
          }
        }
      }
    } else if (_routeArgument?.type == TypePlaylist.other && (listData?.length ?? 0) % (contentsQuery.limit) == 0) {
      if (!_isLoadOther) {
        if (value >= ((listData?.length ?? 0) - 6)) {
          try {
            _isLoadOther = true;
            final values = await contentsQuery.loadNext(context, otherContent: true);
            if (values.isNotEmpty) {
              listData = [...(listData ?? []) as List<ContentData>] + values;
              final prev = context.read<OtherProfileNotifier>();
              prev.user.diaries = [...(prev.user.diaries ?? []), ...values];
            }
          } catch (e) {
            'TypePlaylist.other nextload error : $e'.logger();
          } finally {
            _isLoadOther = false;
          }
        }
      }
    }
  }

  Future<void> createdDynamicLink(
    context, {
    ContentData? data,
  }) async {
    forcePause = true;
    await createdDynamicLinkMixin(
      context,
      data: DynamicLinkData(
        routes: Routes.diaryDetail,
        postID: data?.postID,
        fullName: data?.username,
        description: 'Hyppe Diary',
        thumb: '${data?.fullThumbPath}',
      ),
      copiedToClipboard: false,
    );
  }

  Future _followUser(BuildContext context) async {
    if (_sharedPrefs.readStorage(SpKeys.email) != _listData?.single.email) {
      try {
        final notifier = FollowBloc();
        await notifier.followUserBlocV2(
          context,
          data: FollowUserArgument(
            eventType: InteractiveEventType.following,
            receiverParty: _listData?.single.email ?? '',
          ),
        );
        final fetch = notifier.followFetch;
        if (fetch.followState == FollowState.followUserSuccess) {
          'follow user success'.logger();
        } else {
          'follow user failed'.logger();
        }
      } catch (e) {
        'follow user: ERROR: $e'.logger();
      }
    }
  }

  void showContentSensitive(postID) {
    ContentData? _updatedData;
    _updatedData = _listData?.firstWhere((element) => element.postID == postID);

    if (_updatedData != null) {
      _updatedData.reportedStatus = '';
    }
    notifyListeners();
  }
}
