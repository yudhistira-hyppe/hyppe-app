import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';

import '../../../../../core/constants/themes/hyppe_colors.dart';

class HashtagItem extends StatelessWidget {
  String title;
  int count;
  String countContainer;
  Function()? onTap;
  EdgeInsetsGeometry? padding;
  HashtagItem({Key? key, required this.title, required this.count, required this.countContainer, this.onTap, this.padding}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'HashtagItem');
    return Material(
      color: Colors.transparent,
      child: Ink(
        color: context.getColorScheme().background,
        child: InkWell(
          onTap: onTap,
          splashColor: context.getColorScheme().primary,
          child: Container(
            padding: padding ?? const EdgeInsets.only(left: 18, top: 10, bottom: 10, right: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const CustomIconWidget(iconData: '${AssetPath.vectorPath}hashtag_icon.svg', width: 20, height: 20, defaultColor: false, color: kHyppeTextLightPrimary,),
                fourteenPx,
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextWidget(
                        maxLines: 1,
                        textToDisplay:
                        '#$title',
                        textStyle: context.getTextTheme().bodyText1?.copyWith(color: kHyppeTextLightPrimary),
                        textAlign: TextAlign.start,
                      ),
                      fourPx,
                      Text(
                        "$count $countContainer",
                        style: const TextStyle(
                            fontSize: 12, color: kHyppeGrey),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
