import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/app.dart';
import 'package:hyppe/core/bloc/transaction/historytransaction/state.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/section_dropdown_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/coins/widgets/custom_listtile.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'widget/history_coin.dart';
import 'widget/shimmer_widget.dart';

class Transaction extends StatefulWidget {
  const Transaction({Key? key}) : super(key: key);

  @override
  State<Transaction> createState() => _TransactionState();
}

class _TransactionState extends State<Transaction> {
  final ScrollController scrollController = ScrollController();
  LocalizationModelV2? lang;

  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'Transaction');
    lang = context.read<TranslateNotifierV2>().translate;
    var _notifier = Provider.of<TransactionNotifier>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      initializeDateFormatting('id', null);
      _notifier.resetSelected(context, mounted);
      _notifier.getTypeFilter(context);
      _notifier.getDateFilter(context);
      _notifier.setSkip(0);
      _notifier.tempSelectedDateStart = DateTime.now().toString();
      _notifier.tempSelectedDateEnd = DateTime.now().toString();
      _notifier.initHistory(context, mounted);
      // _scrollController
      //     .addListener(() => _notifier.scrollList(context, _scrollController));
    });
    scrollController.addListener(() async {
      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent) {
        if (_notifier.isLoadMore) {
          return;
        }

        if (mounted) {
          _notifier.isLoadMore = true;
        }

        if (!_notifier.isLastPage && _notifier.isLoadMore) {
          await _notifier.loadMore(context, mounted);
        }

        if (mounted) {
          _notifier.isLoadMore = false;
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void deactivate() {
    Provider.of<TransactionNotifier>(materialAppKey.currentContext ?? context, listen: false).setIsLoading(false);
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
                    Routing().move(Routes.help);
                  },
                  icon: const Icon(Icons.info_outline_rounded))
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(color: kHyppeBurem.withOpacity(.05), border: Border.all(color: kHyppeBurem, width: .5), borderRadius: BorderRadius.circular(18.0)),
                  child: CustomListTile(
                    iconData: "${AssetPath.vectorPath}transaction-new.svg",
                    title: notifier2.translate.yourorder ?? "Pesanan Kamu",
                    onTap: () => Navigator.pushNamed(context, Routes.historyordercoin),
                  ),
                ),
                twentyPx,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomTextWidget(
                      textToDisplay: notifier2.translate.recentTransaction ?? 'Recent Transaction',
                      textStyle: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
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
                        visible: notifier.selectedFiltersValue != 1 || notifier.selectedDateValue != 1,
                        child: GestureDetector(
                          onTap: () {
                            notifier.resetSelected(context, mounted);
                            notifier.isLoading = true;
                            Future.microtask(() => notifier.initHistory(context, mounted));
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 12.0),
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            decoration: BoxDecoration(border: Border.all(color: kHyppeBurem, width: .5), borderRadius: BorderRadius.circular(32.0)),
                            child: const Icon(Icons.close),
                          ),
                        ),
                      ),
                      SectionDropdownWidget(
                          title: notifier.selectedFiltersLabel,
                          onTap: () => notifier.showButtomSheetFilters(context),
                          isActive: notifier.filterDate.isNotEmpty
                              ? notifier.filterList.firstWhere((e) => e.selected == true).index == 1
                                  ? false
                                  : true
                              : false),
                      SectionDropdownWidget(title: notifier.selectedDateLabel, onTap: () => notifier.showButtomSheetDate(context), isActive: notifier.selectedDateValue != 1
                          // isActive: false
                          ),
                    ],
                  ),
                ),
                Expanded(
                  child: Consumer<TransactionNotifier>(builder: (context, notifier, _) {
                    if ((notifier.bloc.dataFetch.dataState == HistoryTransactionState.init || notifier.bloc.dataFetch.dataState == HistoryTransactionState.loading) && !notifier.isLoadMore) {
                      return const ContentLoader();
                    } else {
                      return (notifier.result.isEmpty)
                          ? Container(
                              color: Theme.of(context).colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 10.0),
                              margin: const EdgeInsets.only(bottom: 8.0),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const CustomIconWidget(
                                      iconData: '${AssetPath.vectorPath}icon_no_result.svg',
                                      width: 160,
                                      height: 160,
                                      defaultColor: false,
                                    ),
                                    tenPx,
                                    CustomTextWidget(
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      textToDisplay: lang?.localeDatetime == 'id' ? 'Masih sepi, nih' : 'There\'s no one here',
                                      textStyle: context.getTextTheme().bodyLarge?.copyWith(fontWeight: FontWeight.w700, color: context.getColorScheme().onBackground),
                                    ),
                                    eightPx,
                                    CustomTextWidget(
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      textToDisplay: lang?.localeDatetime == 'id'
                                          ? 'Yuk, mulai miliki penghasilan dari membuat konten dan dukung creator favoritmu!'
                                          : 'Let\'s start earning from creating content and supporting your favorite creators!',
                                      textStyle: context.getTextTheme().bodyLarge,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: () async {
                                notifier.isLoadMore = false;
                                notifier.isLastPage = false;

                                notifier.page = 0;

                                await notifier.initHistory(context, mounted);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10.0),
                                margin: const EdgeInsets.only(bottom: 8.0),
                                child: ListView.builder(
                                  controller: scrollController,
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  itemCount: notifier.isLoadMore ? notifier.result.length + 1 : notifier.result.length,
                                  itemBuilder: (context, index) {
                                    if (notifier.result.length == index) {
                                      return const CustomLoading();
                                    }

                                    return HistoryCoinWidget(
                                      data: notifier.result[index],
                                      lang: lang,
                                    );
                                  },
                                ),
                              ),
                            );
                    }
                  }),
                ),
              ],
            ),
          )),
    );
  }
}
