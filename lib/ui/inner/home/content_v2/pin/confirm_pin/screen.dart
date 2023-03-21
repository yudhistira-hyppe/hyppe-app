import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/pin/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/pin/widget/custom_rectangle_input.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class ConfirmPin extends StatelessWidget {
  const ConfirmPin({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'ConfirmPin');
    return Consumer2<PinAccountNotifier, TranslateNotifierV2>(
      builder: (_, notifier, notifier2, __) => WillPopScope(
        onWillPop: () async {
          Routing().moveBack();
          notifier.pin2Controller.clear();
          notifier.matchingPin = true;
          return false;
        },
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const CustomIconWidget(iconData: "${AssetPath.vectorPath}back-arrow.svg"),
              splashRadius: 1,
              onPressed: () {
                Routing().moveBack();
                notifier.pin2Controller.clear();
                notifier.matchingPin = true;
              },
            ),
            titleSpacing: 0,
            title: CustomTextWidget(
              textToDisplay: notifier2.translate.confirmPin ?? '',
              textStyle: Theme.of(context).textTheme.bodyText1?.copyWith(fontSize: 18 * SizeConfig.scaleDiagonal),
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
                  textToDisplay: notifier2.translate.confirmNewPin ?? '',
                  textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                ),
                sixPx,
                CustomTextWidget(textToDisplay: notifier2.translate.enterYour6DigitHyppePin ?? ''),
                twelvePx,
                CustomRectangleInput(
                  notifier.pin2Controller,
                  onChanged: (value) => notifier.pinConfirmChecking(context, value),
                ),
                !notifier.matchingPin
                    ? CustomTextWidget(
                        textToDisplay: notifier2.translate.enterThePinThatMatchesThePinYouFilledInEarlier ?? '',
                        maxLines: 3,
                        textStyle: Theme.of(context).textTheme.bodyText2?.copyWith(color: kHyppeRed),
                      )
                    : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
