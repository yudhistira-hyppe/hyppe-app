import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_shimmer.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:flutter/material.dart';

class VidDetailShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'VidDetailShimmer');
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        children: [
          const CustomShimmer(),
          Container(
            width: SizeConfig.screenWidth,
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const CustomIconWidget(
                  defaultColor: false,
                  iconData: '${AssetPath.vectorPath}back-arrow.svg',
                  color: Colors.white,
                ),
                Row(
                  children: [
                    CustomIconWidget(defaultColor: false, iconData: '${AssetPath.vectorPath}bookmark.svg', color: Theme.of(context).appBarTheme.iconTheme?.color),
                    twelvePx,
                    CustomIconWidget(defaultColor: false, iconData: '${AssetPath.vectorPath}more.svg', color: Theme.of(context).appBarTheme.iconTheme?.color),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
