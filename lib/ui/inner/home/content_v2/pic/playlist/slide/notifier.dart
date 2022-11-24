import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:hyppe/core/constants/shared_preference_keys.dart';
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
import 'package:story_view/controller/story_controller.dart';

import '../../../../../../../core/arguments/contents/slided_pic_detail_screen_argument.dart';
import '../../../../../../../core/bloc/ads_video/bloc.dart';
import '../../../../../../../core/bloc/ads_video/state.dart';
import '../../../../../../../core/bloc/posts_v2/bloc.dart';
import '../../../../../../../core/bloc/posts_v2/state.dart';
import '../../../../../../../core/models/collection/advertising/ads_video_data.dart';

class SlidedPicDetailNotifier with ChangeNotifier, GeneralMixin {
  final _system = System();
  final _sharedPrefs = SharedPreference();
  ScrollController scrollController = ScrollController();
  ContentsDataQuery contentsQuery = ContentsDataQuery()..limit = 5..featureType = FeatureType.pic;

  final UsersDataQuery _usersFollowingQuery = UsersDataQuery()
    ..eventType = InteractiveEventType.following
    ..withEvents = [InteractiveEvent.initial, InteractiveEvent.accept, InteractiveEvent.request];

  ContentData? _data;
  List<ContentData>? _listData;
  int contentIndex = 0;
  double? _currentPage = 0;
  StatusFollowing _statusFollowing = StatusFollowing.none;

  AdsData _adsData = AdsData();
  AdsData get adsData => _adsData;
  String _adsUrl = '';
  String get adsUrl => _adsUrl;

  SlidedPicDetailScreenArgument? _routeArgument;

  List<ContentData>? get listData => _listData;
  StatusFollowing get statusFollowing => _statusFollowing;
  bool _checkIsLoading = false;
  double? get currentPage => _currentPage;
  bool get checkIsLoading => _checkIsLoading;

  set currentPage(double? val) {
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

  void onUpdate() => notifyListeners();

  Future initAdsVideo(BuildContext context) async {
    _adsUrl = '';
    final count = context.getAdsCount();
    String? urlAds;

    if (count == null) {
      context.setAdsCount(0);
    } else {
      if (count == 4) {
        urlAds = await getAdsVideo(context, true);
      } else if (count == 2) {
        urlAds = await getAdsVideo(context, false);
      }
    }
    if (urlAds != null) {
      _adsUrl = urlAds;
    }
  }

  void initState(BuildContext context, SlidedPicDetailScreenArgument routeArgument) async {
    _routeArgument = routeArgument;
    _currentPage = _routeArgument?.index;
    await initAdsVideo(context);
    if (_routeArgument?.postID != null) {
      print("postSent");
      await _initialPic(context);
    } else {
      print("postNoSent");
      _listData = _routeArgument?.picData;
      _listData.logger();
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

  Future<String?> getAdsVideoApsara(BuildContext context, String apsaraId) async {
    try {
      final notifier = PostsBloc();
      await notifier.getVideoApsaraBlocV2(context, apsaraId: apsaraId);

      final fetch = notifier.postsFetch;

      if (fetch.postsState == PostsState.videoApsaraSuccess) {
        Map jsonMap = json.decode(fetch.data.toString());
        print('jsonMap video Apsara : $jsonMap');
        return jsonMap['PlayUrl'];
        // _eventType = (_betterPlayerRollUri != null) ? BetterPlayerEventType.showingAds : null;
        print('get Ads Video');
        // widget.videoData?.fullContentPath = jsonMap['PlayUrl'];
      }
    } catch (e) {
      'Failed to fetch ads data ${e}'.logger();
    }
    return null;
  }

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
