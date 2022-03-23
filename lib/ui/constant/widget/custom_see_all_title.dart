import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';

import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';

class CustomSeeAllTitle extends StatelessWidget {
  final String title;
  const CustomSeeAllTitle({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xff58125A),
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: CustomTextWidget(
        textToDisplay: title,
        textStyle: theme.textTheme.button!.copyWith(color: kHyppeLightButtonText),
      ),
    );
  }
}
