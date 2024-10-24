import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/notifier.dart';
import 'package:intl/intl.dart';
import 'package:pattern_formatter/numeric_formatter.dart';
import 'package:provider/provider.dart';

class TopWithdrawalWodget extends StatelessWidget {
  final LocalizationModelV2 translate;
  const TopWithdrawalWodget({Key? key, required this.translate})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'TopWithdrawalWodget');
    return Consumer<TransactionNotifier>(
      builder: (_, notifier, __) => Container(
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
            Row(
              children: [
                CustomTextWidget(
                  textToDisplay: 'Hyppe Ballance',
                  textStyle: Theme.of(context).textTheme.titleSmall,
                ),
                fivePx,
                GestureDetector(
                  onTap: () => notifier.showRemarkWithdraw(context),
                  child: const CustomIconWidget(
                    iconData: "${AssetPath.vectorPath}info-icon.svg",
                    height: 14,
                  ),
                )
              ],
            ),
            twelvePx,
            CustomTextWidget(
              textToDisplay: System().currencyFormat(
                  amount: notifier.accountBalance?.totalsaldo ?? 0),
              textStyle: Theme.of(context)
                  .primaryTextTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            thirtyTwoPx,
            CustomTextWidget(
              textToDisplay: 'Amount',
              textStyle: Theme.of(context).textTheme.titleSmall,
            ),
            twentyPx,
            Stack(
              alignment: AlignmentDirectional.centerStart,
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 45, right: 10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.background,
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    border: Border.all(color: kHyppeLightInactive1),
                  ),
                  child: TextFormField(
                    maxLines: 1,
                    // enabled: notifier.isSavedPrice ? false : true,
                    controller: notifier.amountWithdrawalController,
                    onChanged: (val) {
                      notifier.amountWithDrawal = val.replaceAll('.', '');
                    },
                    keyboardAppearance: Brightness.dark,
                    cursorColor: const Color(0xff8A3181),
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                      ThousandsFormatter(
                        formatter: NumberFormat.decimalPattern('id'),
                      )
                    ], // Only numbers can be entered
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      fillColor: kHyppePrimary,
                      errorBorder: InputBorder.none,
                      hintStyle: Theme.of(context).textTheme.bodyMedium,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.only(bottom: 2),
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        bottomLeft: Radius.circular(8)),
                    border: Border.all(color: kHyppeLightInactive1),
                    color: kHyppeLightSurface,
                  ),
                  child: Text(
                    translate.rp ?? 'Rp',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            fivePx,
            CustomTextWidget(
              textToDisplay: notifier.errorNoBalance != ''
                  ? notifier.errorNoBalance
                  : "Minimum Withdrawal Rp 50.000",
              textStyle: TextStyle(
                color: notifier.errorNoBalance != ''
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.secondary,
              ),
            ),
            twentyFourPx,
            SizedBox(
              height: 40,
              child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: 4,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      notifier.amountWithdrawalController.text =
                          System().numberFormat(amount: (index + 1) * 50000);
                      notifier.amountWithDrawal =
                          ((index + 1) * 50000).toString();
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.background,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        border: Border.all(
                            color: notifier.amountWithDrawal ==
                                    ((index + 1) * 50000).toString()
                                ? kHyppePrimary
                                : kHyppeLightInactive1),
                      ),
                      child: Text(
                          '${System().currencyFormat(amount: (index + 1) * 50000)} '),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
