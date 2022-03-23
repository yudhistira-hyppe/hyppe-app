import 'package:flutter/material.dart';
import 'package:hyppe/core/arguments/follow_user_argument.dart';
import 'package:hyppe/core/bloc/follow/bloc.dart';
import 'package:hyppe/core/bloc/follow/state.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/notification_v2/notification.dart';
import 'package:hyppe/core/query_request/notifications_data_query.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/entities/loading/notifier.dart';
import 'package:hyppe/ui/inner/notification/content/all.dart';
import 'package:hyppe/ui/inner/notification/content/like.dart';
import 'package:hyppe/ui/inner/notification/content/general.dart';
import 'package:hyppe/ui/inner/notification/content/follow.dart';
import 'package:hyppe/ui/inner/notification/content/comment.dart';
import 'package:hyppe/ui/inner/notification/content/mention.dart';
import 'package:hyppe/core/extension/custom_extension.dart';

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
    NotificationCategory? eventType,
  }) async {
    Future<List<NotificationModel>> _resFuture;

    notificationsQuery = notificationsQuery..eventType = eventType;

    try {
      if (reload) {
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
  }

  void scrollListener(BuildContext context, ScrollController scrollController) {
    if (scrollController.offset >= scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange &&
        !notificationsQuery.loading &&
        hasNext) {
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

  List<NotificationModel>? likeData() => data!.filterNotification([NotificationCategory.like]);
  List<NotificationModel>? commentData() => data!.filterNotification([NotificationCategory.comment]);
  List<NotificationModel>? followData() => data!.filterNotification([NotificationCategory.follower]);
  List<NotificationModel>? followingData() => data!.filterNotification([NotificationCategory.following]);
  List<NotificationModel>? mentionData() => data!.filterNotification([NotificationCategory.mention]);
  List<NotificationModel>? generalData() => data!.filterNotification([NotificationCategory.general]);

  void resetNotificationData() {
    _data = null;
  }

  void onInitial() {
    _listScreen = {
      AllNotification(): language.all!,
      LikeNotification(): language.like!,
      CommentNotification(): language.comment!,
      const FollowNotification(category: NotificationCategory.follower): language.follow!,
      const FollowNotification(category: NotificationCategory.following): 'Following',
      MentionNotification(): language.mention!,
      GeneralNotification(): language.general!
    };
    _screen = _listScreen.keys.elementAt(0);
  }

  Future acceptUser(
    BuildContext context, {
    required NotificationModel? data,
    required FollowUserArgument argument,
  }) async {
    try {
      System().actionReqiredIdCard(
        context,
        action: () async {
          final notifier = FollowBloc();
          await notifier.followUserBlocV2(context, data: argument);
          final fetch = notifier.followFetch;
          if (fetch.followState == FollowState.followUserSuccess) {
            _data?.removeWhere((element) => element.notificationID == data?.notificationID);
            notifyListeners();
          }
        },
        uploadContentAction: false,
      );
    } catch (e) {
      print(e);
    }
  }

  Future markAsRead(BuildContext context, NotificationModel? data) async {
    int indexP = _data!.indexOf(data!);
    if (!_data![indexP].isRead!) {
      _data![indexP].isRead = true;
      notifyListeners();
    }
  }

  @override
  void setLoading(bool val, {bool setState = true, Object? loadingObject}) {
    super.setLoading(val, loadingObject: loadingObject);
    if (setState) notifyListeners();
  }
}
