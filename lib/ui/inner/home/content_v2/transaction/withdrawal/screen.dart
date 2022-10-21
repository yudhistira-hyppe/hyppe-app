import 'package:flutter/material.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/withdrawal/widget/bottom_withdrawal.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/withdrawal/widget/button_withdrawal.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/withdrawal/widget/top_withdrawal.dart';
import 'package:provider/provider.dart';

class WithdrawalScreen extends StatelessWidget {
  const WithdrawalScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<TranslateNotifierV2>(
      builder: (_, notifier2, __) => WillPopScope(
        onWillPop: () async {
          context.read<TransactionNotifier>().exitPageWithdrawal();
          return false;
        },
        child: Scaffold(
          appBar: AppBar(
            leading: const BackButton(),
            title: CustomTextWidget(
              textStyle: Theme.of(context).textTheme.subtitle1,
              textToDisplay: '${notifier2.translate.withdrawal}',
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TopWithdrawalWodget(translate: notifier2.translate),
                  tenPx,
                  BottomWithdrawalWidget(translate: notifier2.translate),
                  tenPx,
                  // Expanded(child: Container()),
                  ButtonWithdrawalWidget(translate: notifier2.translate),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
