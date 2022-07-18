import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_rich_text_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/upload/pre_upload_content/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OnBuyContentBottomSheet extends StatelessWidget {
  const OnBuyContentBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<PreUploadContentNotifier>(
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextWidget(
                  textToDisplay: notifier.language.purchaseTerms!,
                  textStyle: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomTextWidget(
                      textToDisplay: "Original Content",
                      textStyle: Theme.of(context).textTheme.bodyMedium,
                    ),
                    CustomTextWidget(
                      textToDisplay: "Rp 10.000.000",
                      textStyle: Theme.of(context).textTheme.subtitle1,
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                CustomTextWidget(
                  textToDisplay: "Total Views",
                  textStyle: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 5),
                CustomTextWidget(
                  textToDisplay: "Total Likes",
                  textStyle: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            CustomElevatedButton(
              child: CustomTextWidget(
                textToDisplay: notifier.language.buy!,
                textStyle: Theme.of(context)
                    .textTheme
                    .button!
                    .copyWith(color: kHyppeLightButtonText),
              ),
              width: double.infinity,
              height: 50 * SizeConfig.scaleDiagonal,
              function: () => Routing().move(Routes.reviewBuyContent),
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
