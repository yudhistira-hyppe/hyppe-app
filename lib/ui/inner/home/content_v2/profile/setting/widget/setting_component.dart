import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';

import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';

import 'package:hyppe/ui/inner/home/content_v2/profile/setting/widget/setting_tile.dart';

class SettingComponent extends StatelessWidget {
  final String headerCaption;
  final List<SettingTile> tiles;

  const SettingComponent({
    Key? key,
    required this.tiles,
    required this.headerCaption,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'SettingComponent');
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: CustomTextWidget(
            textToDisplay: headerCaption,
            textStyle: theme.textTheme.subtitle2,
          ),
        ),
        tenPx,
        ...tiles
      ],
    );
  }
}
