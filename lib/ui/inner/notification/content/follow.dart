import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/ui/inner/notification/widget/component.dart';
import 'package:hyppe/ui/inner/notification/widget/component_shimmer.dart';
import 'package:hyppe/ui/inner/notification/widget/page_component.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/ui/inner/notification/notifier.dart';

class FollowNotification extends StatelessWidget {
  final NotificationCategory category;

  const FollowNotification({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'FollowNotification');
    return Consumer<NotificationNotifier>(
      builder: (context, notifier, child) {
        final _data = category == NotificationCategory.follower ? notifier.followData() : notifier.followingData();
        final _itemCount = category == NotificationCategory.follower ? notifier.followItemCount : notifier.followingItemCount;

        return PageComponent(
          data: _data ?? [],
          itemCount: _itemCount,
          builder: (context, index) {
            if (notifier.isLoading) {
              return ComponentShimmer();
            }
            if (_data == null) {
              return ComponentShimmer();
            }
            return Component(
              data: _data[index],
              rightWidget: (_data[index].flowIsDone ?? true)
                  ? const SizedBox.shrink()
                  // : const SizedBox.shrink()
                  : Container(),
              // AcceptButton(
              //   data: _data[index],
              // ),
            );
          },
        );
      },
    );
  }
}
