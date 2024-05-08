import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:provider/provider.dart';

import '../notifier.dart';

class ReportLive extends StatefulWidget {
  const ReportLive({super.key});

  @override
  State<ReportLive> createState() => _ReportLiveState();
}

class _ReportLiveState extends State<ReportLive> {
  @override
  Widget build(BuildContext context) {
    final tn = context.read<TranslateNotifierV2>().translate;
    // var notifier = context.read<ViewStreamingNotifier>();
    return Consumer<ViewStreamingNotifier>(builder: (context, notifier, _) {
      return DraggableScrollableSheet(
        expand: false,
        maxChildSize: .9,
        initialChildSize: .75,
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
              mainAxisSize: MainAxisSize.max,
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
                    tn.selectReport ?? 'Pilih Alasan',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15.0, bottom: 15.0, left: 16, right: 16),
                  child: Divider(color: kHyppeBgNotSolve, thickness: 1),
                ),
                Flexible(
                  child: ListView.builder(
                      itemCount: notifier.groupsReport.length,
                      controller: controller,
                      shrinkWrap: true,
                      primary: false,
                      itemBuilder: (context, i) => RadioListTile(
                            value: notifier.groupsReport[i].index,
                            groupValue: notifier.selectedReportValue,
                            selected: notifier.groupsReport[i].selected,
                            onChanged: (val) {
                              setState(() {
                                notifier.selectedReportValue = val ?? 1;
                              });
                            },
                            activeColor: kHyppePrimary,
                            controlAffinity: ListTileControlAffinity.trailing,
                            title: Text(
                              ' ${notifier.groupsReport[i].text}',
                              style:
                                  TextStyle(color: notifier.groupsReport[i].selected ? Colors.black : Colors.grey, fontWeight: notifier.groupsReport[i].selected ? FontWeight.bold : FontWeight.normal),
                            ),
                          )),
                ),
                fivePx,
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: notifier.selectedReportValue != null
                        ? () {
                            Navigator.pop(context);
                            notifier.responReportLive(context);
                            // context.read<CoinNotifier>().changeSelectedTransaction();
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        backgroundColor: kHyppePrimary),
                    child: SizedBox(
                      width: double.infinity,
                      height: kToolbarHeight,
                      child: Center(
                        child: Text(tn.send ?? 'Kirim', textAlign: TextAlign.center),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }
}
