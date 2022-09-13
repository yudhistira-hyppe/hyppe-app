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
  void initState() {
    final ntfr = Provider.of<VerificationIDNotifier>(context, listen: false);
    ntfr.initSupportDocs();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Consumer<VerificationIDNotifier>(
      builder: (_, notifier, __) => Scaffold(
        appBar: AppBar(
          // leadingWidth: 50 * SizeConfig.screenWidth! / SizeWidget.baseWidthXD,
          // leading: CustomIconButtonWidget(
          //   defaultColor: true,
          //   iconData: "${AssetPath.vectorPath}back-arrow.svg",
          //   onPressed: () => Routing().moveBack(),
          // ),
          titleSpacing: 0,
          title: CustomTextWidget(
            textToDisplay: notifier.language.uploadSupportDoc!,
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
                unorderedList(notifier.language.supportDocNotice1!),
                unorderedList(notifier.language.supportDocNotice2!),
                unorderedList(notifier.language.supportDocNotice3!),
                unorderedList(notifier.language.supportDocNotice4!),
                unorderedList(notifier.language.supportDocNotice5!),
                unorderedList(notifier.language.supportDocNotice6!),
                unorderedList(notifier.language.supportDocNotice7!),
                unorderedList(notifier.language.supportDocNotice8!),
                unorderedList(notifier.language.supportDocNotice9!),
                unorderedList(notifier.language.supportDocNotice10!),
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
            function: () => notifier.selfiePath == ''
                ? notifier.retrySelfie(context)
                : notifier.onPickSupportedDocument(context, true),
            child: CustomTextWidget(
              textToDisplay: notifier.selfiePath == ''
                  ? notifier.language.continueSelfie!
                  : notifier.language.continueStep!,
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
