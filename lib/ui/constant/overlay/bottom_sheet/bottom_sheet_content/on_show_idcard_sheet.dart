import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:flutter/material.dart';

class OnShowInfoIdCardBottomSheet extends StatelessWidget {
  const OnShowInfoIdCardBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: 8 * SizeConfig.scaleDiagonal,
          horizontal: 16 * SizeConfig.scaleDiagonal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const CustomIconWidget(
              iconData: "${AssetPath.vectorPath}handler.svg"),
          CustomTextWidget(
              textOverflow: TextOverflow.visible,
              textStyle: Theme.of(context).textTheme.bodyMedium,
              textToDisplay:
                  "Please make sure the ID number matched with your Physical ID, you can re-take ID picture or appeal if it did not match"),
        ],
      ),
    );
  }
}
