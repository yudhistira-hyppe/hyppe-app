import 'dart:convert';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hyppe/core/bloc/monetization/transaction/state.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/content_discount.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/coins/coinmodel.dart';
import 'package:hyppe/core/models/collection/discount/discountmodel.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/bank_data.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/loading_screen.dart';
import 'package:hyppe/ui/constant/widget/section_widget.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

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
  
  
  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'methodpaymentscoins');
    lang = context.read<TranslateNotifierV2>().translate;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      context.read<PaymentCoinNotifier>().discount = DiscountModel();
      var nn = Provider.of<PaymentCoinNotifier>(context, listen: false);
      nn.translate(lang!);
      nn.initState(context);
      nn.bankSelected = '0';
      var map = ModalRoute.of(context)!.settings.arguments as CointModel;
      nn.selectedCoin = map;
      await nn.initCoinPurchaseDetail(context);
    });
    super.initState();
  }

  @override
  void dispose() {
    
    super.dispose();
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
                notifier.isLoading
                ? const Center(child: CustomLoading())
                : const CardVirtualAccountWidget(),
                SectionWidget(
                  title: lang?.paymentDetails ?? 'Rincian Pembayaran',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const DetailPayWidget(),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, Routes.mydiscount, arguments: {'routes': Routes.paymentCoins, 'totalPayment': notifier.selectedCoin.price??0, 'discount': notifier.discount, 'productType': ContentDiscount.discpaketcoin}),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 12.0),
                    decoration: BoxDecoration(
                      border: Border.all(width: .3, color: kHyppeBurem),
                      borderRadius: BorderRadius.circular(12.0),
                      color: kHyppeBurem.withOpacity(.03)
                    ),
                    child: ListTile(
                      minLeadingWidth: 10,
                      leading: const CustomIconWidget(
                        iconData: "${AssetPath.vectorPath}ic-kupon.svg",
                        defaultColor: false,
                      ),
                      title: (notifier.discount.checked??false) ? Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTextWidget(textToDisplay: '${lang?.discount} ${System().currencyFormat(amount: notifier.discount.nominal_discount)}'),
                          CustomTextWidget(textToDisplay: notifier.discount.code_package??'', textStyle: const TextStyle(color: kHyppeBurem, fontWeight: FontWeight.w400),),
                        ],
                      ):Text(lang?.discountForYou ?? 'Diskon Untukmu'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                    ),
                  ),
                )
              ],
            ),
          ),
          bottomNavigationBar: Container(
            margin: const EdgeInsets.symmetric(vertical: 22, horizontal: 18.0),
            child: ElevatedButton(
              onPressed: notifier.data !=null && notifier.data!.where((element) => element.bankcode!.toLowerCase() == notifier.bankSelected.toLowerCase()).isNotEmpty && !notifier.isLoadingPayNow ? () async {
                
                LoadingScreen.show(context, lang?.processing??'Memproses');
                await notifier.payNow(context);
                
                if (!mounted) return;
                
                Future.delayed(const Duration(milliseconds: 300),() async {
                  await LoadingScreen.hide(context);
                  Future.delayed(const Duration(milliseconds: 200),() {
                    if (notifier.blocPayNow.dataFetch.dataState == TransactionCoinState.getcBlocSuccess){
                      BankData bankdata = notifier.data![notifier.data!.indexWhere((e) => e.bankcode == notifier.bankSelected)];
                      Routing().moveBack();
                      Navigator.pushReplacementNamed(context, Routes.transactionwaiting, arguments: {'bank':bankdata, 'transaction':notifier.transactionCoinDetail});
                    }else if(notifier.blocPayNow.dataFetch.dataState == TransactionCoinState.getBlocError){
                      // print(notifier.blocPayNow.dataFetch.data['message']);
                      Fluttertoast.showToast(msg: notifier.blocPayNow.dataFetch.data['message']);
                    }
                  
                  });
                });
                
              } : null,
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