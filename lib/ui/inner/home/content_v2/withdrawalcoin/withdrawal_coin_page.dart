import 'dart:math';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

import 'notifier.dart';
import 'widgets/bank_account_widget.dart';
import 'widgets/withdrawal_card_widget.dart';

class WithdrawalCoinPage extends StatefulWidget {
  const WithdrawalCoinPage({super.key});

  @override
  State<WithdrawalCoinPage> createState() => _WithdrawalCoinPageState();
}

class _WithdrawalCoinPageState extends State<WithdrawalCoinPage> {
  LocalizationModelV2? lang;
  
  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'exchangecoins');
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      lang = context.read<TranslateNotifierV2>().translate;
      var notif = context.read<WithdrawalCoinNotifier>();
      notif.initSaldo(context);
      notif.initialExchange();
      // notif.totalCoin = context.read<TransactionNotifier>().accountBalance?.totalsaldo??0;
      notif.textController.text = '';
      notif.initBankAccount(context);
    });
    
    super.initState();
  }
  
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<WithdrawalCoinNotifier>(
      builder: (context, notifier, child) {
        print(notifier.withdrawaltransactionDetail.amount);
        return Scaffold(
          appBar: AppBar(
            titleSpacing: 0,
            leading: IconButton(onPressed: () => Routing().moveBack(), icon: const Icon(Icons.arrow_back_ios)),
            title: CustomTextWidget(
              textStyle: theme.textTheme.titleMedium,
              textToDisplay: '${lang?.exchangeCoin}',
            ),
            actions: [
              IconButton(onPressed: ()=>context.read<WithdrawalCoinNotifier>().showButtomSheetInfo(context, lang: lang), icon: const Icon(Icons.info_outline))
            ],
          ),
          body: GestureDetector(
            onTap: (){
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  WithdrawalCardWidget(notif: notifier, lang: lang),
                  fourteenPx,
                  BankAccountWidget(notif: notifier, lang: lang,)
                ],
              ),
            ),
          ),
          bottomNavigationBar: SizedBox(
            height: kToolbarHeight * 2.5,
            child: Column(
              children: [
                Container(
                  height: kToolbarHeight,
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomTextWidget(
                        textToDisplay: lang?.localeDatetime =='id' ? 'Total Penarikan' : 'Total Withdrawal',
                        textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: kHyppeBurem
                        ),
                        textAlign: TextAlign.start,
                      ),
                      GestureDetector(
                        onTap: () => notifier.showButtomSheetFilters(context, lang, mounted),
                        child: Row(
                          children: [
                            CustomTextWidget(
                              textToDisplay: System().currencyFormat(amount: notifier.withdrawaltransactionDetail.totalAmount??0),
                              textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold
                              ),
                              textAlign: TextAlign.start,
                            ),
                            fivePx,
                            Transform.rotate(
                              angle: 90 * pi / 180,
                              child: const Icon(Icons.arrow_forward_ios, size: 18,),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: notifier.dataAcccount.where((e) => e.selected==true).isNotEmpty && notifier.textController.text.isNotEmpty ? (){
                      debugPrint(notifier.dataAcccount.firstWhere((e) => e.selected==true).bankName);
                      // debugPrint(notifier.resultValue.toString());
                      if (notifier.withdrawaltransactionDetail.amount! < 50000){
                        ShowBottomSheet().onShowColouredSheet(context, lang?.localeDatetime == 'id' ? 'Saldo minimum penarikan Rp. 50.000' :'Withdrawals must be at least IDR 50,000', textButton: '', color: Theme.of(context).colorScheme.error);
                      }else{
                        Navigator.pushNamed(context, Routes.pinwithdrawalcoin, arguments: mounted);
                      }
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
                        child: Text(lang?.localeDatetime == 'id' ? 'Tarik' : 'Withdraw', textAlign: TextAlign.center),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}