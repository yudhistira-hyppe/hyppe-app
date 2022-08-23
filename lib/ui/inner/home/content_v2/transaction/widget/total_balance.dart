import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';

class TotalBalance extends StatelessWidget {
  const TotalBalance({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
                textToDisplay: 'Total Balance',
                textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(),
                textAlign: TextAlign.start,
              ),
              fivePx,
              CustomIconWidget(
                iconData: "${AssetPath.vectorPath}info-icon.svg",
                height: 14,
              )
            ],
          ),
          CustomTextWidget(
            textToDisplay: 'Rp 0',
            textStyle: Theme.of(context).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onBackground),
            textAlign: TextAlign.start,
          ),
        ],
      ),
    );
  }
}
