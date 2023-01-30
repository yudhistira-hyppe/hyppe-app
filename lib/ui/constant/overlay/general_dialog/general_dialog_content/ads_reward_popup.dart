import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:flutter/material.dart';

class AdsRewardPopupDialog extends StatelessWidget {
  const AdsRewardPopupDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("masuk kedialog");
    final theme = Theme.of(context);

    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.black.withOpacity(0.3),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CustomIconWidget(iconData: "${AssetPath.vectorPath}coin.svg", defaultColor: false),
            sixPx,
            CustomTextWidget(
              textToDisplay: '+Rp. 400',
              textStyle: theme.textTheme.subtitle1?.copyWith(fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
