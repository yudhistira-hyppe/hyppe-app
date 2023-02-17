import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/account_preferences/notifier.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class HyppeConfirmDeleteAccount extends StatelessWidget {
  const HyppeConfirmDeleteAccount({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AccountPreferencesNotifier>(
      builder: (_, notifier, __) => Scaffold(
        appBar: AppBar(
          title: CustomTextWidget(
            textToDisplay: notifier.language.deleteAccount ?? '',
            textStyle: Theme.of(context).textTheme.headline6?.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          centerTitle: false,
          titleSpacing: 0,
          leading: IconButton(
            icon: const CustomIconWidget(iconData: "${AssetPath.vectorPath}back-arrow.svg"),
            splashRadius: 1,
            onPressed: () {
              Routing().moveBack();
            },
          ),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextWidget(
                    textToDisplay: notifier.language.deleteAccount ?? '',
                    textStyle: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  eightPx,
                  CustomTextWidget(
                    textToDisplay:
                        "${notifier.language.tappingDeleteAccountWillDelete} ${SharedPreference().readStorage(SpKeys.email)} ${notifier.language.accountWillBeDeletedProccessAfter24Hours}",
                    textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(),
                    maxLines: 100,
                    textAlign: TextAlign.start,
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: notifier.confirmDeleteAccount,
                      onChanged: (val) {
                        notifier.confirmDeleteAccount = val ?? false;
                      },
                      activeColor: kHyppePrimary,
                      checkColor: kHyppeLightButtonText,
                    ),
                    Expanded(
                      child: CustomTextWidget(
                        textToDisplay: notifier.language.deletingYourAccountIsPermanent ?? '',
                        textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(),
                        maxLines: 100,
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CustomElevatedButton(
                    width: SizeConfig.screenWidth,
                    height: 49 * SizeConfig.scaleDiagonal,
                    child: notifier.isLoading
                        ? const CustomLoading()
                        : CustomTextWidget(
                            textToDisplay: notifier.language.deleteAccount ?? '',
                            textStyle: notifier.confirmDeleteAccount ? Theme.of(context).textTheme.button?.copyWith(color: kHyppeLightButtonText) : Theme.of(context).primaryTextTheme.button,
                          ),
                    function: notifier.confirmDeleteAccount ? () => notifier.onClickDeleteAccount(context) : null,
                    buttonStyle: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        notifier.confirmDeleteAccount ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
                      ),
                      overlayColor: MaterialStateProperty.all(Colors.transparent),
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
