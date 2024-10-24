import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/outer/sign_up/contents/pin/notifier.dart';
import 'package:hyppe/ui/outer/sign_up/contents/pin/widget/custom_rectangle_input.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/constants/themes/hyppe_colors.dart';
import '../../../../../../core/services/system.dart';

class SignUpPinTop extends StatefulWidget {
  const SignUpPinTop({Key? key}) : super(key: key);

  @override
  State<SignUpPinTop> createState() => _SignUpPinTopState();
}

class _SignUpPinTopState extends State<SignUpPinTop> {
  var timeout = 600;

  var pleaseWait = 0;

  late Timer timer;

  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'SignUpPinTop');
    super.initState();
    pleaseWait = 60;
    timeout = 600;
    startTime();
  }

  void resetTime() {
    setState(() {
      timeout = 600;
    });
  }

  void startTime({bool isReset = false}) {
    if (isReset) {
      resetTime();
    }
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (pleaseWait > 0) {
          pleaseWait--;
        }
        if (timeout > 0) {
          timeout--;
        } else {
          stopTime(isReset: true);
          Navigator.pop(context);
        }
      });
    });
  }

  stopTime({isReset = false}) {
    if (isReset) {
      resetTime();
    }
    setState(() {
      timer.cancel();
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<SignUpPinNotifier>(
      builder: (_, notifier, __) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CustomIconWidget(
            defaultColor: false,
            iconData: "${AssetPath.vectorPath}forgot_password.svg",
          ),
          fortyTwoPx,
          CustomTextWidget(
            textStyle: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(fontWeight: FontWeight.w700),
            textToDisplay: "${notifier.language.otpRegisterText1}",
          ),
          eightPx,
          RichText(
              textAlign: TextAlign.center,
              text: TextSpan(children: [
                TextSpan(
                  text: notifier.language.otpRegisterText2,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                TextSpan(
                  text: "${notifier.argument.email}. ",
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                TextSpan(
                  text: notifier.language.otpRegisterText3,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ])),
          twentyFourPx,
          CustomRectangleInput(afterSuccess: () {
            stopTime(isReset: true);
          }),
          (!notifier.loadingForObject(notifier.resendLoadKey))
              ? Column(
                  children: [
                    fortyPx,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomTextWidget(
                          textStyle: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                  color: context.isDarkMode()
                                      ? Colors.white
                                      : Colors.black),
                          textToDisplay:
                              notifier.language.didntReceiveTheCode ?? '',
                        ),
                        fourPx,
                        pleaseWait == 0
                            ? InkWell(
                                onTap: () {
                                  notifier.resend(context, () {
                                    setState(() {
                                      pleaseWait = 60;
                                      timeout = 600;
                                    });
                                  });
                                },
                                child: CustomTextWidget(
                                  textOverflow: TextOverflow.visible,
                                  textToDisplay: notifier.resendString(),
                                  textStyle: notifier.resendStyle(context),
                                ),
                              )
                            : Row(
                                children: [
                                  CustomTextWidget(
                                    textToDisplay:
                                        '${notifier.language.pleaseWaitFor} ',
                                    textStyle: theme.textTheme.bodySmall,
                                  ),
                                  CustomTextWidget(
                                      textToDisplay:
                                          System().getFullTime(pleaseWait),
                                      textStyle: theme.textTheme.bodySmall
                                          ?.copyWith(
                                              color: context.isDarkMode()
                                                  ? Colors.white
                                                  : Colors.black))
                                ],
                              ),
                      ],
                    )
                  ],
                )
              : const SizedBox(
                  width: 15,
                  height: 15,
                  child: CircularProgressIndicator(
                    strokeWidth: 1,
                    color: kHyppePrimary,
                  )),
          twentyFourPx,
          CustomTextWidget(
            textToDisplay: notifier.language.messageTimeoutPin ?? '',
            textStyle: theme.textTheme.bodySmall,
          ),
          onePx,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomTextWidget(
                textToDisplay: '${notifier.language.inWord?.toLowerCase()} ',
                textStyle: theme.textTheme.bodySmall,
              ),
              CustomTextWidget(
                textToDisplay: '${System().getFullTime(timeout)} ',
                textStyle: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.primary),
              ),
              CustomTextWidget(
                textToDisplay: '${notifier.language.minutes?.toLowerCase()}',
                textStyle: theme.textTheme.bodySmall,
              )
            ],
          )
        ],
      ),
    );
  }
}
