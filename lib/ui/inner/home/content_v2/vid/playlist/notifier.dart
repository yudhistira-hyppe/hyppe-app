import 'dart:convert';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/services.dart';
import 'package:hyppe/core/bloc/ads_video/bloc.dart';
import 'package:hyppe/core/bloc/ads_video/state.dart';
import 'package:hyppe/core/bloc/posts_v2/bloc.dart';
import 'package:hyppe/core/bloc/posts_v2/state.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/utils.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/models/collection/advertising/ads_video_data.dart';
import 'package:hyppe/core/query_request/contents_data_query.dart';
import 'package:hyppe/core/query_request/users_data_query.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/entities/general_mixin/general_mixin.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/inner/home/notifier_v2.dart';
import 'package:hyppe/ux/path.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/bloc/follow/bloc.dart';
import 'package:hyppe/core/bloc/follow/state.dart';
import 'package:hyppe/core/arguments/follow_user_argument.dart';
import 'package:hyppe/core/arguments/contents/vid_detail_screen_argument.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/models/collection/utils/dynamic_link/dynamic_link.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/arguments/comment_argument.dart';
import '../../../../../../core/bloc/comment/bloc.dart';
import '../../../../../../core/models/collection/comment_v2/comment_data_v2.dart';
import '../../../../../../core/models/collection/localization_v2/localization_model.dart';
import 'comments_detail/screen.dart';

class VidDetailNotifier with ChangeNotifier, GeneralMixin {
  LocalizationModelV2 language = LocalizationModelV2();
  translate(LocalizationModelV2 translate) {
    language = translate;
    notifyListeners();
  }

  final UsersDataQuery _usersFollowingQuery = UsersDataQuery()
    ..eventType = InteractiveEventType.following
    ..withEvents = [InteractiveEvent.initial, InteractiveEvent.accept, InteractiveEvent.request];

  ContentsDataQuery contentsQuery = ContentsDataQuery()..featureType = FeatureType.vid;

  ContentData? _data;
  StatusFollowing _statusFollowing = StatusFollowing.none;
  VidDetailScreenArgument? _routeArgument;

  AdsVideo? _adsData;
  AdsVideo? get adsData => _adsData;

  set adsData(val) {
    _adsData = val;
  }

  ContentData? get data => _data;

  set data(ContentData? value) {
    _data = value;
    notifyListeners();
  }

  StatusFollowing get statusFollowing => _statusFollowing;

  bool _checkIsLoading = false;
  bool get checkIsLoading => _checkIsLoading;

  Orientation? _orientation = Orientation.portrait;
  Orientation? get orientation => _orientation;

  set orientation(val) {
    _orientation = val;
    notifyListeners();
  }

  set checkIsLoading(bool val) {
    _checkIsLoading = val;
    notifyListeners();
  }

  set statusFollowing(StatusFollowing statusFollowing) {
    _statusFollowing = statusFollowing;
    notifyListeners();
  }

  void onUpdate() => notifyListeners();

  void updateView(BuildContext context) => System().increaseViewCount(context, _data ?? ContentData()).whenComplete(() => notifyListeners());

  initialize() {
    _loadDetail = true;
  }

  Future initState(BuildContext context, VidDetailScreenArgument routeArgument) async {
    _routeArgument = routeArgument;

    if (_routeArgument?.postID != null) {
      print("hit Api dulu");
      final following = _routeArgument?.vidData?.following;
      await _initialVid(context, _routeArgument?.postID ?? '', _routeArgument?.vidData?.visibility ?? '');
      data?.following = following;
      notifyListeners();
    } else if (_routeArgument?.vidData?.postID != null) {
      // final userName = _routeArgument?.vidData?.username;
      // if (userName?.isEmpty ?? true) {
      final following = _routeArgument?.vidData?.following;
      print('following initState $following');
      await _initialVid(context, _routeArgument?.vidData?.postID ?? '', _routeArgument?.vidData?.visibility ?? '');
      data?.following = following;
      notifyListeners();
      // }
    } else {
      _data = _routeArgument?.vidData;
      notifyListeners();
      _checkFollowingToUser(context, autoFollow: false);
    }
  }

