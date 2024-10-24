import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class ButtonTransaction extends StatelessWidget {
  const ButtonTransaction({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'ButtonTransaction');
    return Consumer2<TransactionNotifier, TranslateNotifierV2>(
      builder: (context, notifier, notifier2, child) => Row(
        children: [
          Expanded(
            child: CustomTextButton(
              onPressed: () {
                notifier.navigateToBankAccount();
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(width: 1.0, color: kHyppePrimary),
              ),
              child: CustomTextWidget(
                textToDisplay: notifier2.translate.addBankAccount ?? '',
                textStyle: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(color: kHyppePrimary),
              ),
            ),
          ),
          sixPx,
          Expanded(
            child: CustomTextButton(
              onPressed: notifier.accountBalance?.totalsaldo == 0
                  ? null
                  : SharedPreference().readStorage(SpKeys.setPin) == 'true'
                      ? () {
                          notifier.navigateToWithDrawal();
                          notifier.initBankAccount(context);
                        }
                      : () {
                          ShowBottomSheet.onShowStatementPin(
                            context,
                            onCancel: () {},
                            onSave: () {
                              Routing()
                                  .moveAndPop(Routes.homePageSignInSecurity);
                            },
                            title: notifier2.translate.addYourHyppePinFirst,
                            bodyText: notifier2.translate
                                    .toAccessTransactionPageYouNeedToSetYourPin ??
                                '',
                          );
                        },
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                      notifier.accountBalance?.totalsaldo == 0
                          ? kHyppeDisabled
                          : kHyppePrimary)),
              child: CustomTextWidget(
                textToDisplay: notifier2.translate.withdrawal ?? '',
                textStyle: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(color: kHyppeLightButtonText),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
