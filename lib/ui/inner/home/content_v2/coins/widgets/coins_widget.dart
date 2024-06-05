import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/setting/setting_notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:provider/provider.dart';

class CoinsWidget extends StatelessWidget {
  final String? accountBalance;
  final LocalizationModelV2? lang;
  const CoinsWidget({super.key, required this.accountBalance, required this.lang});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width, maxHeight: 123),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).colorScheme.surface,
        image: const DecorationImage(
          image: AssetImage("${AssetPath.pngPath}bg-coin.png"), 
          fit: BoxFit.cover)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomTextWidget(
                textToDisplay: 'Total Coins',
                textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: kHyppeSecondary
                ),
                textAlign: TextAlign.start,
              ),
              fivePx,
              GestureDetector(
                onTap: () {
                  ShowBottomSheet.onShowStatementCoins(
                    context,
                    onCancel: () {},
                    onSave: null,
                    title: lang?.localeDatetime =='id' ? 'Ketentuan Hyppe Coins' : 'Hyppe Coins Terms and Conditions',
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
                                child: Text(lang?.localeDatetime =='id' ? 'Hyppe Coins dapat dikonversi menjadi satuan rupiah. 1 hyppe Coins = Rp100':'Hyppe Coins can be converted into IDR. 1 Hyppe Coins = IDR 100'))
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
                                child: Text(lang?.localeDatetime =='id' ? 'Tidak ada pengembalian dana untuk pembelian Hyppe Coins yang telah dilakukan.': 'There are no refunds for Hyppe Coins purchases that have been made.'))
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: CustomIconWidget(
                      iconData: "${AssetPath.vectorPath}ic-coin.svg",
                      defaultColor: false,
                    ),
                  ),
                  CustomTextWidget(
                    textToDisplay: accountBalance ?? '',
                    textStyle: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: kHyppeTextPrimary),
                    textAlign: TextAlign.start,
                  ),
                ],
              ),
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: (){
                    Navigator.pushNamed(context, Routes.topUpCoins);
                  },
                  child: SizedBox(
                    height: kToolbarHeight * .5,
                    child: Row(
                      children: [
                        CustomTextWidget(
                          textToDisplay: 'Top up Coins',
                          textStyle: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: kHyppeTextPrimary),
                          textAlign: TextAlign.start,
                        ),
                        fivePx,
                        const Icon(Icons.arrow_forward_ios, size: 18, color: kHyppeTextPrimary,)
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
          const Divider(
            thickness: 1,
            color: kHyppeBurem,
          ),
          Flexible(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                InkWell(
                  onTap: (){
                    context.handleActionIsGuest(() {
                            context
                                .read<SettingNotifier>()
                                .validateUser(context, context.read<TranslateNotifierV2>());
                          },
                    );
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * .42,
                    height: kToolbarHeight * .5,
                    padding: const EdgeInsets.only(right: 12.0),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Lihat Transaksi', style: TextStyle(color: kHyppeTextPrimary),),
                        Icon(Icons.arrow_forward_ios, size: 18, color: kHyppeTextPrimary,)
                      ],
                    )
                  ),
                ),
                Container(
                  width: 1,
                  height: 24,
                  decoration: const BoxDecoration(
                    border: Border(
                      left: BorderSide(color: kHyppeBurem),
                      right: BorderSide(color: kHyppeBurem)
                    )
                  ),
                ),
                InkWell(
                  onTap: (){
                    Navigator.pushNamed(context, Routes.exchangeCoins);
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * .42,
                    height: kToolbarHeight * .5,
                    padding: const EdgeInsets.only(left: 12.0),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Tukar Coins', style: TextStyle(color: kHyppeTextPrimary),),
                        Icon(Icons.arrow_forward_ios, size: 18, color: kHyppeTextPrimary,)
                      ],
                    )
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}