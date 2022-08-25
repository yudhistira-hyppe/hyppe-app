import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/widget/empty_bank_account.dart';
import 'package:provider/provider.dart';

class BankAccount extends StatelessWidget {
  const BankAccount({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<TransactionNotifier>(
      builder: (context, notifier, child) => Scaffold(
        appBar: AppBar(
          leading: const BackButton(),
          title: CustomTextWidget(
            textStyle: theme.textTheme.subtitle1,
            textToDisplay: '${notifier.language.transaction}',
          ),
          actions: [
            Row(
              children: [
                FlatButton(
                  onPressed: () {},
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomTextWidget(textToDisplay: notifier.language.yes!),
                      Text("Save"),
                    ],
                  ),
                  shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
                ),
              ],
            ),
          ],
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: EmptyBankAccount()),
          ],
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CustomTextButton(
            onPressed: () {},
            style: ButtonStyle(backgroundColor: MaterialStateProperty.all(kHyppePrimary)),
            child: CustomTextWidget(
              textToDisplay: notifier.language.withdrawal!,
              textStyle: Theme.of(context).textTheme.button!.copyWith(color: kHyppeLightButtonText),
            ),
          ),
        ),
      ),
    );
  }
}
