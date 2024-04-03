import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';

class InfoNew extends StatelessWidget {
  final String title;
  final String subtitle;
  const InfoNew({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(11),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: kHyppeBurem)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextWidget(
            textToDisplay: title,
            textAlign: TextAlign.start,
            textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold
            ),
          ),
          fivePx,
          CustomTextWidget(
            textToDisplay: title,
            textAlign: TextAlign.start,
            textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(),
          ),
        ],
      ),
    );
  }
}