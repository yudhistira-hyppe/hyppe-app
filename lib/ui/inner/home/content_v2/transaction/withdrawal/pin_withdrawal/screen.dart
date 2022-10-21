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
import 'package:hyppe/ui/inner/home/content_v2/transaction/notifier.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class PinWithdrawalScreen extends StatelessWidget {
  const PinWithdrawalScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var setPin = SharedPreference().readStorage(SpKeys.setPin);
    return Consumer2<TransactionNotifier, TranslateNotifierV2>(
      builder: (_, notifier, notifier2, __) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const CustomIconWidget(iconData: "${AssetPath.vectorPath}back-arrow.svg"),
            splashRadius: 1,
            onPressed: () {
              Routing().moveBack();
            },
          ),
          titleSpacing: 0,
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
                textToDisplay: notifier2.translate.enterYourCurrentPin!,
                textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
              ),
              sixPx,
              CustomTextWidget(textToDisplay: notifier2.translate.enterYour6DigitHyppePin!),
              twelvePx,
              CustomRectangleInput(
                notifier.pinController,
                onChanged: (value) {
                  print(value);
                  notifier.createWithdraw(context, value);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
