import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';

import 'package:hyppe/core/constants/asset_path.dart';

import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';

class FilterTile extends StatelessWidget {
  final String icon;
  final String caption;
  final Widget? trailing;
  final Function()? onTap;

  const FilterTile({
    Key? key,
    this.onTap,
    this.trailing,
    required this.icon,
    required this.caption,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'FilterTile');
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: InkWell(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  defaultColor: false,
                  color: theme.iconTheme.color,
                  iconData: '${AssetPath.vectorPath}$icon',
                ),
                sixteenPx,
                CustomTextWidget(
                  textToDisplay: caption,
                  textStyle: theme.textTheme.bodyText1,
                ),
              ],
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
