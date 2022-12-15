import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/all_transaction/filter/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/widget/button_transaction.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/widget/buysell_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/widget/empty_bank_account.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/widget/shimmer_transaction_history.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/widget/total_balance.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/widget/witdhdrawal_widget.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class Transaction extends StatefulWidget {
  const Transaction({Key? key}) : super(key: key);

  @override
  State<Transaction> createState() => _TransactionState();
}

class _TransactionState extends State<Transaction> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  @override
  void initState() {
    final _notifier = context.read<TransactionNotifier>();
    _notifier.skip = 0;
    _notifier.initTransactionHistory(context);
    _scrollController.addListener(() => _notifier.scrollList(context, _scrollController));
    super.initState();
  }

  @override
  void dispose() {
    context.read<TransactionNotifier>().isLoading = false;
    super.dispose();
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
              textToDisplay: '${notifier2.translate.transaction}',
            ),
          ),
          body: RefreshIndicator(
            strokeWidth: 2.0,
            color: Colors.purple,
            key: _refreshIndicatorKey,
            onRefresh: () async {
              await notifier.initTransactionHistory(context);
            },
            child: notifier.isLoading
                ? const SingleChildScrollView(child: const ShimmerTransactionHistory())
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          TotalBalance(accountBalance: System().currencyFormat(amount: notifier.accountBalance?.totalsaldo ?? 0)),
                          const ButtonTransaction(),
                          sixPx,
                          // Container(
                          //   decoration: BoxDecoration(
                          //     color: Theme.of(context).colorScheme.background,
                          //     borderRadius: BorderRadius.circular(5),
                          //     boxShadow: const [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.06), blurRadius: 2)],
                          //   ),
                          //   child: Material(
                          //     color: Colors.transparent,
                          //     child: InkWell(
                          //       onTap: () => Routing().move(Routes.transactionInProgress),
                          //       child: Container(
                          //         decoration: BoxDecoration(
                          //           borderRadius: BorderRadius.circular(8),
                          //         ),
                          //         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                          //         child: Row(
                          //           children: [
                          //             const CustomIconWidget(
                          //               iconData: "${AssetPath.vectorPath}hitory-inprogress.svg",
                          //               defaultColor: false,
                          //             ),
                          //             sixPx,
                          //             CustomTextWidget(
                          //               textToDisplay: notifier2.translate.transactionInProgress ?? '',
                          //               textStyle: Theme.of(context).textTheme.caption,
                          //             ),
                          //             Expanded(
                          //               child: Align(
                          //                 alignment: Alignment.centerRight,
                          //                 child: Container(
                          //                   padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          //                   decoration: BoxDecoration(
                          //                     borderRadius: BorderRadius.circular(8),
                          //                     color: (notifier.countTransactionProgress ?? 0) > 0 ? kHyppeDanger : kHyppeLightSecondary,
                          //                   ),
                          //                   child: CustomTextWidget(
                          //                     textToDisplay: "${notifier.countTransactionProgress}",
                          //                     textStyle: Theme.of(context).textTheme.caption?.copyWith(color: kHyppeLightBackground),
                          //                   ),
                          //                 ),
                          //               ),
                          //             )
                          //           ],
                          //         ),
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const CustomTextWidget(textToDisplay: 'Recent Transaction'),
                              CustomTextButton(
                                onPressed: () {
                                  context.read<FilterTransactionNotifier>().getTypeFilter(context);
                                  Routing().move(Routes.allTransaction);
                                },
                                child: CustomTextWidget(
                                    textToDisplay: notifier2.translate.seeMore ?? '',
                                    textStyle: Theme.of(context).textTheme.bodyText2?.copyWith(
                                          color: kHyppePrimary,
                                          fontWeight: FontWeight.bold,
                                        )),
                              )
                            ],
                          ),
                          (notifier.dataTransaction?.isEmpty ?? true)
                              ? EmptyBankAccount(
                                  textWidget: Column(
                                  children: [
                                    CustomTextWidget(
                                      textToDisplay: notifier2.translate.youDontHaveAnyTransactionsYet ?? '',
                                      maxLines: 4,
                                    ),
                                  ],
                                ))
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: notifier.dataTransaction?.length,
                                  itemBuilder: (context, index) {
                                    String title = '';
                                    switch (notifier.dataTransaction?[index].type) {
                                      case TransactionType.withdrawal:
                                        title = notifier2.translate.withdrawal ?? '';
                                        return WithdrawalWidget(
                                          title: title,
                                          language: notifier2.translate,
                                          data: notifier.dataTransaction?[index],
                                        );
                                      default:
                                        return BuySellWidget(
                                          data: notifier.dataTransaction?[index],
                                          language: notifier2.translate,
                                        );
                                    }
                                  }),
                          notifier.isScrollLoading ? const CustomLoading() : const SizedBox()
                        ],
                      ),
                    ),
                  ),
          )),
    );
  }
}
