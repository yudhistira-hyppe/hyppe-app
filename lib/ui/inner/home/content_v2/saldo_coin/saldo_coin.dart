import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

import '../../../../constant/widget/custom_icon_widget.dart';
import '../../../../constant/widget/custom_text_widget.dart';
import 'notifier.dart';

class SaldoCoinWidget extends StatefulWidget {
  final int transactionCoin;
  final Function(bool, int)? isChecking;
  const SaldoCoinWidget({super.key, required this.transactionCoin, this.isChecking});

  @override
  State<SaldoCoinWidget> createState() => _SaldoCoinWidgetState();
}

class _SaldoCoinWidgetState extends State<SaldoCoinWidget> {
  late SaldoCoinNotifier notifier;
  @override
  void initState() {
    super.initState();
    notifier = Provider.of<SaldoCoinNotifier>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      notifier.initSaldo(context);
      notifier.transactionCoin = widget.transactionCoin;
      widget.isChecking!(notifier.visibilityTransaction, notifier.saldoCoin);
    });
  }

  @override
  void didUpdateWidget(SaldoCoinWidget oldWidget) {
    if (oldWidget.transactionCoin != widget.transactionCoin) {
      notifier.transactionCoin = widget.transactionCoin;
      notifier.checkSaldoCoin();
    }

    Future.delayed(const Duration(milliseconds: 300), () {
      widget.isChecking!(notifier.visibilityTransaction, notifier.saldoCoin);
    });
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Consumer<SaldoCoinNotifier>(builder: (context, notifier, _) {
      return Container(
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: CustomIconWidget(
                    iconData: "${AssetPath.vectorPath}ic-coin.svg",
                    height: 32,
                    defaultColor: false,
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(style: textTheme.labelLarge?.copyWith(color: Colors.black), children: [
                        const TextSpan(
                          text: 'Saldo : ',
                        ),
                        TextSpan(
                          text: System().numberFormat(amount: notifier.saldoCoin),
                        )
                      ]),
                    ),
                    Visibility(
                      visible: !notifier.visibilityTransaction,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: RichText(
                          text: TextSpan(children: [
                            TextSpan(text: 'Saldo kurang ', style: textTheme.labelLarge?.copyWith(color: kHyppeBurem, fontSize: 12, fontWeight: FontWeight.normal)),
                            TextSpan(
                                text: System().numberFormat(amount: notifier.transactionCoin - notifier.saldoCoin), style: textTheme.labelLarge?.copyWith(color: Colors.red.shade900, fontSize: 12)),
                            TextSpan(
                                text: ' Coins',
                                style: textTheme.labelLarge?.copyWith(
                                  color: Colors.red.shade900,
                                  fontSize: 12,
                                ))
                          ]),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: widget.transactionCoin < notifier.saldoCoin,
                      // visible: true,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: RichText(
                          text: TextSpan(children: [
                            TextSpan(text: 'Saldo yang akan digunakan ', style: textTheme.labelLarge?.copyWith(color: kHyppeBurem, fontSize: 12, fontWeight: FontWeight.normal)),
                            TextSpan(text: System().numberFormat(amount: notifier.transactionCoin), style: textTheme.labelLarge?.copyWith(fontSize: 12, fontWeight: FontWeight.bold)),
                            TextSpan(text: ' Coins', style: textTheme.labelLarge?.copyWith(fontSize: 12, fontWeight: FontWeight.bold))
                          ]),
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
            GestureDetector(
              onTap: () {
                Routing().move(Routes.topUpCoins);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                width: kToolbarHeight * 1.8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18.0),
                  color: Colors.black.withOpacity(.7),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CustomTextWidget(
                      textToDisplay: 'Top Up',
                      textStyle: textTheme.labelLarge?.copyWith(color: Colors.white),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.white,
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      );
    });
  }
}
