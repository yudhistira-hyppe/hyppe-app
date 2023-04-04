import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/extension/custom_extension.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';

import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:hyppe/core/services/system.dart';

import 'package:hyppe/core/constants/enum.dart';

import 'package:hyppe/core/bloc/follow/bloc.dart';
import 'package:hyppe/core/bloc/follow/state.dart';

import 'package:hyppe/core/extension/log_extension.dart';

import 'package:hyppe/core/query_request/users_data_query.dart';
import 'package:hyppe/core/query_request/contents_data_query.dart';

import 'package:hyppe/ui/constant/entities/general_mixin/general_mixin.dart';

import 'package:hyppe/core/arguments/follow_user_argument.dart';
import 'package:hyppe/core/arguments/contents/pic_detail_screen_argument.dart';

import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/models/collection/utils/dynamic_link/dynamic_link.dart';
import 'package:provider/provider.dart';
import 'package:story_view/controller/story_controller.dart';

import '../../../../../../../core/arguments/contents/slided_pic_detail_screen_argument.dart';
import '../../../../../../../core/bloc/ads_video/bloc.dart';
import '../../../../../../../core/bloc/ads_video/state.dart';
import '../../../../../../../core/bloc/posts_v2/bloc.dart';
import '../../../../../../../core/bloc/posts_v2/state.dart';
import '../../../../../../../core/models/collection/advertising/ads_video_data.dart';
import '../../../profile/other_profile/notifier.dart';
import '../../../profile/self_profile/notifier.dart';
import '../../notifier.dart';

class SlidedPicDetailNotifier with ChangeNotifier, GeneralMixin {
  // final _system = System();
  final _sharedPrefs = SharedPreference();
  ScrollController scrollController = ScrollController();
  ContentsDataQuery contentsQuery = ContentsDataQuery()..featureType = FeatureType.pic;

  final UsersDataQuery _usersFollowingQuery = UsersDataQuery()
    ..eventType = InteractiveEventType.following
    ..withEvents = [InteractiveEvent.initial, InteractiveEvent.accept, InteractiveEvent.request];

  ContentData? _data;
  List<ContentData>? _listData;
  int contentIndex = 0;
  int? _currentPage = 0;
  StatusFollowing _statusFollowing = StatusFollowing.none;

  AdsData _adsData = AdsData();
  AdsData get adsData => _adsData;
  String _adsUrl = '';
  String get adsUrl => _adsUrl;
  bool _isLoadMusic = true;
  bool get isLoadMusic => _isLoadMusic;
  bool _preventMusic = false;
  bool get preventMusic => _preventMusic;
  bool _hitApiMusic = false;
  bool get hitApiMusic => _hitApiMusic;
  String _urlMusic = '';
  String get urlMusic => _urlMusic;
  int _currentIndex = -1;
  int get currentIndex => _currentIndex;
  int _mainIndex = 0;
  int get mainIndex => _mainIndex;

  SlidedPicDetailScreenArgument? _routeArgument;

  List<ContentData>? get listData => _listData;
  StatusFollowing get statusFollowing => _statusFollowing;
  bool _checkIsLoading = false;
  int? get currentPage => _currentPage;
  bool get checkIsLoading => _checkIsLoading;

  bool _isLoadMine = false;
  bool _isLoadOther = false;
  bool _isLoadSearch = false;

  set isLoadMusic(bool state) {
    _isLoadMusic = state;
    notifyListeners();
  }

  setLoadMusic(bool state) {
    _isLoadMusic = state;
  }

  set preventMusic(bool state) {
    _preventMusic = state;
    notifyListeners();
  }

  set hitApiMusic(bool state) {
    _hitApiMusic = state;
    notifyListeners();
  }

  set urlMusic(String val) {
    _urlMusic = val;
    notifyListeners();
  }

  set currentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  set mainIndex(int index) {
    _mainIndex = index;
    notifyListeners();
  }

  setMainIndex(int index) {
    _mainIndex = index;
  }

  set currentPage(int? val) {
    _currentPage = val;
    notifyListeners();
  }

  set checkIsLoading(bool val) {
    _checkIsLoading = val;
    notifyListeners();
  }

  set listData(List<ContentData>? val) {
    _listData = val;
    notifyListeners();
  }

  set statusFollowing(StatusFollowing statusFollowing) {
    _statusFollowing = statusFollowing;
    notifyListeners();
  }

  ContentData? get data => _data;
  set data(ContentData? value) {
    _data = value;
    notifyListeners();
  }

  Future<String?> getAdsVideoApsara(BuildContext context, String apsaraId) async {
    _hitApiMusic = true;
    notifyListeners();
    try {
      final notifier = PostsBloc();
      await notifier.getVideoApsaraBlocV2(context, apsaraId: apsaraId);

      final fetch = notifier.postsFetch;

      if (fetch.postsState == PostsState.videoApsaraSuccess) {
        Map jsonMap = json.decode(fetch.data.toString());
        print('jsonMap video Apsara : $jsonMap');
        _hitApiMusic = false;
        notifyListeners();
        return jsonMap['PlayUrl'];
      } else {
        throw 'error get file apsara';
      }
    } catch (e) {
      'Failed to fetch ads data ${e}'.logger();
      _hitApiMusic = false;
      notifyListeners();
    }
    return null;
  }

