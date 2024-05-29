import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/bloc/monetization/detailtransaction/state.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'notifier.dart';

class TransactionCoinDetailScreen extends StatefulWidget {
  final String? invoiceid;
  const TransactionCoinDetailScreen({super.key, required this.invoiceid});

  @override
  State<TransactionCoinDetailScreen> createState() => _TransactionCoinDetailScreenState();
}

class _TransactionCoinDetailScreenState extends State<TransactionCoinDetailScreen> {
  LocalizationModelV2? lang;
  late TransactionCoinDetailNotifier notifier;

  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'TransactionCoinDetail');
    lang = context.read<TranslateNotifierV2>().translate;
    initializeDateFormatting('id', null);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      notifier = Provider.of<TransactionCoinDetailNotifier>(context, listen: false);
      notifier.detailData(context, invoiceId: widget.invoiceid);
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color? titleColor;
    String? textTitle;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
            onPressed: () => Routing().moveBack(),
            icon: const Icon(Icons.arrow_back_ios)),
        title: CustomTextWidget(
          textStyle: theme.textTheme.titleMedium,
          textToDisplay: lang?.localeDatetime == 'id' ? 'Detail Transaksi' : 'Transaction Detail',
        ),
      ),
      body: Consumer<TransactionCoinDetailNotifier>(
        builder: (context, notifier, _) {
          if (notifier.bloc.dataFetch.dataState == TransactionCoinDetailState.init || notifier.bloc.dataFetch.dataState == TransactionCoinDetailState.loading){
            return const Center(child: CustomLoading(),);
          }
          
          switch (notifier.transactionDetail.status) {
            case 'Cancel':
              titleColor = kHyppeRed;
              textTitle = lang!.localeDatetime == 'id' ? 'Batal' : 'Cancel';
              break;
            case 'WAITING_PAYMENT':
              titleColor = kHyppeGreen;
              textTitle = lang!.localeDatetime == 'id' ? 'Menunggu Pembayaran' : 'Awating Payment';
              break;
            default:
              titleColor = kHyppeGreen;
              textTitle = lang!.localeDatetime == 'id' ? 'Berhasil' : 'Success';
          }
          return SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomTextWidget(
                              textToDisplay: notifier.transactionDetail.jenisTransaksi??'',
                              textStyle: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            fivePx,
                            CustomTextWidget(
                              textToDisplay: DateFormat('dd MMM yyyy, HH:mm', lang?.localeDatetime??'id').format(DateTime.parse(
                            notifier.transactionDetail.updatedAt ??
                                DateTime.now().toString())),
                              textStyle: const TextStyle(fontWeight: FontWeight.normal, color: kHyppeBurem),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: titleColor!.withOpacity(.2),
                            borderRadius: BorderRadius.circular(18.0)),
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                        child: CustomTextWidget(
                            textToDisplay: textTitle??'',
                            textStyle: TextStyle(color: titleColor),
                          ),
                      )
                    ],
                  ),
                  const Divider(
                    thickness: .2,
                  ),
                  fifteenPx,
                  CustomTextWidget(
                    textToDisplay: notifier.transactionDetail.namePaket??'',
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  fifteenPx,
                  Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(width: .2, color: kHyppeBurem),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextWidget(
                          textToDisplay: lang?.localeDatetime == 'id' ? 'Rincian Pesanan' : 'Detail Order',
                          textStyle: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        sixteenPx,
                        detailText(lang?.localeDatetime == 'id' ? 'Transaksi ID' : 'ID Transaction', notifier.transactionDetail.noInvoice),
                        sixteenPx,
                        detailText(lang?.localeDatetime == 'id' ? 'Alamat Email' : 'Email Address', notifier.transactionDetail.emailbuyer),
                        sixteenPx,
                        detailText(lang?.localeDatetime == 'id' ? 'Metode Pembayaran' : 'Payment Method', '${notifier.transactionDetail.bankname} ${notifier.transactionDetail.methodename}'),
                        sixteenPx,
                        detailText(lang?.localeDatetime == 'id' ? 'Jumlah Hyppe Coin' : 'Total Hyppe Coin', '${System().numberFormat(amount: notifier.transactionDetail.totalCoin)} Coins'),
                        const Divider(
                          thickness: .1,
                        ),
                        CustomTextWidget(
                          textToDisplay: lang?.localeDatetime == 'id' ? 'Rincian Pembayaran' : 'Detail Payment',
                          textStyle: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        sixteenPx,
                        detailText(lang?.localeDatetime == 'id' ? 'Harga Hyppe Coin' : 'Price Hyppe Coin', System().currencyFormat(amount: notifier.transactionDetail.totalPrice)),
                        sixteenPx,
                        detailText(lang?.localeDatetime == 'id' ? 'Biaya Layanan' : 'Transaction Fee', System().currencyFormat(amount: notifier.transactionDetail.transactionFees)),
                        const Divider(
                          thickness: .1,
                        ),
                        const CustomTextWidget(
                          textToDisplay: 'Total',
                          textStyle: TextStyle(color: kHyppeBurem),
                        ),
                        sixteenPx,
                        CustomTextWidget(textToDisplay: System().currencyFormat(amount: notifier.transactionDetail.totalamount),
                          textStyle: const TextStyle(fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 18.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Routing().moveBack();
                      },
                      style: ElevatedButton.styleFrom(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          backgroundColor: kHyppePrimary),
                      child: SizedBox(
                        width: 375.0 * SizeConfig.scaleDiagonal,
                        height: 44.0 * SizeConfig.scaleDiagonal,
                        child: Center(
                          child: Text(
                              lang?.localeDatetime == 'id' ? 'Selesai' : 'Done',
                              textAlign: TextAlign.center),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      ),
    );
  }

  Widget detailText(text1, text2, {bool showicon = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomTextWidget(
          textToDisplay: text1,
          textStyle: const TextStyle(color: kHyppeBurem),
        ),
        Row(
          children: [
            Visibility(
              visible: showicon,
              child: const Padding(
                padding: EdgeInsets.only(right: 12.0),
                child: CustomIconWidget(
                  iconData: "${AssetPath.vectorPath}ic-coin.svg",
                  height: 18,
                  defaultColor: false,
                ),
              ),
            ),
            CustomTextWidget(textToDisplay: text2)
          ],
        )
      ],
    );
  }
}