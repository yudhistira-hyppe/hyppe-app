import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:hyppe/initial/hyppe/translate_v2.dart';

import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';

import 'package:hyppe/core/constants/enum.dart';

import 'package:hyppe/core/arguments/follow_user_argument.dart';

import 'package:hyppe/core/models/collection/follow/interactive_follow.dart';

import 'package:hyppe/ui/view/follower/follower_notifier.dart';

class ButtonWidget extends StatelessWidget {
  final InteractiveFollow? data;

  const ButtonWidget({Key? key, this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'ButtonWidget');
    final theme = Theme.of(context);

    return (data?.eventType == InteractiveEventType.follower && data?.event == InteractiveEvent.request) ||
            (data?.eventType == InteractiveEventType.following && data?.event == InteractiveEvent.initial)
        ? CustomTextButton(
            onPressed: () {
              late FollowUserArgument argument;
              if(data != null){
                if (data?.eventType == InteractiveEventType.follower && data?.event == InteractiveEvent.request) {
                  argument = FollowUserArgument(
                    eventType: data?.eventType ?? InteractiveEventType.view,
                    receiverParty: data?.senderOrReceiver ?? '',
                    replyEvent: InteractiveEvent.accept,
                  );

                  context.read<FollowerNotifier>().followUser(context, data: data, argument: argument);
                } else if (data?.eventType == InteractiveEventType.following && data?.event == InteractiveEvent.initial) {
                  argument = FollowUserArgument(
                    receiverParty: data?.senderOrReceiver ?? '',
                    eventType: InteractiveEventType.unfollow,
                  );
                } else if (data?.event == InteractiveEvent.accept || data?.event == InteractiveEvent.done) {
                  argument = FollowUserArgument(
                    receiverParty: data?.senderOrReceiver ?? '',
                    eventType: InteractiveEventType.unfollow,
                  );
                } else {
                  argument = FollowUserArgument(
                    receiverParty: data?.senderOrReceiver ?? '',
                    eventType: InteractiveEventType.following,
                  );

                  context.read<FollowerNotifier>().followUser(context, data: data, argument: argument);
                }
              }

            },
            style: theme.textButtonTheme.style?.copyWith(
              backgroundColor: MaterialStateProperty.all(buttonColor(theme)),
            ),
            child: CustomTextWidget(
              textToDisplay: buttonText(context) ?? '',
              textStyle: Theme.of(context).textTheme.button?.copyWith(
                    color: data?.event != InteractiveEvent.accept ? Colors.white : null,
                  ),
            ),
          )
        : const SizedBox.shrink();
  }

  Color buttonColor(ThemeData theme) {
    if (data?.event != InteractiveEvent.accept) {
      return theme.colorScheme.primary;
    } else {
      return theme.colorScheme.surface;
    }
  }

  String? buttonText(BuildContext context) {
    final _language = Provider.of<TranslateNotifierV2>(context, listen: false);
    if (data?.event == InteractiveEvent.accept || data?.event == InteractiveEvent.done) {
      return _language.translate.following ?? 'following';
    } else if (data?.eventType == InteractiveEventType.follower && data?.event == InteractiveEvent.request) {
      return _language.translate.accept ?? 'accept';
    } else if (data?.eventType == InteractiveEventType.following && data?.event == InteractiveEvent.initial) {
      return _language.translate.requested ?? 'requested';
    } else {
      return _language.translate.follow ?? 'follow';
    }
  }
}
