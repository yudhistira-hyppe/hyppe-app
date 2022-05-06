import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_rich_text_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/upload/pre_upload_content/notifier.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OnShowSuccessPostContentOwnershipBottomSheet extends StatelessWidget {
  const OnShowSuccessPostContentOwnershipBottomSheet({Key? key}) : super(key: key);

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
            Image.asset("${AssetPath.pngPath}user-verified.png"),
            CustomTextWidget(
              textToDisplay: notifier.language.congrats!,
              textStyle: Theme.of(context).textTheme.subtitle1,
            ),
            CustomRichTextWidget(
              textAlign: TextAlign.center,
              textOverflow: TextOverflow.clip,
              textSpan: TextSpan(
                  text: notifier.language
                      .contentOwnershipSuccessInfo!,
                  style: Theme.of(context)
                      .textTheme
                      .caption!.copyWith(height: 1.6)),
            ),
            CustomElevatedButton(
              child: CustomTextWidget(
                textToDisplay: notifier.language.close!,
                textStyle: Theme.of(context)
                    .textTheme
                    .button!
                    .copyWith(color: kHyppeLightButtonText),
              ),
              width: double.infinity,
              height: 50 * SizeConfig.scaleDiagonal,
              function: () => Routing().moveBack(),
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
