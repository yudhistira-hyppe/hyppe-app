import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:hyppe/ui/inner/notification/notifier.dart';

import 'package:hyppe/ui/inner/notification/widget/component.dart';
import 'package:hyppe/ui/inner/notification/widget/component_shimmer.dart';
import 'package:hyppe/ui/inner/notification/widget/image_component.dart';
import 'package:hyppe/ui/inner/notification/widget/page_component.dart';

class CommentNotification extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    FirebaseCrashlytics.instance.setCustomKey('layout', 'CommentNotification');
    return Consumer<NotificationNotifier>(
      builder: (context, notifier, child) => PageComponent(
        data: notifier.commentData() ?? [],
        itemCount: notifier.commentItemCount,
        builder: (context, index) {
          if (notifier.isLoading) {
            return ComponentShimmer();
          }
          return Component(
            data: notifier.commentData()?[index],
            rightWidget: ImageComponent(
              borderRadiusGeometry: BorderRadius.circular(4.0),
              // data: notifier.commentData()?[index].content.firstOrNull(),
              data: notifier.commentData()?[index].content,
            ),
          );
        },
      ),
    );
  }
}
