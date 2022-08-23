import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:provider/provider.dart';

class EmptyBankAccount extends StatelessWidget {
  const EmptyBankAccount({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<TranslateNotifierV2>(
      builder: (context, notifier, child) => Padding(
        padding: const EdgeInsets.all(50.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Center(
              child: CustomIconWidget(
                defaultColor: false,
                iconData: '${AssetPath.vectorPath}no-Result-Found.svg',
              ),
            ),
            CustomTextWidget(textToDisplay: notifier.translate.noSavedAccountYet!, textStyle: Theme.of(context).textTheme.subtitle1!.copyWith(color: Theme.of(context).colorScheme.onBackground)),
            eightPx,
            CustomTextWidget(
              textToDisplay: notifier.translate.addYourBankAccountForAnEasierWithdraw!,
              maxLines: 4,
            ),
          ],
        ),
      ),
    );
  }
}
