import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/section_dropdown_widget.dart';
import 'package:hyppe/ui/constant/widget/section_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/coins/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/coins/widgets/card_coin_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/coins/widgets/custom_listtile.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/notifier.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

import 'widgets/coins_widget.dart';

class CoinPage extends StatefulWidget {
  const CoinPage({super.key});

  @override
  State<CoinPage> createState() => _CoinPageState();
}

class _CoinPageState extends State<CoinPage> {
  LocalizationModelV2? lang;
  
  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'saldocoins');
    lang = context.read<TranslateNotifierV2>().translate;
    context.read<CoinNotifier>().initialCoin();
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
        actions: [
          IconButton(onPressed: (){}, icon: const Icon(Icons.info_outline))
        ],
      ),
      body: Consumer2<TransactionNotifier, CoinNotifier>(
        builder: (context, notifier, cointNotif, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 12.0),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CoinsWidget(accountBalance: System().numberFormat(amount: notifier.accountBalance?.totalsaldo ?? 0)),
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
                        title: "Tambah Akun Bank",
                        onTap: () {
                          notifier.navigateToBankAccount();
                        },
                      ),
                      const Divider(
                        color: kHyppeBurem,
                      ),
                      CustomListTile(
                        iconData: "${AssetPath.vectorPath}ic-disccount.svg",
                        title: "Kupon diskon saya",
                        onTap: () {
                          
                        },
                      )
                    ],
                  ),
                ),
                SectionWidget(
                  title: 'Aktivitas Hyppe Coins', 
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
                          onTap: () => cointNotif.resetSelected(),
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
                Wrap(
                  alignment: WrapAlignment.center,
                  children: widgetGenerate(),
                ),
              ],
            ),
          );
        }
      ),
    );
  }

  List<Widget> widgetGenerate() {
    List<Widget> widget = [];
    for (var i = 0; i < 3; i++) {
      Widget item = const Padding(
        padding: EdgeInsets.symmetric(vertical: 12.0),
        child: CardCoinWidget(title: 'Reward Jual Konten', date: '12 Jan 2023', desc: '[Deskripsi]', subdesc: 'Pendapatan hasil penjualan [Jenis Konten] dari [@username]',),
      );
      widget.add(item);
    }
    return widget;
  }
}