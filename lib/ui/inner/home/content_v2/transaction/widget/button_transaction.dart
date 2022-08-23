import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/notifier.dart';
import 'package:provider/provider.dart';

class ButtonTransaction extends StatelessWidget {
  const ButtonTransaction({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionNotifier>(
      builder: (context, notifier, child) => Row(
        children: [
          Expanded(
            child: CustomTextButton(
              onPressed: () {
                notifier.navigateToBankAccount();
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(width: 1.0, color: kHyppePrimary),
              ),
              child: CustomTextWidget(
                textToDisplay: notifier.language.addBankAccount!,
                textStyle: Theme.of(context).textTheme.button!.copyWith(color: kHyppePrimary),
              ),
            ),
          ),
          sixPx,
          Expanded(
            child: CustomTextButton(
              onPressed: () {},
              style: ButtonStyle(backgroundColor: MaterialStateProperty.all(kHyppePrimary)),
              child: CustomTextWidget(
                textToDisplay: notifier.language.withdrawal!,
                textStyle: Theme.of(context).textTheme.button!.copyWith(color: kHyppeLightButtonText),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
