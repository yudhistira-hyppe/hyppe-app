import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/transaction/transaction_buy_content.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SuccessBuyContentCcreen extends StatelessWidget {
  final TransactionBuyContentModel? data;
  final LocalizationModelV2 lang;
  const SuccessBuyContentCcreen({super.key, required this.data, required this.lang});

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('id', null);
    // print('======== $data');
    final translate = context.read<TranslateNotifierV2>().translate;
    return WillPopScope(
      onWillPop: () async {
        Routing().moveAndRemoveUntil(Routes.lobby, Routes.root);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          titleSpacing: 0,
          automaticallyImplyLeading: false,
          title: CustomTextWidget(
            textToDisplay: translate.localeDatetime == 'id'
                ? 'Pembayaran Telah Berhasil'
                : 'Payment Successfully',
            textStyle:
                Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              fifteenPx,
              fifteenPx,
              const Center(
                child: CustomIconWidget(
                  iconData: "${AssetPath.vectorPath}payment-success.svg",
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
                      textToDisplay: translate.localeDatetime == 'id' ? 'Rincian Pesanan' : 'Detail Order',
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    sixteenPx,
                    detailText(
                        'Transaction ID', data?.noinvoice ?? ''),
                    sixteenPx,
                    detailText(translate.localeDatetime == 'id' ? 'Alamat Email' : 'Email Address', data?.email ?? ''),
                    sixteenPx,
                    detailText(
                        translate.localeDatetime == 'id'?'Tanggal':'Date',
                        DateFormat('dd MMM yyyy', "id").format(DateTime.parse(
                            data?.waktu ??
                                DateTime.now().toString()))),
                    sixteenPx,
                    detailText(
                        translate.localeDatetime == 'id' ? 'Waktu' : 'Time',
                        DateFormat('HH:mm', "id").format(DateTime.parse(
                            data?.waktu ??
                                DateTime.now().toString()))),
                    sixteenPx,
                    detailText(translate.localeDatetime == 'id' ? 'Jenis Transaksi' : 'Transaction Type', data?.jenisTransaksi),
                    sixteenPx,
                    detailText(translate.localeDatetime == 'id' ? 'Harga Konten' : 'Price',
                        '${System().numberFormat(amount: data?.amount??0)} Coins'),
                    sixteenPx,
                    if (data?.diskon != 0 || data?.diskon != null)
                    detailText(translate.localeDatetime == 'id' ? 'Diskon' : 'Disccount',
                        '${System().numberFormat(amount: data?.diskon??0)} Coins'),
                    sixteenPx,
                    detailText(translate.localeDatetime == 'id' ? 'Metode Pembayaran' : 'Payment Method',
                        data?.paymentmethod??''),
                    // sixteenPx,
                    const Divider(
                      height: 30,
                      color: kHyppeBurem,
                    ),
                    // sixteenPx,
                    detailText(translate.localeDatetime == 'id' ? 'Jumlah Pembayaran' : 'Total Payment',
                        '${System().numberFormat(amount: data?.total ?? 0)} Coins'),
                    // sixteenPx,
                    const Divider(
                      height: 30,
                      color: kHyppeBurem,
                    ),
                    // sixteenPx,
                    detailText(
                        'Total Pembayaran',
                        System().numberFormat(
                            amount: data?.total ?? 0),
                        showicon: true)
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: ElevatedButton(
                  onPressed: () {
                    Routing().moveAndRemoveUntil(Routes.lobby, Routes.root);
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
                          translate.localeDatetime == 'id' ? 'Selesai' : 'Done',
                          textAlign: TextAlign.center),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
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
