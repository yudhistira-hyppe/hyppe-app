import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/all_transaction/filter/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/all_transaction/widget/shimmer_all_transaction_history.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/widget/buysell_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/widget/empty_bank_account.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/widget/reward_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/widget/witdhdrawal_widget.dart';
import 'package:provider/provider.dart';

import '../widget/voucher_widget.dart';

class AllTransaction extends StatefulWidget {
  const AllTransaction({Key? key}) : super(key: key);

  @override
  State<AllTransaction> createState() => _AllTransactionState();
}

class _AllTransactionState extends State<AllTransaction> {
  List filterList = [];
  int _select = 0;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  void selected(val) {
    setState(() {
      _select = val;
    });
  }

  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'AllTransaction');
    var _notifier = context.read<FilterTransactionNotifier>();
    _scrollController
        .addListener(() => _notifier.scrollList(context, _scrollController));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<FilterTransactionNotifier, TranslateNotifierV2>(
      builder: (_, notifier, notifier2, __) {
        return Scaffold(
          appBar: AppBar(
            leading: const BackButton(),
            title: CustomTextWidget(
              textStyle: Theme.of(context).textTheme.titleMedium,
              textToDisplay: '${notifier2.translate.transaction}',
            ),
          ),
          body: RefreshIndicator(
            strokeWidth: 2.0,
            color: Colors.purple,
            key: _refreshIndicatorKey,
            onRefresh: () async {
              notifier.scrollList(context, _scrollController, isReload: true);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              controller: _scrollController,
              child: Column(children: [
                SizedBox(
                  height: 50,
                  child: notifier.newFilterList.isNotEmpty
                      ? ListView(
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: false,
                          children: [
                            GestureDetector(
                              onTap: () {
                                notifier.resetFilter(context, back: false);
                                _select = 0;
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(5.0),
                                child: Chip(
                                  // selected: notifier.pickedVisibility(notifier.newFilterList[index]['id']),
                                  shape: StadiumBorder(
                                      side: BorderSide(
                                    color: kHyppeLightSecondary,
                                  )),
                                  label: Icon(Icons.close_rounded),
                                ),
                              ),
                            ),
                            ...List.generate(
                              notifier.newFilterList.length,
                              (index) => GestureDetector(
                                onTap: () {
                                  notifier.filter(context,
                                      notifier.newFilterList[index]['id']);
                                  notifier.filterSelected(context,
                                      notifier.newFilterList[index]['id']);
                                  if (notifier.newFilterList[index]['id'] !=
                                      1) {
                                    selected(
                                        notifier.newFilterList[index]['id']);
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Chip(
                                      // selected: notifier.pickedVisibility(notifier.newFilterList[index]['id']),
                                      backgroundColor: notifier
                                              .newFilterList[index]['selected']
                                          ? Theme.of(context)
                                              .colorScheme
                                              .onSecondary
                                          : Theme.of(context)
                                              .appBarTheme
                                              .backgroundColor,
                                      shape: StadiumBorder(
                                          side: BorderSide(
                                        color: notifier.newFilterList[index]
                                                ['selected']
                                            ? kHyppePrimary
                                            : kHyppeLightSecondary,
                                      )),
                                      label: CustomTextWidget(
                                        textToDisplay: notifier
                                            .newFilterList[index]['name'],
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                                color: notifier.newFilterList[
                                                        index]['selected']
                                                    ? kHyppePrimary
                                                    : kHyppeSecondary,
                                                fontWeight: FontWeight.bold),
                                      )),
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView(
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: false,
                          children: [
                            ...List.generate(
                              notifier.filterList.length,
                              (index) => GestureDetector(
                                onTap: () {
                                  notifier.filter(context,
                                      notifier.filterList[index]['id']);
                                  if (notifier.filterList[index]['id'] != 1) {
                                    selected(notifier.filterList[index]['id']);
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Chip(
                                      // selected: notifier.pickedVisibility(notifier.filterList[index]['id']),
                                      avatar: notifier.filterList[index]
                                                  ['icon'] ==
                                              ''
                                          ? null
                                          : CustomIconWidget(
                                              iconData:
                                                  '${AssetPath.vectorPath}${notifier.filterList[index]['icon']}',
                                            ),
                                      backgroundColor: _select ==
                                              notifier.filterList[index]['id']
                                          ? Theme.of(context)
                                              .colorScheme
                                              .onSecondary
                                          : Theme.of(context)
                                              .appBarTheme
                                              .backgroundColor,
                                      shape: StadiumBorder(
                                          side: BorderSide(
                                        color: _select ==
                                                notifier.filterList[index]['id']
                                            ? kHyppePrimary
                                            : kHyppeLightSecondary,
                                      )),
                                      label: CustomTextWidget(
                                        textToDisplay:
                                            notifier.filterList[index]['name'],
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                                color: _select ==
                                                        notifier.filterList[
                                                            index]['id']
                                                    ? kHyppePrimary
                                                    : kHyppeSecondary,
                                                fontWeight: FontWeight.bold),
                                      )),
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
                notifier.isLoading
                    ? const ShimmerAllTransactionHistory()
                    : notifier.dataAllTransaction?.isEmpty ?? false
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
                        : Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: notifier.dataAllTransaction?.length,
                                itemBuilder: (context, index) {
                                  String title = '';
                                  switch (notifier
                                      .dataAllTransaction?[index].type) {
                                    case TransactionType.withdrawal:
                                      title =
                                          notifier2.translate.withdrawal ?? '';
                                      return WithdrawalWidget(
                                        title: title,
                                        language: notifier2.translate,
                                        data:
                                            notifier.dataAllTransaction?[index],
                                      );
                                    case TransactionType.reward:
                                      title = notifier2.translate.reward ?? '';
                                      return RewardWidget(
                                        title: title,
                                        language: notifier2.translate,
                                        data:
                                            notifier.dataAllTransaction?[index],
                                      );
                                    default:
                                      if (notifier.dataAllTransaction?[index]
                                              .jenis ==
                                          "VOUCHER") {
                                        return VoucherWidget(
                                          data: notifier
                                              .dataAllTransaction?[index],
                                          language: notifier2.translate,
                                        );
                                      } else if (notifier
                                              .dataAllTransaction?[index]
                                              .jenis ==
                                          "Disbursement") {
                                        return WithdrawalWidget(
                                            title: title,
                                            language: notifier2.translate,
                                            data: notifier
                                                .dataAllTransaction?[index]);
                                      }
                                      return BuySellWidget(
                                        data:
                                            notifier.dataAllTransaction?[index],
                                        language: notifier2.translate,
                                      );
                                  }
                                }),
                          ),
                notifier.isScrollLoading
                    ? const CustomLoading()
                    : const SizedBox(),
              ]),
            ),
          ),
        );
      },
    );
  }
}
