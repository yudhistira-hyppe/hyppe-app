import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/inner/home/content_v2/coins/notifier.dart';
import 'package:provider/provider.dart';

class DialogTrans extends StatefulWidget {
  final LocalizationModelV2? lang;
  const DialogTrans({super.key, required this.lang});

  @override
  State<DialogTrans> createState() => _DialogTransState();
}

class _DialogTransState extends State<DialogTrans> {
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      maxChildSize: .9,
      initialChildSize: .55,
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
                widthFactor: 0.15,
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 12.0,
                  ),
                  child: Container(
                    height: 5.0,
                    decoration: const BoxDecoration(
                      color: kHyppeBurem,
                      borderRadius: BorderRadius.all(Radius.circular(2.5)),
                    ),
                  ),
                ),
              ),
              Center(
                child: Text(
                  'Aktivitas Hyppe Coins',
                  style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              makeRadioTiles(context),
              fivePx,
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.read<CoinNotifier>().changeSelectedTransaction(context, mounted);
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    backgroundColor: kHyppePrimary
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: kToolbarHeight,
                    child: Center(
                      child: Text(widget.lang?.apply??'Terapkan',
                          textAlign: TextAlign.center),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget makeRadioTiles(BuildContext context) {
    List<Widget> list = [];
    var coinNotif = context.read<CoinNotifier>();
    for (int i = 0; i < coinNotif.groupsTrans.length; i++) {
      list.add(RadioListTile(
        value: coinNotif.groupsTrans[i].index,
        groupValue: coinNotif.selectedTransValue,
        selected: coinNotif.groupsTrans[i].selected,
        onChanged: (val) {
          setState(() {
            coinNotif.selectedTransValue = val??1;
          });
          
        },
        activeColor: kHyppePrimary,
        controlAffinity: ListTileControlAffinity.trailing,
        title: Text(
          ' ${coinNotif.groupsTrans[i].text}',
          style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.normal),
        ),
      ));
    }
    Column column = Column(
      children: list,
    );
    return column;
  }
}