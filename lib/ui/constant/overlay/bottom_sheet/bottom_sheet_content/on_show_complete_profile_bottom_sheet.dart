import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/account_preferences/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OnShowCompleteProfileBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<TranslateNotifierV2>(
      builder: (_, notifier, __) => Padding(
        padding: EdgeInsets.symmetric(vertical: 8 * SizeConfig.scaleDiagonal, horizontal: 16 * SizeConfig.scaleDiagonal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const CustomIconWidget(iconData: "${AssetPath.vectorPath}handler.svg"),
            CustomTextWidget(
              textToDisplay: notifier.translate.completeProfiles!,
              textStyle: Theme.of(context).textTheme.headline6,
            ),
            CustomTextWidget(
              textToDisplay: notifier.translate.pleaseCompleteProfileToContinue!,
              textStyle: Theme.of(context).textTheme.bodyText1,
              textOverflow: TextOverflow.clip,
            ),
            CustomElevatedButton(
              child: CustomTextWidget(
                textToDisplay: notifier.translate.yesCompleteProfile!,
                textStyle: Theme.of(context).textTheme.button!.copyWith(color: kHyppeLightButtonText),
              ),
              width: double.infinity,
              height: 50 * SizeConfig.scaleDiagonal,
              function: () {
                Provider.of<AccountPreferencesNotifier>(context, listen: false).initialIndex = 1;
                Routing().moveAndPop(Routes.accountPreferences);
              },
              buttonStyle: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primaryVariant),
                  overlayColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primaryVariant)),
            ),
            CustomElevatedButton(
              child: CustomTextWidget(
                textToDisplay: notifier.translate.noLater!,
                textStyle: Theme.of(context).textTheme.button,
              ),
              width: double.infinity,
              height: 50 * SizeConfig.scaleDiagonal,
              function: () => Routing().moveBack(),
              buttonStyle: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.transparent), overlayColor: MaterialStateProperty.all(Colors.transparent)),
            )
          ],
        ),
      ),
    );
  }
}
