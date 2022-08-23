import 'package:flutter/material.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/widget/button_transaction.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/widget/total_balance.dart';
import 'package:provider/provider.dart';

class Transaction extends StatefulWidget {
  const Transaction({Key? key}) : super(key: key);

  @override
  State<Transaction> createState() => _TransactionState();
}

class _TransactionState extends State<Transaction> {
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
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: const [
                  TotalBalance(),
                  ButtonTransaction(),
                ],
              ),
            ),
          )),
    );
  }
}
