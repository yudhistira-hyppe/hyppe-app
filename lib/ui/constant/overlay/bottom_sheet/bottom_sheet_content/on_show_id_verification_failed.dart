import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';

class OnShowIDVerificationFailedBottomSheet extends StatelessWidget {
  const OnShowIDVerificationFailedBottomSheet({Key? key}) : super(key: key);

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
          Image.asset("assets/png/warning.png"),
          CustomTextWidget(
            textToDisplay: "ID Card Number",
            textStyle: Theme.of(context).textTheme.subtitle1,
          ),
          CustomTextWidget(
              textOverflow: TextOverflow.visible,
              textStyle: Theme.of(context).textTheme.bodyMedium,
              textToDisplay:
                  "The ID card number must be contain 16 digits number, the ID card photo that you uploaded did not match with the requirement. Please try again"),
          CustomElevatedButton(
            child: CustomTextWidget(
              textToDisplay: "Re-Take Picture",
              textStyle: Theme.of(context)
                  .textTheme
                  .button!
                  .copyWith(color: kHyppeLightButtonText),
            ),
            width: double.infinity,
            height: 50 * SizeConfig.scaleDiagonal,
            function: () => Routing().moveAndRemoveUntil(
                Routes.verificationIDStep4, Routes.verificationIDStep4),
            buttonStyle: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                    Theme.of(context).colorScheme.primaryVariant),
                overlayColor: MaterialStateProperty.all(
                    Theme.of(context).colorScheme.primaryVariant)),
          ),
        ],
      ),
    );
  }
}
