import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter_aliplayer/flutter_aliplayer.dart';
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
// import 'package:story_view/controller/story_controller.dart';

import '../../../../../../core/bloc/posts_v2/bloc.dart';
import '../../../../../../core/bloc/posts_v2/state.dart';

class PicDetailNotifier with ChangeNotifier, GeneralMixin {
  ContentsDataQuery contentsQuery = ContentsDataQuery()..featureType = FeatureType.pic;

  final UsersDataQuery _usersFollowingQuery = UsersDataQuery()
    ..eventType = InteractiveEventType.following
    ..withEvents = [InteractiveEvent.initial, InteractiveEvent.accept, InteractiveEvent.request];

  ContentData? _data;
  int contentIndex = 0;
  StatusFollowing _statusFollowing = StatusFollowing.none;
  bool _isLoadMusic = true;
  bool get isLoadMusic => _isLoadMusic;
  // bool _preventMusic = false;
  // bool get preventMusic => _preventMusic;
  String _urlMusic = '';
  String get urlMusic => _urlMusic;

  PicDetailScreenArgument? _routeArgument;

  StatusFollowing get statusFollowing => _statusFollowing;
  bool _checkIsLoading = false;
  bool get checkIsLoading => _checkIsLoading;

  set isLoadMusic(bool state) {
    _isLoadMusic = state;
    notifyListeners();
  }

  setLoadMusic(bool state) {
    _isLoadMusic = state;
  }

  // set preventMusic(bool state) {
  //   _preventMusic = state;
  //   notifyListeners();
  // }

  set urlMusic(String val) {
    _urlMusic = val;
  }

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
      'pic playlist'.logger();

      await _initialPic(context, _routeArgument?.postID ?? '', _routeArgument?.picData?.visibility ?? 'PUBLIC');
    } else {
      _data = _routeArgument?.picData;
      data?.isLiked.logger();
      notifyListeners();

      _checkFollowingToUser(context, autoFollow: false);
      _increaseViewCount(context);
      if (_data?.username?.isEmpty ?? true) {
        await initDetailPost(context, _data?.postID ?? '', _routeArgument?.picData?.visibility ?? 'PUBLIC');
      }
    }
  }

  void initMusic(BuildContext context, String apsaraId) async {
    try {
      if (apsaraId.isNotEmpty) {
        final url = await _getAdsVideoApsara(context, apsaraId);
        if (url != null) {
          _urlMusic = url;
          notifyListeners();
        } else {
          throw 'url music is null';
        }
      } else {
        throw 'apsaramusic is empty';
      }
      isLoadMusic = false;
    } catch (e) {
      isLoadMusic = false;
      "Error Init Video $e".logger();
    } finally {
      // Future.delayed(const Duration(milliseconds: 400), () {
      //   isLoadMusic = false;
      // });
    }
  }

  Future<String?> _getAdsVideoApsara(BuildContext context, String apsaraId) async {
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

  Future<ContentData?> getDetailPost(BuildContext context, String postID, String visibility) async {
    try {
      loadPic = true;
      final notifier = PostsBloc();
      await notifier.getContentsBlocV2(context, postID: postID, pageRows: 1, pageNumber: 1, type: FeatureType.pic, visibility: visibility);
      final fetch = notifier.postsFetch;

      final _res = (fetch.data as List<dynamic>?)?.map((e) => ContentData.fromJson(e as Map<String, dynamic>)).toList();
      if (_res != null) {
        if (_res.isNotEmpty) {
          return _res.first;
        } else {
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      e.logger();
    } finally {
      loadPic = false;
    }
    return null;
  }

  Future initDetailPost(BuildContext context, String postID, String visibility) async {
    data = await getDetailPost(context, postID, visibility);
    print("tetsdausdjha1 ${data?.toJson()}");
  }

  bool _loadPic = false;
  bool get loadPic => _loadPic;
  set loadPic(bool state) {
    _loadPic = state;
    notifyListeners();
  }

  setLoadPic(bool state) {
    _loadPic = true;
  }

  Future<void> _initialPic(BuildContext context, String postID, String visibility) async {
    Future<List<ContentData>> _resFuture;

    contentsQuery.postID = postID;
    loadPic = true;
    try {
      'reload contentsQuery : 6'.logger();
      _resFuture = contentsQuery.reload(context, visibility: visibility);

      final res = await _resFuture;
      _data = res.firstOrNull;
      notifyListeners();
      _checkFollowingToUser(context, autoFollow: true);
      _increaseViewCount(context);
      _loadPic = false;
      notifyListeners();
    } catch (e) {
      _loadPic = false;
      'load pic: ERROR: $e'.logger();
    }
  }

  Future followUser(BuildContext context, {bool checkIdCard = true, isUnFollow = false, String receiverParty = '', ContentData? dataContent}) async {
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
            receiverParty: dataContent != null ? dataContent.email ?? '' : _data?.email ?? '',
            eventType: isUnFollow ? InteractiveEventType.unfollow : InteractiveEventType.following,
          ),
        );
        final fetch = notifier.followFetch;
        if (fetch.followState == FollowState.followUserSuccess) {
          if (isUnFollow) {
            if (dataContent != null) {
              dataContent.following = false;
              notifyListeners();
            } else {
              statusFollowing = StatusFollowing.none;
            }
          } else {
            if (dataContent != null) {
              dataContent.following = true;
              notifyListeners();
            } else {
              statusFollowing = StatusFollowing.following;
            }
          }
        } else if (statusFollowing != StatusFollowing.none && statusFollowing != StatusFollowing.following) {
          if (dataContent != null) {
            dataContent.following = false;
            notifyListeners();
          } else {
            statusFollowing = StatusFollowing.none;
          }
        }

        print("=============data ${dataContent?.following}");
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
            eventType: isUnFollow ? InteractiveEventType.unfollow : InteractiveEventType.following,
          ),
        );
        final fetch = notifier.followFetch;
        if (fetch.followState == FollowState.followUserSuccess) {
          if (isUnFollow) {
            statusFollowing = StatusFollowing.none;
          } else {
            statusFollowing = StatusFollowing.following;
          }
        } else if (statusFollowing != StatusFollowing.none && statusFollowing != StatusFollowing.following) {
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
        'reload contentsQuery : dua'.logger();
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
      // Routing().moveAndPop(Routes.lobby);
      Routing().moveAndRemoveUntil(Routes.lobby, Routes.root);

      // Routing().moveBack();
    } else {
      Routing().moveBack();
    }

    return true;
  }

  void showUserTag(BuildContext context, data, postId, {FlutterAliplayer? fAliplayer, String? title, Orientation? orientation}) {
    print('title $title');
    fAliplayer?.pause();
    context.handleActionIsGuest(() {
      ShowBottomSheet.onShowUserTag(
        context,
        value: data,
        function: () {},
        postId: postId,
        title: title,
        // storyController: storyController,
        fAliplayer: fAliplayer,
        orientation: orientation
      );
    });
  }

  void showContentSensitive() {
    _data?.reportedStatus = '';
    notifyListeners();
  }
}
