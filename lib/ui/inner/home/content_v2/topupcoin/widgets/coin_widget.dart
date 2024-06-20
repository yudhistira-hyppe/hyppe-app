import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/notifier.dart';
import 'package:provider/provider.dart';

class CoinWidget extends StatelessWidget {
  const CoinWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final notifier = context.read<TranslateNotifierV2>();
    return Consumer<TransactionNotifier>(
      builder: (context, value, child) => Container(
        constraints:
            BoxConstraints(minWidth: MediaQuery.of(context).size.width),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(width: .3, color: kHyppeBurem)
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CustomTextWidget(
                        textToDisplay: 'Hyppe Coins',
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
                          title: notifier.translate.localeDatetime =='id' ? 'Ketentuan Hyppe Coins' : 'Hyppe Coins Terms and Conditions',
                          initialChildSize: .25,
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
                                      child: Text(notifier.translate.localeDatetime =='id' ? 'Hyppe Coins dapat dikonversi menjadi satuan rupiah. 1 hyppe Coins = Rp100':'Hyppe Coins can be converted into IDR. 1 Hyppe Coins = IDR 100'))
                                  ],
                                ),
                                fifteenPx,
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('•'),
                                    fivePx,
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width * .9,
                                      child: Text(notifier.translate.localeDatetime =='id' ? 'Tidak ada pengembalian dana untuk pembelian Hyppe Coins yang telah dilakukan.': 'There are no refunds for Hyppe Coins purchases that have been made.'))
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
          ],
        ),
      ),
    );
  }
}