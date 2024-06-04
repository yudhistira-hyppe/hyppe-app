import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:provider/provider.dart';

import '../notifier.dart';

class DialogFilters extends StatefulWidget {
  const DialogFilters({super.key});

  @override
  State<DialogFilters> createState() => _DialogFiltersState();
}

class _DialogFiltersState extends State<DialogFilters> {
  @override
  Widget build(BuildContext context) {
    LocalizationModelV2 lang = context.read<TranslateNotifierV2>().translate;
    return DraggableScrollableSheet(
      expand: false,
      maxChildSize: .9,
      initialChildSize: .4,
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
                  lang.localeDatetime =='id'?'Jenis transaksi':'Transaction type',
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
                    context.read<TransactionNotifier>().changeSelectedTransaction(context, mounted);
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
                      child: Text(lang.localeDatetime == 'id'?'Terapkan':'Apply',
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
    var coinNotif = context.read<TransactionNotifier>();
    for (int i = 0; i < coinNotif.filterList.length; i++) {
      list.add(RadioListTile(
        value: coinNotif.filterList[i].index,
        groupValue: coinNotif.selectedFiltersValue,
        selected: coinNotif.filterList[i].selected,
        onChanged: (val) {
          setState(() {
            coinNotif.selectedFiltersValue = val??1;
          });
          
        },
        activeColor: kHyppePrimary,
        controlAffinity: ListTileControlAffinity.trailing,
        title: Text(
          ' ${coinNotif.filterList[i].text}',
          style: TextStyle(
              color: coinNotif.filterList[i].selected ? Colors.black : Colors.grey,
              fontWeight:
                  coinNotif.filterList[i].selected ? FontWeight.bold : FontWeight.normal),
        ),
      ));
    }
    Column column = Column(
      children: list,
    );
    return column;
  }
}
