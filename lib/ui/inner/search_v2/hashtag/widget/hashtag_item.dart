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
  HashtagItem({Key? key, required this.title, required this.count, required this.countContainer, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        color: Colors.white,
        child: InkWell(
          onTap: onTap,
          splashColor: context.getColorScheme().primary,
          child: Container(
            padding: const EdgeInsets.only(left: 18, top: 10, bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const CustomIconWidget(iconData: '${AssetPath.vectorPath}hashtag_icon.svg', width: 20, height: 20,),
                fourteenPx,
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextWidget(
                      textToDisplay:
                      title,
                      textStyle: context.getTextTheme().bodyMedium,
                      textAlign: TextAlign.start,
                    ),
                    Text(
                      count > 500
                          ? "500+ $countContainer"
                          : "$count $countContainer",
                      style: const TextStyle(
                          fontSize: 12, color: kHyppeGrey),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
