import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:provider/provider.dart';

class MySaldoWidget extends StatelessWidget {
  const MySaldoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var trans = context.read<TranslateNotifierV2>().translate;
    return Container(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 24),
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const CustomIconWidget(
                height: 20,
                iconData: "${AssetPath.vectorPath}ic-coin.svg",
                defaultColor: false,
              ),
              sixPx,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${trans.ballance}: 200',
                    style: const TextStyle(color: kHyppeTextLightPrimary, fontWeight: FontWeight.w700),
                  ),
                  sixPx,
                  RichText(
                    text: TextSpan(
                      text: '${trans.toBeUsed} : ',
                      style: const TextStyle(
                        color: kHyppeBurem,
                        fontSize: 12,
                      ),
                      children: [
                        TextSpan(
                          text: '50 Coins',
                          style: TextStyle(color: kHyppeTextLightPrimary, fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.only(top: 6, bottom: 6, left: 16, right: 12),
                decoration: BoxDecoration(color: kHyppeTextLightPrimary, borderRadius: BorderRadius.circular(16)),
                child: Row(
                  children: [
                    Text(
                      'Top Up',
                      style: TextStyle(color: Colors.white),
                    ),
                    CustomIconWidget(
                      iconData: "${AssetPath.vectorPath}arrow_right.svg",
                      defaultColor: false,
                      color: Colors.white,
                    )
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
