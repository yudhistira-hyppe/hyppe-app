import 'package:flutter/material.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:hyppe/core/constants/shared_preference_keys.dart';
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


class SlidedPicDetailNotifier with ChangeNotifier, GeneralMixin {

  final _system = System();
  final _sharedPrefs = SharedPreference();
  ScrollController scrollController = ScrollController();
  ContentsDataQuery contentsQuery = ContentsDataQuery()..featureType = FeatureType.pic;

  final UsersDataQuery _usersFollowingQuery = UsersDataQuery()
    ..eventType = InteractiveEventType.following
    ..withEvents = [InteractiveEvent.initial, InteractiveEvent.accept, InteractiveEvent.request];

  ContentData? _data;
  List<ContentData>? _listData;
  int contentIndex = 0;
  double? _currentPage = 0;
  StatusFollowing _statusFollowing = StatusFollowing.none;

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

  void initState(BuildContext context, SlidedPicDetailScreenArgument routeArgument) async {
    _routeArgument = routeArgument;
    _currentPage = _routeArgument?.index;

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
      System().increaseViewCount(context, _data!).whenComplete(() => notifyListeners());
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