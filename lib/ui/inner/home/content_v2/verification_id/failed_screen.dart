import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/icon_button_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/verification_id/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class VerificationIDFailed extends StatefulWidget {
  const VerificationIDFailed({Key? key}) : super(key: key);

  @override
  State<VerificationIDFailed> createState() => _VerificationIDFailedState();
}

class _VerificationIDFailedState extends State<VerificationIDFailed> {
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
            onPressed: () => notifier.retryTakeIdCard(),
          ),
          titleSpacing: 0,
          title: CustomTextWidget(
            textToDisplay: notifier.language.idVerification!,
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
                const Center(
                  child: Image(
                      image: AssetImage(
                          "${AssetPath.pngPath}verification-failed.png")),
                ),
                CustomTextWidget(
                    textOverflow: TextOverflow.visible,
                    textAlign: TextAlign.left,
                    textToDisplay: notifier.language.failedIdCardInfoTitle!),
                _buildDivider(context),
                CustomTextWidget(
                  textToDisplay: notifier.language.failedIdCardInfoSubTitle!,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                _unorderedList(notifier.language.failedIdCardInfo1!),
                _unorderedList(notifier.language.failedIdCardInfo2!),
                _unorderedList(notifier.language.failedIdCardInfo3!),
                _unorderedList(notifier.language.failedIdCardInfo4!),
                _unorderedList(notifier.language.failedIdCardInfo5!),
                _unorderedList(notifier.language.failedIdCardInfo6!),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CustomTextWidget(textToDisplay: notifier.language.help!),
                    const SizedBox(width: 10),
                    const CustomIconWidget(
                        iconData: "${AssetPath.vectorPath}help.svg"),
                  ],
                ),
                const SizedBox(height: 100)
              ],
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Container(
          height: 130 * SizeConfig.scaleDiagonal,
          padding: const EdgeInsets.only(top: 10, left: 16, right: 16),
          color: Theme.of(context).backgroundColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => notifier.retrySelfie(context, false),
                child: Text(
                  notifier.language.retakeSelfie!,
                  style: textTheme.titleMedium!.copyWith(
                      color: Theme.of(context).colorScheme.primaryVariant),
                ),
              ),
              const SizedBox(height: 16),
              CustomElevatedButton(
                width: SizeConfig.screenWidth,
                height: 44.0 * SizeConfig.scaleDiagonal,
                function: () =>
                    Routing().move(Routes.verificationIDStepSupportingDocs),
                child: CustomTextWidget(
                  textToDisplay: notifier.language.uploadSupportDoc!,
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
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(context) => Divider(
      thickness: 1.0,
      color: Theme.of(context).dividerTheme.color!.withOpacity(0.1));

  Widget _unorderedList(String text) {
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
