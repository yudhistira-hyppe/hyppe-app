import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OnInternalServerErrorBottomSheet extends StatelessWidget {
  final Function tryAgainButton;
  final Function? backButton;
  const OnInternalServerErrorBottomSheet({Key? key, required this.tryAgainButton, this.backButton}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<TranslateNotifierV2>(
      builder: (_, notifier, __) => Container(
        padding: EdgeInsets.all(55 * SizeConfig.scaleDiagonal),
        color: Theme.of(context).colorScheme.background,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Image.asset(
              "${AssetPath.pngPath}internal_server_error.png",
              width: 250 * SizeConfig.scaleDiagonal,
              height: 160 * SizeConfig.scaleDiagonal,
            ),
            SizedBox(height: 35 * SizeConfig.scaleDiagonal),
            CustomTextWidget(
              textToDisplay: notifier.translate.internalServerError!,
              textAlign: TextAlign.center,
              textStyle: TextStyle(fontSize: 18 * SizeConfig.scaleDiagonal, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 14 * SizeConfig.scaleDiagonal),
            CustomTextWidget(
              textToDisplay: notifier.translate.ourSystemIsCurrentlyExperiencingTechnicalIssues!+" "+notifier.translate.pleaseTryAgain!,
              textAlign: TextAlign.center,
              textStyle: Theme.of(context).textTheme.bodyText2,
              textOverflow: TextOverflow.clip,
            ),
            SizedBox(height: 37 * SizeConfig.scaleDiagonal),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: CustomTextButton(
                    onPressed: backButton ?? () => Routing().moveBack(),
                    child: CustomTextWidget(
                      textToDisplay: notifier.translate.back!,
                      textStyle: Theme.of(context).textTheme.button,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: CustomElevatedButton(
                    child: CustomTextWidget(
                      textToDisplay: notifier.translate.tryAgain!,
                      textStyle: Theme.of(context).textTheme.button!.copyWith(color: kHyppeLightButtonText),
                    ),
                    width: 164 * SizeConfig.scaleDiagonal,
                    height: 42 * SizeConfig.scaleDiagonal,
                    function: tryAgainButton,
                    buttonStyle: ButtonStyle(
                        elevation: MaterialStateProperty.all<double>(0.0),
                        visualDensity: VisualDensity.adaptivePlatformDensity,
                        backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.primaryVariant),
                        shape:
                            MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)))),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
