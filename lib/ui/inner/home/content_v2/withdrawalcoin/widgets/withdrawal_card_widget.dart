import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
import 'package:hyppe/ui/constant/widget/textfield.dart';
import 'package:hyppe/ui/inner/home/content_v2/withdrawalcoin/notifier.dart';
import 'package:provider/provider.dart';

class WithdrawalCardWidget extends StatelessWidget {
  final WithdrawalCoinNotifier notif;
  const WithdrawalCardWidget({super.key, required this.notif});

  @override
  Widget build(BuildContext context) {
    final notifier = context.read<TranslateNotifierV2>();
    return Container(
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        border: Border.all(width: .3, color: kHyppeBurem),
        borderRadius: BorderRadius.circular(12.0),
        color: kHyppeBurem.withOpacity(.03)
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical:8.0),
        child: Column(
          children: [
            saldoCoin(notifier),
            fourteenPx,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tukar total saldo Coin ke Rupiah'),
                  TextFieldCustom(
                    controller: notif.textController,
                    placeholder: 'Jumlah Coins',
                    prefixIcon: const CustomIconWidget(
                      iconData: "${AssetPath.vectorPath}ic-coin.svg",
                      defaultColor: false,
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp("[.]"))
                    ],
                    onChange: (p0) {
                      print('total coint ${notif.totalCoin}');
                      notif.debouncer.run(() {
                        if (int.parse(notif.textController.text) > notif.totalCoin) {
                          notif.textController.text = '';
                          notif.typingValue = 0;
                          notif.convertCoin();
                          Fluttertoast.showToast(msg: 'Maksimal Tukar Coins ${System().numberFormat(amount: notif.totalCoin)}');
                        }else{
                          notif.convertCoin();
                        }
                      });
                    },
                  ),
                  Text('Tukar ke ${System().currencyFormat(amount: notif.typingValue)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(),
                  ),
                  SizedBox(
                    height: kToolbarHeight,
                    width: double.infinity,
                    child: ListView.builder(
                      itemCount: notif.groupsCoins.length,
                      physics: const BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, i) => Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                            label: Text(System().numberFormat(amount: notif.groupsCoins[i].value)), 
                            backgroundColor: Colors.transparent,
                            shape: const StadiumBorder(side: BorderSide(width: .2, color: kHyppeBurem)),
                            onSelected: (bool value) {
                              // notif.debouncer.run(() {
                                // if (notif.textController.text.isNotEmpty){
                                  notif.textController.text = notif.groupsCoins[i].value.toStringAsFixed(0);
                                  if (int.parse(notif.textController.text) > notif.totalCoin){
                                    notif.textController.text = '';
                                    notif.typingValue = 0;
                                    notif.convertCoin();
                                    Fluttertoast.showToast(msg: 'Maksimal Tukar Coins ${System().numberFormat(amount: notif.totalCoin)}');
                                  }else{
                                    notif.textController.text = notif.groupsCoins[i].value.toStringAsFixed(0);
                                    if (int.parse(notif.textController.text) > notif.totalCoin){
                                      notif.textController.text = '';
                                      notif.typingValue = 0;
                                      notif.convertCoin();
                                      Fluttertoast.showToast(msg: 'Maksimal Tukar Coins ${System().numberFormat(amount: notif.totalCoin)}');
                                    }else{
                                      notif.textController.text = notif.groupsCoins[i].value.toStringAsFixed(0);
                                      notif.convertCoin();
                                    }
                                  }
                                // }else{
                                //   notif.textController.text = notif.groupsCoins[i].value.toStringAsFixed(0);
                                //   notif.convertCoin();
                                // }
                              // });
                            },
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: kToolbarHeight,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: kHyppeBurem.withOpacity(.5)),
                      borderRadius: BorderRadius.circular(12),
                      color: kHyppeBurem.withOpacity(.2)
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline),
                        fivePx,
                        SizedBox(
                          width: MediaQuery.of(context).size.width * .68,
                          child: Text(
                            'Penarikan dikenai biaya transaksi sebesar Rp6.000 dan biaya penukaran Coins 10%',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
            ),

          ],
        ),
      ),
    );
  }

  Widget saldoCoin(TranslateNotifierV2 lang) {
    return Consumer<WithdrawalCoinNotifier>(
      builder: (context, value, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
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
            fourteenPx,
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
                              textToDisplay: System().numberFormat(amount: value.totalCoin),
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
                            textToDisplay: lang.translate.login ?? 'Login',
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
        );
      }
    );
  }
}