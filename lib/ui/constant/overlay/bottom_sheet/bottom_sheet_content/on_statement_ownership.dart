import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class OnStatementOwnershipBottomSheet extends StatelessWidget {
  Function() onSave;
  Function() onCancel;
  OnStatementOwnershipBottomSheet({Key? key, required this.onSave, required this.onCancel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<TranslateNotifierV2>(
      key: key,
      builder: (_, notifier, __) => Padding(
        padding: EdgeInsets.symmetric(vertical: 8 * SizeConfig.scaleDiagonal, horizontal: 16 * SizeConfig.scaleDiagonal),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CustomIconWidget(iconData: "${AssetPath.vectorPath}handler.svg"),
            tenPx,
            const RotatedBox(
              quarterTurns: 2,
              child: CustomIconWidget(
                iconData: "${AssetPath.vectorPath}info-icon.svg",
                height: 58,
                defaultColor: false,
                color: kHyppePrimary,
              ),
            ),
            thirtySixPx,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CustomTextWidget(
                    textToDisplay: notifier.translate.areYouSure ?? '',
                    textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.onBackground),
                  ),
                ),
                const SizedBox(height: 20),
                CustomTextWidget(
                  textToDisplay: notifier.translate.youNeedACertificateToMarketYourContentYouCanRegisterItLaterDoYouWantToContinue ?? '',
                  textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onBackground),
                  maxLines: 100,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            twentyFourPx,
            CustomElevatedButton(
                height: 40,
                width: MediaQuery.of(context).size.width,
                function: onCancel,
                child: CustomTextWidget(
                  textToDisplay: notifier.translate.yesPostAnyway ?? '',
                ),
                buttonStyle: ButtonStyle(
                  // backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primary),
                  backgroundColor: MaterialStateProperty.all(kHyppePrimary),
                  shadowColor: MaterialStateProperty.all(Colors.white),
                  elevation: MaterialStateProperty.all(0),
                  side: MaterialStateProperty.all(
                    BorderSide(color: kHyppeLightInactive1, width: 1.0, style: BorderStyle.solid),
                  ),
                )),
            tenPx,
            CustomElevatedButton(
              height: 40,
              width: MediaQuery.of(context).size.width,
              function: onSave,
              child: CustomTextWidget(
                textToDisplay: notifier.translate.noIWantToRegister ?? '',
                textStyle: Theme.of(context).textTheme.button?.copyWith(color: kHyppePrimary, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