  // void pauseAudioPlayer(){
  //   try{
  //     audioPlayer.pause();
  //   }catch(e){
  //     e.logger();
  //   }
  // }

  // void resumeAudioPlayer(){
  //   try{
  //     audioPlayer.resume();
  //   }catch(e){
  //     e.logger();
  //   }
  // }

  void onUpdate() => notifyListeners();

  Future initAdsVideo(BuildContext context) async {
    _adsUrl = '';
    final count = context.getAdsCount();
    String? urlAds;
    print('COUNTS ADS $count');

    if (count == null) {
      context.setAdsCount(0);
    } else {
      if (count == 2) {
        urlAds = await getAdsVideo(context, false);
      }
    }
    if (urlAds != null) {
      _adsUrl = urlAds;
    }
  }

  Future<ContentData?> getDetailPost(BuildContext context, String postID) async {
    final notifier = PostsBloc();
    await notifier.getContentsBlocV2(context, postID: postID, pageRows: 1, pageNumber: 1, type: FeatureType.pic);
    final fetch = notifier.postsFetch;

    final res = (fetch.data as List<dynamic>?)?.map((e) => ContentData.fromJson(e as Map<String, dynamic>)).toList();
    if (res != null) {
      return res.firstOrNull();
    } else {
      return null;
    }
  }

  ContentData? _savedData;
  ContentData? get savedData => _savedData;
  set savedData(ContentData? data) {
    _savedData = data;
    notifyListeners();
  }

  Future initDetailPost(BuildContext context, String postID) async {
    savedData = await getDetailPost(context, postID);
    print("tetsdausdjha ${savedData?.toJson()}");
  }

