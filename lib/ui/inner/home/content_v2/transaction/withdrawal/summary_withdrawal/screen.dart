import 'package:flutter/material.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/detail_transaction/widget/two_column_widget.dart';
import 'package:provider/provider.dart';

class SummaryWithdrawalScreen extends StatelessWidget {
  const SummaryWithdrawalScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<TranslateNotifierV2>(
      builder: (_, notifier2, __) => Scaffold(
        appBar: AppBar(
          leading: const BackButton(),
          title: CustomTextWidget(
            textStyle: Theme.of(context).textTheme.subtitle1,
            textToDisplay: '${notifier2.translate.detailTransaction}',
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(11.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 2,
                      spreadRadius: 1,
                      color: Colors.black.withOpacity(0.06),
                    ),
                  ],
                  color: Theme.of(context).colorScheme.background,
                ),
                child: Column(
                  children: [
                    CustomTextWidget(textToDisplay: notifier2.translate.detailTransaction!),
                    TwoColumnWidget('asd', text2: 'asdasd'),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
