import 'package:flutter/material.dart';
import 'package:hyppe/core/arguments/contents/diary_detail_screen_argument.dart';
import 'package:hyppe/core/arguments/contents/pic_detail_screen_argument.dart';
import 'package:hyppe/core/arguments/contents/vid_detail_screen_argument.dart';
import 'package:hyppe/core/arguments/discuss_argument.dart';
import 'package:hyppe/core/arguments/follow_user_argument.dart';
import 'package:hyppe/core/bloc/follow/bloc.dart';
import 'package:hyppe/core/bloc/follow/state.dart';
import 'package:hyppe/core/bloc/message_v2/state.dart';
import 'package:hyppe/core/bloc/posts_v2/bloc.dart';
import 'package:hyppe/core/bloc/posts_v2/state.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/message_v2/message_data_v2.dart';
import 'package:hyppe/core/models/collection/notification_v2/notification.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/query_request/notifications_data_query.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/entities/loading/notifier.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/inner/main/notifier.dart';
import 'package:hyppe/ui/inner/notification/content/all.dart';
import 'package:hyppe/ui/inner/notification/content/like.dart';
import 'package:hyppe/ui/inner/notification/content/general.dart';
import 'package:hyppe/ui/inner/notification/content/follow.dart';
import 'package:hyppe/ui/inner/notification/content/comment.dart';
import 'package:hyppe/ui/inner/notification/content/mention.dart';
import 'package:hyppe/core/extension/custom_extension.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

import '../../../app.dart';
import '../../../core/arguments/other_profile_argument.dart';
import '../../../core/bloc/message_v2/bloc.dart';
import '../../../core/bloc/user_v2/bloc.dart';
import '../../../core/bloc/user_v2/state.dart';
import '../../../core/constants/asset_path.dart';
import '../../../core/constants/shared_preference_keys.dart';
import '../../../core/models/collection/user_v2/profile/user_profile_model.dart';

class NotificationNotifier extends LoadingNotifier with ChangeNotifier {
  LocalizationModelV2 language = LocalizationModelV2();
  translate(LocalizationModelV2 translate) {
    language = translate;
    notifyListeners();
  }

  NotificationsDataQuery notificationsQuery = NotificationsDataQuery()..limit = 25;

  List<NotificationModel>? _data;
  List<NotificationModel>? get data => _data;