  Future _initialVid(BuildContext context, String postID, String visibility) async {
    statusFollowing = StatusFollowing.none;
    // Future<List<ContentData>> _resFuture;

    contentsQuery.postID = postID;

    try {
      loadDetail = true;

      // final String myEmail = SharedPreference().readStorage(SpKeys.email);
      final res = await contentsQuery.reload(context, visibility: visibility);
      data = res.firstOrNull;
      if (data != null) {
        final postID = _data?.postID;
        if (postID != null) {
          getFirstComment(context, postID);
        }
      }
      'reload contentsQuery : ${_data?.toJson()}'.logger();
      loadDetail = false;
      _checkFollowingToUser(context, autoFollow: false);
    } catch (e) {
      loadDetail = false;
      'load vid: ERROR: $e'.logger();
    }
  }

  Future followUser(BuildContext context, {bool checkIdCard = true, isUnFollow = false}) async {
    final _sharedPrefs = SharedPreference();

    if (_sharedPrefs.readStorage(SpKeys.email) != _data?.email) {
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
        print("+++++++++++++++++");
        context.read<HomeNotifier>().updateFollowing(context, email: _data?.email ?? '', statusFollowing: !isUnFollow);

        checkIsLoading = false;
        notifyListeners();
      } catch (e) {
        checkIsLoading = false;
        'follow user: ERROR: $e'.logger();
      }
    }
  }

  Future<void> newFollowUser(BuildContext context, ContentData dataContent, {bool checkIdCard = true, isUnFollow = false, String receiverParty = '', bool isloading = false}) async {
    try {
      dataContent.insight?.isloadingFollow = true;
      print(isloading);
      notifyListeners();
      final notifier = FollowBloc();
      await notifier.followUserBlocV2(
        context,
        data: FollowUserArgument(
          receiverParty: dataContent.email ?? '',
          eventType: isUnFollow ? InteractiveEventType.unfollow : InteractiveEventType.following,
        ),
      );
      final fetch = notifier.followFetch;
      if (fetch.followState == FollowState.followUserSuccess) {
        print('asdasdasd');
        if (isUnFollow) {
          print('1');
          dataContent.following = false;
          dataContent.insight?.isloadingFollow = false;
          notifyListeners();
        } else {
          print('3');
          dataContent.following = true;
          dataContent.insight?.isloadingFollow = false;
          notifyListeners();
        }
      }
      context.read<HomeNotifier>().updateFollowing(context, email: dataContent.email ?? '', statusFollowing: !isUnFollow);

      //   },
      //   uploadContentAction: false,
      // );

      notifyListeners();
    } catch (e) {
      isloading = false;
      'follow user: ERROR: $e'.logger();
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

  // Future<void> _checkFollowingToUser(BuildContext context, {required bool autoFollow}) async {
  //   try {
  //     checkIsLoading = true;
  //     'reload contentsQuery : 17'.logger();
  //     _usersFollowingQuery.senderOrReceiver = _data?.email ?? '';
  //     final _resFuture = _usersFollowingQuery.reload(context);
  //     final _resRequest = await _resFuture;
  //
  //     if (_resRequest.isNotEmpty) {
  //       if (_resRequest.any((element) => element.event == InteractiveEvent.accept)) {
  //         statusFollowing = StatusFollowing.following;
  //       } else if (_resRequest.any((element) => element.event == InteractiveEvent.initial)) {
  //         statusFollowing = StatusFollowing.requested;
  //       } else {
  //         if (autoFollow) {
  //           followUser(context, checkIdCard: false);
  //         }
  //       }
  //     }
  //     checkIsLoading = false;
  //     notifyListeners();
  //   } catch (e) {
  //     'load following request list: ERROR: $e'.logger();
  //   }
  // }

  Future<void> createdDynamicLink(
    context, {
    ContentData? data,
  }) async {
    await createdDynamicLinkMixin(
      context,
      data: DynamicLinkData(
        routes: Routes.vidDetail,
        postID: data?.postID,
        fullName: data?.username,
        description: 'Hyppe Vid',
        thumb: '${data?.fullThumbPath}',
      ),
      copiedToClipboard: false,
    );
  }

  Future<bool> onPop() async {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    if (_routeArgument?.postID != null && _routeArgument?.backPage == false) {
      System().disposeBlock();
      Routing().moveAndPop(Routes.lobby);
    } else {
      System().disposeBlock();
      Routing().moveBack();
    }

    return false;
  }

  void reportContent(BuildContext context, ContentData data) {
    ShowBottomSheet().onReportContent(context, postData: data, type: hyppeVid, adsData: null);
  }

  void showUserTag(BuildContext context, data, postId) {
    ShowBottomSheet.onShowUserTag(context, value: data, function: () {}, postId: postId);
  }

  void showContentSensitive() {
    _data?.reportedStatus = '';
    notifyListeners();
  }

  ///==== Detail V2 ====
  //
  bool _loadDetail = true;
  bool get loadDetail => _loadDetail;
  set loadDetail(bool state) {
    _loadDetail = state;
    notifyListeners();
  }

  CommentDataV2? _firstComment;
  CommentDataV2? get firstComment => _firstComment;
  set firstComment(CommentDataV2? data) {
    _firstComment = data;
    notifyListeners();
  }

  bool _loadComment = true;
  bool get loadComment => _loadComment;
  set loadComment(bool state) {
    _loadComment = state;
    notifyListeners();
  }

  Future getFirstComment(BuildContext context, String postID) async {
    try {
      loadComment = true;
      final param = CommentArgument()
        ..isQuery = true
        ..postID = postID
        ..pageRow = 1
        ..pageNumber = 0;

      final notifier = CommentBloc();
      await notifier.commentsBlocV2(context, argument: param);

      final fetch = notifier.commentFetch;

      final res = (fetch.data as List<dynamic>?)?.map((e) => CommentDataV2.fromJson(e as Map<String, dynamic>)).toList();
      firstComment = res?.first;
      loadComment = false;
    } catch (e) {
      firstComment = null;
      loadComment = false;
      '$e'.logger();
    }
  }

  goToComments(CommentsArgument args) {
    Routing().move(Routes.commentsDetail, argument: args);
  }
  //
  // ContentData? _contentDetail;
  // ContentData? get contentDetail => _contentDetail;
  // set contentDetail(ContentData? detail){
  //   _contentDetail = detail;
  //   notifyListeners();
  // }
  //
  // getDetail(BuildContext context, String postID) async {
  //   contentDetail = await getDetailPost(context, postID);
  // }
  //
  // Future<ContentData?> getDetailPost(BuildContext context, String postID) async{
  //   try{
  //     loadDetail = true;
  //     final notifier = PostsBloc();
  //     await notifier.getContentsBlocV2(context,
  //         postID: postID,
  //         pageRows: 1,
  //         pageNumber: 1,
  //         type: FeatureType.pic);
  //     final fetch = notifier.postsFetch;
  //
  //     final res = (fetch.data as List<dynamic>?)?.map((e) => ContentData.fromJson(e as Map<String, dynamic>)).toList();
  //     loadDetail = false;
  //     if(res != null){
  //       return res.firstOrNull;
  //     }else{
  //       return null;
  //     }
  //   }catch(e){
  //     loadDetail = false;
  //     e.logger();
  //     return null;
  //   }
  //
  // }

  Future getAdsVideo(BuildContext context, bool isContent) async {
    try {
      final notifier = AdsDataBloc();
      await notifier.adsVideoBloc(context, isContent);
      final fetch = notifier.adsDataFetch;

      if (fetch.adsDataState == AdsDataState.getAdsVideoBlocSuccess) {
        // print('data : ${fetch.data.toString()}');
        adsData = fetch.data;
        getAuth(context, videoId: adsData?.data?.videoId ?? '').then((value) => adsData?.data?.apsaraAuth = value);

        // await getAdsVideoApsara(_newClipData?.data?.videoId ?? '');
      }
    } catch (e) {
      'Failed to fetch ads data $e'.logger();
    }
  }

  Future<String> getAuth(BuildContext context, {String videoId = ''}) async {
    String result = '';
    try {
      final notifier = PostsBloc();
      await notifier.getAuthApsara(context, apsaraId: videoId);
      final fetch = notifier.postsFetch;
      if (fetch.postsState == PostsState.videoApsaraSuccess) {
        Map jsonMap = json.decode(fetch.data.toString());
        result = jsonMap['PlayAuth'] ?? '';
      }
      return result;
    } catch (e) {
      return '';
      // 'Failed to fetch ads data $e'.logger();
    }
  }
}
