import 'package:flutter/material.dart';

import 'package:hyppe/ui/inner/message_v2/service/base_channel.dart';

import 'package:hyppe/core/bloc/message_v2/bloc.dart';
import 'package:hyppe/core/arguments/discuss_argument.dart';
import 'package:hyppe/core/response/create_message_response.dart';
import 'package:hyppe/core/models/collection/message_v2/message_data_v2.dart';

class DiscussChannel extends BaseChannel {
  /// Last message of the channel
  MessageDataV2? lastMessage;

  DiscussChannel({
    this.lastMessage,
    required String discussId,
    int? createdAt,
  }) : super(
          discussId: discussId,
          createdAt: createdAt,
        );

  /// Creates a discuss channel with given [params].
  ///
  /// After this method completes successfully, channel event such as
  /// [ChannelEventHandler.onDiscussChannelCreated] will be called].
  static Future<CreateMessageResponse> createDiscussion(
    BuildContext context, {
    required DiscussArgument params,
  }) async {
    final notifier = MessageBlocV2();
    try {
      await notifier.createDiscussionBloc(context, disqusArgument: params);
      return CreateMessageResponse.fromJson(notifier.messageFetch.data[0]);
    } catch (e) {
      rethrow;
    }
  }

  @override
  bool operator ==(other) {
    if (identical(other, this)) return true;
    if (!(super == (other))) return false;

    return other is DiscussChannel && other.lastMessage == lastMessage;
  }

  @override
  int get hashCode => hashValues(
        super.hashCode,
        lastMessage,
      );

  @override
  void copyWith(dynamic other) {
    super.copyWith(other);
    if (other is DiscussChannel) {
      lastMessage = other.lastMessage;
    }
  }
}
