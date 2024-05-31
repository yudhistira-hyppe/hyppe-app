import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ux/path.dart';
import 'package:provider/provider.dart';

import '../notifier.dart';

class InfoDialog extends StatelessWidget {
  final LocalizationModelV2 lang;
  final bool mounted;
  const InfoDialog({super.key, required this.lang, required this.mounted});

  @override
  Widget build(BuildContext context) {
    var result = context.read<WithdrawalCoinNotifier>();
    return DraggableScrollableSheet(
        expand: false,
        maxChildSize: .9,
        initialChildSize: .45,
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
                          borderRadius: const BorderRadius.all(Radius.circular(2.5)),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: kToolbarHeight - 24,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18.0),
                          child: Text(
                            'Rincian Transaksi',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close))
                      ],
                    ),
                  ),
                  const Divider(
                    thickness: .1,
                    color: kHyppeBurem,
                  ),
                  listTile('Jumlah Penarikan', System().currencyFormat(amount: result.withdrawaltransactionDetail.amount)),
                  listTile('Biaya Transaksi', '- ${System().currencyFormat(amount: result.withdrawaltransactionDetail.bankCharge)}'),
                  listTile('Biaya Converensi Coins', '- ${System().currencyFormat(amount: result.withdrawaltransactionDetail.convertFee)}'),
                  const Divider(
                    thickness: .1,
                    color: kHyppeBurem,
                  ),
                  listTile('Jumlah Penarikan', System().currencyFormat(amount: result.withdrawaltransactionDetail.totalAmount)),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: result.dataAcccount.where((e) => e.selected==true).isNotEmpty ? (){
                        debugPrint(result.dataAcccount.firstWhere((e) => e.selected==true).bankName);
                        debugPrint(result.withdrawaltransactionDetail.totalAmount.toString());
                        if (result.withdrawaltransactionDetail.totalAmount! < 50000){
                          ShowBottomSheet().onShowColouredSheet(context, lang.localeDatetime == 'id' ? 'Saldo minimum penarikan Rp. 50.000' :'Withdrawals must be at least IDR 50,000', textButton: '', color: Theme.of(context).colorScheme.error);
                        }else{
                          Navigator.pushNamed(context, Routes.pinwithdrawalcoin, arguments: mounted);
                        }
                      }:null,
                      style: ElevatedButton.styleFrom(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          backgroundColor: kHyppePrimary),
                      child: const SizedBox(
                        width: double.infinity,
                        height: kToolbarHeight,
                        child: Center(
                          child: Text('Tarik', textAlign: TextAlign.center),
                        ),
                      ),
                    ),
                  ),
                ],
              ));
        });
  }

  Widget listTile(String? label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 18.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label??'',
            style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.normal),
          ),
          Text(value??'',
            style: const TextStyle(
                color: kHyppeBurem,
                fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }
}
