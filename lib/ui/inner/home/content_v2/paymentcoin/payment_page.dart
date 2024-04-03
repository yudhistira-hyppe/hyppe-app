import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/loading_screen.dart';
import 'package:hyppe/ui/constant/widget/section_widget.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

import '../topupcoin/notifier.dart';
import 'notifier.dart';
import 'widgets/card_virtual_account.dart';
import 'widgets/detail_pay.dart';

class PaymentCoinPage extends StatefulWidget {
  const PaymentCoinPage({super.key});

  @override
  State<PaymentCoinPage> createState() => _PaymentCoinPageState();
}

class _PaymentCoinPageState extends State<PaymentCoinPage> {
  LocalizationModelV2? lang;
  GroupCoinModel? selectedCoin;
  
  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'methodpaymentscoins');
    lang = context.read<TranslateNotifierV2>().translate;
    context.read<PaymentCoinNotifier>().initialPayment();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    var map = ModalRoute.of(context)!.settings.arguments as GroupCoinModel;
    selectedCoin = map;
    super.didChangeDependencies();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<PaymentCoinNotifier>(
      builder: (context, notifier, child) {
        return Scaffold(
          appBar: AppBar(
            titleSpacing: 0,
            leading: IconButton(onPressed: () => Routing().moveBack(), icon: const Icon(Icons.arrow_back_ios)),
            title: CustomTextWidget(
              textStyle: theme.textTheme.titleMedium,
              textToDisplay: '${lang?.selectPaymentMethod}',
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionWidget(
                  title: 'Virtual Account',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const CardVirtualAccountWidget(),
                SectionWidget(
                  title: 'Rincian Pembayaran',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                DetailPayWidget(value1: selectedCoin?.valueLabel??0),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12.0),
                  decoration: BoxDecoration(
                    border: Border.all(width: .3, color: kHyppeBurem),
                    borderRadius: BorderRadius.circular(12.0),
                    color: kHyppeBurem.withOpacity(.03)
                  ),
                  child: const ListTile(
                    minLeadingWidth: 10,
                    leading: CustomIconWidget(
                      iconData: "${AssetPath.vectorPath}ic-kupon.svg",
                      defaultColor: false,
                    ),
                    title: Text('Gunakan Kupon Diskon'),
                    trailing: Icon(Icons.arrow_forward_ios),
                  ),
                )
              ],
            ),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: notifier.groupsVA.where((e) => e.selected==true).isNotEmpty ? (){
                debugPrint(notifier.groupsVA.firstWhere((e) => e.selected==true).text);
                LoadingScreen.show(context, lang?.processing??'Memproses');
                Future.delayed(const Duration(seconds: 5), () {
                  // 5s over, navigate to a new page
                  LoadingScreen.hide(context);
                });

                // Navigator.pushNamed(context, Routes.paymentCoins, arguments: notifier.groupsVA.firstWhere((e) => e.selected==true));
              }:null,
              style: ElevatedButton.styleFrom(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  backgroundColor: kHyppePrimary),
              child: SizedBox(
                width: double.infinity,
                height: kToolbarHeight,
                child: Center(
                  child: Text('${lang?.paynow}', textAlign: TextAlign.center),
                ),
              ),
            ),
          ),
        );
      }
    );
  }
}