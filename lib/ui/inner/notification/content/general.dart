import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:hyppe/ui/inner/notification/notifier.dart';

import 'package:hyppe/ui/inner/notification/widget/component.dart';
import 'package:hyppe/ui/inner/notification/widget/page_component.dart';
import 'package:hyppe/ui/inner/notification/widget/component_shimmer.dart';

class GeneralNotification extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    FirebaseCrashlytics.instance.setCustomKey('layout', 'GeneralNotification');
    return Consumer<NotificationNotifier>(
      builder: (context, notifier, child) => PageComponent(
        data: notifier.generalData() ?? [],
        itemCount: notifier.generalItemCount,
        builder: (context, index) {
          if (notifier.isLoading) {
            return ComponentShimmer();
          }
          return Component(
            rightWidget: const SizedBox.shrink(),
            data: notifier.generalData()?[index],
          );
        },
      ),
    );
  }
}
