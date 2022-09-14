import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/transaction/bank_account/transaction_history_model.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/detail_transaction/widget/two_column_widget.dart';

class BottomDetailWidget extends StatelessWidget {
  TransactionHistoryModel? data;
  LocalizationModelV2? language;

  BottomDetailWidget({Key? key, this.data, this.language}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data!.type == TransactionType.withdrawal) {
      return withdrawWidget(context);
    } else {
      return buySellWidget(context);
    }
  }

  Widget withdrawWidget(context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      twelvePx,
      const Divider(height: 0.2, thickness: 1, color: Color(0xffF7F7F7)),
      twelvePx,
      data!.bankverificationcharge! > 0
          ? TwoColumnWidget(
              language!.verificationBankAccount!,
              text2: System().currencyFormat(amount: data!.bankverificationcharge),
            )
          : Container(),
      TwoColumnWidget(language!.adminFee!, text2: System().currencyFormat(amount: data!.adminFee)),
      CustomTextWidget(
        textToDisplay: language!.ballanceAmount!,
        textStyle: Theme.of(context).textTheme.caption!,
        maxLines: 3,
      ),
      sixPx,
      CustomTextWidget(
        textToDisplay: System().currencyFormat(amount: data!.totalamount),
        textStyle: Theme.of(context).textTheme.bodyText1!.copyWith(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.bold),
      ),
    ]);
  }

  Widget buySellWidget(context) {
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
        TwoColumnWidget(language!.totalPrice!, text2: System().currencyFormat(amount: data!.amount)),
        TwoColumnWidget(language!.totalIncome!, text2: System().currencyFormat(amount: data!.amount)),
      ],
    );
  }
}
