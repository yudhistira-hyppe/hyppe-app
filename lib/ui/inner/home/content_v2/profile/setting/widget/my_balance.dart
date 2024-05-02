import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/notifier.dart';
import 'package:provider/provider.dart';

import '../../../../../../../core/constants/themes/hyppe_colors.dart';
import '../../../../../../constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import '../../../../../../constant/widget/custom_elevated_button.dart';

class MyBalance extends StatelessWidget {
  const MyBalance({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'MyBalance');
    final notifier = context.read<TranslateNotifierV2>();
    return Consumer<TransactionNotifier>(
      builder: (context, value, child) => Container(
        constraints:
            BoxConstraints(minWidth: MediaQuery.of(context).size.width),
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
                  textToDisplay: 'My Balance',
                  textStyle: Theme.of(context).textTheme.caption?.copyWith(),
                  textAlign: TextAlign.start,
                ),
                fivePx,
                // const CustomIconWidget(
                //   iconData: "${AssetPath.vectorPath}info-icon.svg",
                //   height: 14,
                // )
              ],
            ),
            fivePx,
            value.isLoading
                ? const CustomLoading()
                : Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: CustomTextWidget(
                          textToDisplay: System().currencyFormat(
                              amount: value.accountBalance?.totalsaldo ?? 0),
                          textStyle: Theme.of(context)
                              .textTheme
                              .subtitle1
                              ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground),
                          textAlign: TextAlign.start,
                        ),
                      ),
                      System().showWidgetForGuest(
                        const SizedBox.shrink(),
                        CustomElevatedButton(
                          width: 90,
                          height: 24,
                          buttonStyle: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                Theme.of(context).colorScheme.primary),
                          ),
                          function: () {
                            ShowBottomSheet().onLoginApp(context);
                          },
                          child: CustomTextWidget(
                            textToDisplay: notifier.translate.login ?? 'Login',
                            textStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: kHyppeLightButtonText),
                          ),
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
