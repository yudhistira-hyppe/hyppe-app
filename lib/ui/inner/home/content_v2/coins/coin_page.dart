import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hyppe/core/bloc/transaction/historytransaction/state.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/section_dropdown_widget.dart';
import 'package:hyppe/ui/constant/widget/section_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/coins/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/coins/widgets/card_coin_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/coins/widgets/custom_listtile.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../transaction_coin_detail/screen.dart';
import 'widgets/coins_widget.dart';
import 'widgets/shimmer_widget.dart';

class CoinPage extends StatefulWidget {
  const CoinPage({super.key});

  @override
  State<CoinPage> createState() => _CoinPageState();
}

class _CoinPageState extends State<CoinPage> {
  LocalizationModelV2? lang;
  final ScrollController scrollController = ScrollController();
  
  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'saldocoins');
    lang = context.read<TranslateNotifierV2>().translate;
    var notifier = Provider.of<CoinNotifier>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      initializeDateFormatting('id', null);
      notifier.getDateFilter(context);
      notifier.getTypeFilter(context);
      notifier.initialCoin();
      notifier.initHistory(context, mounted);
      notifier.tempSelectedDateStart = DateTime.now().toString();
      notifier.tempSelectedDateEnd = DateTime.now().toString();

    });
    scrollController.addListener(() async {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent) {
        if (notifier.isLoadMore) {
          return;
        }

        if (mounted) {
          notifier.isLoadMore = true;
        }

        if (!notifier.isLastPage && notifier.isLoadMore) {
          await notifier.loadMore(context, mounted);
        }

        if (mounted) {
          notifier.isLoadMore = false;
        }
      }
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(onPressed: () => Routing().moveBack(), icon: const Icon(Icons.arrow_back_ios)),
        title: CustomTextWidget(
          textStyle: theme.textTheme.titleMedium,
          textToDisplay: '${lang?.saldocoins}',
        ),
      ),
      body: Consumer2<TransactionNotifier, CoinNotifier>(
        builder: (context, notifier, cointNotif, child) {
          return RefreshIndicator(
            onRefresh: () async {
              await context.read<TransactionNotifier>().initSaldo(context);
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 12.0),
              physics: const BouncingScrollPhysics(),
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CoinsWidget(accountBalance: System().numberFormat(amount: notifier.saldoCoin,), lang: lang),
                  thirtySixPx,
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: kHyppeBurem, width: .5),
                      borderRadius: BorderRadius.circular(18.0)
                    ),
                    child: Column(
                      children: [
                        CustomListTile(
                          iconData: "${AssetPath.vectorPath}ic-bank.svg",
                          title: lang?.localeDatetime =='id'? "Tambah Akun Bank" : 'Add Bank Account',
                          onTap: () {
                            notifier.navigateToBankAccount();
                          },
                        ),
                        const Divider(
                          color: kHyppeBurem,
                        ),
                        CustomListTile(
                          iconData: "${AssetPath.vectorPath}ic-disccount.svg",
                          title: lang?.discountForYou ?? 'Diskon Untukmu',
                          onTap: () {
                            Navigator.pushNamed(context, Routes.mydiscount, arguments: {'routes': Routes.saldoCoins});
                          },
                        )
                      ],
                    ),
                  ),
                  SectionWidget(
                    title: lang?.localeDatetime =='id' ? 'Aktivitas Hyppe Coins' : 'Hyppe Coins Activities', 
                    style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Container(
                    height: kToolbarHeight - 8,
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      children: [
                        Visibility(
                          visible: cointNotif.selectedTransValue != 1 || cointNotif.selectedDateValue != 1,
                          child: GestureDetector(
                            onTap: () {
                              cointNotif.resetSelected(context);
                              Future.microtask(() =>
                                cointNotif.initHistory(context, mounted));
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 12.0),
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              decoration: BoxDecoration(
                                border: Border.all(color: kHyppeBurem, width: .5),
                                borderRadius: BorderRadius.circular(32.0)
                              ),
                              child: const Icon(Icons.close),
                            ),
                          ),
                        ),
                        SectionDropdownWidget(
                          title: cointNotif.selectedTransLabel, 
                          onTap: () => cointNotif.showButtomSheetTransaction(context),
                          isActive: cointNotif.groupsTrans.firstWhere((e) => e.selected==true).index == 1 ? false : true,
                        ),
                        SectionDropdownWidget(
                          title: cointNotif.selectedDateLabel, 
                          onTap: () => cointNotif.showButtomSheetDate(context),
                          isActive: cointNotif.groupsDate.firstWhere((e) => e.selected==true).index == 1 ? false : true,
                        ),
                      ],
                    ),
                  ),
                  if ((cointNotif.bloc.dataFetch.dataState ==
                                HistoryTransactionState.init ||
                            cointNotif.bloc.dataFetch.dataState ==
                                HistoryTransactionState.loading) &&
                        !cointNotif.isLoadMore)
                        const ContentLoader()
                  else if (cointNotif.result.isEmpty)
                    Container(
                      color: Theme.of(context).colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 18.0),
                      margin: const EdgeInsets.only(bottom: 8.0),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const CustomIconWidget(
                              iconData:
                                  '${AssetPath.vectorPath}icon_no_result.svg',
                              width: 160,
                              height: 160,
                              defaultColor: false,
                            ),
                            tenPx,
                            CustomTextWidget(
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              textToDisplay: lang?.localeDatetime == 'id'
                                  ? 'Masih sepi, nih'
                                  : 'There\'s no one here',
                              textStyle: context
                                  .getTextTheme()
                                  .bodyLarge
                                  ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: context
                                          .getColorScheme()
                                          .onBackground),
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
                  else Wrap(
                      alignment: WrapAlignment.center,
                      children: widgetGenerate(cointNotif),
                    )
                ],
              ),
            ),
          );
        }
      ),
    );
  }

  List<Widget> widgetGenerate(CoinNotifier notifier) {
    List<Widget> widget = [];
    int lengthResult = notifier.result.length;
    for (var i = 0; i < lengthResult; i++) {
      if (notifier.result.length == i && notifier.isLoadMore){
        Widget item =  const CustomLoading();
        widget.add(item);
      }
      Widget item = Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: GestureDetector(
          onTap: (){
            if (notifier.result[i].type == 'Pembelian Coin'){
              Navigator.push(context, MaterialPageRoute(builder: (context) => TransactionCoinDetailScreen(invoiceid: notifier.result[i].sId??'', status: 'History',)));
            }else{
              Fluttertoast.showToast(msg: 'Feature Not Available');
            }
          },
          child: CardCoinWidget(
            title: notifier.result[i].coa??'', 
            totalCoin: notifier.result[i].totalCoin??0,
            date: DateFormat('dd MMM yyyy', lang!.localeDatetime).format(DateTime.parse(notifier.result[i].updatedAt ?? '2024-03-02')),
            desc: lang?.localeDatetime == 'id' ? notifier.result[i].descTitleId : notifier.result[i].descTitleEn, 
            subdesc: lang?.localeDatetime == 'id' ? notifier.result[i].descContentId : notifier.result[i].descContentEn, 
          ),
        ),
      );
      widget.add(item);
    }
    return widget;
  }
}