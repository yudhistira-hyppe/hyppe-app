import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/widget/buysell_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/widget/empty_bank_account.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/widget/shimmer_transaction_history.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/widget/witdhdrawal_widget.dart';
import 'package:provider/provider.dart';

class TransactionHistoryInProgress extends StatefulWidget {
  const TransactionHistoryInProgress({Key? key}) : super(key: key);

  @override
  State<TransactionHistoryInProgress> createState() => _TransactionHistoryInProgressState();
}

class _TransactionHistoryInProgressState extends State<TransactionHistoryInProgress> {
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    final _notifier = context.read<TransactionNotifier>();
    _notifier.skip = 0;
    _notifier.initTransactionHistoryInProgress(context);
    _scrollController.addListener(() => _notifier.scrollListInProgress(context, _scrollController));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer2<TransactionNotifier, TranslateNotifierV2>(
      builder: (context, notifier, notifier2, child) => Scaffold(
          appBar: AppBar(
            leading: const BackButton(),
            title: CustomTextWidget(
              textStyle: theme.textTheme.subtitle1,
              textToDisplay: '${notifier2.translate.transactionInProgress}',
            ),
          ),
          body: SingleChildScrollView(
            controller: _scrollController,
            child: notifier.isLoadingInProgress
                ? const ShimmerTransactionHistory()
                : Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        notifier.dataTransactionInProgress!.isEmpty
                            ? EmptyBankAccount(
                                textWidget: Column(
                                children: [
                                  CustomTextWidget(
                                    textToDisplay: notifier2.translate.youDontHaveAnyTransactionsYet!,
                                    maxLines: 4,
                                  ),
                                ],
                              ))
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: notifier.dataTransactionInProgress!.length,
                                itemBuilder: (context, index) {
                                  String title = '';
                                  switch (notifier.dataTransactionInProgress![index].type) {
                                    case TransactionType.withdrawal:
                                      title = notifier2.translate.withdrawal!;
                                      return WithdrawalWidget(
                                        title: title,
                                        language: notifier2.translate,
                                        data: notifier.dataTransactionInProgress![index],
                                      );
                                    default:
                                      return BuySellWidget(
                                        data: notifier.dataTransactionInProgress![index],
                                        language: notifier2.translate,
                                      );
                                  }
                                }),
                        notifier.isScrollLoading ? const CustomLoading() : const SizedBox()
                      ],
                    ),
                  ),
          )),
    );
  }
}
