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

class PicDetailNotifier with ChangeNotifier, GeneralMixin {
  ContentsDataQuery contentsQuery = ContentsDataQuery()..featureType = FeatureType.pic;

  final UsersDataQuery _usersFollowingQuery = UsersDataQuery()
    ..eventType = InteractiveEventType.following
    ..withEvents = [InteractiveEvent.initial, InteractiveEvent.accept, InteractiveEvent.request];

  ContentData? _data;
  int contentIndex = 0;
  StatusFollowing _statusFollowing = StatusFollowing.none;

  PicDetailScreenArgument? _routeArgument;

  StatusFollowing get statusFollowing => _statusFollowing;
  bool _checkIsLoading = false;
  bool get checkIsLoading => _checkIsLoading;

  set checkIsLoading(bool val) {
    _checkIsLoading = val;
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

  void initState(BuildContext context, PicDetailScreenArgument routeArgument) async {
    _routeArgument = routeArgument;
    if (_routeArgument?.postID != null) {
      await _initialPic(context);
    } else {
      _data = _routeArgument?.picData;
      data?.isLiked.logger();
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
      print('test6');
      _resFuture = contentsQuery.reload(context);

      final res = await _resFuture;
      _data = res.firstOrNull;
      notifyListeners();
      _checkFollowingToUser(context, autoFollow: true);
      _increaseViewCount(context);
      notifyListeners();
    } catch (e) {
      'load pic: ERROR: $e'.logger();
    }
  }

  Future followUser(BuildContext context, {bool checkIdCard = true}) async {
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
        print('test7');
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
    Routing().move(Routes.picDetailPreview, argument: data);
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
