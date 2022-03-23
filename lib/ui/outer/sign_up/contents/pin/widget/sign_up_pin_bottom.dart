import 'package:hyppe/core/arguments/verify_page_argument.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/outer/sign_up/contents/pin/notifier.dart';
import 'package:provider/provider.dart';

class SignUpPinBottom extends StatelessWidget {
  final VerifyPageArgument argument;

  const SignUpPinBottom({Key? key, required this.argument}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SignUpPinNotifier>(
      builder: (_, notifier, __) => SafeArea(
        child: CustomElevatedButton(
          width: SizeConfig.screenWidth,
          height: 50,
          buttonStyle: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(notifier.verifyButtonColor(context)),
            overlayColor: MaterialStateProperty.all<Color>(notifier.verifyButtonColor(context)),
            foregroundColor: MaterialStateProperty.all<Color>(notifier.verifyButtonColor(context)),
            shadowColor: MaterialStateProperty.all<Color>(notifier.verifyButtonColor(context)),
          ),
          function: notifier.onVerifyButton(context, argument: argument),
          child: notifier.loading
              ? const CustomLoading()
              : CustomTextWidget(
                  textToDisplay: notifier.language.verify!,
                  textStyle: notifier.verifyTextColor(context),
                ),
        ),
        minimum: EdgeInsets.only(bottom: SizeConfig.screenHeight! * 0.075),
      ),
    );
  }
}
