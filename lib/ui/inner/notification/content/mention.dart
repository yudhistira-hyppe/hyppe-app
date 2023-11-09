import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hyppe/core/models/collection/notification_v2/notification.dart';
import 'package:hyppe/ui/inner/notification/notifier.dart';
import 'package:hyppe/ui/inner/notification/widget/component.dart';
import 'package:hyppe/ui/inner/notification/widget/component_shimmer.dart';
import 'package:hyppe/ui/inner/notification/widget/image_component.dart';
import 'package:hyppe/ui/inner/notification/widget/page_component.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MentionNotification extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    FirebaseCrashlytics.instance.setCustomKey('layout', 'MentionNotification');
    return Consumer<NotificationNotifier>(
      builder: (context, notifier, child) => PageComponent(
        data: notifier.mentionData() ?? [],
        itemCount: notifier.mentionItemCount,
        builder: (context, index) {
          if (notifier.isLoading) {
            return ComponentShimmer();
          }
          return Component(
            data: notifier.mentionData()?[index],
            rightWidget: ImageComponent(
              borderRadiusGeometry: BorderRadius.circular(4.0),
              // data: notifier.mentionData()?[index].content.firstOrNull() ?? Content(),
              data: notifier.mentionData()?[index].content ?? Content(),
            ),
          );
        },
      ),
    );
  }
}
