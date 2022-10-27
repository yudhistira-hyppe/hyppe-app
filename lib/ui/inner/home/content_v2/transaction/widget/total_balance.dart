import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:provider/provider.dart';

class TotalBalance extends StatelessWidget {
  String? accountBalance;
  TotalBalance({Key? key, this.accountBalance}) : super(key: key);

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
              GestureDetector(
                onTap: () {
                  ShowBottomSheet.onShowStatementPin(
                    context,
                    onCancel: () {},
                    onSave: null,
                    title: 'Total Balance',
                    bodyText: context.read<TranslateNotifierV2>().translate.cannotBeUsedAsACurrencyForTransactionThisBalanceCanOnlyBeWithdrawn!,
                  );
                },
                child: const CustomIconWidget(
                  iconData: "${AssetPath.vectorPath}info-icon.svg",
                  height: 14,
                ),
              )
            ],
          ),
          CustomTextWidget(
            textToDisplay: accountBalance!,
            textStyle: Theme.of(context).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onBackground),
            textAlign: TextAlign.start,
          ),
        ],
      ),
    );
  }
}
