import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/transaction/bank_account/transaction_history_model.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/notifier.dart';
import 'package:provider/provider.dart';

class RewardWidget extends StatelessWidget {
  final String? title;
  final TransactionHistoryModel? data;
  final LocalizationModelV2? language;
  const RewardWidget({Key? key, this.title, this.data, this.language}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'RewardWidget');
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: kHyppeBurem.withOpacity(.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kHyppeBurem.withOpacity(.3))
        // boxShadow: [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.06), blurRadius: 2)],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            context.read<TransactionNotifier>().getDetailTransactionHistory(context, id: data?.id ?? '', type: System().convertTransactionTypeToString(data?.type), jenis: data?.jenis, isReward: true);
            context.read<TransactionNotifier>().navigateToDetailTransaction();
          },
          child: Container(
            padding: const EdgeInsets.all(11),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: kHyppeGreyLight,
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.06), blurRadius: 2)],
                  ),
                  child: CustomTextWidget(
                    textToDisplay: title ?? '',
                    textStyle: Theme.of(context).textTheme.button?.copyWith(color: kHyppeGrey),
                  ),
                ),
                Divider(height: 0.2, thickness: 1, color: kHyppeBurem.withOpacity(.3)),
                twelvePx,
                CustomTextWidget(
                  textToDisplay: language?.reward ?? '',
                  textStyle: Theme.of(context).textTheme.bodyText2?.copyWith(color: Theme.of(context).colorScheme.onBackground),
                ),
                fourPx,
                CustomTextWidget(
                  textToDisplay: language?.fromBalance ?? '',
                  textStyle: Theme.of(context).textTheme.caption,
                ),
                tenPx,
                CustomTextWidget(
                  textToDisplay: language?.amountEarned ?? '',
                  textStyle: Theme.of(context).textTheme.caption,
                ),
                fourPx,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomTextWidget(
                      textToDisplay: '${data?.debetKredit} ${System().currencyFormat(amount: data?.totalamount)}',
                      textStyle: Theme.of(context).textTheme.bodyText1?.copyWith(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.bold),
                    ),
                    CustomTextWidget(
                      textToDisplay: System().dateFormatter(data?.timestamp?.substring(0, 10) ?? '', 3),
                      textStyle: Theme.of(context).textTheme.caption ?? const TextStyle(),
                    ),
                  ],
                ),
                fourPointFivePx
              ],
            ),
          ),
        ),
      ),
    );
  }
}
