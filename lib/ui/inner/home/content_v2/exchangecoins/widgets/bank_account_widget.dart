import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/exchangecoins/notifier.dart';
import 'package:hyppe/ux/path.dart';

class BankAccountWidget extends StatefulWidget {
  final ExchangeCoinNotifier notif;
  final LocalizationModelV2? lang;
  const BankAccountWidget({super.key, required this.notif, required this.lang});

  @override
  State<BankAccountWidget> createState() => _BankAccountWidgetState();
}

class _BankAccountWidgetState extends State<BankAccountWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 18.0),
      decoration: BoxDecoration(
        border: Border.all(width: .3, color: kHyppeBurem),
        borderRadius: BorderRadius.circular(12.0),
        color: kHyppeBurem.withOpacity(.03)
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical:8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: CustomTextWidget(
                textToDisplay: 'Rekening Bank',
                textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(),
                textAlign: TextAlign.start,
              ),
            ),
            widget.notif.isLoading 
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                height: MediaQuery.of(context).size.width * .5,
                child: const Center(child: CustomLoading()))
            : widget.notif.dataAcccount.isEmpty 
                ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                  child: CustomTextWidget(
                    textToDisplay: widget.lang?.emptyBankAccount ?? '',
                    maxLines: 2,
                  ),
                )
                : makeRadioTiles(context),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, Routes.bankAccount),
                style: ElevatedButton.styleFrom(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      side: const BorderSide(
                        width: 1,
                        color: kHyppePrimary
                      )
                    ),
                    backgroundColor: kHyppeLightButtonText),
                child: SizedBox(
                  width: double.infinity,
                  height: kToolbarHeight - 12,
                  child: Center(
                    child: Text('${widget.lang?.addBankAccount}', textAlign: TextAlign.center, style: const TextStyle(color: kHyppePrimary),),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget makeRadioTiles(BuildContext context) {
    List<Widget> list = [];
    for (int i = 0; i < widget.notif.dataAcccount.length; i++) {
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
              value: widget.notif.dataAcccount[i].id,
              groupValue: widget.notif.selectedBankAccount,
              selected: widget.notif.dataAcccount[i].selected??false,
              onChanged: (val) {
                setState(() {
                  widget.notif.selectedBankAccount = val??'';
                });
                widget.notif.changeSelectedbankaccount(val);
              },
              activeColor: kHyppePrimary,
              controlAffinity: ListTileControlAffinity.trailing,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.notif.dataAcccount[i].bankName}',
                    style: TextStyle(
                        color: (widget.notif.dataAcccount[i].selected ?? false) ? Colors.black : Colors.grey,
                        fontWeight:
                            (widget.notif.dataAcccount[i].selected ?? false) ? FontWeight.bold : FontWeight.normal),
                  ),
                  Text(
                    '${widget.notif.dataAcccount[i].noRek} - ${widget.notif.dataAcccount[i].nama}',
                    style: TextStyle(
                        color: (widget.notif.dataAcccount[i].selected ?? false) ? kHyppeBurem : kHyppeBurem.withOpacity(.4),
                        fontWeight:
                            (widget.notif.dataAcccount[i].selected ?? false) ? FontWeight.w500 : FontWeight.w400),
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