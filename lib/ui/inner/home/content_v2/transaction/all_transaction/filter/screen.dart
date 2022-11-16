import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/all_transaction/filter/notifier.dart';
import 'package:provider/provider.dart';

class AllTransactionFilter extends StatelessWidget {
  AllTransactionFilter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<FilterTransactionNotifier, TranslateNotifierV2>(builder: (_, notifier, notifier2, __) {
      return Scaffold(
          appBar: AppBar(
            leading: const BackButton(),
            title: CustomTextWidget(
              textStyle: Theme.of(context).textTheme.subtitle1,
              textToDisplay: 'Filters',
            ),
            actions: [
              CustomTextButton(
                  onPressed: () => notifier.resetFilter(context),
                  child: CustomTextWidget(
                    textToDisplay: 'Reset',
                    textStyle: Theme.of(context).textTheme.button?.copyWith(color: !notifier.checkButton() ? kHyppeGrey : kHyppePrimary, fontWeight: FontWeight.bold),
                  ))
            ],
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomTextButton(
              onPressed: !notifier.checkButton()
                  ? null
                  : () {
                      notifier.submitFilter(context);
                    },
              style: ButtonStyle(backgroundColor: !notifier.checkButton() ? MaterialStateProperty.all(kHyppeDisabled) : MaterialStateProperty.all(kHyppePrimary)),
              child: CustomTextWidget(
                textToDisplay: 'Apply',
                textStyle: Theme.of(context).textTheme.button?.copyWith(color: kHyppeLightButtonText),
              ),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomTextWidget(
                        textToDisplay: 'Date',
                        textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: kHyppeGrey, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.start,
                      ),
                      SizedBox(
                        width: 25,
                        child: IconButton(
                          icon: Icon(notifier.showDate ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded),
                          onPressed: () {
                            notifier.showDate = !notifier.showDate;
                          },
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ),
                notifier.showDate ? dateFilterWidget(context, notifier) : Container(),
                const Divider(thickness: 0.5, color: kHyppeLightSurface),
                Container(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomTextWidget(
                        textToDisplay: 'Type',
                        textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: kHyppeGrey, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.start,
                      ),
                      SizedBox(
                        width: 25,
                        child: IconButton(
                          icon: Icon(notifier.showType ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded),
                          onPressed: () {
                            notifier.showType = !notifier.showType;
                          },
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ),
                !notifier.showType
                    ? Container()
                    : Expanded(
                        child: ListView.builder(
                            itemCount: notifier.filterType.length,
                            shrinkWrap: false,
                            itemBuilder: (context, index) {
                              return ListTile(
                                onTap: () => notifier.pickType(notifier.filterType[index]['id']),
                                title: CustomTextWidget(
                                  textAlign: TextAlign.left,
                                  textToDisplay: notifier.filterType[index]['name'],
                                  textStyle: Theme.of(context).textTheme.titleSmall,
                                ),
                                trailing: notifier.checkType(notifier.filterType[index]['id'])
                                    ? const Icon(
                                        Icons.check_box_outline_blank,
                                        color: kHyppeGrey,
                                      )
                                    : const Icon(
                                        Icons.check_box,
                                        color: kHyppePrimary,
                                      ),
                              );
                            }),
                      )
              ],
            ),
          ));
    });
  }

  Widget dateFilterWidget(BuildContext context, FilterTransactionNotifier notifier) {
    return Column(
      children: [
        ListTile(
          onTap: () => notifier.pickDate(0),
          title: CustomTextWidget(
            textAlign: TextAlign.left,
            textToDisplay: 'All',
            textStyle: Theme.of(context).textTheme.titleSmall,
          ),
          trailing: !notifier.allSelect
              ? const Icon(
                  Icons.radio_button_off,
                  color: kHyppeGrey,
                )
              : const Icon(
                  Icons.radio_button_checked,
                  color: kHyppePrimary,
                ),
        ),
        ListTile(
          onTap: () => notifier.pickDate(1),
          title: CustomTextWidget(
            textAlign: TextAlign.left,
            textToDisplay: 'Last 7 Days',
            textStyle: Theme.of(context).textTheme.titleSmall,
          ),
          trailing: !notifier.last7DaysSelect
              ? const Icon(
                  Icons.radio_button_off,
                  color: kHyppeGrey,
                )
              : const Icon(
                  Icons.radio_button_checked,
                  color: kHyppePrimary,
                ),
        ),
        ListTile(
          onTap: () => notifier.pickDate(2),
          title: CustomTextWidget(
            textAlign: TextAlign.left,
            textToDisplay: 'Last 30 Days',
            textStyle: Theme.of(context).textTheme.titleSmall,
          ),
          trailing: !notifier.last30DaysSelect
              ? const Icon(
                  Icons.radio_button_off,
                  color: kHyppeGrey,
                )
              : const Icon(
                  Icons.radio_button_checked,
                  color: kHyppePrimary,
                ),
        ),
      ],
    );
  }
}
