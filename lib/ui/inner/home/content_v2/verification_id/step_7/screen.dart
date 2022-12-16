import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:path/path.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/icon_button_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/verification_id/notifier.dart';
import 'package:provider/provider.dart';

class VerificationIDStep7 extends StatefulWidget {
  const VerificationIDStep7({Key? key}) : super(key: key);

  @override
  State<VerificationIDStep7> createState() => _VerificationIDStep7State();
}

class _VerificationIDStep7State extends State<VerificationIDStep7> {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Consumer<VerificationIDNotifier>(
      builder: (_, notifier, __) => WillPopScope(
        onWillPop: () async {
          notifier.retrySelfie(context);
          return false;
        },
        child: Scaffold(
          appBar: AppBar(
            leadingWidth: 50 * (SizeConfig.screenWidth ?? context.getWidth()) / SizeWidget.baseWidthXD,
            leading: CustomIconButtonWidget(
              defaultColor: true,
              iconData: "${AssetPath.vectorPath}back-arrow.svg",
              onPressed: () => notifier.retrySelfie(context),
            ),
            titleSpacing: 0,
            title: CustomTextWidget(
              textToDisplay: 'Selfie',
              textStyle: Theme.of(context).textTheme.headline6?.copyWith(fontSize: 18),
            ),
            centerTitle: false,
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Image.file(
                  notifier.pickedSupportingDocs![0],
                  height: SizeConfig.screenHeight! / 1.4,
                ),
              ),
              sixtyFourPx,
            ],
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          floatingActionButton: Container(
            color: kHyppeLightBackground,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: CustomElevatedButton(
              width: SizeConfig.screenWidth,
              height: 44.0 * SizeConfig.scaleDiagonal,
              function: () => Routing().move(Routes.verificationIDStepSupportingDocsPreview),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (notifier.isLoading)
                    Container(
                      padding: const EdgeInsets.all(5),
                      height: 30,
                      width: 30,
                      child: const CircularProgressIndicator(color: Colors.white),
                    ),
                  const SizedBox(width: 10),
                  CustomTextWidget(
                    textToDisplay: notifier.language.continueStep ?? '',
                    textStyle: textTheme.button?.copyWith(color: kHyppeLightButtonText),
                  ),
                ],
              ),
              buttonStyle: ButtonStyle(
                foregroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primaryVariant),
                shadowColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primaryVariant),
                overlayColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primaryVariant),
                backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primaryVariant),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
