import 'package:flutter/material.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';

class ForgotPasswordTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  const ForgotPasswordTitle({
    Key? key,
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(0, -0.8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomTextWidget(
            textToDisplay: title,
            textStyle: Theme.of(context).textTheme.headline5!.copyWith(fontWeight: FontWeight.bold),
          ),
          eightPx,
          CustomTextWidget(
            maxLines: null,
            textToDisplay: subtitle,
            textOverflow: TextOverflow.visible,
            textStyle: Theme.of(context).textTheme.bodyText2,
          ),
        ],
      ),
    );
  }
}
