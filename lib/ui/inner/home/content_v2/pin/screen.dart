import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/pin/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/pin/widget/custom_rectangle_input.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class PinScreen extends StatefulWidget {
  const PinScreen({Key? key}) : super(key: key);

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'PinScreen');
    super.initState();
    context.read<PinAccountNotifier>().cekUserPin(context);
  }

  @override
  Widget build(BuildContext context) {
    var setPin = SharedPreference().readStorage(SpKeys.setPin);
    return Consumer2<PinAccountNotifier, TranslateNotifierV2>(
      builder: (_, notifier, notifier2, __) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const CustomIconWidget(iconData: "${AssetPath.vectorPath}back-arrow.svg"),
            splashRadius: 1,
            onPressed: () {
              Routing().moveBack();
              if (notifier.changeSetNewPin) notifier.changeSetNewPin = false;
              if (setPin == 'true' && notifier.checkPin) {
                notifier.checkPin = false;
                notifier.pin1Controller.clear();
              }
              notifier.isForgotPin = false;
              // if (notifier.pin3Controller.text != '') notifier.pin3Controller.clear();
            },
          ),
          titleSpacing: 0,
          title: CustomTextWidget(
            textToDisplay: setPin == 'true' ? notifier2.translate.changePin ?? 'Change Pin' : 'Set New Pin',
            textStyle: Theme.of(context).textTheme.bodyText1!.copyWith(fontSize: 18 * SizeConfig.scaleDiagonal),
          ),
          centerTitle: false,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Center(
                child: CustomIconWidget(
                  height: 40,
                  iconData: "${AssetPath.vectorPath}lock-pin.svg",
                  defaultColor: false,
                  color: kHyppePrimary,
                ),
              ),
              CustomTextWidget(
                textToDisplay: setPin == 'true' && !notifier.checkPin ? notifier2.translate.enterYourCurrentPin ?? 'Enter Your Current Pin' : notifier2.translate.enterNewPin ?? 'Eneter New Pin',
                textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
              ),
              sixPx,
              CustomTextWidget(textToDisplay: notifier2.translate.enterYour6DigitHyppePin ?? ''),
              twelvePx,
              CustomRectangleInput(setPin == 'true' && !notifier.checkPin ? notifier.pin3Controller : notifier.pin1Controller, onChanged: (value) {
                if (setPin == 'true' && !notifier.checkPin) {
                  notifier.pinCurentCheking(context, value);
                } else {
                  notifier.pinChecking(context, value);
                }
              }),
              setPin == 'true' && !notifier.changeSetNewPin
                  ? GestureDetector(
                      onTap: () => notifier.forgotPin(context),
                      child: CustomTextWidget(
                        textToDisplay: notifier2.translate.forgotPin ?? 'Forgot Pin',
                        maxLines: 3,
                        textStyle: Theme.of(context).textTheme.bodyText1!.copyWith(color: kHyppePrimary, fontWeight: FontWeight.bold),
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
