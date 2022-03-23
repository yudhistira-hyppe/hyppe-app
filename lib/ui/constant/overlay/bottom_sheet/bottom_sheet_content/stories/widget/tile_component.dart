import 'package:flutter/material.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';

class TileComponent extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget leading;
  final Function function;

  const TileComponent({Key? key, required this.leading, required this.title, required this.subtitle, required this.function}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => function(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            leading,
            sixteenPx,
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextWidget(
                  textToDisplay: title,
                  textStyle: theme.textTheme.subtitle1!.copyWith(
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.left,
                ),
                fivePx,
                CustomTextWidget(
                  textAlign: TextAlign.left,
                  textToDisplay: subtitle,
                  textStyle: theme.textTheme.caption!.copyWith(
                    color: theme.colorScheme.secondaryVariant,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
