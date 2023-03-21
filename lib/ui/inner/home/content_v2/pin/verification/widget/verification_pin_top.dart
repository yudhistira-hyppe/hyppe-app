import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
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
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'VerificationPinTop');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String email = SharedPreference().readStorage(SpKeys.email);
    return Consumer2<PinAccountNotifier, TranslateNotifierV2>(
      builder: (_, notifier, notifier2, __) => Column(
        // mainAxisSize: MainAxisSize.min,
        children: [
          const CustomIconWidget(
            defaultColor: false,
            iconData: "${AssetPath.vectorPath}verification-email.svg",
          ),
          twentyPx,
          SizedBox(
            width: SizeConfig.screenWidth! * 0.8,
            child: Row(
              children: [
                Expanded(
                  child: CustomTextWidget(
                    textStyle: Theme.of(context).textTheme.bodyText2,
                    textToDisplay: "${notifier2.translate.pinTopText2} $email",
                    maxLines: 9,
                  ),
                ),
              ],
            ),
          ),
          fortyTwoPx,
          CustomRectangleVInput(),
          twelvePx,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomTextWidget(
                textStyle: Theme.of(context).textTheme.caption?.copyWith(color: context.isDarkMode() ? Colors.white : Colors.black),
                textToDisplay: notifier2.translate.didntReceiveTheCode ?? '',
              ),
              fourPx,
              InkWell(
                onTap: notifier.resendCode(context),
                child: CustomTextWidget(
                  textOverflow: TextOverflow.visible,
                  textToDisplay: notifier.resendString(context),
                  textStyle: notifier.resendStyle(context),
                ),
              )
            ],
          ),
          twentyFourPx,
          SizedBox(
            width: 300 * SizeConfig.scaleDiagonal,
            child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(children: [
                  TextSpan(
                    text: "${notifier2.translate.thisPageWillAutomaticallyCloseIn}",
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  WidgetSpan(
                    child: TweenAnimationBuilder<Duration>(
                        duration: const Duration(minutes: 10),
                        tween: Tween(begin: const Duration(minutes: 10), end: Duration.zero),
                        onEnd: () {
                          notifier.backHome();
                        },
                        builder: (BuildContext context, Duration value, Widget? child) {
                          final minutes = value.inMinutes;
                          final seconds = value.inSeconds % 60;
                          return CustomTextWidget(
                            textToDisplay: ' ${minutes < 10 ? '0' : ''}$minutes: ${seconds < 10 ? '0' : ''}$seconds',
                            textStyle: Theme.of(context).textTheme.bodyText1?.copyWith(color: kHyppePrimary, fontWeight: FontWeight.bold),
                          );
                        }),
                  ),
                ])),
          ),
        ],
      ),
    );
  }
}
