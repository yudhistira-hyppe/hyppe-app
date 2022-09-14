import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/transaction/bank_account/transaction_history_model.dart';
import 'package:hyppe/ui/constant/widget/custom_cache_image.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';

class MiddleWithdrawalDetailWidget extends StatelessWidget {
  TransactionHistoryModel? data;
  LocalizationModelV2? language;

  MiddleWithdrawalDetailWidget({Key? key, this.data, this.language}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        twelvePx,
        const Divider(height: 0.2, thickness: 1, color: Color(0xffF7F7F7)),
        twelvePx,
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: CustomTextWidget(
            textToDisplay: language!.paymentDetails!,
            textStyle: Theme.of(context).textTheme.bodyText1!.copyWith(
                  color: Theme.of(context).colorScheme.onBackground,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        CustomTextWidget(
          textToDisplay: language!.wtihdrawalTo!,
          textStyle: Theme.of(context).textTheme.caption!,
        ),
        fivePx,
        fivePx,
        CustomTextWidget(
          textToDisplay: data!.namaBank!,
          textStyle: Theme.of(context).textTheme.bodyText1!,
        ),
        CustomTextWidget(
          textToDisplay: "${data!.noRek} - ${data!.namaRek}",
          textStyle: Theme.of(context).textTheme.caption!,
        ),
      ],
    );
  }
}
