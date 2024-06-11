import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';

class PenjualanKontenDetail extends StatelessWidget {
  const PenjualanKontenDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(width: .2, color: kHyppeBurem),
      ),
      child: Column(
        children: [
          CustomTextWidget(
            textToDisplay: 'Detail Transaksi',
            textStyle: const TextStyle(
              color: kHyppeTextLightPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
