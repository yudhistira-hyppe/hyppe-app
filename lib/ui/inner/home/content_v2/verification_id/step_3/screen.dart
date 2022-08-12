import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/icon_button_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/verification_id/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class VerificationIDStep3 extends StatefulWidget {
  const VerificationIDStep3({Key? key}) : super(key: key);

  @override
  State<VerificationIDStep3> createState() => _VerificationIDStep3State();
}

class _VerificationIDStep3State extends State<VerificationIDStep3> {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Consumer<VerificationIDNotifier>(
      builder: (_, notifier, __) => Scaffold(
        appBar: AppBar(
          leadingWidth: 50 * SizeConfig.screenWidth! / SizeWidget.baseWidthXD,
          leading: CustomIconButtonWidget(
            defaultColor: true,
            iconData: "${AssetPath.vectorPath}back-arrow.svg",
            onPressed: () => Routing().moveBack(),
          ),
          titleSpacing: 0,
          title: CustomTextWidget(
            textToDisplay: "ID Verification",
            textStyle:
                Theme.of(context).textTheme.headline6!.copyWith(fontSize: 18),
          ),
          centerTitle: false,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Image(image: AssetImage("assets/png/professional.png")),
                  ],
                ),
                const SizedBox(
                  height: 16,
                ),
                unorderedList(
                    "Make sure you upload an E-KTP photo taken directly from the cellphone camera"),
                unorderedList("Original E-KTP photo or in your own name"),
                unorderedList("Upload a physical E-KTP photo, not a photocopy"),
                unorderedList(
                    "The photo of the E-KTP is not damaged, for example cracked or broken"),
                unorderedList(
                    "The photo of the E-KTP is clear, not blurry, the light is bright enough and not cut off"),
                unorderedList("Photo E-KTP does not use flask"),
                unorderedList(
                    "Make sure the selfie you take is facing the front with sufficient lighting, without flash and not cropped"),
                unorderedList(
                    "If you have followed the method above, but it doesn't work, you can complain about this problem to the Hyppe Help Center 081398582108"),
                const SizedBox(
                  height: 50,
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Container(
            color: Theme.of(context).backgroundColor,
            child: CustomElevatedButton(
              width: SizeConfig.screenWidth,
              height: 44.0 * SizeConfig.scaleDiagonal,
              function: () => Routing().moveAndPop(Routes.verificationIDStep4),
              child: CustomTextWidget(
                textToDisplay: "Continue",
                textStyle:
                    textTheme.button?.copyWith(color: kHyppeLightButtonText),
              ),
              buttonStyle: ButtonStyle(
                foregroundColor: MaterialStateProperty.all(
                    Theme.of(context).colorScheme.primaryVariant),
                shadowColor: MaterialStateProperty.all(
                    Theme.of(context).colorScheme.primaryVariant),
                overlayColor: MaterialStateProperty.all(
                    Theme.of(context).colorScheme.primaryVariant),
                backgroundColor: MaterialStateProperty.all(
                    Theme.of(context).colorScheme.primaryVariant),
              ),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        resizeToAvoidBottomInset: true,
      ),
    );
  }

  Widget unorderedList(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [const Text("• "), Expanded(child: Text(text))],
      ),
    );
  }
}
