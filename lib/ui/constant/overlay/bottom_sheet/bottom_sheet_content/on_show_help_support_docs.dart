import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:flutter/material.dart';

class OnShowHelpSupportDocsBottomSheet extends StatelessWidget {
  const OnShowHelpSupportDocsBottomSheet({Key? key}) : super(key: key);

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
              textToDisplay: "You can add up to 3 supporting documents"),
        ],
      ),
    );
  }
}
