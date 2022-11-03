import 'package:flutter/gestures.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_rich_text_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/outer/sign_up/contents/user_interest/user_interest_notifier.dart';
import 'package:provider/provider.dart';

class SignUpButton extends StatelessWidget {
  final Color buttonColor;
  final Function? onTap;
  final Function? onSkipTap;
  final TextStyle textStyle;
  final String? caption;
  final bool loading;
  final bool withSkipButton;
  const SignUpButton({
    Key? key,
    required this.buttonColor,
    required this.textStyle,
    this.loading = false,
    this.caption,
    this.onTap,
    this.onSkipTap,
    this.withSkipButton = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Consumer<TranslateNotifierV2>(
        builder: (_, notifier, __) => Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            CustomElevatedButton(
              width: SizeConfig.screenWidth,
              height: 50,
              buttonStyle: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(buttonColor),
                  overlayColor: MaterialStateProperty.all<Color>(buttonColor),
                  foregroundColor: MaterialStateProperty.all<Color>(buttonColor),
                  shadowColor: MaterialStateProperty.all<Color>(buttonColor)),
              function: onTap,
              child: loading
                  ? const CustomLoading()
                  : CustomTextWidget(
                      textToDisplay: caption ?? notifier.translate.next ?? '',
                      textStyle: textStyle,
                    ),
            ),
            if (!withSkipButton) SizedBox(height: SizeConfig.screenHeight ?? context.getHeight() * 0.0175),
            if (withSkipButton)
              CustomTextButton(
                onPressed: onSkipTap,
                child: CustomTextWidget(
                  textToDisplay: notifier.translate.skip ?? 'skip',
                  textStyle: Theme.of(context).textTheme.button?.copyWith(
                        color: onSkipTap != null ? Theme.of(context).textTheme.button?.color : Colors.transparent,
                      ),
                ),
              ),
            if (!withSkipButton)
              CustomRichTextWidget(
                textOverflow: TextOverflow.clip,
                textSpan: TextSpan(
                  text: "${notifier.translate.byRegisteringYouAgreeToHyppe} ",
                  style: Theme.of(context).textTheme.bodyText2,
                  children: [
                    TextSpan(
                      text: "${notifier.translate.privacyPolicy} ",
                      style: Theme.of(context).textTheme.bodyText2?.copyWith(fontWeight: FontWeight.bold, color: kHyppePrimary),
                      recognizer: TapGestureRecognizer()..onTap = () => context.read<UserInterestNotifier>().goToEula(),
                    ),
                    TextSpan(
                      text: "${notifier.translate.and} ",
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                    TextSpan(
                      text: notifier.translate.termsOfService,
                      style: Theme.of(context).textTheme.bodyText2?.copyWith(fontWeight: FontWeight.bold, color: kHyppePrimary),
                      recognizer: TapGestureRecognizer()..onTap = () => context.read<UserInterestNotifier>().goToEula(),
                    ),
                  ],
                ),
              ),
            SizedBox(height: SizeConfig.screenHeight ?? context.getHeight() * 0.0175),
          ],
        ),
      ),
    );
  }
}