  set data(List<NotificationModel>? val) {
    _data = val;
    notifyListeners();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int get itemCount => _data == null ? 10 : (_data?.length ?? 0);

  int get likeItemCount => likeData() == null ? 10 : (likeData()?.length ?? 0);

  int get commentItemCount => commentData() == null ? 10 : (commentData()?.length ?? 0);

  int get followItemCount => followData() == null ? 10 : (followData()?.length ?? 0);

  int get followingItemCount => followingData() == null ? 10 : (followingData()?.length ?? 0);

  int get mentionItemCount => mentionData() == null ? 10 : (mentionData()?.length ?? 0);

  int get generalItemCount => generalData() == null ? 10 : (generalData()?.length ?? 0);

  bool get hasNext => notificationsQuery.hasNext;

  Future<void> getNotifications(
    BuildContext context, {
    bool reload = false,
    NotificationCategory? eventTypes,
  }) async {
    if (reload) _isLoading = true;

    notifyListeners();
    Future<List<NotificationModel>> _resFuture;
    notificationsQuery = notificationsQuery..eventType = eventTypes;
    try {
      context.read<MainNotifier>().receivedReaction = false;
      if (reload) {
        print('reload contentsQuery : 22');
        notificationsQuery.eventType = eventType(_pageIndex);
        _resFuture = notificationsQuery.reload(context);
      } else {
        _resFuture = notificationsQuery.loadNext(context);
      }

      final res = await _resFuture;
      if (reload) {
        data = res;
      } else {
        data = [...(data ?? [] as List<NotificationModel>)] + res;
      }
    } catch (e) {
      'load notification list: ERROR: $e'.logger();
    }
    _isLoading = false;
    notifyListeners();
  }

  void scrollListener(BuildContext context, ScrollController scrollController) {
    if (scrollController.offset >= scrollController.position.maxScrollExtent && !scrollController.position.outOfRange && !notificationsQuery.loading && hasNext) {
      getNotifications(context);
    }
  }

  NotificationCategory eventType(int index) {
    switch (index) {
      case 0:
        return NotificationCategory.all;
      case 1:
        return NotificationCategory.like;
      case 2:
        return NotificationCategory.comment;
      case 3:
        return NotificationCategory.follower;
      case 4:
        return NotificationCategory.following;
      case 5:
        return NotificationCategory.mention;
      default:
        return NotificationCategory.general;
    }
  }

  Map<Widget, String> _listScreen = {};
  Widget? _screen;
  int _pageIndex = 0;

  int get pageIndex => _pageIndex;
  Widget? get screen => _screen;
  Map<Widget, String> get listScreen => _listScreen;

  static const String refreshKey = 'refreshKey';
  static const String loadMoreKey = 'loadMoreKey';

  set screen(Widget? val) {
    _screen = val;
    notifyListeners();
  }

  set pageIndex(int val) {
    _pageIndex = val;
    notifyListeners();
  }

  List<NotificationModel>? likeData() => data?.filterNotification([NotificationCategory.like]);
  List<NotificationModel>? commentData() => data?.filterNotification([NotificationCategory.comment]);
  List<NotificationModel>? followData() => data?.filterNotification([NotificationCategory.follower]);
  List<NotificationModel>? followingData() => data?.filterNotification([NotificationCategory.following]);
  List<NotificationModel>? mentionData() => data?.filterNotification([NotificationCategory.mention]);
  List<NotificationModel>? generalData() => data?.filterNotification([NotificationCategory.general]);

  void resetNotificationData() {
    _data = null;
  }

  void onInitial() {
    _listScreen = {
      AllNotification(): language.all ?? '',
      LikeNotification(): language.like ?? '',
      CommentNotification(): language.comment ?? '',
      const FollowNotification(category: NotificationCategory.follower): language.follow ?? 'follow',
      const FollowNotification(category: NotificationCategory.following): language.following ?? 'following',
      MentionNotification(): language.mention ?? '',
      GeneralNotification(): language.general ?? ''
    };
    _screen = _listScreen.keys.elementAt(_pageIndex);
  }

  Future acceptUser(
    BuildContext context, {
    required NotificationModel? data,
    required FollowUserArgument argument,
  }) async {
    try {
      // System().actionReqiredIdCard(
      //   context,
      //   action: () async {
      final notifier = FollowBloc();
      await notifier.followUserBlocV2(context, data: argument);
      final fetch = notifier.followFetch;
      if (fetch.followState == FollowState.followUserSuccess) {
        _data?.removeWhere((element) => element.notificationID == data?.notificationID);
        notifyListeners();
      }
      //   },
      //   uploadContentAction: false,
      // );
    } catch (e) {
      print(e);
    }
  }

  Future markAsRead(BuildContext context, NotificationModel data) async {
    final indexP = _data?.indexOf(data);
    if (indexP != null) {
      if (!(_data?[indexP].isRead ?? false)) {
        _data?[indexP].isRead = true;
        notifyListeners();
      }
    }

    if (data.eventType == 'TRANSACTION') {
      // Routing().move(Routes.transaction);
    }
  }

  @override
  void setLoading(bool val, {bool setState = true, Object? loadingObject}) {
    super.setLoading(val, loadingObject: loadingObject);
    if (setState) notifyListeners();
  }

  Future navigateToContent(BuildContext context, postType, postID) async {
    final featureType = System().getFeatureTypeV2(postType ?? '');
    print('navigateToContent $postType, $postID, $featureType');
    switch (featureType) {
      case FeatureType.vid:
        await onGetContentData(context, featureType, (v) => Routing().move(Routes.vidDetail, argument: VidDetailScreenArgument(vidData: v)), postID);
        break;
      case FeatureType.diary:
        await onGetContentData(context, featureType, (v) => Routing().move(Routes.diaryDetail, argument: DiaryDetailScreenArgument(diaryData: v, type: TypePlaylist.none)), postID);
        break;
      case FeatureType.pic:
        await onGetContentData(context, featureType, (v) => Routing().move(Routes.picDetail, argument: PicDetailScreenArgument(picData: v)), postID);
        break;
      case FeatureType.story:
        // await onGetContentData(context, featureType, (v) => Routing().move(Routes.storyDetail, argument: StoryDetailScreenArgument(storyData: v)), postID);
        await onGetContentData(context, featureType, (v) => Routing().move(Routes.vidDetail, argument: VidDetailScreenArgument(vidData: v)), postID);
        break;
      case FeatureType.txtMsg:
        return;
      case FeatureType.other:
        return;
    }
  }

  Future checkAndNavigateToProfile(BuildContext context, String? username, {bool isReplace = false, bool isPlay = true}) async {
    UserProfileModel? result = null;
    try {
      if (username != null) {
        final fixUsername = username.replaceAll(' ', '');
        final usersNotifier = UserBloc();
        await usersNotifier.getUserProfilesBloc(context, search: fixUsername, withAlertMessage: true, isByUsername: true);
        final usersFetch = usersNotifier.userFetch;
        if (usersFetch.userState == UserState.getUserProfilesSuccess) {
          result = usersFetch.data;
          if (result != null) {
            globalAliPlayer?.pause();
            if (isReplace) {
              await Routing().moveReplacement(Routes.otherProfile, argument: OtherProfileArgument(profile: result, senderEmail: result.email));
            } else {
              await Routing().move(Routes.otherProfile, argument: OtherProfileArgument(profile: result, senderEmail: result.email));
            }
            if (isPlay) {
              globalAliPlayer?.play();
            }
          } else {
            throw "Couldn't find the user ";
          }
        } else if (usersFetch.userState == UserState.getUserProfilesError) {
          throw "Couldn't find the user";
        }
      } else {
        throw "Couldn't find the user";
      }
    } catch (e) {
      try {
        await ShowBottomSheet().onShowColouredSheet(
          context,
          language.userIsNotFound ?? '$e',
          color: Theme.of(context).colorScheme.error,
          iconSvg: "${AssetPath.vectorPath}close.svg",
          sizeIcon: 15,
        );
      } catch (e) {
        e.logger();
      }
    }
  }

  Future onGetContentData(BuildContext context, FeatureType featureType, Function(dynamic) callback, postID) async {
    print('ini imagecomponen');
    final getStory = PostsBloc();
    final List<ContentData> _listContentData = [];
    await getStory.getContentsBlocV2(context, pageNumber: 0, type: featureType, postID: postID ?? '');
    final fetch = getStory.postsFetch;
    if (fetch.postsState == PostsState.getContentsSuccess) {
      if (fetch.data.isNotEmpty) {
        fetch.data.forEach((v) => _listContentData.add(ContentData.fromJson(v)));
        if (featureType == FeatureType.pic || featureType == FeatureType.vid) {
          callback(_listContentData[0]);
        } else {
          callback(_listContentData);
        }
      }
    }
  }

  Future onGetMessageDetail(BuildContext context, Function(MessageDataV2) callback, String disqusID) async {
    final bloc = MessageBlocV2();
    final List<MessageDataV2> data = [];
    final disqusArgument = DiscussArgument(email: SharedPreference().readStorage(SpKeys.email), receiverParty: '');
    await bloc.getDiscussionBloc(context, disqusArgument: disqusArgument, disqusID: disqusID);
    final fetch = bloc.messageFetch;
    if (fetch.chatState == MessageState.createDiscussionBlocSuccess) {
      if (fetch.data.isNotEmpty) {
        fetch.data.forEach((v) => data.add(MessageDataV2.fromJson(v)));
        if (data.isNotEmpty) {
          callback(data[0]);
        }
      }
    }
  }
}
