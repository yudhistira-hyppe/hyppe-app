import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:hyppe/core/services/shared_preference.dart';

import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';

import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';

import 'package:hyppe/ui/outer/forgot_password/user_otp/user_otp_notifier.dart';
import 'package:hyppe/ui/outer/forgot_password/user_otp/widget/custom_rectangle_input.dart';

class SignUpPinTop extends StatelessWidget {
  const SignUpPinTop({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<UserOtpNotifier>(
      builder: (_, notifier, __) {
        final cts = DateTime.now();
        final lts = DateTime.fromMillisecondsSinceEpoch(
            SharedPreference().readStorage(SpKeys.lastTimeStampReachMaxAttempRecoverPassword) ?? DateTime.now().millisecondsSinceEpoch);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CustomIconWidget(
              defaultColor: false,
              iconData: "${AssetPath.vectorPath}verification-email.svg",
            ),
            twentyPx,
            CustomTextWidget(
              textStyle: Theme.of(context).textTheme.bodyText2,
              textToDisplay: "${notifier.language.pinTopText!} ${notifier.argument.email}",
            ),
            fortyTwoPx,
            CustomRectangleInput(),
            if (cts.isAfter(lts) && !notifier.loadingForObject(notifier.resendLoadKey)) ...[
              fortyPx,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomTextWidget(
                    textStyle: Theme.of(context).textTheme.caption,
                    textToDisplay: notifier.language.didntReceiveTheCode ?? '',
                  ),
                  fourPx,
                  InkWell(
                    onTap: () => notifier.resend(context),
                    child: CustomTextWidget(
                      textOverflow: TextOverflow.visible,
                      textToDisplay: notifier.resendString(),
                      textStyle: notifier.resendStyle(context),
                    ),
                  ),
                ],
              )
            ] else ...[
              const CircularProgressIndicator(),
            ],
          ],
        );
      },
    );
  }
}
