import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/transaction/bank_account/transaction_history_model.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/detail_transaction/widget/two_column_widget.dart';

class BottomDetailWidget extends StatelessWidget {
  final TransactionHistoryModel? data;
  final LocalizationModelV2? language;

  const BottomDetailWidget({Key? key, this.data, this.language}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'BottomDetailWidget');
    if (data?.type == TransactionType.withdrawal) {
      return withdrawWidget(context);
    } else if (data?.type == TransactionType.buy) {
      if (data?.jenis == "VOUCHER") {
        return voucherWidget(context);
      } else {
        return buyWidget(context);
      }
    } else if (data?.type == TransactionType.reward) {
      return rewardWidget(context);
    } else {
      return sellWidget(context);
    }
  }

  Widget voucherWidget(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        twelvePx,
        const Divider(height: 0.2, thickness: 1, color: Color(0xffF7F7F7)),
        twelvePx,
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: CustomTextWidget(
            textToDisplay: language?.paymentDetails ?? '',
            textStyle: Theme.of(context).textTheme.bodyText1?.copyWith(
                  color: Theme.of(context).colorScheme.onBackground,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        TwoColumnWidget(
          language?.paymentMethods,
          text2: "${data?.bank?.replaceAll("Bank ", "")} ${data?.paymentmethode == 'VA' ? 'Virtual Account' : data?.paymentmethode}",
        ),
        TwoColumnWidget("${language?.totalPrice} (${data?.detailTransaction?.length} Voucher)", text2: System().currencyFormat(amount: data?.amount ?? 0)),
        data?.adminFee == 0 ? Container() : TwoColumnWidget(language?.adminFee, text2: System().currencyFormat(amount: data?.adminFee ?? 0)),
        TwoColumnWidget(language?.serviceFee, text2: System().currencyFormat(amount: data?.serviceFee ?? 0)),
        TwoColumnWidget(
          language?.totalBelanja,
          text2: System().currencyFormat(amount: data?.totalamount ?? 0),
          textStyle1: const TextStyle(fontWeight: FontWeight.w700),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Widget withdrawWidget(context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      twelvePx,
      const Divider(height: 0.2, thickness: 1, color: Color(0xffF7F7F7)),
      twelvePx,
      TwoColumnWidget(language?.withdrawalAmount ?? '', text2: System().currencyFormat(amount: data?.amount ?? 0)),
      (data?.bankverificationcharge ?? 0) > 0
          ? TwoColumnWidget(
              language?.verificationBankAccount ?? '',
              text2: System().currencyFormat(amount: data?.bankverificationcharge),
            )
          : Container(),
      TwoColumnWidget(language?.adminFee ?? '', text2: System().currencyFormat(amount: data?.adminFee ?? 0)),
      CustomTextWidget(
        textToDisplay: language?.ballanceAmount ?? '',
        textStyle: Theme.of(context).textTheme.caption,
        maxLines: 3,
      ),
      sixPx,
      CustomTextWidget(
        textToDisplay: System().currencyFormat(amount: data?.totalamount ?? 0),
        textStyle: Theme.of(context).textTheme.bodyText1?.copyWith(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.bold),
      ),
    ]);
  }

  Widget sellWidget(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        twelvePx,
        const Divider(height: 0.2, thickness: 1, color: Color(0xffF7F7F7)),
        twelvePx,
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: CustomTextWidget(
            textToDisplay: language?.paymentDetails ?? '',
            textStyle: Theme.of(context).textTheme.bodyText1?.copyWith(
                  color: Theme.of(context).colorScheme.onBackground,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        TwoColumnWidget(language?.totalPrice ?? 'total price', text2: System().currencyFormat(amount: data?.totalamount ?? 0)),
        TwoColumnWidget(language?.totalIncome ?? 'total income', text2: System().currencyFormat(amount: data?.totalamount ?? 0)),
      ],
    );
  }

  Widget buyWidget(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        twelvePx,
        const Divider(height: 0.2, thickness: 1, color: Color(0xffF7F7F7)),
        twelvePx,
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: CustomTextWidget(
            textToDisplay: language?.paymentDetails ?? '',
            textStyle: Theme.of(context).textTheme.bodyText1?.copyWith(
                  color: Theme.of(context).colorScheme.onBackground,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        TwoColumnWidget(
          language?.paymentMethods,
          text2: "${data?.bank?.replaceAll("Bank ", "")} ${data?.paymentmethode == 'VA' ? 'Virtual Account' : data?.paymentmethode}",
        ),
        TwoColumnWidget(data?.jenis == 'BOOST_CONTENT' ? language?.boostPrice : language?.contentPrice, text2: System().currencyFormat(amount: data?.amount ?? 0)),
        data?.jenis == 'BOOST_CONTENT' ? const SizedBox() : TwoColumnWidget(language?.adminFee, text2: System().currencyFormat(amount: data?.adminFee ?? 0)),
        TwoColumnWidget(language?.serviceFee, text2: System().currencyFormat(amount: data?.serviceFee ?? 0)),
        TwoColumnWidget(language?.totalPrice, text2: System().currencyFormat(amount: data?.totalamount ?? 0)),
      ],
    );
  }

  Widget rewardWidget(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        twelvePx,
        const Divider(height: 0.2, thickness: 1, color: Color(0xffF7F7F7)),
        twelvePx,
        TwoColumnWidget(
          language?.amountEarned,
          text2: "",
        ),
        TwoColumnWidget(
          "+${System().currencyFormat(amount: data?.kredit?.toInt())}",
          text2: "",
        ),
      ],
    );
  }
}
