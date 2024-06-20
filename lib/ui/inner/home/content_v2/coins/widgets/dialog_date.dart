import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/textfield.dart';
import 'package:hyppe/ui/inner/home/content_v2/coins/notifier.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DialogDate extends StatefulWidget {
  final LocalizationModelV2? lang;
  const DialogDate({super.key, required this.lang});

  @override
  State<DialogDate> createState() => _DialogDateState();
}

class _DialogDateState extends State<DialogDate> {
  @override
  Widget build(BuildContext context) {
    return Consumer<CoinNotifier>(
      builder: (context, notifier, _) {
        return DraggableScrollableSheet(
          expand: false,
          maxChildSize: .9,
          initialChildSize: notifier.selectedDateValue == 4 ? .6 : .45,
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
              child: Consumer<CoinNotifier>(
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
                      if (notifier.selectedDateValue == 4)
                      Container(
                        height: kToolbarHeight+24,
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 18.0),
                        child: Visibility(
                          visible: notifier.selectedDateValue == 4,
                          child: Row(
                            children: [
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                    const Text('Dari'),
                                    TextFieldCustom(
                                      controller: notifier.textStartDateController,
                                      placeholder: 'Dari',
                                      readOnly: true,
                                      onSubmitted: () => notifier.showButtomSheetDatePicker(context, isStartDate: true),
                                    ),
                                    ],
                                ),
                              ),
                              fourteenPx,
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                    const Text('Sampai'),
                                    TextFieldCustom(
                                      controller: notifier.textEndDateController,
                                      placeholder: 'Sampai',
                                      readOnly: true,
                                      onSubmitted: () => notifier.showButtomSheetDatePicker(context, isStartDate: false),
                                    ),
                                    ],
                                ),
                              )
                            ],
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
                              context.read<CoinNotifier>().changeSelectedDate(context, mounted);
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
                      ),
                    ],
                  );
                }
              ),
            );
          }
        );
      }
    );
  }

  Widget makeRadioTiles(BuildContext context) {
    List<Widget> list = [];
    var coinNotif = context.read<CoinNotifier>();
    for (int i = 0; i < coinNotif.groupsDate.length; i++) {
      list.add(RadioListTile(
        value: coinNotif.groupsDate[i].index,
        groupValue: coinNotif.selectedDateValue,
        selected: coinNotif.groupsDate[i].selected,
        onChanged: (val) {
          setState(() {
            coinNotif.selectedDateValue = val??1;
            if (val == 4){
              var res = coinNotif.groupsDate.firstWhere((e) => e.index == val);
              coinNotif.textStartDateController.text = DateFormat('dd/MM/yyyy').format(DateTime.parse(res.startDate!));
              coinNotif.textEndDateController.text = DateFormat('dd/MM/yyyy').format(DateTime.parse(res.endDate!));
            }
          });
          
        },
        activeColor: kHyppePrimary,
        controlAffinity: ListTileControlAffinity.trailing,
        title: Text(
          ' ${coinNotif.groupsDate[i].text}',
          style: const TextStyle(
              color:  Colors.black,
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