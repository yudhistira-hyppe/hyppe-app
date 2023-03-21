import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';

import 'package:hyppe/core/services/fcm_service.dart';

import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/core/constants/size_config.dart';

class NotificationCircle extends StatelessWidget {
  const NotificationCircle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'NotificationCircle');
    SizeConfig().init(context);

    return ValueListenableBuilder<bool>(
      valueListenable: FcmService().haveNotification,
      builder: (_, value, __) => AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: value ? 1.0 : 0.0,
        child: Transform.translate(
          offset: Offset(
            SizeWidget().calculateSize(170.0, SizeWidget.baseHeightXD, 54.0),
            SizeWidget().calculateSize(-120.0, SizeWidget.baseHeightXD, 54.0),
          ),
          child: Icon(
            Icons.circle,
            color: const Color(0xffFF00B3),
            size: 16 * SizeConfig.scaleDiagonal,
          ),
        ),
      ),
    );
  }
}
