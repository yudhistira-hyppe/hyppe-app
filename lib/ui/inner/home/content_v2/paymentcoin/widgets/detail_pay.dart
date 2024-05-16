import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/inner/home/content_v2/paymentcoin/notifier.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class DetailPayWidget extends StatelessWidget {
  const DetailPayWidget({super.key});

  @override
  Widget build(BuildContext context) {
    LocalizationModelV2 lang = context.read<TranslateNotifierV2>().translate;
    return Consumer<PaymentCoinNotifier>(
      builder: (context, notifier, _) {
        return Container(
          decoration: BoxDecoration(
            border: Border.all(width: .3, color: kHyppeBurem),
            borderRadius: BorderRadius.circular(12.0),
            color: kHyppeBurem.withOpacity(.03)
          ),
          child: Column(
            children: [
              listTile(context, label: lang.price??'Harga', value: notifier.cointPurchaseDetail.price??0, notifier: notifier),
              listTile(context, label: lang.transactionFee?? 'Biaya Transaksi', value: notifier.cointPurchaseDetail.transaction_fee??0, notifier: notifier),
              
              if ((!notifier.isLoadingDetail) && notifier.cointPurchaseDetail.discount != 0)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 18.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Diskon',
                      style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.normal),
                    ),
                    Text('- ${System().currencyFormat(amount: notifier.cointPurchaseDetail.discount??0)}',
                      style: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.normal),
                    )
                  ],
                ),
              ),
              const Divider(
                thickness: .1,
              ),
              if ((!notifier.isLoadingDetail) && notifier.cointPurchaseDetail.discount != 0)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 18.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(lang.totalPayment??'Total Pembayaran',
                        style: const TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.normal),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(System().currencyFormat(amount: notifier.cointPurchaseDetail.total_before_discount),
                            style: const TextStyle(
                                color: Colors.grey,
                                decoration: TextDecoration.lineThrough,
                                fontWeight: FontWeight.normal),
                          ),
                          tenPx,
                          Text(System().currencyFormat(amount: notifier.cointPurchaseDetail.total_payment),
                            style: const TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.normal),
                          ),
                        ],
                      )
                    ],
                  ),
                )
              else
              listTile(context, label: lang.totalPayment??'Total Pembayaran', value: notifier.cointPurchaseDetail.total_before_discount, notifier: notifier),
            ],
          ),
        );
      }
    );
  }

  Widget listTile(BuildContext context, {String? label, int? value, PaymentCoinNotifier? notifier}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 18.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label??'',
            style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.normal),
          ),
          if (notifier!.isLoadingDetail)
            SizedBox(
              height: 8,
              width: MediaQuery.of(context).size.width * .3,
              child: Shimmer.fromColors(
                baseColor: Colors.black45,
                highlightColor: Colors.white,
                child: Container(
                  height: 8,
                  width: MediaQuery.of(context).size.width * .5,
                  decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(4)),
                ),
              ),
            )
          else
          Text(System().currencyFormat(amount: value),
            style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.normal),
          )
        ],
      ),
    );
  }
}