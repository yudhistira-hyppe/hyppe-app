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
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class VerificationIDStep2 extends StatefulWidget {
  const VerificationIDStep2({Key? key}) : super(key: key);

  @override
  State<VerificationIDStep2> createState() => _VerificationIDStep2State();
}

class _VerificationIDStep2State extends State<VerificationIDStep2> {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    bool keyboardIsOpen = MediaQuery.of(context).viewInsets.bottom != 0;

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
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextWidget(
                    textToDisplay: notifier.language.realName ?? '',
                    textStyle: textTheme.titleMedium,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: context.isLightMode() ? Colors.black12 : Colors.white,
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: TextFormField(
                      controller: notifier.realNameController,
                      maxLines: 1,
                      keyboardAppearance: Brightness.dark,
                      cursorColor: const Color(0xff8A3181),
                      style: textTheme.bodyText2
                          ?.copyWith(fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        hintStyle: textTheme.bodyText2,
                        errorBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.all(5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  CustomTextWidget(
                      textOverflow: TextOverflow.visible,
                      textAlign: TextAlign.left,
                      textStyle:
                          textTheme.caption?.copyWith(color: Colors.black26),
                      textToDisplay: notifier.language.reaNameNotice ?? '')
                ],
              ),
              Visibility(
                visible: !keyboardIsOpen,
                child: CustomElevatedButton(
                  width: SizeConfig.screenWidth,
                  height: 44.0 * SizeConfig.scaleDiagonal,
                  function: () => notifier.submitStep2(context),
                  child: CustomTextWidget(
                    textToDisplay: notifier.language.continueStep ?? '',
                    textStyle: textTheme.button
                        ?.copyWith(color: kHyppeLightButtonText),
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
            ],
          ),
        ),
      ),
    );
  }
}
