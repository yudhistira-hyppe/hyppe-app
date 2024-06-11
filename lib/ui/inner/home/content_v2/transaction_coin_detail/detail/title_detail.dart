import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';

class TitleDetail extends StatelessWidget {
  final String? title;
  final String? subTitle;
  const TitleDetail({super.key, this.title, this.subTitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextWidget(
            textToDisplay: title ?? '',
            textStyle: const TextStyle(
              color: kHyppeTextLightPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          CustomTextWidget(
            textToDisplay: subTitle ?? '',
            textStyle: const TextStyle(
              color: kHyppeBurem,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
