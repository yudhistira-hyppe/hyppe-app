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
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'notifier.dart';

class PaymentSuccessScreen extends StatefulWidget {
  final Map? map;
  const PaymentSuccessScreen({super.key, required this.map});

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> {
  LocalizationModelV2? lang;
  late PaymentSuccessCoinNotifier notifier;

  final ValueNotifier<bool> isloading = ValueNotifier<bool>(true);

  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'paymentcoinsuccess');
    isloading.value = true;
    lang = context.read<TranslateNotifierV2>().translate;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      notifier =
          Provider.of<PaymentSuccessCoinNotifier>(context, listen: false);
      await notifier.detailData(context, map: widget.map);
      isloading.value = false;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('id', null);
    final theme = Theme.of(context);
    Color? titleColor;
    String? textTitle;
    return WillPopScope(
      onWillPop: () async {
        // Routing().moveAndRemoveUntil(Routes.lobby, Routes.root);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          titleSpacing: 0,
          automaticallyImplyLeading: false,
          title: CustomTextWidget(
            textToDisplay: lang?.localeDatetime == 'id'
                ? 'Pembayaran Telah Berhasil'
                : 'Payment Successfully',
            textStyle:
                Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
          ),
          centerTitle: true,
        ),
        body: ValueListenableBuilder<bool>(
            valueListenable: isloading,
            builder: (context, value, _) {
              if (value) {
                return const Center(
                  child: CustomLoading(),
                );
              }
              return Consumer<PaymentSuccessCoinNotifier>(
                  builder: (context, notifier, _) {
                if (notifier.bloc.dataFetch.dataState ==
                        TransactionCoinDetailState.init ||
                    notifier.bloc.dataFetch.dataState ==
                        TransactionCoinDetailState.loading) {
                  return const Center(
                    child: CustomLoading(),
                  );
                }

                switch (notifier.transactionDetail.status) {
                  case 'Cancel':
                    titleColor = kHyppeRed;
                    textTitle =
                        lang!.localeDatetime == 'id' ? 'Batal' : 'Cancel';
                    break;
                  case 'WAITING_PAYMENT':
                    titleColor = kHyppeGreen;
                    textTitle = lang!.localeDatetime == 'id'
                        ? 'Menunggu Pembayaran'
                        : 'Awating Payment';
                    break;
                  default:
                    titleColor = kHyppeGreen;
                    textTitle =
                        lang!.localeDatetime == 'id' ? 'Berhasil' : 'Success';
                }
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      fifteenPx,
                      fifteenPx,
                      const Center(
                        child: CustomIconWidget(
                          iconData:
                              "${AssetPath.vectorPath}payment-success.svg",
                          defaultColor: false,
                        ),
                      ),
                      fifteenPx,
                      fifteenPx,
                      Container(
                        padding: const EdgeInsets.all(12.0),
                        margin: const EdgeInsets.symmetric(
                            vertical: 22.0, horizontal: 12.0),
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(
                                width: 1, color: kHyppeBurem.withOpacity(.2))),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomTextWidget(
                              textToDisplay: lang?.localeDatetime == 'id'
                                  ? 'Rincian Pesanan'
                                  : 'Order Detail',
                              textStyle:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            sixteenPx,
                            detailText('Transaction ID',
                                notifier.transactionDetail.noInvoice ?? ''),
                            sixteenPx,
                            detailText('Package ID',
                                notifier.transactionDetail.packageid ?? ''),
                            sixteenPx,
                            detailText(
                                lang?.localeDatetime == 'id'
                                    ? 'Tanggal'
                                    : 'Date',
                                DateFormat('dd MMM yyyy', "id").format(
                                    DateTime.parse(
                                        notifier.transactionDetail.createdAt ??
                                            DateTime.now().toString()))),
                            sixteenPx,
                            detailText(
                                lang?.localeDatetime == 'id' ? 'Waktu' : 'Time',
                                DateFormat('HH:mm', "id").format(DateTime.parse(
                                    notifier.transactionDetail.createdAt ??
                                        DateTime.now().toString()))),
                            sixteenPx,
                            detailText(
                                lang?.localeDatetime == 'id'
                                    ? 'Jenis Transaksi'
                                    : 'Transaction Type',
                                notifier.transactionDetail.jenisTransaksi ??
                                    'Beli Coins'),
                            sixteenPx,
                            detailText(
                                lang?.localeDatetime == 'id'
                                    ? 'Nama Paket'
                                    : 'Package Name',
                                notifier.transactionDetail.namePaket ??
                                    'Beli Coins'),
                            sixteenPx,
                            detailText(
                                lang?.localeDatetime == 'id'
                                    ? 'Jumlah Coins'
                                    : 'Total Coins',
                                System().numberFormat(
                                    amount:
                                        notifier.transactionDetail.coin ?? 0)),
                            sixteenPx,
                            detailText(
                                lang?.localeDatetime == 'id'
                                    ? 'Metode Pembayaran'
                                    : 'Payment Method',
                                '${notifier.transactionDetail.bankname} ${notifier.transactionDetail.methodename}'),
                            // sixteenPx,
                            const Divider(
                              height: 30,
                              color: kHyppeBurem,
                            ),
                            // sixteenPx,
                            detailText(
                                lang?.localeDatetime == 'id'
                                    ? 'Jumlah Pembayaran'
                                    : 'Total Price',
                                System().currencyFormat(
                                    amount: notifier.transactionDetail.amount ??
                                        0)),
                            sixteenPx,
                            detailText(
                                lang?.localeDatetime == 'id'
                                    ? 'Biaya Transaksi'
                                    : 'Transaction Fee',
                                System().currencyFormat(
                                    amount: notifier.transactionDetail
                                            .transactionFees ??
                                        0)),
                            sixteenPx,
                            const Divider(
                              height: 30,
                              color: kHyppeBurem,
                            ),
                            // sixteenPx,
                            detailText(
                                lang?.localeDatetime == 'id'
                                    ? 'Total Pembayaran'
                                    : 'Total Payment',
                                System().currencyFormat(
                                    amount: notifier
                                            .transactionDetail.totalamount ??
                                        0),
                                showicon: true,
                                bold: true)
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: ElevatedButton(
                          onPressed: () {
                            if (widget.map?['type']=='FCM'){
                              Routing()
                                .moveAndRemoveUntil(Routes.lobby, Routes.root);
                            }else{
                              Routing().moveBack();
                            }
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
                                  lang?.localeDatetime == 'id'
                                      ? 'Selesai'
                                      : 'Done',
                                  textAlign: TextAlign.center),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              });
            }),
      ),
    );
  }

  Widget detailText(text1, text2, {bool showicon = false, bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomTextWidget(
          textToDisplay: text1,
          textStyle: TextStyle(
              color: bold ? kHyppeBackground : kHyppeBurem,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal),
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
            CustomTextWidget(
              textToDisplay: text2,
              textStyle: TextStyle(
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal),
            )
          ],
        )
      ],
    );
  }
}
