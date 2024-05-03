import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/notifier.dart';
import 'package:provider/provider.dart';

class DialogDate extends StatefulWidget {
  const DialogDate({super.key});

  @override
  State<DialogDate> createState() => _DialogDateState();
}

class _DialogDateState extends State<DialogDate> {
  @override
  Widget build(BuildContext context) {
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
          child: Consumer<TransactionNotifier>(
            builder: (context, notifier, child) {
              return Column(
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
                      'Periode Transaksi',
                      style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  makeRadioTiles(context),
                  twoPx,
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          context.read<TransactionNotifier>().changeSelectedDate();
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
                            child: Text(context
                                      .watch<TranslateNotifierV2>()
                                      .translate
                                      .apply ??
                                  'Terapkan',
                                textAlign: TextAlign.center),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
          ),
        );
      }
    );
  }

  Widget makeRadioTiles(BuildContext context) {
    List<Widget> list = [];
    var notifier = context.read<TransactionNotifier>();
    for (int i = 0; i < notifier.filterDate.length; i++) {
      list.add(RadioListTile(
        value: notifier.filterDate[i].index,
        groupValue: notifier.selectedDateValue,
        selected: notifier.filterDate[i].selected,
        onChanged: (val) {
          setState(() {
            notifier.selectedDateValue = val??1;
          });
          
        },
        activeColor: kHyppePrimary,
        controlAffinity: ListTileControlAffinity.trailing,
        title: Text(
          ' ${notifier.filterDate[i].text}',
          style: TextStyle(
              color: notifier.filterDate[i].selected ? Colors.black : Colors.grey,
              fontWeight:
                  notifier.filterDate[i].selected ? FontWeight.bold : FontWeight.normal),
        ),
      ));
    }
    Column column = Column(
      children: list,
    );
    return column;
  }
}