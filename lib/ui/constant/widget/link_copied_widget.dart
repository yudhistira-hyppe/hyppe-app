import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:flutter/material.dart';

class LinkCopied extends StatelessWidget {
  const LinkCopied({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8.0),
      ),
      height: 35,
      width: size.width * 0.9,
      alignment: Alignment.center,
      child: CustomTextWidget(
          textToDisplay: 'Link Copied',
          textStyle:
              theme.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w500)),
    );
  }
}
