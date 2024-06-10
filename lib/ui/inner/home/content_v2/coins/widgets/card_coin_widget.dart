import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';

class CardCoinWidget extends StatelessWidget {
  final String title;
  final String date;
  final String? desc;
  final String? subdesc;
  final int totalCoin;
  const CardCoinWidget({super.key, required this.title, required this.date, required this.totalCoin, this.desc, this.subdesc});

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: SizeConfig.screenHeight! * .25,
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(width: .5, color: kHyppeBurem.withOpacity(.2)),
        color: kHyppeBurem.withOpacity(.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.start,
          ),
          fivePx,
          Text(
            date,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(color: kHyppeBurem),
            textAlign: TextAlign.start,
          ),
          // tenPx,
          const Divider(
            thickness: .2,
            color: kHyppeBurem,
          ),
          Text(
            desc ?? '',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.start,
          ),
          fivePx,
          SizedBox(
            height: SizeConfig.screenHeight! * .05,
            child: Text(
              subdesc ?? '',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(color: kHyppeBurem),
              textAlign: TextAlign.start,
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Text(
              'Total',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(color: kHyppeBurem, fontWeight: FontWeight.bold),
              textAlign: TextAlign.start,
            ),
          ),
          fivePx,
          Row(
            children: [
              const Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: CustomIconWidget(
                  iconData: "${AssetPath.vectorPath}ic-coin.svg",
                  height: 18,
                  defaultColor: false,
                ),
              ),
              CustomTextWidget(
                textToDisplay: System().numberFormat(amount: totalCoin),
                textStyle: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.start,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
