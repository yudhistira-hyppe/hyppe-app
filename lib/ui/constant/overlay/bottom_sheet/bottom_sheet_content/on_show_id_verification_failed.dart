import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/inner/home/content_v2/verification_id/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class OnShowIDVerificationFailedBottomSheet extends StatelessWidget {
  const OnShowIDVerificationFailedBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<VerificationIDNotifier>(
      builder: (_, notifier, __) => Padding(
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
              textToDisplay: "Please Try Again",
              textStyle: Theme.of(context).textTheme.subtitle1,
            ),
            CustomTextWidget(
                textOverflow: TextOverflow.visible,
                textStyle: Theme.of(context).textTheme.bodyMedium,
                textToDisplay:
                    "The ID card number and/or your Real Name did not match. Make sure the lighting sufficient and the ID card is in a good condition. Please try again"),
            CustomElevatedButton(
              child: CustomTextWidget(
                textToDisplay: "Upload Supporting Document",
                textStyle: Theme.of(context)
                    .textTheme
                    .button!
                    .copyWith(color: kHyppePrimary),
              ),
              width: double.infinity,
              height: 50 * SizeConfig.scaleDiagonal,
              function: () => Routing().moveAndRemoveUntil(
                  Routes.verificationIDStepSupportDocsEula,
                  Routes.verificationIDStepSupportDocsEula),
            ),
            CustomElevatedButton(
              child: CustomTextWidget(
                textToDisplay: "Re-Take ID Picture",
                textStyle: Theme.of(context)
                    .textTheme
                    .button!
                    .copyWith(color: kHyppeLightButtonText),
              ),
              width: double.infinity,
              height: 50 * SizeConfig.scaleDiagonal,
              function: () => notifier.retryTakeIdCard(),
              buttonStyle: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                      Theme.of(context).colorScheme.primaryVariant),
                  overlayColor: MaterialStateProperty.all(
                      Theme.of(context).colorScheme.primaryVariant)),
            ),
          ],
        ),
      ),
    );
  }
}
