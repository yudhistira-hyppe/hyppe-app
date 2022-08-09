import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/inner/notification/widget/accept_button.dart';
import 'package:hyppe/ui/inner/notification/notifier.dart';
import 'package:hyppe/ui/inner/notification/widget/component.dart';
import 'package:hyppe/ui/inner/notification/widget/component_shimmer.dart';
import 'package:hyppe/ui/inner/notification/widget/image_component.dart';
import 'package:hyppe/ui/inner/notification/widget/page_component.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart' show IterableExtension;

class AllNotification extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Consumer<NotificationNotifier>(
        builder: (context, notifier, child) => PageComponent(
          data: notifier.data ?? [],
          itemCount: notifier.itemCount,
          builder: (context, index) {
            if (notifier.data == null) {
              return ComponentShimmer();
            }
            return Component(
              data: notifier.data![index],
              rightWidget: notifier.data![index].flowIsDone!
                  ? const SizedBox.shrink()
                  : System().convertEventType(notifier.data?[index].eventType) == InteractiveEventType.follower ||
                          System().convertEventType(notifier.data?[index].eventType) == InteractiveEventType.following
                      // ? Container()
                      ? Container()
                      // ? AcceptButton(data: notifier.data?[index])
                      : ImageComponent(
                          borderRadiusGeometry: BorderRadius.circular(4.0),
                          data: notifier.data?[index].content.firstOrNull,
                        ),
            );
          },
        ),
      );
}
