import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/transaction/bank_account/bank_account_model.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/notifier.dart';
import 'package:provider/provider.dart';

import 'info_new.dart';

class ListDataBankAccount extends StatelessWidget {
  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey;
  final List<BankAccount>? dataAcccount;
  final String? textRemove;
  final String? textUpTo;
  final String? textsubtitleUpto;
  const ListDataBankAccount({Key? key, required this.refreshIndicatorKey, this.dataAcccount, this.textRemove, this.textUpTo, this.textsubtitleUpto}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'ListDataBankAccount');
    var language = context.read<TranslateNotifierV2>().translate;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          InfoNew(
            title: textUpTo ?? '',
            subtitle: textsubtitleUpto ?? '',
          ),
          RefreshIndicator(
            key: refreshIndicatorKey,
            color: kHyppePrimary,
            backgroundColor: kHyppeLightBackground,
            strokeWidth: 4.0,
            onRefresh: () async {
              // Replace this delay with the code to be executed during refresh
              // and return a Future when code finishs execution.
              return Future<void>.delayed(const Duration(seconds: 3));
            },
            child: ListView.builder(
                shrinkWrap: true,
                itemCount: dataAcccount?.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.only(bottom: 10),
                    decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: kHyppeLightSurface))),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // CustomTextWidget(textToDisplay: dataAcccount[index].idBank )
                            Row(
                              children: [
                                CustomTextWidget(
                                  textToDisplay: dataAcccount?[index].bankName ?? '',
                                  textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onBackground),
                                ),
                                sixPx,
                                dataAcccount?[index].statusInquiry != null && (dataAcccount?[index].statusInquiry ?? false)
                                    ? Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(50),
                                          color: kHyppePrimaryLight,
                                        ),
                                        child: const CustomIconWidget(
                                          defaultColor: false,
                                          iconData: '${AssetPath.vectorPath}user-verified.svg',
                                        ),
                                      )
                                    : Container()
                              ],
                            ),
                            sixPx,
                            CustomTextWidget(
                              textToDisplay: '${dataAcccount?[index].noRek} - ${(dataAcccount?[index].nama)?.toUpperCase()}',
                              textStyle: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        if (dataAcccount?[index].status != null) statusWidget(language, dataAcccount?[index].status ?? ''),
                        SizedBox(
                          height: 30,
                          child: CustomTextButton(
                              onPressed: () {
                                context.read<TransactionNotifier>().confirmDeleteBankAccount(
                                      context,
                                      dataAcccount?[index].bankName,
                                      dataAcccount?[index].noRek,
                                      dataAcccount?[index].nama,
                                      dataAcccount?[index].id,
                                      index,
                                    );
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(width: 1.0, color: kHyppePrimary),
                              ),
                              child: CustomTextWidget(
                                textToDisplay: textRemove ?? '',
                                textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: kHyppePrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              )),
                        )
                      ],
                    ),
                  );
                }),
          ),
          // infoMaxAccount(title: textUpTo ?? '')
        ],
      ),
    );
  }

  Widget statusWidget(LocalizationModelV2 language, String status) {
    var title = '';
    Color colorsBg = kHyppeRedLight;
    Color colorsTitle = kHyppeRed;
    if (status == 'NEW') {
      title = language.reviewed ?? '';
    } else if (status == 'reject') {
      title = language.rejected ?? '';
    } else {
      title = language.approved ?? '';
      colorsBg = kHyppeGreenLight;
      colorsTitle = kHyppeGreen;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: colorsBg, borderRadius: BorderRadius.circular(20)),
      child: CustomTextWidget(
        textToDisplay: title,
        textStyle: TextStyle(color: colorsTitle),
      ),
    );
  }
}
