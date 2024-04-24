import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/bank_data.dart';
import 'package:hyppe/ui/constant/widget/custom_cache_image.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/inner/home/content_v2/payment_method/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/notifier.dart';
import 'package:provider/provider.dart';

class ListBankAccountWidget extends StatefulWidget {
  final LocalizationModelV2 lang;
  final bool position;
  const ListBankAccountWidget({super.key, required this.lang, required this.position});

  @override
  State<ListBankAccountWidget> createState() => _ListBankAccountWidgetState();
}

class _ListBankAccountWidgetState extends State<ListBankAccountWidget> {
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
        expand: false,
        maxChildSize: .9,
        initialChildSize: .5,
        builder: (_, controller) {
          return Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
              ),
            ),
            child: Column(
              children: [
                FractionallySizedBox(
                  widthFactor: 0.1,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 12.0,
                    ),
                    child: Container(
                      height: 5.0,
                      decoration: BoxDecoration(
                        color: kHyppeBurem.withOpacity(.5),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(2.5)),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.lang.choosebank ?? 'Pilih Bank',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const Divider(
                  thickness: .1,
                  color: kHyppeBurem,
                ),
                Expanded(
                  child: Consumer<PaymentMethodNotifier>(
                    builder: (context, notifier, __) {
                      return notifier.groupdata == null
                          ? const CustomLoading()
                          : ListView.builder(
                              controller: controller,
                              physics: const BouncingScrollPhysics(),
                              itemCount: notifier.groupdata?.length,
                              itemBuilder: (context, index) {
                                return makeRadioTiles(context, notifier,
                                    notifier.groupdata![index]);
                              },
                            );
                    },
                  ),
                ),
                Consumer<PaymentMethodNotifier>(
                    builder: (context, notifier, __) {
                  return notifier.selectedbankdata == ''
                      ? const SizedBox.shrink()
                      : Column(
                          children: [
                            twoPx,
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    var res = notifier.groupdata!.firstWhere((e) => e.selected==true);
                                    BankData data = BankData(id: res.id, atm: res.atm, bankIcon: res.bankIcon, bankcode: res.bankcode, bankname: res.bankname, internetBanking: res.internetBanking, mobileBanking: res.mobileBanking);
                                    context.read<TransactionNotifier>().bankInsert(data, position: widget.position);
                                  },
                                  style: ElevatedButton.styleFrom(
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      backgroundColor: kHyppePrimary),
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: kToolbarHeight,
                                    child: Center(
                                      child: Text(
                                          widget.lang.choosebank ??
                                              'Pilih Bank',
                                          textAlign: TextAlign.center),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            twoPx,
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    context.read<PaymentMethodNotifier>().selectedbankdata = '';
                                  },
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: kToolbarHeight,
                                    child: Center(
                                      child: Text(
                                        widget.lang.cancel ?? 'Batal',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            color: kHyppePrimary),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                }),
              ],
            ),
          );
        });
  }

  Widget makeRadioTiles(BuildContext context, PaymentMethodNotifier notifier,
      GroupBankData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RadioListTile(
        value: data.id,
        groupValue: notifier.selectedbankdata,
        selected: data.selected ?? false,
        onChanged: (val) {
          setState(() {
            notifier.selectedbankdata = val ?? '';
          });
          notifier.changeSelectedBank(val);
        },
        activeColor: kHyppePrimary,
        controlAffinity: ListTileControlAffinity.trailing,
        title: Row(
          children: [
            CustomCacheImage(
              imageUrl: data.bankIcon,
              imageBuilder: (_, imageProvider) {
                return Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: imageProvider, fit: BoxFit.contain),
                  ),
                );
              },
              errorWidget: (_, __, ___) {
                return Container(
                  width: 35,
                  height: 35,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.contain,
                      image:
                          AssetImage('${AssetPath.pngPath}content-error.png'),
                    ),
                  ),
                );
              },
              emptyWidget: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.contain,
                    image: AssetImage('${AssetPath.pngPath}content-error.png'),
                  ),
                ),
              ),
            ),
            tenPx,
            Text(
              ' ${data.bankname ?? ''}',
              style: TextStyle(
                  color: data.selected ?? false ? Colors.black : Colors.grey,
                  fontWeight: data.selected ?? false
                      ? FontWeight.bold
                      : FontWeight.normal),
            ),
          ],
        ),
      ),
    );
  }
}
