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
import 'package:hyppe/ui/inner/home/content_v2/transaction/screen.dart';
import 'package:pattern_formatter/numeric_formatter.dart';
import 'package:provider/provider.dart';

class TopWithdrawalWodget extends StatelessWidget {
  LocalizationModelV2 translate;
  TopWithdrawalWodget({Key? key, required this.translate}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                  textStyle: Theme.of(context).textTheme.subtitle2,
                ),
                fivePx,
                const CustomIconWidget(
                  iconData: "${AssetPath.vectorPath}info-icon.svg",
                  height: 14,
                )
              ],
            ),
            twelvePx,
            CustomTextWidget(
              textToDisplay: System().currencyFormat(amount: notifier.accountBalance!.totalsaldo ?? 0),
              textStyle: Theme.of(context).primaryTextTheme.headline5!.copyWith(fontWeight: FontWeight.w700),
            ),
            thirtyTwoPx,
            CustomTextWidget(
              textToDisplay: 'Amount',
              textStyle: Theme.of(context).textTheme.subtitle2,
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
                    validator: (String? input) {
                      // if (input?.isEmpty ?? true) {
                      //   return notifier.language.pleaseSetPrice;
                      // } else {
                      //   return null;
                      // }
                    },
                    // enabled: notifier.isSavedPrice ? false : true,
                    controller: notifier.amountWithdrawal,
                    // onChanged: (val) {
                    //   if (val.isNotEmpty) {
                    //     notifier.priceIsFilled = true;
                    //   } else {
                    //     notifier.priceIsFilled = false;
                    //   }
                    // },
                    keyboardAppearance: Brightness.dark,
                    cursorColor: const Color(0xff8A3181),
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly, ThousandsFormatter()], // Only numbers can be entered
                    style: Theme.of(context).textTheme.bodyText2!.copyWith(fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      fillColor: kHyppePrimary,
                      errorBorder: InputBorder.none,
                      hintStyle: Theme.of(context).textTheme.bodyText2,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.only(bottom: 2),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8)),
                    border: Border.all(color: kHyppeLightInactive1),
                    color: kHyppeLightSurface,
                  ),
                  child: Text(
                    translate.rp!,
                    style: Theme.of(context).textTheme.bodyText2!.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            fivePx,
            const CustomTextWidget(textToDisplay: "Minimum Withdrawal Rp 50.000"),
            twentyFourPx,
            SizedBox(
              height: 40,
              child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: 4,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => notifier.amountWithdrawal.text = System().numberFormat(amount: (index + 1) * 50000),

                    // (System().numberFormat(((index + 1) * 50000))).toString(),
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.background,
                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                        border: Border.all(color: kHyppeLightInactive1),
                      ),
                      child: Text('${System().currencyFormat(amount: (index + 1) * 50000)} '),
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
