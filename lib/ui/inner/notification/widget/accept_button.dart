import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hyppe/core/arguments/follow_user_argument.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/models/collection/notification_v2/notification.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/notification/notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AcceptButton extends StatelessWidget {
  final NotificationModel? data;

  const AcceptButton({Key? key, this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'AcceptButton');
    final theme = Theme.of(context);

    return SizedBox(
      width: 68,
      height: 24,
      child: CustomTextButton(
        onPressed: () {
          late FollowUserArgument argument;

          if (data?.eventType == 'FOLLOWER' && data?.event == 'REQUEST') {
            argument = FollowUserArgument(
              receiverParty: data?.mate ?? '',
              replyEvent: InteractiveEvent.accept,
              eventType: System().convertEventType(data?.eventType),
            );

            context
                .read<NotificationNotifier>()
                .acceptUser(context, data: data, argument: argument);
          } else if (data?.eventType == 'FOLLOWING' &&
              data?.event == 'INITIAL') {
            argument = FollowUserArgument(
              receiverParty: data?.mate ?? '',
              eventType: InteractiveEventType.unfollow,
            );
          } else if (data?.event == 'ACCEPT' || data?.event == 'DONE') {
            argument = FollowUserArgument(
              receiverParty: data?.mate ?? '',
              eventType: InteractiveEventType.unfollow,
            );
          } else {
            argument = FollowUserArgument(
              receiverParty: data?.mate ?? '',
              eventType: InteractiveEventType.following,
            );

            context
                .read<NotificationNotifier>()
                .acceptUser(context, data: data, argument: argument);
          }
        },
        style: theme.textButtonTheme.style?.copyWith(
          backgroundColor: MaterialStateProperty.all(buttonColor(theme)),
          padding: MaterialStateProperty.all(EdgeInsets.zero),
        ),
        child: CustomTextWidget(
          textToDisplay: buttonText(context) ?? '',
          textStyle: theme.textTheme.labelLarge?.copyWith(
            color: data?.event != 'ACCEPT' ? Colors.white : null,
          ),
        ),
      ),
    );
  }

  Color buttonColor(ThemeData theme) {
    print('warna');
    print(System().convertEvent(data?.event));
    if (System().convertEvent(data?.event) != InteractiveEvent.accept) {
      return theme.colorScheme.primary;
    } else {
      return theme.colorScheme.surface;
    }
  }

  String? buttonText(BuildContext context) {
    final _language = Provider.of<TranslateNotifierV2>(context, listen: false);
    if (System().convertEvent(data?.event) == InteractiveEvent.accept ||
        System().convertEvent(data?.event) == InteractiveEvent.done) {
      return _language.translate.following ?? 'following';
    } else if (System().convertEventType(data?.eventType) ==
            InteractiveEventType.follower &&
        System().convertEvent(data?.event) == InteractiveEvent.request) {
      return _language.translate.accept ?? 'accept';
    } else if (System().convertEventType(data?.eventType) ==
            InteractiveEventType.following &&
        System().convertEvent(data?.event) == InteractiveEvent.initial) {
      return 'Requested';
    } else {
      return _language.translate.follow;
    }
  }
}
