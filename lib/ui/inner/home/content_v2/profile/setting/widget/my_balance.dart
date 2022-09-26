import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/notifier.dart';
import 'package:provider/provider.dart';

class MyBalance extends StatelessWidget {
  const MyBalance({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionNotifier>(
      builder: (context, value, child) => Container(
        constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).colorScheme.surface,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomTextWidget(
                  textToDisplay: 'My Balance',
                  textStyle: Theme.of(context).textTheme.caption!.copyWith(),
                  textAlign: TextAlign.start,
                ),
                fivePx,
                const CustomIconWidget(
                  iconData: "${AssetPath.vectorPath}info-icon.svg",
                  height: 14,
                )
              ],
            ),
            fivePx,
            value.isLoading
                ? const CustomLoading()
                : CustomTextWidget(
                    textToDisplay: System().currencyFormat(amount: value.accountBalance!.totalsaldo ?? 0),
                    textStyle: Theme.of(context).textTheme.subtitle1!.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onBackground),
                    textAlign: TextAlign.start,
                  ),
          ],
        ),
      ),
    );
  }
}
