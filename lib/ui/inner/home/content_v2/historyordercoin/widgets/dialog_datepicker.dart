import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/inner/home/content_v2/coins/notifier.dart';
import 'package:provider/provider.dart';

import '../notifier.dart';

class DialogDatePicker extends StatelessWidget {
  final bool isStartDate;
  const DialogDatePicker({super.key, required this.isStartDate});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      maxChildSize: .9,
      initialChildSize: .6,
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
                      'Pilih Tanggal',
                      style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    height: SizeConfig.screenHeight! * 0.35,
                    width: double.infinity,
                    child: CupertinoDatePicker(
                          initialDateTime: DateTime.now(),
                          maximumDate: DateTime.now(),
                          maximumYear: DateTime.now().year,
                          minimumDate: DateTime(2020, 01, 01),
                          dateOrder: DatePickerDateOrder.dmy,
                          mode: CupertinoDatePickerMode.date,
                          onDateTimeChanged: (DateTime v) {
                            context.read<HistoryOrderCoinNotifier>().settempSelectedDate(v.toString());
                          },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        context.read<HistoryOrderCoinNotifier>().selectedDatePicker(isStartDate: isStartDate);
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        backgroundColor: kHyppePrimary
                      ),
                      child: const SizedBox(
                        width: double.infinity,
                        height: kToolbarHeight,
                        child: Center(
                          child: Text('Terapkan',
                              textAlign: TextAlign.center),
                        ),
                      ),
                    ),
                  ),
                  fivePx,
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        backgroundColor: kHyppeLightBackground
                      ),
                      child: const SizedBox(
                        width: double.infinity,
                        height: kToolbarHeight,
                        child: Center(
                          child: Text('Batal',
                              textAlign: TextAlign.center, style: TextStyle(color: kHyppePrimary),),
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
}