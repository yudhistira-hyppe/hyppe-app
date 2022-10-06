import 'package:hyppe/core/arguments/message_detail_argument.dart';
import 'package:hyppe/core/bloc/message_v2/bloc.dart';
import 'package:hyppe/core/bloc/message_v2/state.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/message_v2/message_data_v2.dart';
import 'package:hyppe/core/query_request/discuss_data_query.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:hyppe/ux/routing.dart';

import 'package:hyppe/core/services/system.dart';

class MessageNotifier extends ChangeNotifier {
  bool _muteMessage = false;
  bool get muteMessage => _muteMessage;

  DiscussDataQuery discussQuery = DiscussDataQuery()
    ..withDetail = false
    ..limit = 25;

  int get itemCount => _discussData == null
      ? 1
      : discussQuery.hasNext
          ? (_discussData?.length ?? 0) + 1
          : (_discussData?.length ?? 0);

  bool get hasNext => discussQuery.hasNext;

  List<MessageDataV2>? _discussData;

  List<MessageDataV2>? get discussData => _discussData;

  String? _choosedisqusID;
  String? get choosedisqusID => _choosedisqusID;

  String? _choosePhotoReceiver;
  String? get choosePhotoReceiver => _choosePhotoReceiver;

  set discussData(List<MessageDataV2>? val) {
    _discussData = val;
    notifyListeners();
  }

  set muteMessage(bool val) {
    _muteMessage = val;
    notifyListeners();
  }

  set choosedisqusID(String? val) {
    _choosedisqusID = val;
    notifyListeners();
  }

  set choosePhotoReceiver(String? val) {
    _choosePhotoReceiver = val;
    notifyListeners();
  }

  Future<void> getDiscussion(
    BuildContext context, {
    bool reload = false,
  }) async {
    Future<List<MessageDataV2>> _resFuture;

    try {
      if (reload) {
        print('test22');
        _resFuture = discussQuery.reload(context);
      } else {
        _resFuture = discussQuery.loadNext(context);
      }

      final res = await _resFuture;
      if (reload) {
        discussData = res;
      } else {
        discussData = [...(discussData ?? [] as List<MessageDataV2>)] + res;
      }
    } catch (e) {
      'load discuss list: ERROR: $e'.logger();
    }
  }

  void scrollListener(BuildContext context, ScrollController scrollController) {
    if (scrollController.offset >= scrollController.position.maxScrollExtent && !scrollController.position.outOfRange && !discussQuery.loading && hasNext) {
      getDiscussion(context);
    }
  }

  void onClickUser(BuildContext context, MessageDataV2? data) {
    // get email sender
    final emailSender = SharedPreference().readStorage(SpKeys.email);

    // get self profile data
    final _selfProfile = Provider.of<SelfProfileNotifier>(context, listen: false);

    Routing().move(
      Routes.messageDetail,
      argument: MessageDetailArgument(
        mate: Mate(
          email: emailSender,
          fullName: _selfProfile.user.profile?.fullName,
          username: _selfProfile.user.profile?.username,
          avatar: Avatar(
            mediaUri: _selfProfile.user.profile?.avatar?.mediaUri,
            mediaType: _selfProfile.user.profile?.avatar?.mediaType,
            mediaEndpoint: _selfProfile.user.profile?.avatar?.mediaEndpoint,
            mediaBasePath: _selfProfile.user.profile?.avatar?.mediaBasePath,
          ),
        ),
        emailReceiver: data?.senderOrReceiverInfo?.email ?? '',
        usernameReceiver: data?.senderOrReceiverInfo?.username ?? '',
        fullnameReceiver: data?.senderOrReceiverInfo?.fullName ?? '',
        photoReceiver: System().showUserPicture(data?.senderOrReceiverInfo?.avatar?.mediaEndpoint) ?? '',
      ),
    );
  }

  // Future<void> onLongPressUser(BuildContext context, MessageDataV2? data) async {
  //   choosedisqusID = data?.disqusID;
  //   choosePhotoReceiver = System().showUserPicture(data?.senderOrReceiverInfo?.avatar?.mediaEndpoint) ?? '';
  //   ShowBottomSheet.onLongPressDeleteMessage(context);
  //   notifyListeners();
  // }

  Future<void> deletetConversation(BuildContext context, String email, String postId) async {
    final notifier = MessageBlocV2();
    await notifier.deleteDiscussionBloc(context, postEmail: email, postId: postId);
    final fetch = notifier.messageFetch;
    if (fetch.chatState == MessageState.deleteDiscussionBlocSuccess) {
      getDiscussion(context, reload: true);
      Routing().moveBack();
    }
    notifyListeners();
  }
}
