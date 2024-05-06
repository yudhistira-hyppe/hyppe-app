import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/inner/home/content_v2/paymentcoin/notifier.dart';
import 'package:provider/provider.dart';

class CardVirtualAccountWidget extends StatefulWidget {
  const CardVirtualAccountWidget({super.key});

  @override
  State<CardVirtualAccountWidget> createState() => _CardVirtualAccountWidgetState();
}

class _CardVirtualAccountWidgetState extends State<CardVirtualAccountWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: .3, color: kHyppeBurem),
        borderRadius: BorderRadius.circular(12.0),
        color: kHyppeBurem.withOpacity(.05)
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical:8.0),
        child: Column(
          children: [
            makeRadioTiles(context),
          ],
        ),
      ),
    );
  }

  Widget makeRadioTiles(BuildContext context) {
    List<Widget> list = [];
    var payNotif = context.read<PaymentCoinNotifier>();
    for (int i = 0; i < payNotif.data!.length; i++) {
      list.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Column(
          children: [
            Divider(
              color: kHyppeBurem.withOpacity(.5),
              indent: 18,
              endIndent: 18,
            ),
            RadioListTile(
              value: payNotif.data![i].bankcode,
              groupValue: payNotif.bankSelected,
              selected: payNotif.bankSelected == payNotif.data![i].bankcode,
              onChanged: (val) {
                setState(() {
                  payNotif.bankSelected = val ?? '';
                });
              },
              activeColor: kHyppePrimary,
              controlAffinity: ListTileControlAffinity.trailing,
              title: Row(
                children: [
                  SizedBox(
                    width: 38,
                    child: Image(
                      image: NetworkImage(payNotif.data![i].bankIcon??''),
                    ),
                  ),
                  tenPx,
                  Text(
                    ' ${payNotif.data![i].bankname}',
                    style: TextStyle(
                        color: payNotif.bankSelected == payNotif.data![i].bankcode ? Colors.black : Colors.grey,
                        fontWeight:
                            payNotif.bankSelected == payNotif.data![i].bankcode ? FontWeight.bold : FontWeight.normal),
                  ),
                ],
              ),
            ),
          ],
        ),
      ));
    }
    Column column = Column(
      children: list,
    );
    return column;
  }
}