import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/inner/notification/notifier.dart';
import 'package:hyppe/ui/inner/notification/widget/component.dart';
import 'package:hyppe/ui/inner/notification/widget/component_shimmer.dart';
import 'package:hyppe/ui/inner/notification/widget/image_component.dart';
import 'package:hyppe/ui/inner/notification/widget/page_component.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:collection/collection.dart' show IterableExtension;

class AllNotification extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'AllNotification');
    return Consumer<NotificationNotifier>(
      builder: (context, notifier, child) => PageComponent(
        data: notifier.data ?? [],
        itemCount: notifier.itemCount,
        builder: (context, index) {
          if (notifier.isLoading) {
            return ComponentShimmer();
          }
          return Component(
            data: notifier.data?[index],
            rightWidget: System().convertEventType(notifier.data?[index].eventType) == InteractiveEventType.follower ||
                    System().convertEventType(notifier.data?[index].eventType) == InteractiveEventType.live ||
                    System().convertEventType(notifier.data?[index].eventType) == InteractiveEventType.kyc ||
                    System().convertEventType(notifier.data?[index].eventType) == InteractiveEventType.following ||
                    System().convertEventType(notifier.data?[index].event) == InteractiveEventType.coin ||
                    System().convertEventType(notifier.data?[index].event) == InteractiveEventType.withdrawal ||
                    System().convertEventType(notifier.data?[index].event) == InteractiveEventType.withdrawalfailed ||
                    System().convertEventType(notifier.data?[index].event) == InteractiveEventType.withdrawalsuccess ||
                    System().convertEventType(notifier.data?[index].event) == InteractiveEventType.adsclick
                // notifier.data?[index].event == 'REQUEST_APPEAL'
                // notifier.data?[index].event == 'ADMIN_FLAGING' ||
                // notifier.data?[index].event == 'NOTSUSPENDED_APPEAL'
                ? Container()
                // ? AcceptButton(data: notifier.data?[index])
                : ImageComponent(
                    borderRadiusGeometry: BorderRadius.circular(4.0),
                    // data: notifier.data?[index].content.firstOrNull,
                    data: notifier.data?[index].content,
                    postType: notifier.data?[index].postType,
                    postID: notifier.data?[index].postID,
                  ),
          );
        },
      ),
    );
  }
}