  Future<void> nextPlaylistPic(BuildContext context, int value) async {
    print('onPageChanged Image : masuk');
    if (_routeArgument?.type == TypePlaylist.landingpage) {
      if (value == ((listData?.length ?? 0) - 1) && (listData?.length ?? 0) % (contentsQuery.limit) == 0) {
        print('onPageChanged Image : masuk');
        try {
          final values = await contentsQuery.loadNext(context, isLandingPage: true);
          if (values.isNotEmpty) {
            listData = [...(listData ?? []) as List<ContentData>] + values;
            final prev = context.read<PreviewPicNotifier>();
            prev.initialPic(context, list: values);
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
              prev.user.pics = [...(prev.user.pics ?? []), ...values];
            }
          } catch (e) {
            'TypePlaylist.mine nextload error : $e'.logger();
          } finally {
            _isLoadMine = false;
          }
        }
      }
    } else if (_routeArgument?.type == TypePlaylist.other) {
      if (!_isLoadOther) {
        if (value >= ((listData?.length ?? 0) - 6) && (listData?.length ?? 0) % (contentsQuery.limit) == 0) {
          try {
            _isLoadOther = true;
            final values = await contentsQuery.loadNext(context, otherContent: true);
            if (values.isNotEmpty) {
              listData = [...(listData ?? []) as List<ContentData>] + values;
              final prev = context.read<OtherProfileNotifier>();
              prev.user.pics = [...(prev.user.pics ?? []), ...values];
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

  void initState(BuildContext context, SlidedPicDetailScreenArgument routeArgument) async {
    _routeArgument = routeArgument;
    _currentPage = _routeArgument?.index.toInt();
    // await initAdsVideo(context);
    if (_routeArgument?.postID != null) {
      print("postSent");
      await _initialPic(context);
    } else {
      print("postNoSent");
      _listData = _routeArgument?.picData;
      contentsQuery.limit = _routeArgument?.limit ?? 5;
      contentsQuery.page = _routeArgument?.page ?? 1;
      notifyListeners();
      _checkFollowingToUser(context, autoFollow: false);
      _increaseViewCount(context);
    }
  }

  Future<void> _initialPic(
    BuildContext context,
  ) async {
    Future<List<ContentData>> _resFuture;

    contentsQuery.postID = _routeArgument?.postID;

    try {
      print('reload contentsQuery : 8');
      _resFuture = contentsQuery.reload(context);

      final res = await _resFuture;
      _listData = res;
      notifyListeners();
      _checkFollowingToUser(context, autoFollow: true);
      _increaseViewCount(context);
      notifyListeners();
    } catch (e) {
      'load pic: ERROR: $e'.logger();
    }
  }

  void onWillPop(bool mounted) {
    if (mounted) {
      if (_routeArgument?.postID != null && _routeArgument?.backPage == false) {
        print('ada postid');
        Routing().moveAndPop(Routes.lobby);
      } else {
        print('tanpa postid');
        Routing().moveBack();
      }
    }
  }

  Future<String?> getAdsVideo(BuildContext context, bool isContent) async {
    try {
      final notifier = AdsDataBloc();
      await notifier.adsVideoBloc(context, isContent);
      final fetch = notifier.adsDataFetch;

      if (fetch.adsDataState == AdsDataState.getAdsVideoBlocSuccess) {
        print('getAdsVideo : ${fetch.data.toString()}');
        final _newClipData = fetch.data;
        _adsData = _newClipData.data;
        return await getAdsVideoApsara(context, _newClipData.data.videoId ?? '');
      }
    } catch (e) {
      'Failed to fetch ads data $e'.logger();
    }
    return null;
  }

  // Future<String?> getAdsVideoApsara(BuildContext context, String apsaraId) async {
  //   try {
  //     final notifier = PostsBloc();
  //     await notifier.getVideoApsaraBlocV2(context, apsaraId: apsaraId);
  //
  //     final fetch = notifier.postsFetch;
  //
  //     if (fetch.postsState == PostsState.videoApsaraSuccess) {
  //       Map jsonMap = json.decode(fetch.data.toString());
  //       print('jsonMap video Apsara : $jsonMap');
  //       return jsonMap['PlayUrl'];
  //       // _eventType = (_betterPlayerRollUri != null) ? BetterPlayerEventType.showingAds : null;
  //       print('get Ads Video');
  //       // widget.videoData?.fullContentPath = jsonMap['PlayUrl'];
  //     }
  //   } catch (e) {
  //     'Failed to fetch ads data ${e}'.logger();
  //   }
  //   return null;
  // }

  Future followUser(BuildContext context, {bool checkIdCard = true}) async {
    if (_sharedPrefs.readStorage(SpKeys.email) != _listData?.single.email) {
      try {
        checkIsLoading = true;
        if (checkIdCard) {
          // System().actionReqiredIdCard(
          //   context,
          //   action: () async {
          // statusFollowing = StatusFollowing.requested;
          final notifier = FollowBloc();
          await notifier.followUserBlocV2(
            context,
            data: FollowUserArgument(
              receiverParty: _listData?.single.email ?? '',
              eventType: InteractiveEventType.following,
            ),
          );
          final fetch = notifier.followFetch;
          if (fetch.followState == FollowState.followUserSuccess) {
            statusFollowing = StatusFollowing.following;
          } else {
            statusFollowing = StatusFollowing.none;
          }
          //   },
          //   uploadContentAction: false,
          // );
        } else {
          // statusFollowing = StatusFollowing.requested;
          final notifier = FollowBloc();
          await notifier.followUserBlocV2(
            context,
            data: FollowUserArgument(
              receiverParty: _data?.email ?? '',
              eventType: InteractiveEventType.following,
            ),
          );
          final fetch = notifier.followFetch;
          if (fetch.followState == FollowState.followUserSuccess) {
            statusFollowing = StatusFollowing.following;
          } else {
            statusFollowing = StatusFollowing.none;
          }
        }
        checkIsLoading = false;
        notifyListeners();
      } catch (e) {
        'follow user: ERROR: $e'.logger();
      }
    }
  }

  Future<void> _increaseViewCount(BuildContext context) async {
    try {
      System().increaseViewCount(context, _data ?? ContentData()).whenComplete(() => notifyListeners());
    } catch (e) {
      'post view request: ERROR: $e'.logger();
    }
  }

  Future<void> _checkFollowingToUser(BuildContext context, {required bool autoFollow}) async {
    final _sharedPrefs = SharedPreference();

    if (_sharedPrefs.readStorage(SpKeys.email) != _data?.email) {
      try {
        checkIsLoading = true;
        _usersFollowingQuery.senderOrReceiver = _data?.email ?? '';
        print('reload contentsQuery : 9');
        final _resFuture = _usersFollowingQuery.reload(context);
        final _resRequest = await _resFuture;
        if (_resRequest.isNotEmpty) {
          if (_resRequest.any((element) => element.event == InteractiveEvent.accept)) {
            statusFollowing = StatusFollowing.following;
          } else if (_resRequest.any((element) => element.event == InteractiveEvent.initial)) {
            statusFollowing = StatusFollowing.requested;
          } else {
            if (autoFollow) {
              followUser(context, checkIdCard: false);
            }
          }
        }
        checkIsLoading = false;
        notifyListeners();
      } catch (e) {
        'load following request list: ERROR: $e'.logger();
      }
    }
  }

  void navigateToDetailPic(ContentData? data) {
    Routing().move(Routes.picDetail, argument: PicDetailScreenArgument(picData: data));
  }

  Future<void> createdDynamicLink(
    context, {
    ContentData? data,
  }) async {
    await createdDynamicLinkMixin(
      context,
      data: DynamicLinkData(
        routes: Routes.picDetail,
        postID: data?.postID,
        fullName: data?.username,
        description: 'Hyppe Pic',
        thumb: '${data?.fullThumbPath}',
      ),
      copiedToClipboard: false,
    );
  }

  Future<bool> onPop() async {
    if (_routeArgument?.postID != null && _routeArgument?.backPage == false) {
      Routing().moveAndPop(Routes.lobby);
    } else {
      Routing().moveBack();
    }

    return true;
  }

  void showUserTag(BuildContext context, data, postId, {final StoryController? storyController}) {
    ShowBottomSheet.onShowUserTag(context, value: data, function: () {}, postId: postId, storyController: storyController);
  }
}
