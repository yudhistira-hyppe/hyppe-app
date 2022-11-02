import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
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
          leadingWidth: 50 * (SizeConfig.screenWidth ?? context.getWidth()) / SizeWidget.baseWidthXD,
          leading: CustomIconButtonWidget(
            defaultColor: true,
            iconData: "${AssetPath.vectorPath}back-arrow.svg",
            onPressed: () => Routing().moveBack(),
          ),
          titleSpacing: 0,
          title: CustomTextWidget(
            textToDisplay: notifier.language.idVerification ?? '',
            textStyle:
                Theme.of(context).textTheme.headline6?.copyWith(fontSize: 18),
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
                unorderedList(notifier.language.uploadIdCardNotice1 ?? ''),
                unorderedList(notifier.language.uploadIdCardNotice2 ?? ''),
                unorderedList(notifier.language.uploadIdCardNotice3 ?? ''),
                unorderedList(notifier.language.uploadIdCardNotice4 ?? ''),
                unorderedList(notifier.language.uploadIdCardNotice5 ?? ''),
                unorderedList(notifier.language.uploadIdCardNotice6 ?? ''),
                unorderedList(notifier.language.uploadIdCardNotice7 ?? ''),
                unorderedList(notifier.language.uploadIdCardNotice8 ?? ''),
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
            function: () => Routing().moveAndPop(Routes.verificationIDStep4),
            child: CustomTextWidget(
              textToDisplay: notifier.language.continueStep ?? '',
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
