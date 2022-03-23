import 'package:flutter/material.dart';

import 'package:hyppe/core/constants/asset_path.dart';

import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';

class SettingTile extends StatelessWidget {
  final String icon;
  final String caption;
  final Widget? trailing;
  final Function()? onTap;

  const SettingTile({
    Key? key,
    this.onTap,
    this.trailing,
    required this.icon,
    required this.caption,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  defaultColor: false,
                  height: 20,
                  width: 20,
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
