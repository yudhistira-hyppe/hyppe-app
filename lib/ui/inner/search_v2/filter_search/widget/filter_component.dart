import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';

import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/search_v2/filter_search/widget/filter_tile.dart';


class FilterComponent extends StatelessWidget {
  final String headerCaption;
  final List<FilterTile> tiles;

  const FilterComponent({
    Key? key,
    required this.tiles,
    required this.headerCaption,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'FilterComponent');
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextWidget(
          textToDisplay: headerCaption,
          textStyle: theme.textTheme.subtitle2,
        ),
        tenPx,
        ...tiles
      ],
    );
  }
}
