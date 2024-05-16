import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hyppe/app.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_shimmer.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/section_dropdown_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/coins/widgets/custom_listtile.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/all_transaction/filter/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/widget/buysell_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/widget/empty_bank_account.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/widget/reward_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/widget/voucher_widget.dart';
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
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'Transaction');
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final _notifier = context.read<TransactionNotifier>();
      _notifier.resetSelected();
      _notifier.getTypeFilter(context);
      _notifier.setSkip(0);
      _notifier.initTransactionHistory(context);
      _scrollController
          .addListener(() => _notifier.scrollList(context, _scrollController));
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void deactivate() {
    Provider.of<TransactionNotifier>(materialAppKey.currentContext ?? context,
            listen: false)
        .setIsLoading(false);
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer2<TransactionNotifier, TranslateNotifierV2>(
      builder: (context, notifier, notifier2, child) => Scaffold(
          appBar: AppBar(
            leading: const BackButton(),
            title: CustomTextWidget(
              textStyle: theme.textTheme.titleMedium,
              textToDisplay: '${notifier2.translate.transaction}',
            ),
            actions: [
              IconButton(
                  onPressed: () {
                    Fluttertoast.showToast(msg: 'Feature not yet available');
                  },
                  icon: const Icon(Icons.info_outline_rounded))
            ],
          ),
          body: RefreshIndicator(
            strokeWidth: 2.0,
            color: Colors.purple,
            key: _refreshIndicatorKey,
            onRefresh: () async {
              notifier.skip = 0;
              await notifier.initTransactionHistory(context);
            },
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // TotalBalance(accountBalance: System().numberFormat(amount: notifier.accountBalance?.totalsaldo ?? 0)),
                    // const ButtonTransaction(),
                    Container(
                      decoration: BoxDecoration(
                          color: kHyppeBurem.withOpacity(.05),
                          border: Border.all(color: kHyppeBurem, width: .5),
                          borderRadius: BorderRadius.circular(18.0)),
                      child: CustomListTile(
                        iconData: "${AssetPath.vectorPath}transaction-new.svg",
                        title: notifier2.translate.yourorder?? "Pesanan Kamu",
                        onTap: () => Navigator.pushNamed(context, Routes.historyordercoin),
                      ),
                    ),
                    twentyPx,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomTextWidget(
                          textToDisplay:
                              notifier2.translate.recentTransaction ??
                                  'Recent Transaction',
                          textStyle: const TextStyle(
                              fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                        // CustomTextButton(
                        //   onPressed: () {
                        //     context
                        //         .read<FilterTransactionNotifier>()
                        //         .getTypeFilter(context);
                        //     Routing().move(Routes.allTransaction);
                        //   },
                        //   child: CustomTextWidget(
                        //     textToDisplay: notifier2.translate.seeMore ?? '',
                        //     textStyle: Theme.of(context)
                        //         .textTheme
                        //         .bodyMedium
                        //         ?.copyWith(
                        //           color: kHyppePrimary,
                        //           fontWeight: FontWeight.bold,
                        //         ),
                        //   ),
                        // )
                      ],
                    ),
                    twelvePx,
                    Container(
                      height: kToolbarHeight - 8,
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        children: [
                          Visibility(
                            visible: notifier.selectedFiltersValue.isNotEmpty ||
                                notifier.selectedDateValue != 1,
                            child: GestureDetector(
                              onTap: () {
                                notifier.resetSelected();
                                notifier.isLoading = true;
                                Future.microtask(() => notifier.initTransactionHistory(context));
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 12.0),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: kHyppeBurem, width: .5),
                                    borderRadius: BorderRadius.circular(32.0)),
                                child: const Icon(Icons.close),
                              ),
                            ),
                          ),
                          SectionDropdownWidget(
                            title: notifier.selectedFiltersValue.isEmpty
                                ? notifier.selectedFiltersLabel
                                : notifier.selectedFiltersValue
                                    .map((e) => e)
                                    .join(', '),
                            onTap: () {
                              notifier.selectedTransaksi = false;
                              notifier.showButtomSheetFilters(context);
                              notifier.loadpickType();
                            },
                            isActive: notifier.selectedFiltersValue.isNotEmpty,
                          ),
                          SectionDropdownWidget(
                              title: notifier.selectedDateLabel,
                              onTap: () =>
                                  notifier.showButtomSheetDate(context),
                              isActive: notifier.selectedDateValue != 1
                              // isActive: false
                              ),
                        ],
                      ),
                    ),
                    notifier.isLoading
                        ? SingleChildScrollView(
                            child: Column(
                            children: List.generate(
                              10,
                              (index) => Padding(
                                padding: EdgeInsets.only(
                                    top: 13 * SizeConfig.scaleDiagonal),
                                child: CustomShimmer(
                                    width: (SizeConfig.screenWidth!),
                                    height: 150,
                                    radius: 4),
                              ),
                            ),
                          ))
                        : (notifier.dataTransaction?.isEmpty ?? true)
                            ? EmptyBankAccount(
                                textWidget: Column(
                                children: [
                                  CustomTextWidget(
                                    textToDisplay: notifier2.translate
                                            .youDontHaveAnyTransactionsYet ??
                                        '',
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
                                  switch (
                                      notifier.dataTransaction?[index].type) {
                                    case TransactionType.withdrawal:
                                      title =
                                          notifier2.translate.withdrawal ?? '';
                                      return WithdrawalWidget(
                                        title: title,
                                        language: notifier2.translate,
                                        data: notifier.dataTransaction?[index],
                                      );
                                    case TransactionType.reward:
                                      title = notifier2.translate.reward ?? '';
                                      return RewardWidget(
                                        title: title,
                                        language: notifier2.translate,
                                        data: notifier.dataTransaction?[index],
                                      );
                                    default:
                                      if (notifier
                                              .dataTransaction?[index].jenis ==
                                          "VOUCHER") {
                                        return VoucherWidget(
                                          data:
                                              notifier.dataTransaction?[index],
                                          language: notifier2.translate,
                                        );
                                      } else if (notifier
                                              .dataTransaction?[index].jenis ==
                                          "Disbursement") {
                                        return WithdrawalWidget(
                                            title: title,
                                            language: notifier2.translate,
                                            data: notifier
                                                .dataTransaction?[index]);
                                      } else {
                                        return BuySellWidget(
                                          data:
                                              notifier.dataTransaction?[index],
                                          language: notifier2.translate,
                                        );
                                      }
                                  }
                                }),
                    notifier.isScrollLoading
                        ? const CustomLoading()
                        : const SizedBox()
                  ],
                ),
              ),
            ),
          )),
    );
  }
}
