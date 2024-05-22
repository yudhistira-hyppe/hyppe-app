import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

import '../../../../../../../core/constants/themes/hyppe_colors.dart';
import '../../../../../../constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import '../../../../../../constant/widget/custom_elevated_button.dart';
import '../setting_notifier.dart';

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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CustomTextWidget(
                        textToDisplay: 'Total Coins',
                        textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(),
                        textAlign: TextAlign.start,
                      ),
                      fivePx,
                      GestureDetector(
                        onTap: () {
                          ShowBottomSheet.onShowStatementCoins(
                            context,
                            onCancel: () {},
                            onSave: null,
                            title: 'Ketentuan Hyppe Coins',
                            initialChildSize: .3,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12.0),
                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('•'),
                                      fivePx,
                                      SizedBox(
                                        width: MediaQuery.of(context).size.width * .9,
                                        child: const Text('Hyppe Coins dapat dikonversi menjadi satuan rupiah. 1 hyppe Coins = Rp100'))
                                    ],
                                  ),
                                  fivePx,
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('•'),
                                      fivePx,
                                      SizedBox(
                                        width: MediaQuery.of(context).size.width * .9,
                                        child: const Text('Tidak ada pengembalian dana untuk pembelian Hyppe Coins yang telah dilakukan.'))
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        child: const CustomIconWidget(
                          iconData: "${AssetPath.vectorPath}info-icon.svg",
                          height: 14,
                        ),
                      ),
                    ],
                  ),
                  fivePx,
                  value.isLoading
                      ? const CustomLoading()
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(right: 8.0),
                                    child: CustomIconWidget(
                                      iconData: "${AssetPath.vectorPath}ic-coin.svg",
                                      defaultColor: false,
                                    ),
                                  ),
                                  CustomTextWidget(
                                    textToDisplay: System().numberFormat(amount: value.saldoCoin),
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onBackground),
                                    textAlign: TextAlign.start,
                                  ),
                                ],
                              )
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
            IconButton(onPressed: (){
              context.handleActionIsGuest(() {
                context
                    .read<SettingNotifier>()
                    .validateUserCoins(context, notifier);
              });
              // Routing().move(Routes.saldoCoins);
            }, icon: const Icon(Icons.arrow_forward_ios))
          ],
        ),
      ),
    );
  }
}