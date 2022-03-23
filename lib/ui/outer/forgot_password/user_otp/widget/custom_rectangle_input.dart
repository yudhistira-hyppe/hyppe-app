import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_otp_field_widget.dart';

import 'package:hyppe/ui/outer/forgot_password/user_otp/user_otp_notifier.dart';

class CustomRectangleInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserOtpNotifier>(
      builder: (_, notifier, __) => SizedBox(
        width: 200,
        child: Column(
          children: [
            notifier.inCorrectCode
                ? CustomTextWidget(
                    textToDisplay: notifier.language.incorrectCode!,
                    textStyle: Theme.of(context).textTheme.bodyText2!.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                  )
                : const SizedBox.shrink(),
            sixPx,
            CustomOTPFieldWidget(
              lengthPinCode: 4,
              controller: notifier.pinController,
              onChanged: (_) {
                notifier.isOTPCodeFullFilled = notifier.pinController.text.length == 4;
              },
            ),
          ],
        ),
      ),
    );
  }
}
