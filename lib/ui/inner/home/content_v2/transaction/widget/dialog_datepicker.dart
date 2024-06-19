import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/inner/home/content_v2/coins/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/notifier.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DialogDatePicker extends StatelessWidget {
  final bool isStartDate;
  const DialogDatePicker({super.key, required this.isStartDate});

  @override
  Widget build(BuildContext context) {
    LocalizationModelV2 lang = context.read<TranslateNotifierV2>().translate;
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
                      lang.localeDatetime =='id'?'Pilih Tanggal':'Select Date Range',
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
                          initialDateTime: DateFormat('yyyy-MM-dd').parse(isStartDate ? notifier.tempSelectedDateStart : notifier.tempSelectedDateEnd),
                          maximumDate: DateTime.now(),
                          maximumYear: DateTime.now().year,
                          minimumDate: DateFormat('yyyy-MM-dd').parse(isStartDate ? DateTime(2020, 01, 01).toString() : notifier.tempSelectedDateStart),
                          dateOrder: DatePickerDateOrder.dmy,
                          mode: CupertinoDatePickerMode.date,
                          onDateTimeChanged: (DateTime v) {
                            if (isStartDate){
                              context.read<TransactionNotifier>().tempSelectedDateStart = v.toString();
                            }else{
                              context.read<TransactionNotifier>().tempSelectedDateEnd = v.toString();
                            }
                            
                          },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        context.read<TransactionNotifier>().selectedDatePicker(isStartDate: isStartDate);
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
                          child: Text(lang.apply??'Terapkan',
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
                      child: SizedBox(
                        width: double.infinity,
                        height: kToolbarHeight,
                        child: Center(
                          child: Text(lang.cancel??'Batal',
                              textAlign: TextAlign.center, style: const TextStyle(color: kHyppePrimary),),
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