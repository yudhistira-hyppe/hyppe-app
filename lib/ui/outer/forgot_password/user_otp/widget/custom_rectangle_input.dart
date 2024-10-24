import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_otp_field_widget.dart';

import 'package:hyppe/ui/outer/forgot_password/user_otp/user_otp_notifier.dart';

class CustomRectangleInput extends StatelessWidget {
  final Function afterSuccess;
  const CustomRectangleInput({required this.afterSuccess});
  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'CustomRectangleInput');
    final theme = Theme.of(context);
    return Consumer<UserOtpNotifier>(
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
                  await notifier.onVerifyButton(context, afterSuccess);
                }
                // notifier.isOTPCodeFullFilled = notifier.pinController.text.length == 4;
              },
            ),
            sixPx,
            notifier.isLoading
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
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
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
