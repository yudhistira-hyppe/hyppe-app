import 'package:hyppe/core/extension/custom_extension.dart';
import 'package:hyppe/ui/inner/notification/notifier.dart';
import 'package:hyppe/ui/inner/notification/widget/component.dart';
import 'package:hyppe/ui/inner/notification/widget/component_shimmer.dart';
import 'package:hyppe/ui/inner/notification/widget/image_component.dart';
import 'package:hyppe/ui/inner/notification/widget/page_component.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LikeNotification extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Consumer<NotificationNotifier>(
        builder: (context, notifier, child) => PageComponent(
          data: notifier.likeData() ?? [],
          itemCount: notifier.likeItemCount,
          builder: (context, index) {
            if (notifier.isLoading) {
              return ComponentShimmer();
            }
            return Component(
              data: notifier.likeData()?[index],
              rightWidget: ImageComponent(
                borderRadiusGeometry: BorderRadius.circular(4.0),
                // data: notifier.likeData()?[index].content.firstOrNull(),
                data: notifier.likeData()?[index].content,
              ),
            );
          },
        ),
      );
}
