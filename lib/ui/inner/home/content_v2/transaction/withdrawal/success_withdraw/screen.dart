import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/detail_transaction/widget/two_column_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/notifier.dart';
import 'package:provider/provider.dart';

class SuccessWithdrawScreen extends StatelessWidget {
  const SuccessWithdrawScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<TransactionNotifier, TranslateNotifierV2>(
      builder: (_, notifier, notifier2, __) => Scaffold(
          body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              twentyPx,
              const CustomIconWidget(
                iconData: "${AssetPath.vectorPath}congrats-icon.svg",
                defaultColor: false,
              ),
              twentyPx,
              Text(
                notifier2.translate.congrats!,
                style: Theme.of(context).primaryTextTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(notifier2.translate.yourTransactionisBeingProcessedNow ?? ''),
              twentyPx,
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
                      textToDisplay: notifier2.translate.detailTransaction!,
                      textStyle: Theme.of(context).primaryTextTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold),
                    ),
                    twentyPx,
                    TwoColumnWidget(notifier2.translate.transferTo, text2: notifier.withdarawalSummarymodel!.name),
                    sixPx,
                    TwoColumnWidget(notifier2.translate.bankName, text2: notifier.withdarawalSummarymodel!.bankName),
                    sixPx,
                    TwoColumnWidget(
                      'Status',
                      text2: System().statusWithdrwal(context, notifier.withdarawalmodel!.status!),
                    ),
                    sixPx,
                    TwoColumnWidget(notifier2.translate.bankAccount, text2: notifier.withdarawalSummarymodel!.bankAccount),
                    sixPx,
                    const Divider(
                      color: kHyppeLightSurface,
                    ),
                    sixPx,
                    TwoColumnWidget(notifier2.translate.withdrawalAmount, text2: System().currencyFormat(amount: notifier.withdarawalmodel!.amount)),
                    notifier.withdarawalmodel!.bankVerificationCharge != null && notifier.withdarawalmodel!.bankVerificationCharge! > 0
                        ? Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: TwoColumnWidget(
                              notifier2.translate.verificationBankAccount,
                              text2: System().currencyFormat(amount: notifier.withdarawalmodel!.bankVerificationCharge),
                            ),
                          )
                        : Container(),
                    sixPx,
                    TwoColumnWidget(notifier2.translate.adminFee, text2: System().currencyFormat(amount: notifier.withdarawalmodel!.bankDisbursmentCharge)),
                    sixPx,
                    TwoColumnWidget(notifier2.translate.withdrawal, text2: System().currencyFormat(amount: notifier.withdarawalmodel!.totalamount)),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                color: Theme.of(context).colorScheme.background,
                height: 60 * SizeConfig.scaleDiagonal,
                child: SizedBox(
                  width: SizeConfig.screenWidth,
                  child: CustomTextButton(
                    onPressed: () => notifier.backtransaction(),
                    child: Text(notifier2.translate.backtoTransaction!),
                    style: ButtonStyle(backgroundColor: MaterialStateProperty.all(kHyppePrimary)),
                  ),
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }
}
