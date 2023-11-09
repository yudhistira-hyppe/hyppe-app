import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';

import '../../../../../../../core/constants/asset_path.dart';
import '../../../../../../../core/services/system.dart';
import '../../../../../../constant/widget/custom_icon_widget.dart';
import '../../../../../../constant/widget/custom_spacer.dart';
import '../../../../../../constant/widget/custom_text_widget.dart';

class UserTemplate extends StatelessWidget {
  final String username;
  final bool isVerified;
  final String? date;
  const UserTemplate(
      {Key? key, required this.username, required this.isVerified, this.date})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'UserTemplate');
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        CustomTextWidget(
          textToDisplay: username,
          textStyle: context.getTextTheme().caption?.copyWith(
                color: context.getColorScheme().onBackground,
                fontWeight: FontWeight.w700,
              ),
        ),
        if (isVerified) twoPx,
        if (isVerified)
          const CustomIconWidget(
            iconData: '${AssetPath.vectorPath}ic_verified.svg',
            defaultColor: false,
            width: 16,
            height: 16,
          ),
        if (date != null) eightPx,
        if (date != null)
          CustomTextWidget(
              textToDisplay: System().readTimestamp(
                DateTime.parse(System().dateTimeRemoveT(date))
                    .millisecondsSinceEpoch,
                context,
                fullCaption: true,
              ),
              textStyle: context
                  .getTextTheme()
                  .caption
                  ?.copyWith(color: context.getColorScheme().secondary))
      ],
    );
  }
}
