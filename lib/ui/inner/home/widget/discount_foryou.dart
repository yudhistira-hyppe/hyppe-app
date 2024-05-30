import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:provider/provider.dart';

class DiscountForyou extends StatelessWidget {
  const DiscountForyou({super.key});

  @override
  Widget build(BuildContext context) {
    var trans = context.read<TranslateNotifierV2>().translate;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: kHyppeBorderTab,
        ),
        color: const Color(0xffFBFBFB),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const CustomIconWidget(
                height: 20,
                iconData: "${AssetPath.vectorPath}ic-kupon.svg",
                defaultColor: false,
              ),
              eightPx,
              Text(
                "${trans.discountForYou}",
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 10),
              )
            ],
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            color: kHyppeTextLightPrimary,
            size: 15,
          ),
        ],
      ),
    );
  }
}
