import 'package:flutter/material.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/constants/asset_path.dart';
import '../../../../../../core/constants/themes/hyppe_colors.dart';
import '../../../../../../initial/hyppe/translate_v2.dart';
import '../../../../widget/custom_gesture.dart';
import '../../../../widget/custom_icon_widget.dart';
import '../../../../widget/custom_profile_image.dart';
import '../../../../widget/custom_spacer.dart';
import '../../../../widget/custom_text_widget.dart';

class OnDeleteWatcherComment extends StatefulWidget {
  const OnDeleteWatcherComment({super.key});

  @override
  State<OnDeleteWatcherComment> createState() => _OnDeleteWatcherCommentState();
}

class _OnDeleteWatcherCommentState extends State<OnDeleteWatcherComment> {
  @override
  Widget build(BuildContext context) {
    final language = context.read<TranslateNotifierV2>().translate;
    return Container(
      height: double.infinity,
      width: double.infinity,
      padding: const EdgeInsets.only(left: 16, right: 16, top: 12),
      decoration: BoxDecoration(
        color: context.getColorScheme().background,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(12),
          topLeft: Radius.circular(12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const CustomIconWidget(
              iconData: "${AssetPath.vectorPath}handler.svg"),
          sixteenPx,
          const CustomProfileImage(
            width: 56,
            height: 56,
            following: true,
            imageUrl:
                'https://storage.googleapis.com/pai-images/52723c8072804e4493c246ca8aef68a1.jpeg',
          ),
          fourPx,
          CustomTextWidget(
            textAlign: TextAlign.left,
            textToDisplay: 'Natalia Jessica',
            textStyle: context.getTextTheme().bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          fourPx,
          CustomTextWidget(
            textAlign: TextAlign.left,
            textToDisplay: 'natalia.jessica',
            textStyle: context
                .getTextTheme()
                .bodySmall
                ?.copyWith(fontWeight: FontWeight.w400, color: kHyppeBurem),
          ),
          eightPx,
          CustomGesture(
            margin: EdgeInsets.zero,
            onTap: () {},
            child: Container(
              width: double.infinity,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: CustomTextWidget(
                textToDisplay: language.deleteComment2 ?? 'Hapus Komentar',
                textAlign: TextAlign.center,
                textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.red),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            height: 2,
            color: kHyppeBorder,
          ),
          CustomGesture(
            margin: EdgeInsets.zero,
            onTap: () {},
            child: Container(
              width: double.infinity,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: CustomTextWidget(
                textToDisplay: language.pinComment ?? 'Semat Komentar',
                textAlign: TextAlign.center,
                textStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: context.getColorScheme().onBackground),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
