import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/withdrawal/pin_withdrawal/otp_field_widget.dart';
import 'package:hyppe/ui/inner/upload/pre_upload_content/notifier.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class PinBoostpostScreen extends StatelessWidget {
  const PinBoostpostScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'PinBoostcontentScreen');
    // var setPin = SharedPreference().readStorage(SpKeys.setPin);
    return Consumer2<PreUploadContentNotifier, TranslateNotifierV2>(
      builder: (_, notifier, notifier2, __) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const CustomIconWidget(iconData: "${AssetPath.vectorPath}back-arrow.svg"),
            splashRadius: 1,
            onPressed: () {
              Routing().moveBack();
              notifier.pinController.clear();
              notifier.errorPinWithdrawMsg = '';
            },
          ),
          titleSpacing: 0,
          centerTitle: false,
          title: const Text('PIN Verifikasi'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              fifteenPx,
              fifteenPx,
              const Center(
                child: CustomIconWidget(
                  height: 40,
                  iconData: "${AssetPath.vectorPath}lock-pin.svg",
                  defaultColor: false,
                  color: kHyppeBackground,
                ),
              ),
              fifteenPx,
              fifteenPx,
              CustomTextWidget(
                textToDisplay: notifier2.translate.enterYourCurrentPin ?? 'Enter Your Current Pin',
                textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
              ),
              sixPx,
              CustomTextWidget(textToDisplay: notifier2.translate.enterYour6DigitHyppePin ?? ''),
              twelvePx,
              PinWithdrawal(
                controller: notifier.pinController,
                lengthPinCode: 6,
                msgError: notifier.errorPinWithdrawMsg,
                onChanged: (val) {},
                onCompleted: (value) {
                  print(value);
                  notifier.createBoostpost(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
