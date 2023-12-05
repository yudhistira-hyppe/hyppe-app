import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';

class CustomEmptyWidget extends StatelessWidget {
  final String? title;
  final String? subtitle;
  const CustomEmptyWidget({Key? key, this.title, this.subtitle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TranslateNotifierV2 tn = context.read<TranslateNotifierV2>();
    FirebaseCrashlytics.instance.setCustomKey('layout', 'CustomEmptyWidget');
    return Column(
      children: <Widget>[
        SizedBox(
          // width: 200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CustomIconWidget(
                iconData: '${AssetPath.vectorPath}icon_no_result.svg',
                width: 160,
                height: 160,
                defaultColor: false,
              ),
              tenPx,
              CustomTextWidget(
                textToDisplay: title ?? '',
                maxLines: 2,
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w700,
                ),
              ),
              eightPx,
              CustomTextWidget(
                textToDisplay: subtitle ?? '',
                maxLines: 2,
                textStyle: const TextStyle(
                  color: kHyppeSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
