import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:provider/provider.dart';

class RemarkWithdrawalDialog extends StatelessWidget {
  const RemarkWithdrawalDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = context.read<TranslateNotifierV2>();
    return Container(
      decoration: BoxDecoration(
        color: Color(0xAA323232),
        borderRadius: BorderRadius.circular(8.0),
      ),
      height: 80,
      width: SizeConfig.screenWidth! * 0.9,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Remark :',
            style: TextStyle(color: kHyppeLightBackground),
          ),
          twelvePx,
          Text(
            translate.translate.aVerifiedBankDoesNotNeed ?? '',
            maxLines: 5,
          ),
        ],
      ),
    );
  }
}
