import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/section_widget.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

import 'notifier.dart';
import 'widgets/card_coin_widget.dart';
import 'widgets/coin_widget.dart';

class TopUpCoinPage extends StatefulWidget {
  const TopUpCoinPage({super.key});

  @override
  State<TopUpCoinPage> createState() => _TopUpCoinPageState();
}

class _TopUpCoinPageState extends State<TopUpCoinPage> {
  LocalizationModelV2? lang;

  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'Top Up Hyppe Coins');
    lang = context.read<TranslateNotifierV2>().translate;
    context.read<TopUpCoinNotifier>().initialCoin();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<TopUpCoinNotifier>(
      builder: (context, notifier, child) {
        return Scaffold(
          appBar: AppBar(
            titleSpacing: 0,
            leading: IconButton(
                onPressed: () => Routing().moveBack(),
                icon: const Icon(Icons.arrow_back_ios)),
            title: CustomTextWidget(
              textStyle: theme.textTheme.titleMedium,
              textToDisplay: '${lang?.topupcoin}',
            ),
          ),
          body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 12.0),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: CoinWidget(),
                  ),
                  SectionWidget(
                    title: lang?.buyhyppecoins??'Beli Hyppe Coins',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w400),
                  ),
                  Wrap(
                    alignment: WrapAlignment.start,
                    children: widgetGenerate(notifier),
                  ),
                ],
              ),
            ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: notifier.groupsCoins.where((e) => e.selected==true).isNotEmpty ? (){
                Navigator.pushNamed(context, Routes.paymentCoins, arguments: notifier.groupsCoins.firstWhere((e) => e.selected==true));
              }:null,
              style: ElevatedButton.styleFrom(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  backgroundColor: kHyppePrimary),
              child: const SizedBox(
                width: double.infinity,
                height: kToolbarHeight,
                child: Center(
                  child: Text('Top Up', textAlign: TextAlign.center),
                ),
              ),
            ),
          ),
        );
      }
    );
  }

  List<Widget> widgetGenerate(TopUpCoinNotifier notifier) {
    List<Widget> widget = [];
    for (var i = 0; i < notifier.groupsCoins.length; i++) {
      Widget item = Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        child: GestureDetector(
          onTap: (){
            notifier.changeSelectedCoin(i+1);
          },
          child: CardCoinWidget(
            coin: notifier.groupsCoins[i].value,
            coinlabel: notifier.groupsCoins[i].valueLabel,
            selected: notifier.groupsCoins[i].selected,
          ),
        ),
      );
      widget.add(item);
    }
    return widget;
  }
}
