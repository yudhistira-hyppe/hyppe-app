import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/icon_button_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/verification_id/notifier.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class VerificationIDStepSupportingDocs extends StatefulWidget {
  const VerificationIDStepSupportingDocs({Key? key}) : super(key: key);

  @override
  State<VerificationIDStepSupportingDocs> createState() =>
      _VerificationIDStepSupportingDocsState();
}

class _VerificationIDStepSupportingDocsState
    extends State<VerificationIDStepSupportingDocs> {
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
            textToDisplay: "Upload Supporting Document",
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
                    Image(
                        image: AssetImage("assets/png/verification-docs.png")),
                  ],
                ),
                const SizedBox(
                  height: 16,
                ),
                unorderedList(
                    "You can upload supporting documents such as, Family Identity Card, Passport, and Driver’s License issued legally by the country"),
                unorderedList(
                    "Make sure your full name is listed on your family identity card"),
                unorderedList(
                    "Make sure your name and ID Number on the family identity card can be read clearly and in matches with the ID card that you uploaded earlier"),
                unorderedList(
                    "Supporting documents such as a passport, you can upload the front page of your passport which displays your photo and full name"),
                unorderedList(
                    "Make sure your Driver’s License full name matches the ID card that you uploaded earlier"),
                unorderedList(
                    "Make sure your supporting documents are original"),
                unorderedList(
                    "Upload a original supporting document, not a copy"),
                unorderedList(
                    "The photo of the supporting document is not damaged, for example torn, cracked, blurry, broken, and/or dirty"),
                unorderedList("Do not use flash for taking the photo"),
                unorderedList(
                    "If you have followed the method above, but it doesn't work, you can complain about this problem to the Hyppe Help Center 081398582108"),
                const SizedBox(
                  height: 50,
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: Container(
          color: Theme.of(context).backgroundColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: CustomElevatedButton(
            width: SizeConfig.screenWidth,
            height: 44.0 * SizeConfig.scaleDiagonal,
            function: () => notifier.onPickSupportedDocument(context, true),
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
