import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/outer/sign_up/contents/pin/notifier.dart';
import 'package:hyppe/ui/outer/sign_up/contents/pin/widget/custom_rectangle_input.dart';
import 'package:provider/provider.dart';

class SignUpPinTop extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SignUpPinNotifier>(
      builder: (_, notifier, __) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CustomIconWidget(
            defaultColor: false,
            iconData: "${AssetPath.vectorPath}verification-email.svg",
          ),
          twentyPx,
          CustomTextWidget(
            textStyle: Theme.of(context).textTheme.bodyText2,
            textToDisplay: "${notifier.language.pinTopText2} ${notifier.email}",
          ),
          fortyTwoPx,
          CustomRectangleInput(),
          twelvePx,
          notifier.resendPilih
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomTextWidget(
                      textStyle: Theme.of(context).textTheme.caption?.copyWith(color: context.isDarkMode() ? Colors.white : Colors.black),
                      textToDisplay: notifier.language.didntReceiveTheCode ?? '',
                    ),
                    fourPx,
                    // notifier.startTimers
                    //     ? TweenAnimationBuilder<Duration>(
                    //         duration: Duration(seconds: 10),
                    //         tween: Tween(begin: Duration(seconds: 10), end: Duration.zero),
                    //         onEnd: () {
                    //           notifier.startTimers = false;
                    //           print('notifier.startTimers ${notifier.startTimers}');
                    //           // Routing().moveBack();
                    //           // notifier.initTransactionHistory(context);
                    //         },
                    //         builder: (BuildContext context, Duration value, Widget? child) {
                    //           final minutes = value.inMinutes;
                    //           final seconds = value.inSeconds % 60;
                    //           return CustomTextWidget(
                    //             textToDisplay: ' 00 : ${minutes < 10 ? '0' : ''}$minutes : ${seconds < 10 ? '0' : ''}$seconds',
                    //             textStyle: notifier.resendStyle(context),
                    //           );
                    //         })
                    //     : Container(),
                    InkWell(
                      onTap: notifier.resendCode(context, withStartTimer: true),
                      child: CustomTextWidget(
                        textOverflow: TextOverflow.visible,
                        textToDisplay: notifier.resendString(),
                        textStyle: notifier.resendStyle(context),
                      ),
                    )
                  ],
                )
              : SizedBox(),
        ],
      ),
    );
  }
}
