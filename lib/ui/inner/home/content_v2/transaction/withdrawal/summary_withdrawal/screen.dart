import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/detail_transaction/widget/two_column_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/notifier.dart';
import 'package:provider/provider.dart';

class SummaryWithdrawalScreen extends StatelessWidget {
  const SummaryWithdrawalScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<TransactionNotifier, TranslateNotifierV2>(
      builder: (_, notifier, notifier2, __) => Scaffold(
        appBar: AppBar(
          leading: const BackButton(),
          title: CustomTextWidget(
            textStyle: Theme.of(context).textTheme.subtitle1,
            textToDisplay: '${notifier2.translate.detailTransaction}',
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(11.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 2,
                      spreadRadius: 1,
                      color: Colors.black.withOpacity(0.06),
                    ),
                  ],
                  color: Theme.of(context).colorScheme.background,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextWidget(
                      textToDisplay: notifier2.translate.detailTransaction ?? '',
                      textStyle: Theme.of(context).primaryTextTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    twentyPx,
                    TwoColumnWidget(notifier2.translate.transferTo, text2: notifier.withdarawalSummarymodel?.name),
                    sixPx,
                    TwoColumnWidget(notifier2.translate.bankName, text2: notifier.withdarawalSummarymodel?.bankName),
                    sixPx,
                    TwoColumnWidget(notifier2.translate.bankAccount, text2: notifier.withdarawalSummarymodel?.bankAccount),
                    sixPx,
                    const Divider(
                      color: kHyppeLightSurface,
                    ),
                    sixPx,
                    TwoColumnWidget(notifier2.translate.withdrawalAmount, text2: System().currencyFormat(amount: notifier.withdarawalSummarymodel?.amount)),
                    notifier.withdarawalSummarymodel?.chargeInquiry != null && (notifier.withdarawalSummarymodel?.chargeInquiry ?? 0) > 0
                        ? Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: TwoColumnWidget(
                              notifier2.translate.verificationBankAccount,
                              text2: System().currencyFormat(amount: notifier.withdarawalSummarymodel?.chargeInquiry),
                            ),
                          )
                        : Container(),
                    sixPx,
                    TwoColumnWidget(notifier2.translate.adminFee, text2: System().currencyFormat(amount: notifier.withdarawalSummarymodel?.adminFee)),
                    sixPx,
                    TwoColumnWidget(notifier2.translate.withdrawal, text2: System().currencyFormat(amount: notifier.withdarawalSummarymodel?.totalAmount)),
                  ],
                ),
              ),
              twelvePx,
              Container(
                padding: const EdgeInsets.all(11.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 2,
                      spreadRadius: 1,
                      color: Colors.black.withOpacity(0.06),
                    ),
                  ],
                  border: Border.all(color: kHyppeLightInactive1),
                  color: kHyppeLightSurface,
                ),
                child: Text(
                  notifier2.translate.theBalanceWillBeTransferredToTheDesignatedAccount ?? '',
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 5,
                ),
              ),
            ],
          ),
        ),
        bottomSheet: Container(
          padding: const EdgeInsets.fromLTRB(16, 5, 16, 5),
          color: Theme.of(context).colorScheme.background,
          height: 140 * SizeConfig.scaleDiagonal,
          child: Column(
            children: [
              Text(
                notifier2.translate.byClickingWithdrawYouHereby ?? '',
                maxLines: 5,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              twentyPx,
              SizedBox(
                width: SizeConfig.screenWidth,
                child: CustomTextButton(
                  onPressed: () => notifier.navigateToPin(),
                  child: Text(notifier2.translate.withdrawal ?? ''),
                  style: ButtonStyle(backgroundColor: MaterialStateProperty.all(kHyppePrimary)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
