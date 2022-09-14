import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/inner/home/content_v2/pin/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/pin/verification/widget/custom_rectangle_v_input.dart';

import 'package:provider/provider.dart';

class VerificationPinTop extends StatefulWidget {
  const VerificationPinTop({Key? key}) : super(key: key);

  @override
  State<VerificationPinTop> createState() => _VerificationPinTopState();
}

class _VerificationPinTopState extends State<VerificationPinTop> {
  @override
  Widget build(BuildContext context) {
    return Consumer<PinAccountNotifier>(
      builder: (_, notifier, __) => Column(
        // mainAxisSize: MainAxisSize.min,
        children: [
          const CustomIconWidget(
            defaultColor: false,
            iconData: "${AssetPath.vectorPath}verification-email.svg",
          ),
          twentyPx,
          CustomTextWidget(
            textStyle: Theme.of(context).textTheme.bodyText2,
            textToDisplay: notifier.language.pinTopText! + " ${notifier.email}",
          ),
          fortyTwoPx,
          CustomRectangleVInput(),
          twelvePx,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomTextWidget(
                textStyle: Theme.of(context).textTheme.caption,
                textToDisplay: notifier.language.didntReceiveTheCode ?? '',
              ),
              fourPx,
              InkWell(
                onTap: notifier.resendCode(context),
                child: CustomTextWidget(
                  textOverflow: TextOverflow.visible,
                  textToDisplay: notifier.resendString(),
                  textStyle: notifier.resendStyle(context),
                ),
              )
            ],
          ),
          twentyFourPx,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomTextWidget(
                textStyle: Theme.of(context).textTheme.bodyText1,
                textToDisplay: notifier.language.thisPageWillAutomaticallyCloseIn!,
              ),
              TweenAnimationBuilder<Duration>(
                  duration: Duration(minutes: 1),
                  tween: Tween(begin: Duration(minutes: 1), end: Duration.zero),
                  onEnd: () {
                    notifier.backHome();
                  },
                  builder: (BuildContext context, Duration value, Widget? child) {
                    final minutes = value.inMinutes;
                    final seconds = value.inSeconds % 60;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: CustomTextWidget(
                        textToDisplay: ' ${minutes < 10 ? '0' : ''}$minutes: ${seconds < 10 ? '0' : ''}$seconds',
                        textStyle: Theme.of(context).textTheme.bodyText1!.copyWith(color: kHyppePrimary, fontWeight: FontWeight.bold),
                      ),
                    );
                  }),
            ],
          ),
        ],
      ),
    );
  }
}
