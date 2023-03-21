import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/inner/home/content_v2/pin/notifier.dart';
import 'package:provider/provider.dart';

class VerificationPinBottom extends StatelessWidget {
  const VerificationPinBottom({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'VerificationPinBottom');
    return Consumer2<PinAccountNotifier, TranslateNotifierV2>(
      builder: (_, notifier, notifier2, __) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: CustomElevatedButton(
          width: SizeConfig.screenWidth,
          height: 50,
          buttonStyle: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(notifier.verifyButtonColor(context)),
            overlayColor: MaterialStateProperty.all<Color>(notifier.verifyButtonColor(context)),
            foregroundColor: MaterialStateProperty.all<Color>(notifier.verifyButtonColor(context)),
            shadowColor: MaterialStateProperty.all<Color>(notifier.verifyButtonColor(context)),
          ),
          function: !notifier.checkSubmitButtonOTP()
              ? null
              : () {
                  notifier.checkOtp(context);
                },
          child: notifier.loading
              ? const CustomLoading()
              : CustomTextWidget(
                  textToDisplay: notifier2.translate.verify ?? '',
                  textStyle: notifier.verifyTextColor(context),
                ),
        ),
      ),
    );
  }
}
