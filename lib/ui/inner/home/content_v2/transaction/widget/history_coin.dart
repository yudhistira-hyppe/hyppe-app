import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/coins/history_transaction.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction_coin_detail/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/withdrawalcoin/detail/screen.dart';
import 'package:intl/intl.dart';

class HistoryCoinWidget extends StatelessWidget {
  final TransactionHistoryCoinModel data;
  final LocalizationModelV2? lang;
  const HistoryCoinWidget({super.key, required this.data, this.lang});

  @override
  Widget build(BuildContext context) {
    Color? titleColor;
    String? textTitle;
    switch (data.status?.toLowerCase()) {
      case 'failed':
      case 'rejected':
        titleColor = kHyppeRed;
        textTitle = lang!.localeDatetime == 'id' ? 'Gagal' : 'Failed';
        break;
      case 'pending':
      case 'in progress':
        titleColor = kHyppeRed;
        textTitle = lang!.localeDatetime == 'id' ? 'Dalam Proses' : 'In Progress';
        break;
      default:
        titleColor = kHyppeGreen;
        textTitle = lang!.localeDatetime == 'id' ? 'Berhasil' : 'Success';
    }


    return GestureDetector(
      onTap: () {
        if (data.type == 'Pembelian Coin'){
          Navigator.push(context, MaterialPageRoute(builder: (context) => TransactionCoinDetailScreen(invoiceid: data.noInvoice??'', title: lang?.localeDatetime == 'id' ? 'Detail Transaksi' : 'Transaction Detail', status: 'History',)));
        }else{
          // Fluttertoast.showToast(msg: 'Feature Not Available');
          Navigator.push(context, MaterialPageRoute(builder: (context) => TransactionDetailScreen(invoiceid: data.noInvoice??'', title: lang?.localeDatetime == 'id'
              ? 'Detail Transaksi'
              : 'Transaction Detail',)));
        }
        // 
      },
      child: Container(
        width: double.infinity,
        height: SizeConfig.screenHeight! * .22,
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
        margin: const EdgeInsets.symmetric(vertical: 12.0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(width: .5, color: kHyppeBurem.withOpacity(.2)),
            color: kHyppeBurem.withOpacity(.05)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lang!.localeDatetime == 'id'
                          ? data.type == 'Penukaran Coin' ? 'Penukaran Coin' : 'Pembelian Coins'
                          : data.type == 'Penukaran Coin' ? 'Exchanged Coins' : 'Coin Purchase',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.start,
                    ),
                    CustomTextWidget(
                      textToDisplay: DateFormat('dd MMM yyyy', lang!.localeDatetime)
                          .format(DateTime.parse(data.updatedAt ?? '2024-03-02')),
                      // textStyle: textTheme.bodyMedium,
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                      color: titleColor.withOpacity(.2),
                      borderRadius: BorderRadius.circular(18.0)),
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                  child: CustomTextWidget(
                      textToDisplay: textTitle,
                      textStyle: TextStyle(color: titleColor),
                    ),
                )
              ],
            ),
            tenPx,
            const Divider(
              thickness: .2,
              color: kHyppeBurem,
            ),
            Flexible(
              child: SizedBox(
                height: SizeConfig.screenHeight! * .2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(lang?.localeDatetime == 'id' ? data.subtitleId??'' : data.subtitleEn??'', 
                      maxLines: 2,
                      style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                                fontWeight: FontWeight.bold),
                        textAlign: TextAlign.start,
                    ),
                    Text(lang?.localeDatetime == 'id' ? data.contentId??'' : data.contentEn??'', 
                      maxLines: 2,
                      style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(
                                color: kHyppeBurem),
                        textAlign: TextAlign.start,
                    ),
                  ],
                ),
              ),
            ),

            fifteenPx,
            Align(
              alignment: Alignment.bottomLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Text('Total', 
                      style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(
                                color: kHyppeBurem,
                                fontWeight: FontWeight.bold),
                        textAlign: TextAlign.start,
                    ),
                  ),
                  CustomTextWidget(
                    textToDisplay: System().currencyFormat(amount: data.detail![0].totalAmount),
                    textStyle: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(
                            fontWeight: FontWeight.bold),
                    textAlign: TextAlign.start,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
