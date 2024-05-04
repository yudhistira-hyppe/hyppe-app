import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/constants/utils.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:provider/provider.dart';

class DetailPayWidget extends StatelessWidget {
  final int value1;
  const DetailPayWidget({super.key, required this.value1});

  @override
  Widget build(BuildContext context) {
    LocalizationModelV2 lang = context.read<TranslateNotifierV2>().translate;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: .3, color: kHyppeBurem),
        borderRadius: BorderRadius.circular(12.0),
        color: kHyppeBurem.withOpacity(.03)
      ),
      child: Column(
        children: [
          listTile(lang.price??'Harga', value1),
          listTile(lang.transactionFee?? 'Biaya Transaksi', withdrawalfree),
          const Divider(
            thickness: .1,
          ),
          listTile(lang.totalPayment??'Total Pembayaran', value1+withdrawalfree),
        ],
      ),
    );
  }

  Widget listTile(String? label, int? value) {
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