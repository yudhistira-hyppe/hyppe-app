import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
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
    return Consumer<TransactionNotifier>(builder: (context, notifier, _) {
      return DraggableScrollableSheet(
          expand: false,
          maxChildSize: .9,
          initialChildSize: .5,
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
                      'Semua Transaksi',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                      child: ListView.builder(
                    itemCount: notifier.filterList.length,
                    physics: const BouncingScrollPhysics(),
                    controller: controller,
                    itemBuilder: (context, i) {
                      return ListTile(
                        onTap: () => notifier.pickType(i),
                        title: CustomTextWidget(
                          textAlign: TextAlign.left,
                          textToDisplay: notifier.filterList[i].text,
                          textStyle: Theme.of(context).textTheme.titleSmall,
                        ),
                        trailing: !notifier.filterList[i].selected
                            ? const Icon(
                                Icons.check_box_outline_blank,
                                color: kHyppeGrey,
                              )
                            : const Icon(
                                Icons.check_box,
                                color: kHyppePrimary,
                              ),
                      );
                    },
                  )),
                  fivePx,
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // context.read<TransactionNotifier>().changeSelectedTransaction();
                      },
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
                          child: Text(
                              context
                                      .watch<TranslateNotifierV2>()
                                      .translate
                                      .apply ??
                                  'Terapkan',
                              textAlign: TextAlign.center),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          });
    });
  }
}
