import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/notifier.dart';
import 'package:provider/provider.dart';

class ButtonWithdrawalWidget extends StatelessWidget {
  final LocalizationModelV2? translate;
  const ButtonWithdrawalWidget({Key? key, this.translate}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'ButtonWithdrawalWidget');
    return Consumer<TransactionNotifier>(
      builder: (_, notifier, __) => SizedBox(
        width: SizeConfig.screenWidth,
        height: 50,
        child: CustomTextButton(
          onPressed: notifier.withdrawalButton()
              ? () {
                  if (!notifier.isLoadingSummaryWithdraw) {
                    notifier.summaryWithdrawal(context);
                  }
                }
              : null,
          style: ButtonStyle(backgroundColor: notifier.withdrawalButton() ? MaterialStateProperty.all(kHyppePrimary) : MaterialStateProperty.all(kHyppeDisabled)),
          child: notifier.isLoadingSummaryWithdraw
              ? const CustomLoading()
              : CustomTextWidget(
                  textToDisplay: translate?.next ?? '',
                  textStyle: Theme.of(context).textTheme.button?.copyWith(color: kHyppeLightButtonText),
                ),
        ),
      ),
    );
  }
}
