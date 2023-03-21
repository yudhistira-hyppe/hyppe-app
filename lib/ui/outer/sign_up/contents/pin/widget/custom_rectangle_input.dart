import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/outer/sign_up/contents/pin/notifier.dart';
import 'package:provider/provider.dart';

import '../../../../../constant/widget/custom_otp_field_widget.dart';

class CustomRectangleInput extends StatelessWidget {
  Function afterSuccess;
  CustomRectangleInput({required this.afterSuccess});
  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'CustomRectangleInput');
    final theme = Theme.of(context);
    return Consumer<SignUpPinNotifier>(
      builder: (_, notifier, __) => SizedBox(
        width: 250,
        child: Column(
          children: [
            CustomOTPFieldWidget(
              isWrong: notifier.inCorrectCode,
              lengthPinCode: 4,
              controller: notifier.pinController,
              onChanged: (text) async {
                print('lenght of the pin: ${text.length}');
                notifier.inCorrectCode = false;
                if (text.length == 4) {

                  notifier.onVerifyButton(context, afterSuccess);
                }
                // notifier.isOTPCodeFullFilled = notifier.pinController.text.length == 4;
              },
            ),
            sixPx,
            notifier.loading
                ? SizedBox(
                width: 15,
                height: 15,
                child: CircularProgressIndicator(
                  color: theme.colorScheme.primary,
                  strokeWidth: 1,
                ))
                : notifier.inCorrectCode
                ? CustomTextWidget(
              textToDisplay: notifier.language.incorrectCode ?? '',
              textStyle:
              Theme.of(context).textTheme.bodyText2?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            )
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
