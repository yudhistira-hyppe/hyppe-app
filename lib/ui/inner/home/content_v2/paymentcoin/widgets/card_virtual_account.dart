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
    for (int i = 0; i < payNotif.groupsVA.length; i++) {
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
              value: payNotif.groupsVA[i].index,
              groupValue: payNotif.selectedva,
              selected: payNotif.groupsVA[i].selected,
              onChanged: (val) {
                setState(() {
                  payNotif.selectedva = val??1;
                });
                payNotif.changeSelectedva(val);
              },
              activeColor: kHyppePrimary,
              controlAffinity: ListTileControlAffinity.trailing,
              title: Row(
                children: [
                  SizedBox(
                    width: 38,
                    child: Image.asset(payNotif.groupsVA[i].icon),
                  ),
                  tenPx,
                  Text(
                    ' ${payNotif.groupsVA[i].text}',
                    style: TextStyle(
                        color: payNotif.groupsVA[i].selected ? Colors.black : Colors.grey,
                        fontWeight:
                            payNotif.groupsVA[i].selected ? FontWeight.bold : FontWeight.normal),
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