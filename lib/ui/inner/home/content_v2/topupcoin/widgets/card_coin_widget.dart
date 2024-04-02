import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';

class CardCoinWidget extends StatelessWidget {
  final int coin;
  final int coinlabel;
  final bool selected;
  const CardCoinWidget({super.key, required this.coin, required this.coinlabel, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 3.8,
      height: MediaQuery.of(context).size.width / 5,
      decoration: BoxDecoration(
        color: kHyppeBurem.withOpacity(.05),
        border: Border.all(width: selected ? 2 : .3, color: selected ? kHyppePrimary : kHyppeBurem),
        borderRadius: BorderRadius.circular(12.0)
      ),
      child: Stack(
        children: [
          Visibility(
            visible: selected,
            child: const Positioned(
              right: 5,
              top: 5,
              child: CustomIconWidget(
                iconData: "${AssetPath.vectorPath}ic-check_circle.svg",
                defaultColor: false,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(right: 8.0),
                      child: CustomIconWidget(
                        iconData: "${AssetPath.vectorPath}ic-coin.svg",
                        defaultColor: false,
                        height: 18,
                      ),
                    ),
                    CustomTextWidget(
                      textToDisplay: System().numberFormat(amount: coin),
                      textStyle: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onBackground),
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
                fivePx,
                CustomTextWidget(
                  textToDisplay: System().currencyFormat(amount: coinlabel),
                  textStyle: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                          fontWeight: FontWeight.w400),
                  textAlign: TextAlign.start,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}